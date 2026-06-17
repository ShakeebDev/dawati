import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dawati/core/constants/app_constants.dart';
import 'package:dawati/core/errors/failures.dart';
import 'package:dawati/shared/services/supabase_service.dart';
import 'package:dawati/features/events/data/models/event_model.dart';

class EventRepository {
  final SupabaseService _supabase;

  EventRepository(this._supabase);

  /// جلب جميع المناسبات للمنظم الحالي
  Future<Result<List<EventModel>>> getMyEvents() async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) return Failure(AuthFailure.unknown());

      final response = await _supabase.client
          .from(AppConstants.eventsTable)
          .select('*, guests(count), checkins(count)')
          .eq('created_by', userId)
          .isFilter('deleted_at', null)
          .order('date', ascending: false);

      final List<EventModel> events = (response as List).map((json) {
        final guestData = json['guests'];
        int total = 0;
        if (guestData is List && guestData.isNotEmpty) {
          total = guestData[0]['count'] ?? 0;
        } else if (guestData is Map) {
          total = guestData['count'] ?? 0;
        }

        final checkinData = json['checkins'];
        int checkedIn = 0;
        if (checkinData is List && checkinData.isNotEmpty) {
          checkedIn = checkinData[0]['count'] ?? 0;
        } else if (checkinData is Map) {
          checkedIn = checkinData['count'] ?? 0;
        }

        return EventModel.fromJson({
          ...json,
          'total_guests': total,
          'confirmed_guests': 0, // تحديث لاحق
          'checked_in_guests': checkedIn,
        });
      }).toList();

      return Success(events);
    } catch (e) {
      return Failure(DatabaseFailure.unknown(e));
    }
  }

  /// إنشاء مناسبة جديدة
  Future<Result<EventModel>> createEvent(EventModel event) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null || userId.isEmpty) {
        return Failure(
            AuthFailure(message: 'المستخدم غير مسجل دخول بشكل صحيح'));
      }

      // بناء البيانات مع استبعاد الـ id الفارغ (نتركه لـ Supabase)
      final data = <String, dynamic>{
        'name': event.name,
        'date': event.date.toIso8601String(),
        'location': event.location,
        'entry_type': event.entryType,
        'event_type': event.eventType,
        'created_by': userId,
        if (event.invitationTemplate != null)
          'invitation_template': event.invitationTemplate,
        if (event.invitationText != null)
          'invitation_text': event.invitationText,
      };

      final response = await _supabase.client
          .from(AppConstants.eventsTable)
          .insert(data)
          .select()
          .single();

      return Success(EventModel.fromJson(response));
    } on PostgrestException catch (e) {
      // خطأ من Supabase — نعرض الرسالة الحقيقية للمساعدة في التشخيص
      final msg = e.code == '42501'
          ? 'ليس لديك صلاحية إنشاء مناسبة. تأكد من أن حسابك منظم (organizer).'
          : 'خطأ في قاعدة البيانات: ${e.message}';
      return Failure(DatabaseFailure(message: msg, code: e.code));
    } catch (e) {
      return Failure(DatabaseFailure(message: 'حدث خطأ غير متوقع: ${e.toString()}', code: 'unknown'));
    }
  }

  /// جلب تفاصيل مناسبة محددة مع إحصائيات دقيقة
  Future<Result<EventModel>> getEventDetails(String eventId) async {
    try {
      // جلب بيانات المناسبة
      final response = await _supabase.client
          .from(AppConstants.eventsTable)
          .select()
          .eq('id', eventId)
          .isFilter('deleted_at', null)
          .single();

      // الأفضل استخدام استعلامات Count منفصلة لدعم ملايين السجلات مستقبلاً

      final totalGuests = await _supabase.client
          .from(AppConstants.guestsTable)
          .select('id')
          .eq('event_id', eventId);

      final checkedInGuests = await _supabase.client
          .from(AppConstants.guestsTable)
          .select('id')
          .eq('event_id', eventId)
          .eq('status', 'checked_in');

      return Success(EventModel.fromJson({
        ...response,
        'total_guests': (totalGuests as List).length,
        'checked_in_guests': (checkedInGuests as List).length,
      }));
    } catch (e) {
      return Failure(DatabaseFailure.unknown(e));
    }
  }

  /// تحديث بيانات مناسبة موجودة
  Future<Result<EventModel>> updateEvent(EventModel event) async {
    try {
      final response = await _supabase.client
          .from(AppConstants.eventsTable)
          .update(event.toUpdateJson())
          .eq('id', event.id)
          .select()
          .single();
      return Success(EventModel.fromJson(response));
    } catch (e) {
      return Failure(DatabaseFailure.unknown(e));
    }
  }

  /// حذف مناسبة (نستخدم Soft Delete لمنع تجاوز حد المناسبات للمجاني)
  Future<Result<bool>> deleteEvent(String eventId) async {
    try {
      await _supabase.client
          .from(AppConstants.eventsTable)
          .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', eventId);
      return const Success(true);
    } catch (e) {
      return Failure(DatabaseFailure.unknown(e));
    }
  }
}

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.read(supabaseServiceProvider));
});
