import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/features/analytics/presentation/providers/analytics_provider.dart';

class OverviewTab extends StatelessWidget {
  final AnalyticsSummary summary;
  final String eventId;

  const OverviewTab({super.key, required this.summary, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
      children: [
        // بطاقات الإحصائيات الرئيسية
        _buildStatGrid(context),
        const SizedBox(height: 24),

        // شريط التقدم الحضور
        _buildAttendanceCard(context),
        const SizedBox(height: 24),

        // مخطط الدائرة
        if (summary.total > 0) ...[
          _buildPieChart(context),
          const SizedBox(height: 24),
        ],

        // التوزيع الساعي
        if (summary.hourlyDistribution.isNotEmpty) ...[
          _buildHourlyChart(context),
          const SizedBox(height: 24),
        ],

        // آخر الداخلين
        if (summary.recentEntries.isNotEmpty) ...[
          _buildSectionHeader(
              context, 'آخر الداخلين', Icons.access_time_rounded),
          const SizedBox(height: 12),
          ...summary.recentEntries.take(5).map(
                (e) => _buildEntryTile(context, e),
              ),
        ] else ...[
          _buildEmptyCheckins(context),
        ],
      ],
    );
  }

  Widget _buildStatGrid(BuildContext context) {
    final stats = [
      _StatInfo(
        label: 'إجمالي الضيوف',
        value: '${summary.total}',
        icon: Icons.people_rounded,
        color: AppTheme.navyPrimary,
        subtitle: 'مسجّلون',
      ),
      _StatInfo(
        label: 'دخلوا',
        value: '${summary.checkedIn}',
        icon: Icons.how_to_reg_rounded,
        color: AppTheme.success,
        subtitle: 'حضروا فعلاً',
      ),
      _StatInfo(
        label: 'لم يصلوا',
        value: '${summary.pending}',
        icon: Icons.hourglass_empty_rounded,
        color: Colors.orange.shade600,
        subtitle: 'غائبون',
      ),
      _StatInfo(
        label: 'كبار الشخصيات',
        value: '${summary.vipCount}',
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFF7C3AED),
        subtitle: 'VIP',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.1,
      children: stats.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        return _StatCard(stat: s)
            .animate()
            .fadeIn(delay: (i * 80).ms)
            .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic);
      }).toList(),
    );
  }

  Widget _buildAttendanceCard(BuildContext context) {
    final rate = summary.attendanceRate / 100;
    final theme = Theme.of(context);
    final Color progressColor = rate < 0.4
        ? Colors.red.shade400
        : rate < 0.6
            ? Colors.orange.shade500
            : rate < 0.85
                ? AppTheme.success
                : AppTheme.goldPrimary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle(
                  'نسبة الحضور', Icons.trending_up_rounded, context),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: progressColor.withOpacity(0.3)),
                ),
                child: Text(
                  '${summary.attendanceRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // شريط التقدم مع أنيميشن
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: rate.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 16,
                    backgroundColor: theme.brightness == Brightness.dark
                        ? Colors.white10
                        : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                if (value > 0.15)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          '${(value * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniChip(
                  '${summary.checkedIn} حضروا', AppTheme.success),
              const SizedBox(width: 10),
              _buildMiniChip(
                  '${summary.pending} لم يصلوا', Colors.orange.shade600),
              const SizedBox(width: 10),
              _buildMiniChip(
                  '${summary.total} إجمالي', Colors.grey),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1);
  }

  Widget _buildMiniChip(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPieChart(BuildContext context) {
    final checkedIn = summary.checkedIn.toDouble();
    final pending = summary.pending.toDouble();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 45,
                startDegreeOffset: -90,
                sections: [
                  PieChartSectionData(
                    value: checkedIn > 0 ? checkedIn : 0.001,
                    color: AppTheme.success,
                    radius: 52,
                    title: checkedIn > 0 ? '${summary.checkedIn}' : '',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (pending > 0)
                    PieChartSectionData(
                      value: pending,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white12
                          : Colors.grey.shade200,
                      radius: 44,
                      title: '',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('توزيع الحضور', Icons.donut_large_rounded, context),
                const SizedBox(height: 16),
                _legend(
                    AppTheme.success, 'حضروا', '${summary.checkedIn}'),
                const SizedBox(height: 10),
                _legend(
                    Colors.grey, 'لم يصلوا', '${summary.pending}'),
                if (summary.vipCount > 0) ...[
                  const SizedBox(height: 10),
                  _legend(const Color(0xFF7C3AED), 'VIP',
                      '${summary.vipCount}'),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildHourlyChart(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hours = summary.hourlyDistribution;
    if (hours.isEmpty) return const SizedBox.shrink();

    // نحضر كل الساعات من 0 إلى 23
    final maxVal = hours.values.isEmpty
        ? 1
        : hours.values.reduce((a, b) => a > b ? a : b);

    final allHours = List.generate(24, (i) => i);
    final relevantHours = allHours
        .where((h) => hours.containsKey(h) || (h >= 8 && h <= 23))
        .toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
              'التوزيع الساعي', Icons.access_time_filled_rounded, context),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxVal * 1.3).toDouble(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        isDark ? const Color(0xFF1A2840) : AppTheme.navyPrimary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final h = relevantHours[group.x];
                      return BarTooltipItem(
                        '${h.toString().padLeft(2, '0')}:00\n',
                        const TextStyle(
                            color: Colors.white70, fontSize: 10),
                        children: [
                          TextSpan(
                            text: '${rod.toY.toInt()} ضيف',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          )
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final h = relevantHours[val.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${h}',
                            style: TextStyle(
                                fontSize: 9,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey.shade500),
                          ),
                        );
                      },
                      reservedSize: 18,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: maxVal > 0 ? maxVal / 3 : 1,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                barGroups: relevantHours.asMap().entries.map((entry) {
                  final i = entry.key;
                  final h = entry.value;
                  final count = hours[h] ?? 0;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                        gradient: LinearGradient(
                          colors: count > 0
                              ? [
                                  AppTheme.navyPrimary.withOpacity(0.7),
                                  AppTheme.goldPrimary,
                                ]
                              : [Colors.grey.shade200, Colors.grey.shade200],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildEntryTile(BuildContext context, LiveEntry entry) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isVip
            ? const Color(0xFF7C3AED).withOpacity(0.06)
            : isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entry.isVip
              ? const Color(0xFF7C3AED).withOpacity(0.2)
              : theme.dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: entry.isVip
                  ? const Color(0xFF7C3AED).withOpacity(0.15)
                  : AppTheme.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              entry.isVip
                  ? Icons.workspace_premium_rounded
                  : Icons.check_circle_rounded,
              color: entry.isVip ? const Color(0xFF7C3AED) : AppTheme.success,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.guestName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (entry.isVip) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0xFFFFD700),
                            Color(0xFFFFA500)
                          ]),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('VIP',
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ),
                    ],
                  ],
                ),
                if (entry.gateName != null || entry.scannedByName != null)
                  Text(
                    [
                      if (entry.gateName != null) '🚪 ${entry.gateName}',
                      if (entry.scannedByName != null)
                        '👤 ${entry.scannedByName}',
                    ].join('  '),
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(entry.checkedInAt),
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.navyPrimary),
              ),
              Text(
                _formatDate(entry.checkedInAt),
                style:
                    const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }

  Widget _buildEmptyCheckins(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(32),
      decoration: _cardDecoration(context),
      child: Column(
        children: [
          Icon(Icons.sensors_off_rounded,
              size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'لا توجد إدخالات بعد',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          const Text(
            'ستظهر هنا إحصائيات الضيوف عند بدء الفحص',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.goldPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppTheme.goldPrimary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.goldPrimary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _legend(Color color, String label, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(label,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 6),
        Text('($count)',
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : AppTheme.shadowLow,
        border: Border.all(
            color:
                Theme.of(context).dividerColor.withOpacity(0.08)),
      );

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}';
  }
}

// ─── Stat card internals ─────────────────────────────────────────────────────

class _StatInfo {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  _StatInfo({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });
}

class _StatCard extends StatelessWidget {
  final _StatInfo stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: isDark ? null : AppTheme.shadowLow,
        border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: stat.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat.icon, color: stat.color, size: 18),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: stat.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    stat.subtitle,
                    style: TextStyle(
                        fontSize: 9,
                        color: stat.color,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  stat.value,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.color),
                ),
              ),
              Text(
                stat.label,
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
