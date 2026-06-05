import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/features/analytics/presentation/providers/analytics_provider.dart';

class GatesTab extends StatelessWidget {
  final AnalyticsSummary summary;

  const GatesTab({super.key, required this.summary});

  static const List<Color> _gateColors = [
    AppTheme.goldPrimary,
    AppTheme.navyPrimary,
    AppTheme.success,
    Color(0xFFEA580C),
    Color(0xFF7C3AED),
    Color(0xFF0891B2),
  ];

  @override
  Widget build(BuildContext context) {
    if (summary.gateStats.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.door_sliding_rounded,
                  size: 44, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد بيانات بوابات بعد',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'ستظهر هنا إحصائيات البوابات بعد بدء الفحص',
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    final total = summary.checkedIn;
    final maxCount = summary.gateStats
        .map((g) => g.count)
        .reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
      children: [
        // رأس القسم
        _buildHeader(context),
        const SizedBox(height: 20),

        // مخطط الدائرة إذا كان هناك أكثر من بوابة
        if (summary.gateStats.length > 1) ...[
          _buildPieChart(context),
          const SizedBox(height: 24),
        ],

        // بطاقات البوابات
        ...summary.gateStats.asMap().entries.map((entry) {
          final i = entry.key;
          final gate = entry.value;
          final pct = total == 0 ? 0.0 : gate.count / total;
          final barPct = maxCount == 0 ? 0.0 : gate.count / maxCount;
          final color = _gateColors[i % _gateColors.length];

          return _GateCard(
            gate: gate,
            percentage: pct,
            barPercentage: barPct,
            rank: i + 1,
            delay: i * 80,
            color: color,
          );
        }),

        const SizedBox(height: 24),

        // تحليل توازن الحمل
        _buildLoadAnalysis(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.goldPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.door_sliding_rounded,
              color: AppTheme.goldPrimary, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائيات البوابات',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '${summary.gateStats.length} ${summary.gateStats.length == 1 ? 'بوابة' : 'بوابات'} • ${summary.checkedIn} إجمالي',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildPieChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sections = summary.gateStats.asMap().entries.map((entry) {
      final i = entry.key;
      final gate = entry.value;
      final color = _gateColors[i % _gateColors.length];
      return PieChartSectionData(
        value: gate.count.toDouble(),
        color: color,
        radius: 55,
        title: gate.count > 0 ? '${gate.count}' : '',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: isDark ? null : AppTheme.shadowLow,
        border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                startDegreeOffset: -90,
                sections: sections,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: summary.gateStats.asMap().entries.map((entry) {
                final i = entry.key;
                final gate = entry.value;
                final color = _gateColors[i % _gateColors.length];
                final pct = summary.checkedIn == 0
                    ? 0.0
                    : gate.count / summary.checkedIn * 100;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          gate.gateName,
                          style: const TextStyle(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildLoadAnalysis(BuildContext context) {
    if (summary.gateStats.length < 2) return const SizedBox.shrink();

    final max = summary.gateStats.first;
    final min = summary.gateStats.last;
    final diff = max.count - min.count;
    final isBalanced = diff <= 5 ||
        (max.count > 0 && diff / max.count < 0.3);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBalanced
              ? [AppTheme.success.withOpacity(0.06), Colors.transparent]
              : [Colors.orange.withOpacity(0.06), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isBalanced
              ? AppTheme.success.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isBalanced
                  ? AppTheme.success.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBalanced
                  ? Icons.balance_rounded
                  : Icons.warning_amber_rounded,
              color: isBalanced ? AppTheme.success : Colors.orange,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBalanced
                      ? 'توزيع متوازن على البوابات ✓'
                      : 'تفاوت في الحمل بين البوابات',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isBalanced ? AppTheme.success : Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isBalanced
                      ? 'الإدخالات موزعة بشكل جيد، الفارق $diff ضيف فقط.'
                      : 'بوابة "${max.gateName}" أكثر ضغطاً بفارق $diff ضيف عن "${min.gateName}".',
                  style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
                ),
                if (!isBalanced) ...[
                  const SizedBox(height: 8),
                  Text(
                    '💡 يُنصح بتوجيه بعض الضيوف إلى "${min.gateName}" لتخفيف الضغط',
                    style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 11,
                        height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

// ─── Gate Card ─────────────────────────────────────────────────────────────

class _GateCard extends StatelessWidget {
  final GateStat gate;
  final double percentage;
  final double barPercentage;
  final int rank;
  final int delay;
  final Color color;

  const _GateCard({
    required this.gate,
    required this.percentage,
    required this.barPercentage,
    required this.rank,
    required this.delay,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isTop = rank == 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: isTop
            ? [
                BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ]
            : isDark
                ? null
                : AppTheme.shadowLow,
        border: Border.all(
            color: isTop
                ? color.withOpacity(0.3)
                : Theme.of(context).dividerColor.withOpacity(0.08),
            width: isTop ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // رتبة البوابة
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: isTop
                      ? Border.all(color: color.withOpacity(0.4), width: 1.5)
                      : null,
                ),
                child: Center(
                  child: isTop
                      ? Icon(Icons.emoji_events_rounded, color: color, size: 20)
                      : Text(
                          '$rank',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            gate.gateName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isTop) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'الأكثر نشاطاً',
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${gate.count} ضيف دخل',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // النسبة
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(percentage * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Text(
                    'من الإجمالي',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // شريط التقدم مع أنيميشن
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: barPercentage.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: isDark
                    ? Colors.white10
                    : Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // معلومات إضافية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${gate.count} من ${(gate.count / (percentage == 0 ? 1 : percentage)).round()} ضيف',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
              Text(
                '${(barPercentage * 100).toStringAsFixed(0)}% من الأقصى',
                style: TextStyle(fontSize: 10, color: color.withOpacity(0.7)),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }
}
