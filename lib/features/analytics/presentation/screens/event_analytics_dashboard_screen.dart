import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:dawati/features/analytics/presentation/widgets/live_feed_tab.dart';
import 'package:dawati/features/analytics/presentation/widgets/overview_tab.dart';
import 'package:dawati/features/analytics/presentation/widgets/gates_tab.dart';
import 'package:dawati/core/widgets/responsive_wrapper.dart';

class EventAnalyticsDashboardScreen extends ConsumerStatefulWidget {
  final String eventId;
  final String eventName;

  const EventAnalyticsDashboardScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  ConsumerState<EventAnalyticsDashboardScreen> createState() =>
      _EventAnalyticsDashboardScreenState();
}

class _EventAnalyticsDashboardScreenState
    extends ConsumerState<EventAnalyticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _forceRefresh() {
    ref.invalidate(analyticsSummaryProvider(widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(analyticsSummaryProvider(widget.eventId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ResponsiveWrapper(
        useScroll: false,
        padding: EdgeInsets.zero,
        maxWidth: 800,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              floating: false,
              backgroundColor: isDark ? const Color(0xFF0D1B2A) : AppTheme.navyPrimary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: _forceRefresh,
                  tooltip: 'تحديث',
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _buildHeader(summaryAsync),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Container(
                  color: isDark ? const Color(0xFF0D1B2A) : AppTheme.navyPrimary,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.goldPrimary,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: AppTheme.fontFamily,
                    ),
                    tabs: const [
                      Tab(
                        text: 'نظرة عامة',
                        icon: Icon(Icons.dashboard_rounded, size: 16),
                        iconMargin: EdgeInsets.only(bottom: 2),
                      ),
                      Tab(
                        text: 'سجل الدخول',
                        icon: Icon(Icons.sensors_rounded, size: 16),
                        iconMargin: EdgeInsets.only(bottom: 2),
                      ),
                      Tab(
                        text: 'البوابات',
                        icon: Icon(Icons.door_sliding_rounded, size: 16),
                        iconMargin: EdgeInsets.only(bottom: 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: summaryAsync.when(
            data: (summary) => TabBarView(
              controller: _tabController,
              children: [
                OverviewTab(summary: summary, eventId: widget.eventId),
                LiveFeedTab(eventId: widget.eventId, summary: summary),
                GatesTab(summary: summary),
              ],
            ),
            loading: () => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      color: AppTheme.goldPrimary,
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'جاري تحميل التحليلات...',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline_rounded,
                          size: 36, color: AppTheme.error),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'تعذّر تحميل البيانات',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$err',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _forceRefresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('إعادة المحاولة'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.navyPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AsyncValue<AnalyticsSummary> summaryAsync) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A1628), Color(0xFF102040), Color(0xFF1A3050)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // زخارف خلفية
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.goldPrimary.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.goldPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.goldPrimary.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bar_chart_rounded,
                                color: AppTheme.goldPrimary, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'لوحة التحليل',
                              style: TextStyle(
                                  color: AppTheme.goldPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _LiveIndicator(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.eventName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  summaryAsync.when(
                    data: (summary) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _MiniStat(
                            label: 'حضروا',
                            value: '${summary.checkedIn}',
                            color: AppTheme.success,
                            icon: Icons.how_to_reg_rounded,
                          ),
                          const SizedBox(width: 20),
                          _MiniStat(
                            label: 'إجمالي',
                            value: '${summary.total}',
                            color: Colors.white70,
                            icon: Icons.people_rounded,
                          ),
                          const SizedBox(width: 20),
                          _MiniStat(
                            label: 'نسبة الحضور',
                            value:
                                '${summary.attendanceRate.toStringAsFixed(0)}%',
                            color: AppTheme.goldPrimary,
                            icon: Icons.percent_rounded,
                          ),
                          if (summary.vipCount > 0) ...[
                            const SizedBox(width: 20),
                            _MiniStat(
                              label: 'VIP',
                              value: '${summary.vipCount}',
                              color: const Color(0xFFDBA5FF),
                              icon: Icons.workspace_premium_rounded,
                            ),
                          ],
                        ],
                      ),
                    ),
                    loading: () => const SizedBox(
                      height: 20,
                      child: LinearProgressIndicator(
                        color: AppTheme.goldPrimary,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mini widgets ─────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color.withOpacity(0.8)),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _LiveIndicator extends StatefulWidget {
  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.15 + _pulse.value * 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade400.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 6 * _pulse.value,
                  )
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'مباشر',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
