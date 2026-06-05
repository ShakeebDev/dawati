import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/features/analytics/presentation/providers/analytics_provider.dart';

class LiveFeedTab extends StatelessWidget {
  final String eventId;
  final AnalyticsSummary summary;

  const LiveFeedTab({
    super.key,
    required this.eventId,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final entries = summary.recentEntries;

    if (entries.isEmpty) {
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
              child: Icon(Icons.sensors_off_rounded,
                  size: 44, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد إدخالات بعد',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'ستظهر هنا سجلات الدخول فور بدء فحص QR',
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    return Column(
      children: [
        // شريط الملخص العلوي
        _buildSummaryBar(context),

        // قائمة الإدخالات
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _LiveEntryCard(entry: entry, index: index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : AppTheme.navyPrimary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppTheme.navyPrimary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _SummaryChip(
            icon: Icons.list_alt_rounded,
            label: '${summary.recentEntries.length} إدخال',
            color: AppTheme.navyPrimary,
          ),
          const SizedBox(width: 16),
          if (summary.vipCount > 0) ...[
            _SummaryChip(
              icon: Icons.workspace_premium_rounded,
              label: '${summary.vipCount} VIP',
              color: const Color(0xFF7C3AED),
            ),
            const SizedBox(width: 16),
          ],
          _SummaryChip(
            icon: Icons.percent_rounded,
            label: '${summary.attendanceRate.toStringAsFixed(0)}% حضور',
            color: AppTheme.success,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color),
        ),
      ],
    );
  }
}

class _LiveEntryCard extends StatelessWidget {
  final LiveEntry entry;
  final int index;

  const _LiveEntryCard({required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    final isVip = entry.isVip;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color accentColor = isVip
        ? const Color(0xFF7C3AED)
        : index == 0
            ? AppTheme.success
            : AppTheme.navyPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVip
            ? const Color(0xFF7C3AED).withOpacity(0.06)
            : index == 0
                ? AppTheme.success.withOpacity(0.04)
                : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVip
              ? const Color(0xFF7C3AED).withOpacity(0.3)
              : index == 0
                  ? AppTheme.success.withOpacity(0.25)
                  : theme.dividerColor.withOpacity(0.08),
          width: isVip || index == 0 ? 1.5 : 1,
        ),
        boxShadow: isVip
            ? [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : index == 0
                ? [
                    BoxShadow(
                      color: AppTheme.success.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
      ),
      child: Row(
        children: [
          // الرقم / الأيقونة
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(isVip || index == 0 ? 0.15 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isVip
                  ? Icon(Icons.star_rounded,
                      color: Colors.amber.shade400, size: 20)
                  : index == 0
                      ? Icon(Icons.check_circle_rounded,
                          color: AppTheme.success, size: 20)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: accentColor.withOpacity(0.7)),
                        ),
            ),
          ),
          const SizedBox(width: 14),

          // الاسم والتفاصيل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.guestName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isVip ? const Color(0xFF7C3AED) : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isVip) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0xFFFFD700),
                            Color(0xFFFFA500),
                          ]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'VIP',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ],
                    if (index == 0 && !isVip) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'آخر دخول',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.success),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  runSpacing: 2,
                  children: [
                    if (entry.gateName != null)
                      _InfoBadge(
                        icon: Icons.door_sliding_outlined,
                        label: entry.gateName!,
                        color: Colors.teal,
                      ),
                    if (entry.scannedByName != null)
                      _InfoBadge(
                        icon: Icons.badge_outlined,
                        label: entry.scannedByName!,
                        color: Colors.blueGrey,
                      ),
                  ],
                ),
              ],
            ),
          ),

          // الوقت
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(entry.checkedInAt),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: accentColor,
                ),
              ),
              Text(
                _formatDate(entry.checkedInAt),
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 25).ms).slideX(begin: 0.05, end: 0);
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}';
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
