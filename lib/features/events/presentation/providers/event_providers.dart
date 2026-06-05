import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:dawati/features/events/data/repositories/event_repository.dart';
import 'package:dawati/core/errors/failures.dart';

/// موفر قائمة المناسبات مع تحديث تلقائي مضمون
/// يعمل بثلاث طبقات:
///   1. جلب فوري عند الفتح
///   2. Realtime Postgres Changes (إذا كانت مفعّلة)
///   3. تحديث دوري كل 10 ثوانٍ كـ fallback
final eventsListProvider = StreamProvider<List<EventModel>>((ref) async* {
  final repo = ref.read(eventRepositoryProvider);
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  // controller يستقبل التحديثات من الـ Realtime والـ Timer
  final controller = StreamController<List<EventModel>>();

  Future<void> fetchAndEmit() async {
    try {
      final result = await repo.getMyEvents();
      if (result is Success<List<EventModel>> && !controller.isClosed) {
        controller.add(result.data);
      }
    } catch (_) {}
  }

  // الطبقة 1: تحديث دوري كل 10 ثوانٍ مضمون
  final timer = Timer.periodic(const Duration(seconds: 10), (_) {
    fetchAndEmit();
  });

  // الطبقة 2: Realtime Postgres Changes
  RealtimeChannel? channel;
  if (userId != null && userId.isNotEmpty) {
    channel = supabase.channel('events_dash_$userId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'events',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'created_by',
        value: userId,
      ),
      callback: (_) => fetchAndEmit(),
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'guests',
      callback: (_) => fetchAndEmit(),
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'checkins',
      callback: (_) => fetchAndEmit(),
    );

    channel.subscribe();
  }

  // تنظيف عند التخلص
  ref.onDispose(() {
    timer.cancel();
    if (channel != null) supabase.removeChannel(channel);
    controller.close();
  });

  // الطبقة 3: الجلب الفوري للقيمة الأولى (yield مباشر)
  final firstResult = await repo.getMyEvents();
  if (firstResult is Success<List<EventModel>>) {
    yield firstResult.data;
  } else {
    yield [];
  }

  // ثم نبث كل تحديث من الـ controller
  yield* controller.stream;
});

/// موفر تفاصيل مناسبة محددة
final eventDetailsProvider =
    FutureProvider.family<EventModel?, String>((ref, eventId) async {
  final repo = ref.read(eventRepositoryProvider);
  final result = await repo.getEventDetails(eventId);
  if (result is Success<EventModel>) return result.data;
  if (result is Failure<EventModel>) throw result.failure.message;
  return null;
});
