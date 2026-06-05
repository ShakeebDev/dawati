import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── نماذج البيانات ─────────────────────────────────────────────────────────

/// إدخال مباشر في السجل الحي
class LiveEntry {
  final String id;
  final String guestName;
  final String? gateName;
  final bool isVip;
  final DateTime checkedInAt;
  final String? scannedByName;

  const LiveEntry({
    required this.id,
    required this.guestName,
    this.gateName,
    required this.isVip,
    required this.checkedInAt,
    this.scannedByName,
  });
}

/// إحصائيات بوابة واحدة
class GateStat {
  final String gateName;
  final int count;
  GateStat({required this.gateName, required this.count});
}

/// ملخص التحليلات الكاملة
class AnalyticsSummary {
  final int total;
  final int checkedIn;
  final int pending;
  final int vipCount;
  final List<GateStat> gateStats;
  final List<LiveEntry> recentEntries;
  final Map<int, int> hourlyDistribution; // ساعة -> عدد

  double get attendanceRate => total == 0 ? 0 : (checkedIn / total * 100);

  const AnalyticsSummary({
    required this.total,
    required this.checkedIn,
    required this.pending,
    required this.vipCount,
    required this.gateStats,
    required this.recentEntries,
    required this.hourlyDistribution,
  });

  factory AnalyticsSummary.empty() => const AnalyticsSummary(
        total: 0,
        checkedIn: 0,
        pending: 0,
        vipCount: 0,
        gateStats: [],
        recentEntries: [],
        hourlyDistribution: {},
      );
}

// ─── Analytics Summary Provider ──────────────────────────────────────────────

/// موفر الإحصائيات الكاملة البثي (Realtime Stream Provider Family)
final analyticsSummaryProvider =
    StreamProvider.family<AnalyticsSummary, String>((ref, eventId) async* {
  final supabase = Supabase.instance.client;

  Future<AnalyticsSummary> fetchSummary() async {
    // 1. إجمالي الضيوف في المناسبة
    final guestsRes = await supabase
        .from('guests')
        .select('id, name, status')
        .eq('event_id', eventId)
        .isFilter('deleted_at', null);

    final allGuests = guestsRes as List<dynamic>;
    final total = allGuests.length;

    // 2. بيانات الإدخالات مع join لجدول الضيوف
    // checkins يحتوي: id, guest_id, event_id, scanned_by, scanned_at, gate_name
    // نجلب بيانات الضيف عبر guest_id → guests(name)
    final checkinsRes = await supabase
        .from('checkins')
        .select('id, guest_id, scanned_by, scanned_at, guests(name)')
        .eq('event_id', eventId)
        .order('scanned_at', ascending: false);

    final checkins = checkinsRes as List<dynamic>;
    final checkedIn = checkins.length;

    // جلب أسماء الموظفين الذين قاموا بالمسح بشكل منفصل لتفادي أخطاء PostgREST العلاقات
    final scannedByIds = checkins
        .map((c) => c['scanned_by'] as String?)
        .where((id) => id != null)
        .toSet()
        .toList();

    final profilesMap = <String, String>{};
    if (scannedByIds.isNotEmpty) {
      try {
        final profilesRes = await supabase
            .from('profiles')
            .select('id, name')
            .inFilter('id', scannedByIds);
        for (final p in profilesRes as List<dynamic>) {
          profilesMap[p['id'] as String] = p['name'] as String? ?? 'موظف';
        }
      } catch (_) {
        // تفشل بهدوء إن حدثت مشكلة في الصلاحيات
      }
    }

    // 3. حساب إحصائيات البوابات من event_staff (كمستوى احتياطي للموثوقية)
    final staffGatesRes = await supabase
        .from('event_staff')
        .select('staff_id, gate_name')
        .eq('event_id', eventId);
    
    final staffGates = <String, String>{};
    for (final sg in staffGatesRes as List<dynamic>) {
      if (sg['gate_name'] != null) {
        staffGates[sg['staff_id'] as String] = sg['gate_name'] as String;
      }
    }

    // 4. حساب VIP ومعالجة الإدخالات
    int vipCount = 0;
    final gateMap = <String, int>{};
    final hourlyMap = <int, int>{};
    final recentEntries = <LiveEntry>[];

    for (final c in checkins) {
      final guestData = c['guests'] as Map<String, dynamic>?;
      final guestName = guestData?['name'] as String? ?? 'ضيف';
      final scannedBy = c['scanned_by'] as String?;
      final scannedByName = scannedBy != null ? profilesMap[scannedBy] : null;
      
      // البوابة: نقرأها من جدول event_staff المرتبط بالموظف الذي قام بالمسح
      final gateName = scannedBy != null ? staffGates[scannedBy] : null;
      
      // VIP check
      final nameLower = guestName.toLowerCase();
      final isVip = nameLower.contains('vip') || nameLower.contains('كبار');
      if (isVip) vipCount++;

      // إحصائيات البوابات
      final gateKey = gateName ?? 'غير محدد';
      gateMap[gateKey] = (gateMap[gateKey] ?? 0) + 1;

      // التوزيع الساعي
      final scannedAt = DateTime.tryParse(c['scanned_at'] as String? ?? '');
      if (scannedAt != null) {
        final hour = scannedAt.hour;
        hourlyMap[hour] = (hourlyMap[hour] ?? 0) + 1;
      }

      // آخر 20 إدخال
      if (recentEntries.length < 20) {
        recentEntries.add(LiveEntry(
          id: c['id'] as String,
          guestName: guestName,
          gateName: gateName,
          isVip: isVip,
          checkedInAt: scannedAt ?? DateTime.now(),
          scannedByName: scannedByName,
        ));
      }
    }

    final gateStats = gateMap.entries
        .map((e) => GateStat(gateName: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return AnalyticsSummary(
      total: total,
      checkedIn: checkedIn,
      pending: total - checkedIn,
      vipCount: vipCount,
      gateStats: gateStats,
      recentEntries: recentEntries,
      hourlyDistribution: hourlyMap,
    );
  }

  // 1. بث الملخص الأولي مباشرة
  yield await fetchSummary();

  // 2. إنشاء قناة بث واستقبال التغييرات من قاعدة البيانات
  final controller = StreamController<AnalyticsSummary>();
  final channel = supabase.channel('realtime_analytics_$eventId');

  // استماع للتغييرات في جدول الضيوف لهذه المناسبة
  channel.onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'guests',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'event_id',
      value: eventId,
    ),
    callback: (payload) async {
      if (!controller.isClosed) {
        final summary = await fetchSummary();
        controller.add(summary);
      }
    },
  );

  // استماع لتسجيل حضور ضيف في هذه المناسبة
  channel.onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'checkins',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'event_id',
      value: eventId,
    ),
    callback: (payload) async {
      if (!controller.isClosed) {
        final summary = await fetchSummary();
        controller.add(summary);
      }
    },
  );

  channel.subscribe();

  // تنظيف القناة عند التخلص من الموفر
  ref.onDispose(() {
    supabase.removeChannel(channel);
    controller.close();
  });

  yield* controller.stream;
});

// ─── Auto-refresh Notifier ───────────────────────────────────────────────────

/// حالة التحديث التلقائي
class AutoRefreshNotifier extends StateNotifier<DateTime> {
  AutoRefreshNotifier() : super(DateTime.now());

  void refresh() => state = DateTime.now();
}

final autoRefreshProvider =
    StateNotifierProvider<AutoRefreshNotifier, DateTime>(
        (_) => AutoRefreshNotifier());
