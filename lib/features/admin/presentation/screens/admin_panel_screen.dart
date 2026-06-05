import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/core/utils/app_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dawati/core/widgets/responsive_wrapper.dart';

import '../providers/admin_providers.dart';
import '../widgets/organizer_card.dart';
import '../widgets/audit_log_card.dart';
import '../widgets/plan_card.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  
  // فلاتر التصفية للمنظمين
  String _searchQuery = '';
  String _selectedOrganizerFilter = 'all'; // all, active, suspended, pro, free, admins
  
  // فلاتر التصفية للسجلات
  String _selectedLogFilter = 'all'; // all, subscription, block, rate_limit, checkin

  bool _isProcessing = false;

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

  /// تنفيذ ترقية الاشتراك عبر الـ RPC الآمن
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
        if (success) {
          _refreshData();
        }
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'حدث خطأ غير متوقع: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// تحديث حالة الحساب (نشط، موقوف، محظور)
  Future<void> _updateAccountStatus(String profileId, String status) async {
    setState(() => _isProcessing = true);
    final supabase = Supabase.instance.client;
    
    try {
      await supabase
          .from('profiles')
          .update({'status': status})
          .eq('id', profileId);
          
      if (mounted) {
        AppUtils.showSnackBar(context, 'تم تحديث حالة الحساب بنجاح');
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'فشل تحديث حالة الحساب: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// تحديث دور المستخدم (أدمن، منظم، موظف)
  Future<void> _updateUserRole(String profileId, String role) async {
    setState(() => _isProcessing = true);
    final supabase = Supabase.instance.client;
    
    try {
      await supabase
          .from('profiles')
          .update({'role': role})
          .eq('id', profileId);
          
      if (mounted) {
        AppUtils.showSnackBar(context, 'تم تحديث دور المستخدم بنجاح');
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'فشل تحديث دور المستخدم: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final organizersAsync = ref.watch(adminOrganizersProvider);
    final auditLogsAsync = ref.watch(adminAuditLogsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'لوحة إدارة النظام والاشتراكات',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshData,
            tooltip: 'تحديث البيانات',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.goldPrimary,
          indicatorWeight: 3,
          labelColor: isDark ? Colors.white : AppTheme.navyPrimary,
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: AppTheme.fontFamily),
          tabs: const [
            Tab(text: 'المنظمين والاشتراكات', icon: Icon(Icons.people_alt_rounded, size: 18)),
            Tab(text: 'الخطط والحدود', icon: Icon(Icons.card_membership_rounded, size: 18)),
            Tab(text: 'سجلات الرقابة', icon: Icon(Icons.history_toggle_off_rounded, size: 18)),
          ],
        ),
      ),
      body: ResponsiveWrapper(
        useScroll: false,
        padding: EdgeInsets.zero,
        maxWidth: 900,
        child: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                // التبويب الأول: المنظمين والاشتراكات
                _buildOrganizersTab(organizersAsync),
                
                // التبويب الثاني: تفاصيل الباقات الافتراضية
                _buildPlansTab(),
                
                // التبويب الثالث: سجلات النظام الرقابية
                _buildAuditLogsTab(auditLogsAsync),
              ],
            ),
            
            if (_isProcessing)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(color: AppTheme.goldPrimary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // تبويب المنظمين والاشتراكات
  // ----------------------------------------------------
  Widget _buildOrganizersTab(AsyncValue<List<Map<String, dynamic>>> asyncVal) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return asyncVal.when(
      data: (profiles) {
        // حساب الإحصائيات البرمجية بشكل تفاعلي
        final totalOrganizers = profiles.length;
        
        final proOrganizers = profiles.where((p) {
          final subs = p['subscriptions'] as List<dynamic>? ?? [];
          if (subs.isEmpty) return false;
          final activeSub = subs.firstWhere((s) => s['status'] == 'active', orElse: () => null);
          if (activeSub == null) return false;
          final plan = activeSub['plans'] as Map<String, dynamic>?;
          return plan != null && plan['name'] == 'Pro Plan';
        }).length;
        
        final suspendedCount = profiles.where((p) => p['status'] == 'suspended' || p['status'] == 'blocked').length;

        // تصفية القائمة بناءً على خيارات البحث والفلترة الذكية
        final filtered = profiles.where((p) {
          // 1. تصفية بالبحث النصي
          final name = (p['name'] as String? ?? '').toLowerCase();
          final email = (p['email'] as String? ?? '').toLowerCase();
          final phone = (p['phone'] as String? ?? '').toLowerCase();
          final matchesSearch = name.contains(_searchQuery) ||
                 email.contains(_searchQuery) ||
                 phone.contains(_searchQuery);
                 
          if (!matchesSearch) return false;

          // 2. تصفية بالفلتر المحدد
          final status = p['status'] as String? ?? 'active';
          final role = p['role'] as String? ?? 'organizer';
          
          final subs = p['subscriptions'] as List<dynamic>? ?? [];
          Map<String, dynamic>? activeSub;
          if (subs.isNotEmpty) {
            activeSub = subs.firstWhere((s) => s['status'] == 'active', orElse: () => null);
          }
          final plan = activeSub != null ? activeSub['plans'] as Map<String, dynamic>? : null;
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
            // شريط الإحصائيات العلوي الأنيق
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
                      title: 'مشترك برو (Pro)',
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

            // شريط البحث المطور
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'بحث باسم المنظم أو البريد أو الجوال...',
                  hintStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: theme.cardTheme.color,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // أزرار الفلترة الأفقية التفاعلية
            Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip(id: 'all', label: 'الكل (${profiles.length})'),
                  _buildFilterChip(id: 'pro', label: 'باقة برو (Pro)'),
                  _buildFilterChip(id: 'free', label: 'باقة فري (Free)'),
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
                          'لا يوجد منظمين متطابقين مع الفلتر الحالي',
                          style: TextStyle(color: Colors.grey, fontFamily: AppTheme.fontFamily),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final profile = filtered[index];
                          return OrganizerCard(
                            profile: profile,
                            onUpdateSubscription: (planName, customMaxEvents, customMaxGuests) {
                              _updateSubscription(
                                profile['id'] as String,
                                planName,
                                'active',
                                customMaxEvents: customMaxEvents,
                                customMaxGuests: customMaxGuests,
                              );
                            },
                            onUpdateAccountStatus: (status) {
                              _updateAccountStatus(profile['id'] as String, status);
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
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.goldPrimary)),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('حدث خطأ في تحميل البيانات: $e', textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTheme.fontFamily)),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            color: colors.first.withOpacity(isDark ? 0.15 : 0.25),
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
            color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
          ),
        ),
        checkmarkColor: Colors.white,
        selectedColor: AppTheme.goldPrimary,
        backgroundColor: theme.cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppTheme.goldPrimary : theme.dividerColor.withOpacity(0.08),
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

  // ----------------------------------------------------
  // تبويب الباقات الافتراضية
  // ----------------------------------------------------
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

  // ----------------------------------------------------
  // تبويب سجلات النظام والرقابة
  // ----------------------------------------------------
  Widget _buildAuditLogsTab(AsyncValue<List<Map<String, dynamic>>> asyncVal) {
    final theme = Theme.of(context);
    
    return asyncVal.when(
      data: (logs) {
        if (logs.isEmpty) {
          return const Center(child: Text('لا توجد سجلات رقابة حالية في النظام', style: TextStyle(color: Colors.grey, fontFamily: AppTheme.fontFamily)));
        }

        // تصفية السجلات بناءً على زر الفلترة المحدد
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
            // أزرار تصفية السجلات الأفقية
            Container(
              height: 48,
              margin: const EdgeInsets.only(top: 20, bottom: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildLogFilterChip(id: 'all', label: 'الكل'),
                  _buildLogFilterChip(id: 'subscription', label: 'الاشتراكات'),
                  _buildLogFilterChip(id: 'block', label: 'المنع والتجاوزات'),
                  _buildLogFilterChip(id: 'rate_limit', label: 'المسح السريع'),
                  _buildLogFilterChip(id: 'checkin', label: 'الدخول'),
                ],
              ),
            ),
            
            // قائمة السجلات
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: filteredLogs.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد سجلات متطابقة مع الفلتر',
                          style: TextStyle(color: Colors.grey, fontFamily: AppTheme.fontFamily),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                        itemCount: filteredLogs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];
                          return AuditLogCard(log: log);
                        },
                      ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.goldPrimary)),
      error: (e, _) => Center(child: Text('حدث خطأ في تحميل السجلات: $e', style: TextStyle(fontFamily: AppTheme.fontFamily))),
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
            color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7),
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
            color: isSelected ? Colors.blue.shade700 : theme.dividerColor.withOpacity(0.08),
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
