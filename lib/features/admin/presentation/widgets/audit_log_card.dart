import 'package:flutter/material.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/core/utils/app_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuditLogCard extends StatefulWidget {
  final Map<String, dynamic> log;

  const AuditLogCard({
    super.key,
    required this.log,
  });

  @override
  State<AuditLogCard> createState() => _AuditLogCardState();
}

class _AuditLogCardState extends State<AuditLogCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final action = widget.log['action'] as String? ?? 'action';
    final profile = widget.log['profiles'] as Map<String, dynamic>?;
    final userName = profile != null ? profile['name'] as String? ?? 'أدمن/منظم' : 'مجهول';
    
    final date = DateTime.parse(widget.log['created_at'] as String);
    final formattedTime = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final formattedDate = AppUtils.formatDateArabic(date);
    
    Color logColor = Colors.blue;
    String actionLabel = action;
    IconData icon = Icons.info_outline_rounded;
    
    if (action == 'subscription_updated') {
      logColor = Colors.purple;
      actionLabel = 'تحديث باقة اشتراك';
      icon = Icons.card_membership_rounded;
    } else if (action == 'unauthorized_event_creation') {
      logColor = Colors.red;
      actionLabel = 'حظر إنشاء مناسبة (تجاوز)';
      icon = Icons.gpp_bad_rounded;
    } else if (action == 'rate_limit_exceeded') {
      logColor = Colors.orange;
      actionLabel = 'تجاوز حد المسح السريع';
      icon = Icons.speed_rounded;
    } else if (action == 'successful_checkin') {
      logColor = Colors.green;
      actionLabel = 'عملية دخول ناجحة';
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: logColor.withOpacity(0.15)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: logColor.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: logColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: logColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  actionLabel,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: logColor,
                                    fontFamily: AppTheme.fontFamily,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppTheme.fontFamily,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '•',
                                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3)),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                                      fontFamily: AppTheme.fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'المسؤول: $userName',
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.bold,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.log['details'] != null) ...[
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor.withOpacity(0.08),
                          ),
                        ),
                        child: SelectableText(
                          widget.log['details'].toString(),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: isDark ? Colors.teal.shade200 : Colors.teal.shade800,
                          ),
                        ),
                      ),
                    ),
                    crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}
