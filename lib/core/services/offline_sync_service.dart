import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:retry/retry.dart';
import 'package:uuid/uuid.dart';
import '../storage/secure_storage_service.dart';
import 'local_database_service.dart';

/// حالة الاتصال
enum ConnectivityStatus { online, offline }

/// خدمة المزامنة وإدارة حالة الاتصال
/// تدعم Exponential Backoff و Idempotency و Conflict Resolution
class OfflineSyncService {
  final LocalDatabaseService _localDb;
  final SupabaseClient _supabase;
  final Ref? _ref;

  final _connectivityController = StreamController<ConnectivityStatus>.broadcast();
  ConnectivityStatus _currentStatus = ConnectivityStatus.online;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;

  Stream<ConnectivityStatus> get statusStream => _connectivityController.stream;
  ConnectivityStatus get currentStatus => _currentStatus;
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;
  bool get isOnline => _currentStatus == ConnectivityStatus.online;

  OfflineSyncService({
    required LocalDatabaseService localDb,
    required SupabaseClient supabase,
    Ref? ref,
  })  : _localDb = localDb,
        _supabase = supabase,
        _ref = ref;

  /// تهيئة الخدمة ومراقبة الاتصال
  Future<void> initialize() async {
    final initial = await Connectivity().checkConnectivity();
    _handleConnectivityChange(initial);

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    final newStatus = hasConnection ? ConnectivityStatus.online : ConnectivityStatus.offline;

    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      if (!_connectivityController.isClosed) {
        _connectivityController.add(_currentStatus);
      }

      if (isOnline) {
        _scheduleSyncAfterReconnect();
      } else {
        _syncTimer?.cancel();
      }
    }
  }

  void _scheduleSyncAfterReconnect() {
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(seconds: 3), () async {
      await syncPendingCheckins();
    });
  }

  /// مزامنة عمليات الدخول المعلقة مع Supabase باستخدام Exponential Backoff والتحقق من النزاهة
  Future<SyncResult> syncPendingCheckins() async {
    if (isOffline) {
      return const SyncResult(synced: 0, failed: 0, conflicts: 0, message: 'لا يوجد اتصال بالإنترنت');
    }
    if (_isSyncing) {
      return const SyncResult(synced: 0, failed: 0, conflicts: 0, message: 'المزامنة قيد التشغيل بالفعل');
    }

    _isSyncing = true;
    final pending = await _localDb.getPendingCheckins();
    
    if (pending.isEmpty) {
      _isSyncing = false;
      return const SyncResult(synced: 0, failed: 0, conflicts: 0, message: 'لا توجد عمليات معلقة');
    }

    // إعداد متغيرات التدقيق الأمني وهويات الدفعة والأجهزة
    final staffId = _supabase.auth.currentUser?.id ?? 'unknown_staff';
    final deviceId = await SecureStorageService().getOrCreateDeviceId();
    final syncBatchId = const Uuid().v4();

    // جلب معرف المناسبة لتسجيل سجل التدقيق بدقة
    final firstCheckin = pending.first;
    final guest = await _localDb.findGuestByQrToken(firstCheckin['qr_token'] as String);
    final eventId = guest?['event_id'] as String? ?? 'unknown_event';

    // 1. تسجيل بدء المزامنة في سجل التدقيق
    await _localDb.writeAuditLog(
      eventId: eventId,
      deviceId: deviceId,
      staffId: staffId,
      action: 'sync_started',
      details: 'بدء عملية مزامنة لعدد ${pending.length} سجل. دفعة: $syncBatchId',
      networkState: 'online',
      syncBatchId: syncBatchId,
    );

    int synced = 0;
    int failed = 0;
    int conflicts = 0;

    final retryOptions = const RetryOptions(
      maxAttempts: 3,
      delayFactor: Duration(seconds: 2), // Exponential Backoff (2s, 4s, 8s)
    );

    for (final checkin in pending) {
      final checkinId = checkin['id'] as String;

      // 2. التحقق من نزاهة التشفير محلياً قبل الرفع (HMAC-SHA256 Integrity check)
      final calculatedHash = await _localDb.calculateCheckinHmac(
        id: checkinId,
        guestId: checkin['guest_id'] as String,
        qrToken: checkin['qr_token'] as String,
        scannedAt: checkin['scanned_at'] as String,
        jti: checkin['jti'] as String? ?? '',
        gateName: checkin['gate_name'] as String?,
      );

      final dbHash = checkin['integrity_hash'] as String? ?? '';
      
      if (calculatedHash != dbHash) {
        // اكتشاف خرق للنزاهة المحلي! يتم إيقاف الرفع فوراً وتسجيل الحدث
        await _localDb.writeAuditLog(
          eventId: eventId,
          deviceId: deviceId,
          staffId: staffId,
          action: 'integrity_violation',
          details: 'تم رصد خرق لنزاهة البيانات في السجل المحلي: $checkinId. تم إلغاء المزامنة لهذا السجل.',
          networkState: 'online',
          syncBatchId: syncBatchId,
        );

        // وسم السجل بالتعارض الأمني لمنع محاولة المزامنة المستمرة
        await _localDb.updatePendingCheckinStatus(
          checkinId, 
          'failed', 
          conflictReason: 'integrity_violation',
        );

        conflicts++;
        continue;
      }

      try {
        await retryOptions.retry(
          () async {
            // Idempotent Request: نرسل الـ ID المحلي كـ idempotency key ليمنع السيرفر التكرار
            final response = await _supabase.rpc('sync_offline_checkin', params: {
              'p_idempotency_key': checkinId,
              'p_guest_id': checkin['guest_id'],
              'p_qr_token': checkin['qr_token'],
              'p_scanned_at': checkin['scanned_at'],
            });

            final status = response['status'] as String?;
            
            if (status == 'success' || status == 'already_synced') {
              await _localDb.updatePendingCheckinStatus(checkinId, 'success');
              synced++;

              // تحديث البوابة في السيرفر بشكل منفصل كإجراء أمني تشغيلي
              final gateName = checkin['gate_name'] as String?;
              if (gateName != null) {
                try {
                  await _supabase
                      .from('checkins')
                      .update({'gate_name': gateName})
                      .eq('guest_id', checkin['guest_id'])
                      .eq('scanned_at', checkin['scanned_at']);
                } catch (_) {
                  // يفشل بهدوء إن لم يكن العمود مهيأ بعد على السيرفر
                }
              }
            } else if (status == 'conflict') {
              final reason = response['reason'] as String?;
              await _localDb.updatePendingCheckinStatus(
                checkinId, 
                'failed', 
                conflictReason: reason,
              );
              conflicts++;
            } else {
              throw Exception('Unexpected status');
            }
          },
          retryIf: (e) => e is PostgrestException || e is TimeoutException,
        );
      } catch (_) {
        await _localDb.incrementRetryCount(checkinId);
        failed++;
      }
    }

    _isSyncing = false;
    _ref?.invalidate(pendingCheckinsCountProvider);

    // 3. تسجيل نهاية عملية المزامنة وحصيلتها في سجل التدقيق
    if (failed > 0) {
      await _localDb.writeAuditLog(
        eventId: eventId,
        deviceId: deviceId,
        staffId: staffId,
        action: 'sync_failed',
        details: 'فشل مزامنة بعض السجلات. نجح: $synced، فشل اتصال: $failed، تعارضات/نزاهة: $conflicts. دفعة: $syncBatchId',
        networkState: 'online',
        syncBatchId: syncBatchId,
      );
    } else {
      await _localDb.writeAuditLog(
        eventId: eventId,
        deviceId: deviceId,
        staffId: staffId,
        action: 'sync_completed',
        details: 'اكتملت مزامنة السجلات المعلقة بنجاح. عدد السجلات: $synced. دفعة: $syncBatchId',
        networkState: 'online',
        syncBatchId: syncBatchId,
      );
    }
    
    // تحديث وقت المزامنة للكشف عن التلاعب بالوقت (Clock Drift)
    await SecureStorageService().updateLastSyncTime();

    return SyncResult(
      synced: synced,
      failed: failed,
      conflicts: conflicts,
      message: 'تمت مزامنة $synced بنجاح، ووجود $conflicts تعارض، وفشل $failed لضعف الشبكة.',
    );
  }

  /// تحميل وتخزين ضيوف مناسبة محلياً من Supabase (Pre-load)
  Future<void> cacheEventGuests(String eventId) async {
    if (isOffline) return;
    try {
      final response = await _supabase
          .from('guests')
          .select()
          .eq('event_id', eventId)
          .order('name');

      final guests = (response as List<dynamic>)
          .map((g) => Map<String, dynamic>.from(g as Map))
          .toList();

      await _localDb.cacheGuests(eventId, guests);
    } catch (_) {
      // فشل التنزيل
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _connectivityController.close();
  }
}

/// نتيجة عملية المزامنة
class SyncResult {
  final int synced;
  final int failed;
  final int conflicts;
  final String message;

  const SyncResult({
    required this.synced,
    required this.failed,
    required this.conflicts,
    required this.message,
  });
}

// ─── Providers ───

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final service = OfflineSyncService(
    localDb: localDatabaseService,
    supabase: Supabase.instance.client,
    ref: ref,
  );
  ref.onDispose(service.dispose);
  return service;
});

final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(offlineSyncServiceProvider);
  return service.statusStream;
});

final pendingCheckinsCountProvider = FutureProvider<int>((ref) async {
  final pending = await localDatabaseService.getPendingCheckins();
  return pending.length;
});
