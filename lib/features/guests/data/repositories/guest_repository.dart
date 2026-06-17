import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawati/core/constants/app_constants.dart';
import 'package:dawati/core/errors/failures.dart';
import 'package:dawati/core/services/local_database_service.dart';
import 'package:dawati/core/services/offline_sync_service.dart';
import 'package:dawati/shared/services/supabase_service.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';

class GuestRepository {
  final SupabaseService _supabase;
  final LocalDatabaseService _localDb;
  final OfflineSyncService _syncService;

  GuestRepository(this._supabase, this._localDb, this._syncService);

  /// جلب قائمة الضيوف مع دعم وضع عدم الاتصال
  Future<Result<List<GuestModel>>> getGuests({
    required String eventId,
    String? query,
    int? offset,
    int? limit,
  }) async {
    // ─── أون‌لاين: جلب من Supabase + تخزين محلي ───
    if (_syncService.isOnline) {
      try {
        dynamic request =
            _supabase.client.from(AppConstants.guestsTable).select();

        request = request.eq('event_id', eventId);

        if (query != null && query.isNotEmpty) {
          request = request.or('name.ilike.%$query%,phone.ilike.%$query%');
        }

        if (offset != null && limit != null) {
          request = request.range(offset, offset + limit - 1);
        }

        final response = await request.order('name');
        final List<GuestModel> guests =
            (response as List).map((json) => GuestModel.fromJson(json)).toList();

        // خزّن القائمة الكاملة محلياً (بدون بحث)
        if (query == null || query.isEmpty) {
          await _localDb.cacheGuests(
            eventId,
            guests.map((g) => g.toJson()..['id'] = g.id..['created_at'] = g.createdAt.toIso8601String()).toList(),
          );
        }

        return Success(guests);
      } catch (e) {
        // الاتصال فشل — نسقط إلى الوضع المحلي
      }
    }

    // ─── أوف‌لاين: جلب من قاعدة البيانات المحلية ───
    final hasCached = await _localDb.hasGuestsCached(eventId);
    if (!hasCached) {
      return Failure(
        DatabaseFailure.unknown(
          'لا يوجد اتصال بالإنترنت ولم يتم تخزين قائمة الضيوف مسبقاً',
        ),
      );
    }

    var rows = await _localDb.getCachedGuests(eventId);

    // تصفية محلية حسب البحث
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      rows = rows.where((r) {
        final name = (r['name'] as String? ?? '').toLowerCase();
        final phone = (r['phone'] as String? ?? '').toLowerCase();
        return name.contains(q) || phone.contains(q);
      }).toList();
    }

    // تقطيع (pagination) محلي
    if (offset != null && limit != null) {
      final start = offset.clamp(0, rows.length);
      final end = (offset + limit).clamp(0, rows.length);
      rows = rows.sublist(start, end);
    }

    final guests = rows.map((r) {
      return GuestModel(
        id: r['id'] as String,
        eventId: r['event_id'] as String,
        name: r['name'] as String,
        phone: r['phone'] as String? ?? '',
        allowedEntries: r['allowed_entries'] as int? ?? 1,
        currentEntries: r['current_entries'] as int? ?? 0,
        qrToken: r['qr_token'] as String? ?? '',
        status: r['status'] as String? ?? 'pending',
        tableNumber: r['table_number'] as String?,
        seatNumber: r['seat_number'] as String?,
        notes: r['notes'] as String?,
        createdAt: r['created_at'] != null
            ? DateTime.tryParse(r['created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
    }).toList();

    return Success(guests);
  }

  /// إضافة ضيف جديد (يستلزم الإنترنت)
  Future<Result<GuestModel>> addGuest(GuestModel guest) async {
    if (_syncService.isOffline) {
      return Failure(DatabaseFailure.unknown('يلزم الاتصال بالإنترنت لإضافة ضيف جديد'));
    }
    try {
      final response = await _supabase.client
          .from(AppConstants.guestsTable)
          .insert(guest.toJson())
          .select()
          .single();

      return Success(GuestModel.fromJson(response));
    } catch (e) {
      return Failure(DatabaseFailure.unknown(e));
    }
  }

  /// إضافة مجموعة ضيوف دفعة واحدة (يستلزم الإنترنت)
  Future<Result<List<GuestModel>>> addGuests(List<GuestModel> guests) async {
    if (_syncService.isOffline) {
      return Failure(DatabaseFailure.unknown('يلزم الاتصال بالإنترنت لإضافة الضيوف'));
    }
    try {
      final response = await _supabase.client
          .from(AppConstants.guestsTable)
          .insert(guests.map((g) => g.toJson()).toList())
          .select();

      final List<GuestModel> addedGuests =
          (response as List).map((json) => GuestModel.fromJson(json)).toList();

      return Success(addedGuests);
    } catch (e) {
      return Failure(DatabaseFailure.unknown(e));
    }
  }

  /// حذف ضيف (يستلزم الإنترنت)
  Future<Result<void>> deleteGuest(String guestId) async {
    if (_syncService.isOffline) {
      return Failure(DatabaseFailure.unknown('يلزم الاتصال بالإنترنت لحذف ضيف'));
    }
    try {
      await _supabase.client
          .from(AppConstants.guestsTable)
          .delete()
          .eq('id', guestId);
      return const Success(null);
    } catch (e) {
      return Failure(DatabaseFailure.unknown(e));
    }
  }

  /// تحديث بيانات ضيف (يستلزم الإنترنت)
  Future<Result<GuestModel>> updateGuest(GuestModel guest) async {
    if (_syncService.isOffline) {
      return Failure(DatabaseFailure.unknown('يلزم الاتصال بالإنترنت لتحديث بيانات الضيف'));
    }
    try {
      final response = await _supabase.client
          .from(AppConstants.guestsTable)
          .update(guest.toJson())
          .eq('id', guest.id)
          .select()
          .single();

      return Success(GuestModel.fromJson(response));
    } catch (e) {
      return Failure(DatabaseFailure.unknown(e));
    }
  }
}

final guestRepositoryProvider = Provider<GuestRepository>((ref) {
  return GuestRepository(
    ref.read(supabaseServiceProvider),
    localDatabaseService,
    ref.read(offlineSyncServiceProvider),
  );
});
