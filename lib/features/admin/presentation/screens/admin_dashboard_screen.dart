import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/core/widgets/theme_toggle_button.dart';
import 'package:dawati/core/widgets/responsive_wrapper.dart';
import 'package:dawati/features/auth/presentation/providers/auth_provider.dart';

import '../providers/admin_providers.dart';
import '../widgets/organizer_card.dart';
import '../widgets/audit_log_card.dart';
import '../widgets/plan_card.dart';
import 'package:dawati/core/utils/app_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// لوحة تحكم المدير المستقلة - واجهة إدارة النظام بعيداً عن واجهة المنظم
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedOrganizerFilter = 'all';
  String _selectedLogFilter = 'all';
  bool _isProcessing = false;

  // ألوان لوحة الإدارة
  static const Color adminBlue = Color(0xFF1E40AF);
  static const Color adminIndigo = Color(0xFF4F46E5);
  static const Color adminGold = AppTheme.goldPrimary;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    ref.invalidate(adminOrganizersProvider);
    ref.invalidate(adminAuditLogsProvider);
  }

  Future<void> _updateSubscription(
    String organizerId,
    String planName,
    String status, {
    int? customMaxEvents,
    int? customMaxGuests,
  }) async {
    setState(() => _isProcessing = true);
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase.rpc(
        'update_organizer_subscription',
        params: {
          'p_organizer_id': organizerId,
          'p_plan_name': planName,
          'p_status': status,
          'p_custom_max_events': customMaxEvents,
          'p_custom_max_guests': customMaxGuests,
        },
      );
      final data = response as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;
      final message = data['message'] as String? ?? 'تمت العملية';
      if (mounted) {
        AppUtils.showSnackBar(context, message, isError: !success);
        if (success) _refreshData();
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'حدث خطأ غير متوقع: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _updateAccountStatus(String profileId, String status) async {
    setState(() => _isProcessing = true);
    final supabase = Supabase.instance.client;
    try {
      await supabase
          .from('profiles')
          .update({'status': status}).eq('id', profileId);
      if (mounted) {
        AppUtils.showSnackBar(context, 'تم تحديث حالة الحساب بنجاح');
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'فشل تحديث حالة الحساب: $e',
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _updateUserRole(String profileId, String role) async {
    setState(() => _isProcessing = true);
    final supabase = Supabase.instance.client;
    try {
      await supabase
          .from('profiles')
          .update({'role': role}).eq('id', profileId);
      if (mounted) {
        AppUtils.showSnackBar(context, 'تم تحديث دور المستخدم بنجاح');
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'فشل تحديث دور المستخدم: $e',
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final organizersAsync = ref.watch(adminOrganizersProvider);
    final auditLogsAsync = ref.watch(adminAuditLogsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: _buildAdminDrawer(context, ref, user, isDark),
      body: Stack(
        children: [
          // خلفية الأدمن - لون داكن رسمي
          if (isDark) ...[
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      adminIndigo.withOpacity(0.2),
                      adminIndigo.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 200,
              left: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      adminGold.withOpacity(0.08),
                      adminGold.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],

          Column(
            children: [
              // ── AppBar المخصصة ──
              _buildAdminAppBar(context, isDark, theme),

              // ── محتوى التبويبات ──
              Expanded(
                child: ResponsiveWrapper(
                  useScroll: false,
                  padding: EdgeInsets.zero,
                  maxWidth: 900,
                  child: Stack(
                    children: [
                      TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOrganizersTab(organizersAsync, theme, isDark),
                          _buildPlansTab(),
                          _buildAuditLogsTab(auditLogsAsync, theme),
                        ],
                      ),
                      if (_isProcessing)
                        Container(
                          color: Colors.black45,
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.goldPrimary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// AppBar الخاصة بالمدير
  Widget _buildAdminAppBar(
      BuildContext context, bool isDark, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B)]
              : [adminBlue, adminIndigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: adminIndigo.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── شريط العنوان ──
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu_rounded,
                          color: Colors.white, size: 22),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // شعار وعنوان
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'لوحة إدارة النظام',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'إدارة المنظمين والاشتراكات والرقابة',
                          style: GoogleFonts.cairo(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // زر التحديث
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        color: Colors.white70, size: 20),
                    onPressed: _refreshData,
                    tooltip: 'تحديث',
                  ),
                  // زر تبديل الوضع
                  const ThemeToggleButton(),
                ],
              ),
            ),

            // ── TabBar ──
            TabBar(
              controller: _tabController,
              indicatorColor: adminGold,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  fontFamily: AppTheme.fontFamily),
              tabs: const [
                Tab(
                    text: 'المنظمون والاشتراكات',
                    icon: Icon(Icons.people_alt_rounded, size: 18)),
                Tab(
                    text: 'الخطط والحدود',
                    icon: Icon(Icons.card_membership_rounded, size: 18)),
                Tab(
                    text: 'سجلات الرقابة',
                    icon: Icon(Icons.history_toggle_off_rounded, size: 18)),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  /// القائمة الجانبية للمدير
  Widget _buildAdminDrawer(
      BuildContext context, WidgetRef ref, user, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                    : [adminBlue, adminIndigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'المدير',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: adminGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: adminGold.withOpacity(0.4), width: 1),
                  ),
                  child: Text(
                    '🔑 مدير النظام',
                    style: TextStyle(
                      color: adminGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // قائمة الروابط
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _AdminDrawerTile(
                  icon: Icons.dashboard_rounded,
                  title: 'لوحة التحكم الرئيسية',
                  subtitle: 'إدارة المنظمين والاشتراكات',
                  isSelected: true,
                  onTap: () => Navigator.pop(context),
                ),
                _AdminDrawerTile(
                  icon: Icons.qr_code_scanner_rounded,
                  title: 'ماسح بطاقات الدخول',
                  subtitle: 'مسح QR وتسجيل الحضور',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/scanner');
                  },
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withOpacity(0.06)),
                ),
                _AdminDrawerTile(
                  icon: Icons.settings_rounded,
                  title: 'الإعدادات',
                  subtitle: 'إعدادات الحساب والمظهر',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/settings');
                  },
                ),
              ],
            ),
          ),

          // زر تسجيل الخروج
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('تسجيل الخروج',
                  style: TextStyle(fontFamily: AppTheme.fontFamily)),
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

  // ────────────────────────────────────────────────────
  // تبويب المنظمين والاشتراكات
  // ────────────────────────────────────────────────────
  Widget _buildOrganizersTab(
      AsyncValue<List<Map<String, dynamic>>> asyncVal,
      ThemeData theme,
      bool isDark) {
    return asyncVal.when(
      data: (profiles) {
        final totalOrganizers = profiles.length;

        final proOrganizers = profiles.where((p) {
          final subs = p['subscriptions'] as List<dynamic>? ?? [];
          if (subs.isEmpty) return false;
          final activeSub =
              subs.firstWhere((s) => s['status'] == 'active', orElse: () => null);
          if (activeSub == null) return false;
          final plan = activeSub['plans'] as Map<String, dynamic>?;
          return plan != null && plan['name'] == 'Pro Plan';
        }).length;

        final suspendedCount = profiles
            .where((p) =>
                p['status'] == 'suspended' || p['status'] == 'blocked')
            .length;

        final filtered = profiles.where((p) {
          final name = (p['name'] as String? ?? '').toLowerCase();
          final email = (p['email'] as String? ?? '').toLowerCase();
          final phone = (p['phone'] as String? ?? '').toLowerCase();
          final matchesSearch = name.contains(_searchQuery) ||
              email.contains(_searchQuery) ||
              phone.contains(_searchQuery);
          if (!matchesSearch) return false;

          final status = p['status'] as String? ?? 'active';
          final role = p['role'] as String? ?? 'organizer';
          final subs = p['subscriptions'] as List<dynamic>? ?? [];
          Map<String, dynamic>? activeSub;
          if (subs.isNotEmpty) {
            activeSub =
                subs.firstWhere((s) => s['status'] == 'active', orElse: () => null);
          }
          final plan =
              activeSub != null ? activeSub['plans'] as Map<String, dynamic>? : null;
          final planName = plan != null ? plan['name'] as String? ?? '' : '';

          switch (_selectedOrganizerFilter) {
            case 'active':
              return status == 'active';
            case 'suspended':
              return status == 'suspended' || status == 'blocked';
            case 'pro':
              return planName == 'Pro Plan';
            case 'free':
              return planName == 'Free Plan' || subs.isEmpty;
            case 'admins':
              return role == 'admin';
            default:
              return true;
          }
        }).toList();

        return Column(
          children: [
            // شريط الإحصائيات
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'إجمالي المنظمين',
                      value: totalOrganizers.toString(),
                      colors: [Colors.teal, Colors.teal.shade700],
                      icon: Icons.people_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'مشترك برو',
                      value: proOrganizers.toString(),
                      colors: [Colors.purple, Colors.purple.shade700],
                      icon: Icons.star_border_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'الحسابات المعلقة',
                      value: suspendedCount.toString(),
                      colors: [Colors.orange.shade700, Colors.red.shade700],
                      icon: Icons.block_flipped,
                    ),
                  ),
                ],
              ),
            ),

            // شريط البحث
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'بحث باسم المنظم أو البريد أو الجوال...',
                  hintStyle:
                      TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: theme.cardTheme.color,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // أزرار الفلترة
            Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip(
                      id: 'all', label: 'الكل (${profiles.length})'),
                  _buildFilterChip(id: 'pro', label: 'باقة Pro'),
                  _buildFilterChip(id: 'free', label: 'باقة Free'),
                  _buildFilterChip(id: 'active', label: 'النشطين'),
                  _buildFilterChip(id: 'suspended', label: 'المعلقين'),
                  _buildFilterChip(id: 'admins', label: 'المدراء'),
                ],
              ),
            ),

            // قائمة البطاقات
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'لا يوجد منظمون متطابقون مع الفلتر',
                          style: TextStyle(
                              color: Colors.grey, fontFamily: AppTheme.fontFamily),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(20, 10, 20, 40),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final profile = filtered[index];
                          return OrganizerCard(
                            profile: profile,
                            onUpdateSubscription:
                                (planName, customMaxEvents, customMaxGuests) {
                              _updateSubscription(
                                profile['id'] as String,
                                planName,
                                'active',
                                customMaxEvents: customMaxEvents,
                                customMaxGuests: customMaxGuests,
                              );
                            },
                            onUpdateAccountStatus: (status) {
                              _updateAccountStatus(
                                  profile['id'] as String, status);
                            },
                            onUpdateUserRole: (role) {
                              _updateUserRole(profile['id'] as String, role);
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.goldPrimary)),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('حدث خطأ في تحميل البيانات: $e',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: AppTheme.fontFamily)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required List<Color> colors,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
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
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppTheme.fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: Colors.white70, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 50.ms, duration: 200.ms);
  }

  Widget _buildFilterChip({required String id, required String label}) {
    final isSelected = _selectedOrganizerFilter == id;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
          ),
        ),
        checkmarkColor: Colors.white,
        selectedColor: adminIndigo,
        backgroundColor: theme.cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? adminIndigo
                : theme.dividerColor.withOpacity(0.08),
          ),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedOrganizerFilter = id;
          });
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────
  // تبويب الخطط والحدود
  // ────────────────────────────────────────────────────
  Widget _buildPlansTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        PlanCard(
          title: 'الخطة المجانية (Free Plan)',
          price: 'مجانية للأبد (مناسبة تجريبية)',
          maxEvents: 'مناسبة واحدة فقط (1)',
          maxGuests: '50 ضيف كحد أقصى للمناسبة',
          allowStaff: 'غير مسموح بإضافة موظفي مسح',
          color: AppTheme.goldPrimary,
        ),
        SizedBox(height: 24),
        PlanCard(
          title: 'الخطة الاحترافية (Pro Plan)',
          price: 'اشتراك مدفوع كامل (تنظيم متكامل)',
          maxEvents: 'عدد لا نهائي من المناسبات',
          maxGuests: 'عدد لا نهائي من الضيوف لكل مناسبة',
          allowStaff: 'مسموح بإضافة طاقم موظفي مسح غير محدود',
          color: Colors.purple,
          isPremium: true,
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────
  // تبويب سجلات الرقابة
  // ────────────────────────────────────────────────────
  Widget _buildAuditLogsTab(
      AsyncValue<List<Map<String, dynamic>>> asyncVal, ThemeData theme) {
    return asyncVal.when(
      data: (logs) {
        if (logs.isEmpty) {
          return const Center(
              child: Text('لا توجد سجلات رقابة حالية',
                  style:
                      TextStyle(color: Colors.grey, fontFamily: AppTheme.fontFamily)));
        }

        final filteredLogs = logs.where((log) {
          if (_selectedLogFilter == 'all') return true;
          final action = log['action'] as String? ?? '';
          switch (_selectedLogFilter) {
            case 'subscription':
              return action == 'subscription_updated';
            case 'block':
              return action == 'unauthorized_event_creation';
            case 'rate_limit':
              return action == 'rate_limit_exceeded';
            case 'checkin':
              return action == 'successful_checkin';
            default:
              return true;
          }
        }).toList();

        return Column(
          children: [
            Container(
              height: 48,
              margin: const EdgeInsets.only(top: 20, bottom: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildLogFilterChip(id: 'all', label: 'الكل'),
                  _buildLogFilterChip(
                      id: 'subscription', label: 'الاشتراكات'),
                  _buildLogFilterChip(
                      id: 'block', label: 'المنع والتجاوزات'),
                  _buildLogFilterChip(
                      id: 'rate_limit', label: 'المسح السريع'),
                  _buildLogFilterChip(id: 'checkin', label: 'الدخول'),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: filteredLogs.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد سجلات متطابقة',
                          style: TextStyle(
                              color: Colors.grey, fontFamily: AppTheme.fontFamily),
                        ),
                      )
                    : ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(20, 10, 20, 40),
                        itemCount: filteredLogs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return AuditLogCard(log: filteredLogs[index]);
                        },
                      ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.goldPrimary)),
      error: (e, _) => Center(
          child: Text('حدث خطأ في تحميل السجلات: $e',
              style: TextStyle(fontFamily: AppTheme.fontFamily))),
    );
  }

  Widget _buildLogFilterChip({required String id, required String label}) {
    final isSelected = _selectedLogFilter == id;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
          ),
        ),
        checkmarkColor: Colors.white,
        selectedColor: Colors.blue.shade700,
        backgroundColor: theme.cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? Colors.blue.shade700
                : theme.dividerColor.withOpacity(0.08),
          ),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedLogFilter = id;
          });
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────
// Widget مساعد: عنصر قائمة Drawer للإدمن
// ────────────────────────────────────────────────────
class _AdminDrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _AdminDrawerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selColor = const Color(0xFF4F46E5);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? selColor.withOpacity(isDark ? 0.2 : 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? selColor.withOpacity(0.15)
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.08)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected
                ? selColor
                : (isDark ? Colors.white60 : Colors.grey.shade600),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
            color: isSelected
                ? selColor
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 10,
            color: isDark ? Colors.white38 : Colors.grey.shade500,
          ),
        ),
        onTap: onTap,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
