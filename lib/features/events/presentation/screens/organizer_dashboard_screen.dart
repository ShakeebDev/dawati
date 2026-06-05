import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:dawati/features/auth/presentation/providers/auth_provider.dart';
import 'package:dawati/features/events/presentation/providers/event_providers.dart';
import 'package:dawati/core/widgets/theme_toggle_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dawati/core/widgets/responsive_wrapper.dart';

/// لوحة تحكم المنظم المطورة - تصميم خارق بألوان نيون زاهية وجذابة (ألوان كذابة) وواجهات مبسطة
class OrganizerDashboardScreen extends ConsumerWidget {
  const OrganizerDashboardScreen({super.key});

  // باليتة الألوان الزاهية النيونية (الخرافية)
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color neonPink = Color(0xFFEC4899);
  static const Color neonOrange = Color(0xFFF97316);
  static const Color glassWhite = Color(0x0FFFFFFF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final eventsAsync = ref.watch(eventsListProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: _buildDrawer(context, ref, user),
      body: RefreshIndicator(
        color: neonPurple,
        onRefresh: () async {
          ref.invalidate(eventsListProvider);
          return ref.read(eventsListProvider.future);
        },
        child: Stack(
          children: [
            // خلفية فنية مع توهجات نيونية في الخلفية
            if (isDark) ...[
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        neonPurple.withOpacity(0.18),
                        neonPurple.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 250,
                left: -150,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        neonCyan.withOpacity(0.12),
                        neonCyan.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            ResponsiveWrapper(
              useScroll: false,
              padding: EdgeInsets.zero,
              maxWidth: 1200,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // 1. هيدر علوي مخصص وجميل
                  _buildSliverAppBar(context, isDark, theme),

                  // 2. بطاقة الترحيب والإحصائية الكلية (مخطط الحضور النيوني)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                      child: eventsAsync.when(
                        skipLoadingOnRefresh: true,
                        skipLoadingOnReload: true,
                        data: (events) => _buildVibrantOverviewCard(context, events, user, isDark),
                        loading: () => Container(height: 180, decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(24))),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ),
                  ),

                  // 3. أزرار الإجراءات السريعة (تصميم نيون مريح للمس وسهل الاستخدام)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: _buildQuickActionsGrid(context, ref, user, isDark),
                    ),
                  ),

                  // 4. قسم الإحصائيات الأفقية الزجاجية المتوهجة
                  SliverToBoxAdapter(
                    child: eventsAsync.when(
                      skipLoadingOnRefresh: true,
                      skipLoadingOnReload: true,
                      data: (events) {
                        final totalEvents = events.length;
                        final totalGuests = events.fold<int>(
                          0,
                          (sum, event) => sum + (event.totalGuests ?? 0),
                        );
                        final checkedIn = events.fold<int>(
                          0,
                          (sum, event) => sum + (event.checkedInGuests ?? 0),
                        );
                        final remaining = totalGuests - checkedIn;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _DashboardGlowStatCard(
                                title: 'المناسبات النشطة',
                                value: '$totalEvents',
                                icon: Icons.auto_awesome_motion_rounded,
                                glowColor: neonPurple,
                                isDark: isDark,
                              ),
                              _DashboardGlowStatCard(
                                title: 'إجمالي الضيوف',
                                value: '$totalGuests',
                                icon: Icons.people_alt_rounded,
                                glowColor: neonCyan,
                                isDark: isDark,
                              ),
                              _DashboardGlowStatCard(
                                title: 'بانتظار الحضور',
                                value: '${remaining < 0 ? 0 : remaining}',
                                icon: Icons.hourglass_top_rounded,
                                glowColor: neonPink,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const _LoadingStats(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // 5. عنوان قائمة الفعاليات
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            'المناسبات القادمة',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: neonPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'عرض الكل',
                              style: TextStyle(
                                color: neonPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 6. قائمة المناسبات المحسنة والأبسط في المقاسات
                  eventsAsync.when(
                    skipLoadingOnRefresh: true,
                    skipLoadingOnReload: true,
                    data: (events) => events.isEmpty
                        ? const SliverFillRemaining(child: _EmptyState())
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _EnhancedEventCard(
                                  event: events[index],
                                  index: index,
                                  isDark: isDark,
                                ),
                                childCount: events.length,
                              ),
                            ),
                          ),
                    loading: () => const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: neonPurple)),
                    ),
                    error: (err, stack) => SliverFillRemaining(
                      child: Center(child: Text('حدث خطأ: $err')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 90,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Builder(
        builder: (context) => Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.grid_view_rounded,
              color: isDark ? Colors.white : AppTheme.navyPrimary,
              size: 20,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      title: Text(
        'دعوتي الذكية',
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : AppTheme.navyPrimary,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            shape: BoxShape.circle,
          ),
          child: const ThemeToggleButton(),
        ),
      ],
    );
  }

  /// كرت الترحيب التفاعلي الذي يحتوي على نسبة حضور دائرية متوهجة ومظهر نيون رائع
  Widget _buildVibrantOverviewCard(BuildContext context, List<EventModel> events, user, bool isDark) {
    final theme = Theme.of(context);
    final totalGuests = events.fold<int>(0, (sum, event) => sum + (event.totalGuests ?? 0));
    final checkedIn = events.fold<int>(0, (sum, event) => sum + (event.checkedInGuests ?? 0));
    final double percent = totalGuests == 0 ? 0.0 : (checkedIn / totalGuests);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF311042)]
              : [const Color(0xFFEFF6FF), const Color(0xFFFAE8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: neonPurple.withOpacity(isDark ? 0.25 : 0.1),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(
          color: (isDark ? Colors.white : neonPurple).withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: neonPurple.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'لوحة تحكم المنظم',
                    style: TextStyle(
                      color: neonPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'أهلاً بك، ${user?.name.split(' ')[0] ?? "منظمنا"} 👋',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  events.isEmpty 
                      ? 'ابدأ بإنشاء مناسبة جديدة لتصميم بطاقتك'
                      : 'نسبة حضور ضيوفك الإجمالية ممتازة اليوم!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // مؤشر الحضور الدائري النيوني الرائع
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 85,
                height: 85,
                child: CustomPaint(
                  painter: _GlowingProgressPainter(
                    percentage: percent,
                    activeColor: neonPurple,
                    inactiveColor: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppTheme.navyPrimary,
                    ),
                  ),
                  Text(
                    'الحضور',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95));
  }

  /// الإجراءات السريعة بتصميم نيون وبسيط جداً بدون تعقيد
  Widget _buildQuickActionsGrid(BuildContext context, WidgetRef ref, user, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 14),
            child: Text(
              'إجراءات سريعة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 16,
            alignment: WrapAlignment.spaceEvenly,
            children: [
              _QuickActionCircleButton(
                label: 'إضافة مناسبة',
                icon: Icons.add_circle_outline_rounded,
                color: neonPurple,
                onTap: () => context.push('/dashboard/event/create'),
              ),
              _QuickActionCircleButton(
                label: 'ماسح الدخول',
                icon: Icons.qr_code_scanner_rounded,
                color: neonCyan,
                onTap: () {
                  context.push('/scanner');
                },
              ),
              _QuickActionCircleButton(
                label: 'الإعدادات',
                icon: Icons.tune_rounded,
                color: neonOrange,
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      height: 56,
      width: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [neonPurple, neonPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: neonPurple.withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => context.push('/dashboard/event/create'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: Text(
          'مناسبة جديدة',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack);
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                    : [neonPurple, const Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? "U",
                style: const TextStyle(
                  fontSize: 24,
                  color: neonPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: Text(
              user?.name ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user?.email ?? ""),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerTile(
                  icon: Icons.dashboard_rounded,
                  title: 'لوحة التحكم الرئيسية',
                  isSelected: true,
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerTile(
                  icon: Icons.qr_code_scanner_rounded,
                  title: 'ماسح بطاقات الدخول',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/scanner');
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Divider(color: theme.dividerColor.withOpacity(0.1)),
                ),
                _DrawerTile(
                  icon: Icons.settings_rounded,
                  title: 'إعدادات الحساب والمظهر',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/settings');
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('تسجيل الخروج'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.08),
                foregroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// زر إجراء سريع دائري جميل وسهل الضغط
class _QuickActionCircleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCircleButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 78,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isDark ? 0.35 : 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// كرت الإحصائيات الزجاجي المتوهج نيونياً
class _DashboardGlowStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color glowColor;
  final bool isDark;

  const _DashboardGlowStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.glowColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: glowColor.withOpacity(isDark ? 0.18 : 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(isDark ? 0.06 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: glowColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: glowColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppTheme.navyPrimary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}

/// كارت المناسبة المحسن والأبسط بصرياً بمقاسات مريحة
class _EnhancedEventCard extends StatelessWidget {
  final EventModel event;
  final int index;
  final bool isDark;

  const _EnhancedEventCard({
    required this.event,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = event.isToday;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isToday
              ? OrganizerDashboardScreen.neonPurple.withOpacity(0.4)
              : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
          width: isToday ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/dashboard/event/${event.id}'),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: isToday
                          ? const LinearGradient(
                              colors: [OrganizerDashboardScreen.neonPurple, OrganizerDashboardScreen.neonPink],
                            )
                          : null,
                      color: isToday
                          ? null
                          : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF3F4F6)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.celebration_rounded,
                      color: isToday ? Colors.white : OrganizerDashboardScreen.neonPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isToday)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: OrganizerDashboardScreen.neonPink.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.circle, color: OrganizerDashboardScreen.neonPink, size: 8),
                                      SizedBox(width: 4),
                                      Text(
                                        'مباشر اليوم',
                                        style: TextStyle(
                                          color: OrganizerDashboardScreen.neonPink,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          event.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded,
                                size: 13,
                                color: theme.colorScheme.onSurface.withOpacity(0.4)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.45),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.2)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CompactStatItem(
                    label: 'المدعوين',
                    value: '${event.totalGuests}',
                    icon: Icons.people_outline,
                  ),
                  _CompactStatItem(
                    label: 'حضروا',
                    value: '${event.checkedInGuests ?? 0}',
                    icon: Icons.check_circle_outline,
                    color: OrganizerDashboardScreen.neonCyan,
                  ),
                  _ActionIcon(
                    icon: Icons.person_add_alt_1_rounded,
                    onTap: () =>
                        context.push('/dashboard/event/${event.id}/guests/add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 80).ms).slideY(begin: 0.08);
  }
}

class _CompactStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _CompactStatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon,
            size: 15,
            color: color ?? theme.colorScheme.onSurface.withOpacity(0.3)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: OrganizerDashboardScreen.neonPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: OrganizerDashboardScreen.neonPurple,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isSelected
            ? OrganizerDashboardScreen.neonPurple
            : theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? OrganizerDashboardScreen.neonPurple
              : theme.colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
      selected: isSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration_rounded,
              size: 90,
              color: OrganizerDashboardScreen.neonPurple.withOpacity(0.12),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد مناسبات نشطة حالياً',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'ابدأ بإنشاء أول مناسبة لك بكل سهولة',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingStats extends StatelessWidget {
  const _LoadingStats();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(
          2,
          (index) => Container(
            width: 150,
            height: 110,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }
}

/// رسام لرسم مؤشر نسبة مئوية دائري متوهج ومتدرج (خرافي)
class _GlowingProgressPainter extends CustomPainter {
  final double percentage;
  final Color activeColor;
  final Color inactiveColor;

  _GlowingProgressPainter({
    required this.percentage,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. رسم الخلفية الخاملة للمؤشر
    final inactivePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth - 1;
    canvas.drawCircle(center, radius, inactivePaint);

    // 2. رسم القوس الفعال بنظام تدرج نيون متوهج
    final rect = Rect.fromCircle(center: center, radius: radius);
    final activePaint = Paint()
      ..shader = LinearGradient(
        colors: [activeColor, const Color(0xFFEC4899), activeColor],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // توهج خفي خلف المؤشر النشط
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [activeColor.withOpacity(0.5), const Color(0xFFEC4899).withOpacity(0.5)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth + 2
      ..imageFilter = ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3);

    final double sweepAngle = 2 * math.pi * percentage;

    // رسم التوهج أولاً
    if (percentage > 0) {
      canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, glowPaint);
      canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, activePaint);
    }
  }

  @override
  bool shouldRepaint(_GlowingProgressPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}
