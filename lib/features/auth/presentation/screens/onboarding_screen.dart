import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dawati/core/constants/app_constants.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'تنظيم ذكي لمناسباتك',
      description:
          'قم بإنشاء وإدارة مناسباتك بكل سهولة واحترافية من مكان واحد.',
      icon: Icons.event_available_rounded,
    ),
    OnboardingItem(
      title: 'دعوات رقمية فاخرة',
      description: 'صمم دعواتك الخاصة وأرسلها لضيوفك عبر الواتساب برمز QR آمن.',
      icon: Icons.qr_code_2_rounded,
    ),
    OnboardingItem(
      title: 'دخول سريع وآمن',
      description: 'مسح سريع للدعوات عند البوابة مع إحصائيات فورية للحضور.',
      icon: Icons.verified_user_rounded,
    ),
  ];

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingKey, true);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final isSmallScreen = availableHeight < 600;

            return Column(
              children: [
                // صفحات السلايدر تأخذ المساحة المتاحة
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _items.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      return _buildPage(_items[index], isSmallScreen);
                    },
                  ),
                ),

                // قسم التنقل والأزرار ثابت في الأسفل
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // نقاط التقدم
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _items.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppTheme.goldPrimary
                                  : Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 28),

                      // زر التالي / ابدأ
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          ),
                          onPressed: () {
                            if (_currentPage < _items.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _finishOnboarding();
                            }
                          },
                          child: Text(_currentPage == _items.length - 1
                              ? 'ابدأ الآن'
                              : 'التالي'),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          'تخطي',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item, bool isSmallScreen) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 20 : 30),
              decoration: BoxDecoration(
                color: AppTheme.goldPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                size: isSmallScreen ? 70 : 100,
                color: AppTheme.goldPrimary,
              ),
            ).animate().scale(duration: 600.ms),
            SizedBox(height: isSmallScreen ? 24 : 40),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 22 : null,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              item.description,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  OnboardingItem(
      {required this.title, required this.description, required this.icon});
}
