import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/core/theme/theme_provider.dart';
import 'package:dawati/features/auth/presentation/providers/auth_provider.dart';
import 'package:dawati/features/scanner/presentation/providers/gate_provider.dart';
import 'package:dawati/core/widgets/responsive_wrapper.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ResponsiveWrapper(
        useScroll: false,
        padding: EdgeInsets.zero,
        maxWidth: 600,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ملف المستخدم
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: isDark ? null : AppTheme.shadowLow,
                border: isDark
                    ? Border.all(color: theme.dividerColor.withOpacity(0.1))
                    : null,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? "U",
                      style: TextStyle(
                        fontSize: 24,
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? "مستخدم",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          user?.email ?? "",
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.edit_outlined,
                        color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            if (user?.role == 'staff' || user?.isStaff == true) ...[
              _buildSectionTitle(context, 'بوابة المسح الحالية'),
              _buildGateSelectorTile(context, ref),
              const SizedBox(height: 24),
            ],

            _buildSectionTitle(context, 'عام'),
            _buildSettingTile(
              context,
              icon: Icons.notifications_none_rounded,
              title: 'التنبيهات',
              subtitle: 'تخصيص تنبيهات الحضور والفعاليات',
              onTap: () {},
            ),
            _buildSettingTile(
              context,
              icon: Icons.language_rounded,
              title: 'اللغة',
              subtitle: 'العربية',
              onTap: () {},
            ),
            _buildSettingTile(
              context,
              icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              title: 'المظهر الداكن',
              subtitle: isDark ? 'مفعل' : 'غير مفعل',
              trailing: Switch.adaptive(
                value: isDark,
                activeColor: AppTheme.goldPrimary,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                },
              ),
              onTap: () {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),

            const SizedBox(height: 24),
            if (user?.role == 'admin' || user?.isAdmin == true) ...[
              _buildSectionTitle(context, 'الإدارة والتحكم'),
              _buildSettingTile(
                context,
                icon: Icons.admin_panel_settings_rounded,
                title: 'لوحة إدارة النظام',
                subtitle: 'ترقية الاشتراكات ومراقبة المنظمين والسجلات',
                onTap: () => context.push('/admin/panel'),
              ),
              const SizedBox(height: 24),
            ],
            _buildSectionTitle(context, 'الحماية والخصوصية'),
            _buildSettingTile(
              context,
              icon: Icons.lock_outline_rounded,
              title: 'تغيير كلمة المرور',
              onTap: () {},
            ),
            _buildSettingTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'سياسة الخصوصية',
              onTap: () {},
            ),

            const SizedBox(height: 24),
            _buildSectionTitle(context, 'عن التطبيق'),
            _buildSettingTile(
              context,
              icon: Icons.info_outline_rounded,
              title: 'حول دعوتي',
              onTap: () {},
            ),
            _buildSettingTile(
              context,
              icon: Icons.support_agent_rounded,
              title: 'الدعم الفني',
              onTap: () {},
            ),

            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('تسجيل الخروج'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : AppTheme.shadowLow,
        border: isDark
            ? Border.all(color: theme.dividerColor.withOpacity(0.1))
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.5)),
              )
            : null,
        trailing: trailing ??
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: theme.colorScheme.onSurface.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildGateSelectorTile(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentGate = ref.watch(gateProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : AppTheme.shadowLow,
        border: isDark
            ? Border.all(color: theme.dividerColor.withOpacity(0.1))
            : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.goldPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.door_sliding_rounded, color: AppTheme.goldPrimary, size: 20),
        ),
        title: const Text(
          'البوابة الحالية',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          currentGate ?? 'لم يتم تحديد بوابة بعد',
          style: TextStyle(
            fontSize: 12,
            color: currentGate != null ? AppTheme.goldDark : theme.colorScheme.onSurface.withOpacity(0.5),
            fontWeight: currentGate != null ? FontWeight.bold : null,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: theme.colorScheme.onSurface.withOpacity(0.3)),
        onTap: () => _showGateSelectionDialog(context, ref),
      ),
    );
  }

  void _showGateSelectionDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final currentGate = ref.watch(gateProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اختر بوابة الجلسة الحالية',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'سيتم إسناد كافة عمليات المسح القادمة إلى هذه البوابة',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ...kAvailableGates.map((gate) {
                      final isSelected = currentGate == gate;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          gate,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : null,
                            color: isSelected ? AppTheme.goldDark : null,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppTheme.goldPrimary)
                            : null,
                        onTap: () {
                          ref.read(gateProvider.notifier).setGate(gate);
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }
}
