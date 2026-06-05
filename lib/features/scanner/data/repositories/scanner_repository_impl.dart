import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/local_database_service.dart';
import '../../../../core/services/offline_sync_service.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../../core/security/qr_signature_service.dart';
import '../../../../core/storage/secure_storage_service.dart';

import '../../domain/entities/checkin_entity.dart';
import '../../domain/entities/scanner_failure.dart';
import '../../domain/repositories/scanner_repository.dart';

class ScannerRepositoryImpl implements IScannerRepository {
  final SupabaseService _supabase;
  final LocalDatabaseService _localDb;
  final OfflineSyncService _syncService;
  final QrSignatureService _qrSignatureService;

  ScannerRepositoryImpl(
    this._supabase,
    this._localDb,
    this._syncService,
    this._qrSignatureService,
  );

  @override
  Future<Either<ScannerFailure, CheckInEntity>> processCheckIn(String qrToken, {String? gateName}) async {
    // 1. التحقق من التوقيع الرقمي (سواء كنا أونلاين أو أوفلاين كطبقة حماية أولى)
    // يمكن تعطيل هذا التحقق الأولي هنا وجعله للسيرفر فقط، لكن لزيادة الأمان نتحقق محلياً
    final signatureResult = await _qrSignatureService.verifyQrToken(qrToken);
    
    // إذا كان التوكن غير صالح كتوقيع، نرفضه مباشرة 
    // (إلا لو كان النظام لا يزال يدعم UUID القديم، يمكن تمريره. لكننا سنفترض أننا انتقلنا لـ JWT)
    if (!signatureResult.isValid && signatureResult.errorReason != 'missing_keys') {
      if (signatureResult.errorReason == 'expired_qr') {
        return Left(ScannerFailure(type: ScannerFailureType.expiredQr));
      }
      return Left(ScannerFailure(type: ScannerFailureType.invalidQr));
    }

    // 2. إذا كنا متصلين بالإنترنت -> نعتمد على السيرفر (Single Source of Truth)
    if (_syncService.isOnline) {
      return await _processOnline(qrToken, gateName: gateName);
    } 
    
    // 3. إذا كنا غير متصلين -> نعتمد على Offline Secure Engine
    return await _processOffline(qrToken, signatureResult.payload, gateName: gateName);
  }

  Future<Either<ScannerFailure, CheckInEntity>> _processOnline(String qrToken, {String? gateName}) async {
    try {
      final response = await _supabase.client.rpc(
        AppConstants.processCheckinRpc,
        params: {'p_qr_token': qrToken},
      );

      final data = response as Map<String, dynamic>;
      final isSuccess = data['success'] as bool? ?? false;

      if (isSuccess) {
        final resultData = data['data'] as Map<String, dynamic>;
        
        // تحديث الكاش المحلي إن وُجد
        final guestId = resultData['guest_id'] as String?;
        if (guestId != null) {
          await _localDb.updateGuestCheckin(guestId, resultData['current_entries'] ?? 0, 'checked_in');
          
          // تحديث البوابة في السيرفر بشكل منفصل كإجراء أمني تشغيلي
          if (gateName != null) {
            try {
              await _supabase.client
                  .from('checkins')
                  .update({'gate_name': gateName})
                  .eq('guest_id', guestId)
                  .order('scanned_at', ascending: false)
                  .limit(1);
            } catch (e) {
              // يفشل بهدوء إن لم يكن العمود مهيأ بعد على السيرفر
              print('Defensive gate_name update ignored: $e');
            }
          }
        }

        final guestName = resultData['guest_name'] as String? ?? 'ضيف';
        final isVip = guestName.toUpperCase().contains('VIP') ||
            guestName.contains('كبار الشخصيات') ||
            resultData['is_vip'] == true;

        return Right(CheckInEntity(
          guestName: guestName,
          eventName: resultData['event_name'] as String? ?? '',
          remainingEntries: (resultData['allowed_entries'] as int? ?? 1) - (resultData['current_entries'] as int? ?? 1),
          message: 'تم تسجيل الدخول بنجاح',
          gateName: gateName,
          isVip: isVip,
        ));
      } else {
        final error = data['error'] as String?;
        return Left(ScannerFailure(type: _mapServerError(error)));
      }
    } catch (e) {
      // إذا فشل الاتصال رغم أن الـ SyncService يقول Online، ننتقل للـ Offline
      // أو نرد بخطأ شبكة. الأفضل هنا الرد بخطأ شبكة وتوجيه المستخدم للتحقق من الإنترنت
      // أو السماح بتجربة الأوفلاين.
      return Left(ScannerFailure(
        type: ScannerFailureType.networkError,
        internalLog: e.toString(),
      ));
    }
  }

  Future<Either<ScannerFailure, CheckInEntity>> _processOffline(String qrToken, Map<String, dynamic>? payload, {String? gateName}) async {
    if (payload == null) {
      return Left(ScannerFailure(type: ScannerFailureType.invalidQr, internalLog: 'Null payload in offline'));
    }

    final guestId = payload['guest_id'] as String?;
    final eventId = payload['event_id'] as String?;
    final jti = payload['jti'] as String?;

    if (guestId == null || eventId == null || jti == null) {
      return Left(ScannerFailure(type: ScannerFailureType.invalidQr));
    }

    // 1. التحقق من عدم محاولة إعادة الاستخدام محلياً (Local Replay Cache)
    if (await _localDb.isTokenPendingSync(jti)) {
      final staffId = _supabase.client.auth.currentUser?.id ?? 'unknown_staff';
      final deviceId = await SecureStorageService().getOrCreateDeviceId();

      await _localDb.writeAuditLog(
        eventId: eventId,
        deviceId: deviceId,
        staffId: staffId,
        action: 'replay_detected',
        details: 'محاولة إعادة استخدام التوكن ذو المعرف فريد: $jti في وضع الأوفلاين.',
        networkState: 'offline',
      );

      return Left(ScannerFailure(type: ScannerFailureType.alreadyScanned));
    }

    // 2. هل نملك بيانات هذا الضيف محلياً؟ (Offline Restrictions)
    final localGuest = await _localDb.findGuestByQrToken(qrToken);
    if (localGuest == null) {
      // لا يُسمح بإدخال ضيوف غير محملين مسبقاً
      return Left(ScannerFailure(type: ScannerFailureType.offlineNotAllowed));
    }

    // 3. التحقق من عدد مرات الدخول
    final allowed = localGuest['allowed_entries'] as int? ?? 1;
    final current = localGuest['current_entries'] as int? ?? 0;

    if (current >= allowed) {
      return Left(ScannerFailure(type: ScannerFailureType.entriesExceeded));
    }

    // 4. التحقق من حالة الدعوة
    final status = localGuest['status'] as String?;
    if (status == 'revoked' || status == 'cancelled') {
      return Left(ScannerFailure(type: ScannerFailureType.revokedInvitation));
    }

    // 5. الموافقة المحلية المؤقتة
    final newCurrent = current + 1;
    await _localDb.updateGuestCheckin(localGuest['id'] as String, newCurrent, 'checked_in');

    // 6. إضافة لـ Offline Queue
    await _localDb.addPendingCheckin(
      id: const Uuid().v4(),
      guestId: guestId,
      qrToken: qrToken,
      scannedAt: DateTime.now(),
      jti: jti,
      gateName: gateName,
    );

    final guestName = localGuest['name'] as String? ?? 'ضيف';
    final notes = localGuest['notes'] as String? ?? '';
    final isVip = guestName.toUpperCase().contains('VIP') ||
        guestName.contains('كبار الشخصيات') ||
        notes.toUpperCase().contains('VIP') ||
        notes.contains('كبار الشخصيات');

    return Right(CheckInEntity(
      guestName: guestName,
      eventName: '',
      remainingEntries: allowed - newCurrent,
      message: 'تم تسجيل الدخول (وضع عدم الاتصال)',
      isOffline: true,
      gateName: gateName,
      isVip: isVip,
    ));
  }

  ScannerFailureType _mapServerError(String? errorCode) {
    switch (errorCode) {
      case 'INVALID_INVITATION':
      case 'NOT_FOUND':
        return ScannerFailureType.invalidQr;
      case 'EXPIRED':
        return ScannerFailureType.expiredQr;
      case 'LIMIT_REACHED':
        return ScannerFailureType.entriesExceeded;
      case 'REVOKED':
        return ScannerFailureType.revokedInvitation;
      case 'RATE_LIMITED':
        return ScannerFailureType.serverError;
      default:
        return ScannerFailureType.invalidQr;
    }
  }
}

final scannerRepositoryProvider = Provider<IScannerRepository>((ref) {
  return ScannerRepositoryImpl(
    ref.read(supabaseServiceProvider),
    localDatabaseService,
    ref.read(offlineSyncServiceProvider),
    ref.read(qrSignatureServiceProvider),
  );
});
