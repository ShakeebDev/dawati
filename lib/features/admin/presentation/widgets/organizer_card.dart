import 'package:flutter/material.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/core/utils/app_utils.dart';
import 'subscription_upgrade_dialog.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OrganizerCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final Function(String planName, int? customMaxEvents, int? customMaxGuests) onUpdateSubscription;
  final Function(String status) onUpdateAccountStatus;
  final Function(String role) onUpdateUserRole;

  const OrganizerCard({
    super.key,
    required this.profile,
    required this.onUpdateSubscription,
    required this.onUpdateAccountStatus,
    required this.onUpdateUserRole,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final subs = profile['subscriptions'] as List<dynamic>? ?? [];
    
    // البحث عن الاشتراك النشط
    Map<String, dynamic>? activeSub;
    if (subs.isNotEmpty) {
      activeSub = subs.firstWhere(
        (s) => s['status'] == 'active',
        orElse: () => subs.first,
      ) as Map<String, dynamic>?;
    }
    
    final plan = activeSub != null ? activeSub['plans'] as Map<String, dynamic>? : null;
    final planName = plan != null ? plan['name'] as String : 'بدون باقة';
    final currentCustomMaxEvents = activeSub != null ? activeSub['custom_max_events'] as int? : null;
    final currentCustomMaxGuests = activeSub != null ? activeSub['custom_max_guests'] as int? : null;
    
    final accStatus = profile['status'] as String? ?? 'active';
    final role = profile['role'] as String? ?? 'staff';

    // الألوان للبادجات
    Color planColor = planName == 'Pro Plan' ? Colors.purple : AppTheme.goldPrimary;
    Color statusColor = accStatus == 'active'
        ? Colors.green
        : (accStatus == 'suspended' ? Colors.orange : Colors.red);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? null : AppTheme.shadowLow,
        border: Border.all(
          color: theme.dividerColor.withOpacity(isDark ? 0.12 : 0.06),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: Hero(
              tag: 'avatar-${profile['id']}',
              child: CircleAvatar(
                radius: 22,
                backgroundColor: planColor.withOpacity(0.1),
                child: Text(
                  (profile['name'] as String? ?? 'U').substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: planColor, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 14,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ),
            ),
            title: Text(
              profile['name'] as String? ?? 'منظم غير معروف',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 14,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  profile['email'] as String? ?? '', 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11, 
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: planColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: planColor.withOpacity(0.15)),
                      ),
                      child: Text(
                        planName,
                        style: TextStyle(
                          color: planColor, 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        accStatus == 'active' ? 'نشط' : (accStatus == 'suspended' ? 'موقوف' : 'محظور'),
                        style: TextStyle(
                          color: statusColor, 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                    ),
                    if (role == 'admin')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'مدير للنظام',
                          style: TextStyle(
                            color: Colors.red, 
                            fontSize: 10, 
                            fontWeight: FontWeight.bold,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: theme.dividerColor.withOpacity(0.08)),
                    const SizedBox(height: 8),
                    if (profile['phone'] != null && (profile['phone'] as String).isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.phone_iphone_rounded, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'الجوال: ${profile['phone']}', 
                              style: TextStyle(fontSize: 13, fontFamily: AppTheme.fontFamily),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تاريخ التسجيل: ${AppUtils.formatDateArabic(DateTime.parse(profile['created_at'] as String))}',
                            style: TextStyle(
                              fontSize: 13, 
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (currentCustomMaxEvents != null || currentCustomMaxGuests != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.settings_suggest_rounded, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'حدود مخصصة: '
                              '${currentCustomMaxEvents != null ? "المناسبات ($currentCustomMaxEvents)" : ""}'
                              '${currentCustomMaxEvents != null && currentCustomMaxGuests != null ? " | " : ""}'
                              '${currentCustomMaxGuests != null ? "الضيوف ($currentCustomMaxGuests)" : ""}',
                              style: TextStyle(
                                fontSize: 13, 
                                color: Colors.blue, 
                                fontWeight: FontWeight.bold, 
                                fontFamily: AppTheme.fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'إجراءات التحكم السريع:', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // ترقية الاشتراك
                        ActionChip(
                          avatar: const Icon(Icons.upgrade_rounded, size: 16, color: Colors.white),
                          backgroundColor: Colors.purple,
                          label: const Text(
                            'ترقية لـ Pro Plan', 
                            style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: AppTheme.fontFamily),
                          ),
                          onPressed: () => _openUpgradeDialog(context, 'Pro Plan', currentCustomMaxEvents, currentCustomMaxGuests),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.money_off_rounded, size: 16),
                          label: const Text(
                            'إرجاع لـ Free Plan', 
                            style: TextStyle(fontSize: 12, fontFamily: AppTheme.fontFamily),
                          ),
                          onPressed: () => _openUpgradeDialog(context, 'Free Plan', currentCustomMaxEvents, currentCustomMaxGuests),
                        ),
                        // إيقاف وتفعيل الحساب
                        if (accStatus == 'active')
                          ActionChip(
                            avatar: const Icon(Icons.block_rounded, size: 16, color: Colors.white),
                            backgroundColor: Colors.orange.shade700,
                            label: const Text(
                              'تعليق الحساب', 
                              style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: AppTheme.fontFamily),
                            ),
                            onPressed: () => onUpdateAccountStatus('suspended'),
                          )
                        else
                          ActionChip(
                            avatar: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white),
                            backgroundColor: Colors.green.shade700,
                            label: const Text(
                              'تفعيل الحساب', 
                              style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: AppTheme.fontFamily),
                            ),
                            onPressed: () => onUpdateAccountStatus('active'),
                          ),
                        // تبديل الدور لـ Admin
                        if (role != 'admin')
                          ActionChip(
                            avatar: const Icon(Icons.admin_panel_settings_rounded, size: 16),
                            label: const Text(
                              'منح رتبة مدير', 
                              style: TextStyle(fontSize: 12, fontFamily: AppTheme.fontFamily),
                            ),
                            onPressed: () => onUpdateUserRole('admin'),
                          )
                        else
                          ActionChip(
                            avatar: const Icon(Icons.person_remove_rounded, size: 16),
                            label: const Text(
                              'إلغاء رتبة مدير', 
                              style: TextStyle(fontSize: 12, fontFamily: AppTheme.fontFamily),
                            ),
                            onPressed: () => onUpdateUserRole('organizer'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  void _openUpgradeDialog(
    BuildContext context, 
    String plan, 
    int? currentEvents, 
    int? currentGuests,
  ) {
    showDialog(
      context: context,
      builder: (context) => SubscriptionUpgradeDialog(
        planName: plan,
        currentCustomEvents: currentEvents,
        currentCustomGuests: currentGuests,
        onConfirm: (customEvents, customGuests) {
          onUpdateSubscription(plan, customEvents, customGuests);
        },
      ),
    );
  }
}
