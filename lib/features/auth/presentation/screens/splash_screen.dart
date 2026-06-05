import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:dawati/core/constants/app_constants.dart';
import 'package:dawati/core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawati/features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // الحد الأدنى لعرض شاشة البداية هو ثانيتين
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // ننتظر حتى ينتهي الـ authProvider من تحميل الجلسة
      while (ref.read(authProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      if (mounted) {
        // بمجرد انتهاء التحميل، ننتقل. سيقوم الـ Router Guard بتوجيهنا للمكان الصحيح
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navyDark,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.luxuryGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة التطبيق (مؤقتة باستخدام أيقونة Flutter)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.goldPrimary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.goldPrimary.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                size: 80,
                color: AppTheme.goldPrimary,
              ),
            )
                .animate()
                .scale(duration: 800.ms, curve: Curves.easeOutBack)
                .fadeIn(),

            const SizedBox(height: 24),

            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppTheme.goldPrimary,
                    letterSpacing: 2,
                  ),
            ).animate().slideY(begin: 0.5, duration: 600.ms).fadeIn(),

            const SizedBox(height: 8),

            Text(
              AppConstants.appTagline,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 60),

            const CircularProgressIndicator(
              color: AppTheme.goldPrimary,
              strokeWidth: 2,
            ).animate().fadeIn(delay: 1.seconds),
          ],
        ),
      ),
    );
  }
}
