import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/core/constants/app_constants.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _selectRole(BuildContext context, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userRoleKey, role);

    if (!context.mounted) return;

    if (role == AppConstants.roleOrganizer) {
      context.go('/dashboard');
    } else {
      context.go('/scanner');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.luxuryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars, color: AppTheme.goldPrimary, size: 80),
                    const SizedBox(height: 32),
                    Text(
                      'مرحباً بك في دعوتي',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.goldPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'يرجى اختيار طبيعة استخدامك للتطبيق',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    _RoleCard(
                      title: 'منظم مناسبات',
                      description: 'إنشاء المناسبات، إدارة الضيوف، والتحليلات',
                      icon: Icons.event_available,
                      onTap: () => _selectRole(context, AppConstants.roleOrganizer),
                    ),
                    const SizedBox(height: 20),
                    _RoleCard(
                      title: 'موظف استقبال',
                      description: 'مسح رموز QR والتحقق من دخول الضيوف',
                      icon: Icons.qr_code_scanner,
                      onTap: () => _selectRole(context, AppConstants.roleStaff),
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
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: AppTheme.goldPrimary.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.goldPrimary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.goldPrimary, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.goldPrimary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
