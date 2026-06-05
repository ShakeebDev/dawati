import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/features/events/presentation/providers/event_providers.dart';
import 'package:dawati/features/events/data/repositories/event_repository.dart';
import 'package:dawati/core/errors/failures.dart';
import 'package:dawati/core/utils/app_utils.dart';
import 'package:dawati/core/widgets/responsive_wrapper.dart';

class EventDetailsScreen extends ConsumerWidget {
  final String eventId;
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailsProvider(eventId));

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(eventDetailsProvider(eventId));
          return ref.read(eventDetailsProvider(eventId).future);
        },
        child: eventAsync.when(
          data: (event) {
            if (event == null) {
              return const Center(child: Text('المناسبة غير موجودة'));
            }
            return ResponsiveWrapper(
              useScroll: false,
              padding: EdgeInsets.zero,
              maxWidth: 750,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildAppBar(context, event, ref),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildStatsGrid(event),
                          const SizedBox(height: 24),
                          _buildActionGrid(context, event),
                          const SizedBox(height: 24),
                          _buildEventInfo(context, event),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('حدث خطأ أثناء جلب التفاصيل: $err',
                  textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المناسبة'),
        content: const Text(
            'هل أنت متأكد من حذف هذه المناسبة؟ سيتم حذف جميع الضيوف المرتبطين بها نهائياً.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result =
          await ref.read(eventRepositoryProvider).deleteEvent(eventId);
      if (result is Success) {
        ref.invalidate(eventsListProvider);
        if (context.mounted) {
          context.pop();
          AppUtils.showSnackBar(context, 'تم حذف المناسبة بنجاح');
        }
      } else {
        if (context.mounted) {
          AppUtils.showSnackBar(context, 'فشل حذف المناسبة', isError: true);
        }
      }
    }
  }

  Widget _buildAppBar(BuildContext context, event, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor:
          isDark ? theme.scaffoldBackgroundColor : AppTheme.navyPrimary,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
          onPressed: () =>
              context.push('/dashboard/event/create', extra: event),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          onPressed: () => _confirmDelete(context, ref, event),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        title: Text(
          event.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: isDark ? null : AppTheme.luxuryGradient,
                color: isDark ? theme.scaffoldBackgroundColor : null,
              ),
            ),
            // نمنمة أو زخرفة في الخلفية
            Positioned(
              right: -30,
              top: -30,
              child: Icon(
                Icons.celebration_rounded,
                size: 200,
                color: AppTheme.goldPrimary.withOpacity(0.05),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 60,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.goldPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppTheme.goldPrimary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppTheme.goldPrimary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      event.entryType == 'single' ? 'دخول لمرة' : 'دخول متعدد',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(event) {
    return Row(
      children: [
        _StatItem(
          label: 'الضيوف',
          value: '${event.totalGuests ?? 0}',
          icon: Icons.group,
          color: AppTheme.navyPrimary,
        ),
        const SizedBox(width: 12),
        _StatItem(
          label: 'حضروا',
          value: '${event.checkedInGuests ?? 0}',
          icon: Icons.check_circle,
          color: AppTheme.success,
        ),
        const SizedBox(width: 12),
        _StatItem(
          label: 'متبقي',
          value: '${event.remainingGuests}',
          icon: Icons.hourglass_empty,
          color: AppTheme.goldPrimary,
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildActionGrid(BuildContext context, event) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإجراءات السريعة',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _ActionCard(
              title: 'إدارة الضيوف',
              subtitle: 'إضافة وتعديل',
              icon: Icons.people_outline_rounded,
              color: AppTheme.goldDark,
              onTap: () => context.push('/dashboard/event/${event.id}/guests'),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
            _ActionCard(
              title: 'بطاقة الدعوة',
              subtitle: 'تصميم ومشاركة',
              icon: Icons.qr_code_2_rounded,
              color: AppTheme.navyPrimary,
              onTap: () =>
                  context.push('/dashboard/event/${event.id}/invitation'),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2),
            _ActionCard(
              title: 'التحليل',
              subtitle: 'إحصائيات الحضور',
              icon: Icons.analytics_outlined,
              color: AppTheme.info,
              onTap: () =>
                  context.push(Uri(path: '/dashboard/event/${event.id}/analytics', queryParameters: {'name': event.name}).toString()),
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
            _ActionCard(
              title: 'موظفو الاستقبال',
              subtitle: 'إضافة وإدارة الطاقم',
              icon: Icons.badge_outlined,
              color: Colors.teal,
              onTap: () => _showManageStaffDialog(context, event.id),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
            _ActionCard(
              title: 'الإعدادات',
              subtitle: 'تعديل البيانات',
              icon: Icons.settings_suggest_outlined,
              color: Colors.grey[700]!,
              onTap: () {},
            ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
          ],
        ),
      ],
    );
  }

  Widget _buildEventInfo(BuildContext context, event) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'الموقع',
            value: event.location,
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: Icons.calendar_month_outlined,
            label: 'التاريخ',
            value: event.date.toString().split(' ')[0],
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: Icons.door_front_door_outlined,
            label: 'سياسة الدخول',
            value:
                event.entryType == 'single' ? 'دخول مرة واحدة' : 'دخول متعدد',
          ),
        ],
      ),
    );
  }

  void _showManageStaffDialog(BuildContext context, String eventId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ManageStaffDialog(eventId: eventId),
    );
  }
}

class _ManageStaffDialog extends StatefulWidget {
  final String eventId;
  const _ManageStaffDialog({required this.eventId});

  @override
  State<_ManageStaffDialog> createState() => _ManageStaffDialogState();
}

class _ManageStaffDialogState extends State<_ManageStaffDialog> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _selectedGate;
  bool _isLoading = false;
  bool _isCreateMode = false;
  List<Map<String, dynamic>> _staffList = [];
  List<String> _gates = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      
      const gatesData = [
        'بوابة رئيسية',
        'بوابة VIP',
        'بوابة العائلات',
        'بوابة B',
      ];

      // نحاول أولاً مع gate_name
      List<dynamic> staffResponse;
      try {
        staffResponse = await supabase
            .from('event_staff')
            .select('id, staff_id, gate_name, profiles!event_staff_staff_id_fkey(id, name, email)')
            .eq('event_id', widget.eventId);
      } catch (_) {
        // fallback بدون gate_name إذا العمود غير موجود
        staffResponse = await supabase
            .from('event_staff')
            .select('id, staff_id, profiles!event_staff_staff_id_fkey(id, name, email)')
            .eq('event_id', widget.eventId);
      }

      final List<Map<String, dynamic>> list = [];
      for (var item in staffResponse) {
        final profile = item['profiles'] as Map<String, dynamic>?;
        final name = profile?['name'] ?? 'مجهول';
        final email = profile?['email'] ?? '';
        list.add({
          'event_staff_id': item['id'],
          'staff_id': item['staff_id'],
          'gate_name': item['gate_name'],
          'name': name,
          'email': email,
        });
      }

      setState(() {
        _gates = gatesData;
        _staffList = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تحميل البيانات: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addStaff() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.rpc(
        'assign_staff_to_event',
        params: {
          'p_event_id': widget.eventId,
          'p_staff_email': email,
          'p_gate_name': _selectedGate,
        },
      );

      final data = (response is Map<String, dynamic>) ? response : <String, dynamic>{};
      final success = data['success'] as bool? ?? false;
      final errorMsg = data['error'] as String?;

      if (success) {
        _emailController.clear();
        setState(() => _selectedGate = null);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الموظف بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = errorMsg == 'STAFF_NOT_FOUND'
              ? 'لم يتم العثور على حساب موظف بهذا البريد الإلكتروني.\nتأكد أن المستخدم مسجل ودوره "موظف استقبال".'
              : errorMsg == 'FORBIDDEN'
                  ? 'ليس لديك صلاحية لإضافة موظفين لهذه المناسبة.'
                  : 'فشل إضافة الموظف: $errorMsg';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء الإضافة: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeStaff(String staffId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.rpc(
        'remove_staff_from_event',
        params: {
          'p_event_id': widget.eventId,
          'p_staff_id': staffId,
        },
      );

      final data = (response is Map<String, dynamic>) ? response : <String, dynamic>{};
      final success = data['success'] as bool? ?? false;

      if (success) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إزالة الموظف بنجاح')),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'فشل إزالة الموظف';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewStaffAndAssign() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'يرجى تعبئة الاسم والبريد الإلكتروني وكلمة المرور.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // Step 1: Create the new staff account via RPC (runs as SECURITY DEFINER)
      final createResp = await supabase.rpc(
        'create_staff_account',
        params: {
          'p_email': email,
          'p_password': password,
          'p_name': name,
          'p_phone': phone.isEmpty ? null : phone,
          'p_event_id': widget.eventId,
          'p_gate_name': _selectedGate,
        },
      );

      final data = (createResp is Map<String, dynamic>)
          ? createResp
          : <String, dynamic>{};
      final success = data['success'] as bool? ?? false;
      final errorMsg = data['error'] as String?;

      if (success) {
        _emailController.clear();
        _nameController.clear();
        _phoneController.clear();
        _passwordController.clear();
        setState(() {
          _selectedGate = null;
          _isCreateMode = false;
        });
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء حساب الموظف وإسناده بنجاح ✅'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = errorMsg == 'EMAIL_EXISTS'
              ? 'البريد الإلكتروني مستخدم بالفعل. جرّب "إضافة موظف موجود".'
              : 'فشل إنشاء الحساب: ${errorMsg ?? "خطأ غير معروف"}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showEditGateDialog(String email, String? currentGate) async {
    String? tempSelectedGate = currentGate;
    
    await showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'تعديل بوابة الموظف',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الموظف: $email',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tempSelectedGate,
                    hint: const Text('اختر البوابة الجديدة'),
                    items: _gates
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) {
                      setStateDialog(() {
                        tempSelectedGate = val;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    
                    try {
                      final supabase = Supabase.instance.client;
                      final response = await supabase.rpc(
                        'assign_staff_to_event',
                        params: {
                          'p_event_id': widget.eventId,
                          'p_staff_email': email,
                          'p_gate_name': tempSelectedGate,
                        },
                      );

                      final data = (response is Map<String, dynamic>) ? response : <String, dynamic>{};
                      final success = data['success'] as bool? ?? false;
                      
                      if (success) {
                        await _loadData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تعديل بوابة الموظف بنجاح')),
                          );
                        }
                      } else {
                        setState(() {
                          _errorMessage = 'فشل تعديل البوابة: ${data['error']}';
                          _isLoading = false;
                        });
                      }
                    } catch (e) {
                      setState(() {
                        _errorMessage = 'حدث خطأ: $e';
                        _isLoading = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('حفظ التعديل'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final accent = AppTheme.goldPrimary;

    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: mediaQuery.size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        child: ListView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          children: [
            // ─── Header ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إدارة موظفي الاستقبال',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Mode Toggle ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildToggleBtn(
                    label: 'إضافة موظف موجود',
                    icon: Icons.person_search_rounded,
                    active: !_isCreateMode,
                    onTap: () {
                      setState(() {
                        _isCreateMode = false;
                        _errorMessage = null;
                        _emailController.clear();
                        _nameController.clear();
                        _phoneController.clear();
                        _passwordController.clear();
                      });
                    },
                    accent: accent,
                    isDark: isDark,
                  ),
                  _buildToggleBtn(
                    label: 'إنشاء حساب جديد',
                    icon: Icons.person_add_alt_1_rounded,
                    active: _isCreateMode,
                    onTap: () {
                      setState(() {
                        _isCreateMode = true;
                        _errorMessage = null;
                        _emailController.clear();
                        _nameController.clear();
                        _phoneController.clear();
                        _passwordController.clear();
                      });
                    },
                    accent: accent,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Form ─────────────────────────────────────────────────
            if (_isCreateMode) ...[
              _buildTextField(
                controller: _nameController,
                hint: 'الاسم الكامل للموظف',
                icon: Icons.badge_outlined,
                type: TextInputType.name,
              ),
              const SizedBox(height: 10),
            ],
            _buildTextField(
              controller: _emailController,
              hint: _isCreateMode
                  ? 'البريد الإلكتروني (سيستخدم للدخول)'
                  : 'البريد الإلكتروني للموظف',
              icon: Icons.email_outlined,
              type: TextInputType.emailAddress,
            ),
            if (_isCreateMode) ...[
              const SizedBox(height: 10),
              _buildTextField(
                controller: _phoneController,
                hint: 'رقم الجوال (اختياري)',
                icon: Icons.phone_outlined,
                type: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _passwordController,
                hint: 'كلمة المرور (6 أحرف على الأقل)',
                icon: Icons.lock_outline_rounded,
                type: TextInputType.visiblePassword,
                obscure: true,
              ),
            ],
            const SizedBox(height: 12),

            // ─── Gate Dropdown ────────────────────────────────────────
            if (_gates.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                value: _selectedGate,
                hint: const Text('اختر البوابة (اختياري)'),
                items: _gates
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedGate = val),
                decoration: InputDecoration(
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ─── Action Button ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : (_isCreateMode ? _createNewStaffAndAssign : _addStaff),
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(
                        _isCreateMode
                            ? Icons.person_add_alt_1_rounded
                            : Icons.person_add_rounded,
                        size: 18,
                      ),
                label: Text(
                  _isCreateMode ? 'إنشاء الحساب وإسناده' : 'إضافة الموظف',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            // ─── Error ────────────────────────────────────────────────
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const Divider(height: 28),

            // ─── Staff List ───────────────────────────────────────────
            Text(
              'الموظفون الحاليون (${_staffList.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 10),
            if (_isLoading && _staffList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_staffList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'لا يوجد موظفو استقبال مضافون حالياً',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              )
            else
              ..._staffList.map((staff) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.04)
                        : Colors.black.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: theme.dividerColor.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: accent.withOpacity(0.12),
                        child: Text(
                          (staff['name'] as String? ?? '?')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: TextStyle(
                              color: accent, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              staff['name'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              staff['email'] ?? '',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 11),
                            ),
                            if (staff['gate_name'] != null)
                              Row(
                                children: [
                                  const Icon(
                                      Icons.door_front_door_outlined,
                                      size: 11,
                                      color: Colors.teal),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      'بوابة: ${staff['gate_name']}',
                                      style: const TextStyle(
                                          color: Colors.teal,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_road_rounded,
                            color: accent, size: 20),
                        tooltip: 'تعديل البوابة',
                        onPressed: _isLoading
                            ? null
                            : () => _showEditGateDialog(
                                staff['email'], staff['gate_name']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_remove_rounded,
                            color: Colors.redAccent, size: 20),
                        tooltip: 'إزالة الموظف',
                        onPressed: _isLoading
                            ? null
                            : () => _removeStaff(staff['staff_id']),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleBtn({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    required Color accent,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? accent.withOpacity(isDark ? 0.25 : 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: active
                ? Border.all(color: accent.withOpacity(0.5))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: active ? accent : Colors.grey),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: active
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: active ? accent : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: Theme.of(context).brightness == Brightness.dark
              ? null
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 10),
                ],
          border: Theme.of(context).brightness == Brightness.dark
              ? Border.all(color: Colors.white10)
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : AppTheme.shadowLow,
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.goldDark, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
