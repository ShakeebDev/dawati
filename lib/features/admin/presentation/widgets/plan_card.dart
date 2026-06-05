import 'package:flutter/material.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String maxEvents;
  final String maxGuests;
  final String allowStaff;
  final Color color;
  final bool isPremium;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.maxEvents,
    required this.maxGuests,
    required this.allowStaff,
    required this.color,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPremium ? color : theme.dividerColor.withOpacity(0.08),
          width: isPremium ? 2.0 : 1.0,
        ),
        boxShadow: isPremium
            ? [
                BoxShadow(
                  color: color.withOpacity(isDark ? 0.08 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                )
              ]
            : (isDark ? [] : AppTheme.shadowLow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color,
                    fontFamily: AppTheme.fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isPremium) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'موصى به',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            price,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          const Divider(height: 32),
          _buildPlanRuleRow(Icons.event_available_rounded, 'حد المناسبات:', maxEvents, theme),
          const SizedBox(height: 14),
          _buildPlanRuleRow(Icons.people_alt_outlined, 'الضيوف لكل مناسبة:', maxGuests, theme),
          const SizedBox(height: 14),
          _buildPlanRuleRow(Icons.no_accounts_outlined, 'طاقم بوابات وموظفين:', allowStaff, theme),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPlanRuleRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 13,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ),
      ],
    );
  }
}
