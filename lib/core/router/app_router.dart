import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:dawati/features/auth/presentation/screens/splash_screen.dart';
import 'package:dawati/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:dawati/features/auth/presentation/screens/login_screen.dart';
import 'package:dawati/features/auth/presentation/screens/register_screen.dart';
import 'package:dawati/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:dawati/features/events/presentation/screens/organizer_dashboard_screen.dart';
import 'package:dawati/features/events/presentation/screens/create_event_screen.dart';
import 'package:dawati/features/events/presentation/screens/event_details_screen.dart';
import 'package:dawati/features/guests/presentation/screens/guests_list_screen.dart';
import 'package:dawati/features/guests/presentation/screens/add_guest_screen.dart';
import 'package:dawati/features/guests/presentation/screens/guest_details_screen.dart';
import 'package:dawati/features/scanner/presentation/pages/scanner_page.dart';
import 'package:dawati/features/scanner/presentation/pages/offline_pending_screen.dart';
import 'package:dawati/features/scanner/presentation/pages/sync_conflict_screen.dart';
import 'package:dawati/features/analytics/presentation/screens/event_analytics_dashboard_screen.dart';
import 'package:dawati/features/invitation/presentation/screens/invitation_builder_screen.dart';
import 'package:dawati/features/invitation/presentation/screens/invitation_preview_screen.dart';
import 'package:dawati/features/invitation/presentation/screens/bulk_send_screen.dart';
import 'package:dawati/features/settings/presentation/screens/settings_screen.dart';
import 'package:dawati/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:dawati/features/auth/presentation/screens/device_trust_screen.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:dawati/core/constants/app_constants.dart';

// SECURITY: استخدام authProvider للتحقق من الـ Role من السيرفر مباشرة
import 'package:dawati/features/auth/presentation/providers/auth_provider.dart';

/// مزود الـ Router مع Role-Based Guards من السيرفر
final goRouterProvider = Provider<GoRouter>((ref) {
  // SECURITY: نستمع لـ Stream المصادقة حتى يُعاد تقييم الـ redirect
  // عند كل تغيير في الـ Auth State (login/logout/suspend)
  final refreshListenable = _AuthRefreshListenable(
    ref.watch(authStateStreamProvider.future).asStream(),
  );

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool(AppConstants.onboardingKey) ?? false;

      // ── السماح بشاشة الـ Splash دائماً ──
      if (state.matchedLocation == '/splash') return null;

      // ── عرض الـ Onboarding إذا لم يكتمل ──
      if (!onboardingDone && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }

      // SECURITY: جلب حالة المصادقة من الـ Server (ليس من Local Cache)
      final authState = ref.read(authProvider);
      final user = authState.user;

      final isAuthRoute = [
        '/login',
        '/register',
        '/role-selection',
        '/onboarding',
      ].contains(state.matchedLocation);

      // ── المستخدم في حالة تحميل ──
      if (authState.isLoading) return null;

      // ── غير مسجل الدخول ──
      if (user == null) {
        return isAuthRoute ? null : '/login';
      }

      // SECURITY: التحقق من حالة الحساب من السيرفر
      // إذا كان موقوفاً يتم تسجيل الخروج تلقائياً
      if (!user.isActive) {
        ref.read(authProvider.notifier).logout();
        return '/login';
      }

      // ── مسجل الدخول ويحاول فتح صفحة تسجيل دخول ──
      if (isAuthRoute || state.matchedLocation == '/login') {
        if (user.isStaff) return '/scanner';
        // SECURITY: المدير يذهب للوحة الإدارة المستقلة، المنظم للداشبورد العادي
        if (user.isAdmin) return '/admin';
        return '/dashboard';
      }

      // SECURITY: توجيه كل من يحتاج التوثيق إلى شاشة الثقة
      // ملاحظة: سنعتمد على شاشة الثقة لفحص نفسها لتجنب التعقيد في الـ Router
      // لكن يمكننا السماح بـ /device-trust للـ Staff أو Admin
      if (state.matchedLocation == '/device-trust') return null;

      // ── SECURITY: Role-Based Route Guards ──
      // Staff لا يمكنه الوصول لأي Route خارج /scanner حتى لو عدّل الـ URL يدوياً
      if (user.isStaff) {
        final allowedPaths = ['/scanner', '/settings'];
        final isAllowed = allowedPaths.any((p) => state.uri.path.startsWith(p));
        if (!isAllowed) return '/scanner';
      }

      // ── SECURITY: Admin Route Guards ──
      // Admin لا يمكنه الوصول لـ /dashboard (لوحة المنظم)
      if (state.uri.path.startsWith('/dashboard') && user.isAdmin) {
        return '/admin';
      }
      // المنظم العادي لا يمكنه الوصول لـ /admin
      if (state.uri.path.startsWith('/admin') && !user.isAdmin) {
        return user.isStaff ? '/scanner' : '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/device-trust',
        builder: (context, state) => const DeviceTrustScreen(),
      ),

      // ── Organizer / Admin Routes ──
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const OrganizerDashboardScreen(),
        routes: [
          GoRoute(
            path: 'event/create',
            builder: (context, state) =>
                CreateEventScreen(event: state.extra as EventModel?),
          ),
          GoRoute(
            path: 'event/:eventId',
            builder: (context, state) =>
                EventDetailsScreen(eventId: state.pathParameters['eventId']!),
            routes: [
              GoRoute(
                path: 'guests',
                builder: (context, state) => GuestsListScreen(
                    eventId: state.pathParameters['eventId']!),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => AddGuestScreen(
                      eventId: state.pathParameters['eventId']!,
                    ),
                  ),
                  GoRoute(
                    path: ':guestId',
                    builder: (context, state) => GuestDetailsScreen(
                      guestId: state.pathParameters['guestId']!,
                      eventId: state.pathParameters['eventId']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'analytics',
                builder: (context, state) {
                  final eventName = state.uri.queryParameters['name'] ?? 'تفاصيل المناسبة';
                  return EventAnalyticsDashboardScreen(
                    eventId: state.pathParameters['eventId']!,
                    eventName: eventName,
                  );
                },
              ),
              GoRoute(
                path: 'invitation',
                builder: (context, state) => InvitationBuilderScreen(
                  eventId: state.pathParameters['eventId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'bulk-send',
                    builder: (context, state) => BulkSendScreen(
                      eventId: state.pathParameters['eventId']!,
                    ),
                  ),
                  GoRoute(
                    path: ':guestId',
                    builder: (context, state) => InvitationPreviewScreen(
                      guestId: state.pathParameters['guestId']!,
                      eventId: state.pathParameters['eventId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Staff Routes ──
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerPage(),
        routes: [
          GoRoute(
            path: 'pending',
            builder: (context, state) => const OfflinePendingScreen(),
          ),
          GoRoute(
            path: 'conflict',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return SyncConflictScreen(
                pendingCheckinId: extra['pendingCheckinId'] ?? '',
                guestId: extra['guestId'] ?? '',
                guestName: extra['guestName'] ?? 'غير معروف',
                conflictReason: extra['conflictReason'] ?? 'غير معروف',
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // ── Admin Routes (منفصلة تماماً عن Organizer) ──
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      // نبقي /admin/panel كـ fallback للتوافق مع الكود القديم
      GoRoute(
        path: '/admin/panel',
        redirect: (context, state) => '/admin',
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('الصفحة غير موجودة: ${state.error}')),
    ),
  );
});

/// Listenable يربط GoRouter بـ Auth Stream لإعادة التقييم عند كل تغيير
class _AuthRefreshListenable extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  _AuthRefreshListenable(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
