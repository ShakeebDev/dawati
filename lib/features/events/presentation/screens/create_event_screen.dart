import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:url_launcher/url_launcher.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/core/utils/app_utils.dart';
import 'package:dawati/core/errors/failures.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:dawati/features/events/data/repositories/event_repository.dart';
import 'package:dawati/features/auth/presentation/providers/auth_provider.dart';
import 'package:dawati/features/events/presentation/providers/event_providers.dart';
import 'package:dawati/core/widgets/responsive_wrapper.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  final EventModel? event;
  const CreateEventScreen({super.key, this.event});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  String _entryType = 'single';
  String _eventType = 'other';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _nameController.text = widget.event!.name;
      _locationController.text = widget.event!.location;
      _selectedDate = widget.event!.date;
      _entryType = widget.event!.entryType;
      _eventType = widget.event!.eventType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.goldDark,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        AppUtils.showSnackBar(
          context,
          'يرجى اختيار تاريخ المناسبة',
          isError: true,
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final user = ref.read(authProvider).user;
    if (user == null) return;

    final event = EventModel(
      id: widget.event?.id ?? '',
      name: _nameController.text.trim(),
      date: _selectedDate!,
      location: _locationController.text.trim(),
      entryType: _entryType,
      eventType: _eventType,
      createdBy: user.id,
      createdAt: widget.event?.createdAt ?? DateTime.now(),
    );

    final result = widget.event == null
        ? await ref.read(eventRepositoryProvider).createEvent(event)
        : await ref.read(eventRepositoryProvider).updateEvent(event);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result is Success<EventModel>) {
        AppUtils.showSnackBar(
            context,
            widget.event == null
                ? 'تم إنشاء المناسبة بنجاح'
                : 'تم تحديث المناسبة بنجاح');
        ref.invalidate(eventsListProvider);
        if (widget.event != null) {
          ref.invalidate(eventDetailsProvider(widget.event!.id));
        }
        context.pop();
      } else if (result is Failure<EventModel>) {
        final errorMsg = result.failure.message;
        if (errorMsg.contains('limit reached') || errorMsg.contains('Limit reached') || errorMsg.contains('Event limit reached')) {
          _showUpgradeDialog(context);
        } else {
          AppUtils.showSnackBar(
            context,
            errorMsg,
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.event == null ? 'إنشاء مناسبة جديدة' : 'تعديل المناسبة'),
        backgroundColor: Colors.transparent,
      ),
      body: ResponsiveWrapper(
        maxWidth: 500,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تفاصيل المناسبة',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldDark,
                    ),
              ),
              const SizedBox(height: 24),
              // اختيار نوع الحفل
              Text(
                'نوع الحفل',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _EventTypeOption(
                      id: 'wedding',
                      label: 'زفاف',
                      icon: Icons.favorite_rounded,
                      isSelected: _eventType == 'wedding',
                      onTap: () => setState(() => _eventType = 'wedding'),
                    ),
                    _EventTypeOption(
                      id: 'graduation',
                      label: 'تخرج',
                      icon: Icons.school_rounded,
                      isSelected: _eventType == 'graduation',
                      onTap: () => setState(() => _eventType = 'graduation'),
                    ),
                    _EventTypeOption(
                      id: 'birthday',
                      label: 'ميلاد',
                      icon: Icons.cake_rounded,
                      isSelected: _eventType == 'birthday',
                      onTap: () => setState(() => _eventType = 'birthday'),
                    ),
                    _EventTypeOption(
                      id: 'dinner',
                      label: 'عشاء',
                      icon: Icons.restaurant_rounded,
                      isSelected: _eventType == 'dinner',
                      onTap: () => setState(() => _eventType = 'dinner'),
                    ),
                    _EventTypeOption(
                      id: 'other',
                      label: 'أخرى',
                      icon: Icons.more_horiz_rounded,
                      isSelected: _eventType == 'other',
                      onTap: () => setState(() => _eventType = 'other'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المناسبة',
                  prefixIcon: Icon(Icons.celebration),
                  hintText: 'مثلاً: محمد & أحمد',
                ),
                validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppTheme.goldDark,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'تاريخ المناسبة'
                            : intl.DateFormat(
                                'yyyy-MM-dd',
                              ).format(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null
                              ? Colors.grey
                              : Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'الموقع / القاعة',
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'مثلاً: قاعة ليلتي - الحصب',
                ),
                validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
              ),
              const SizedBox(height: 24),
              Text(
                'نوع الدخول',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _EntryTypeCard(
                      title: 'دخول لمرة واحدة',
                      subtitle: 'الباركود يعمل لمرة واحدة فقط',
                      icon: Icons.person,
                      isSelected: _entryType == 'single',
                      onTap: () => setState(() => _entryType = 'single'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _EntryTypeCard(
                      title: 'دخول متعدد',
                      subtitle: 'يسمح بالخروج والعودة',
                      icon: Icons.group,
                      isSelected: _entryType == 'multi',
                      onTap: () => setState(() => _entryType = 'multi'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('حفظ ونشر المناسبة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.star_rounded, color: AppTheme.goldPrimary, size: 28),
            SizedBox(width: 8),
            Text('ترقية الحساب مطلوبة', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لقد وصلت للحد الأقصى المسموح به للمناسبات في باقتك الحالية (مناسبة واحدة مجانية).',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'لإنشاء عدد غير محدود من الفعاليات وإضافة طاقم العمل، يرجى ترقية حسابك إلى الباقة الاحترافية.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366), // WhatsApp Green
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text('طلب ترقية عبر الواتساب'),
            onPressed: () async {
              Navigator.pop(context);
              final phoneNumber = '967738180731';
              final message = 'مرحباً، أرغب في ترقية حسابي على تطبيق دعوتي إلى الباقة الاحترافية (Pro Plan) لتفعيل ميزة إنشاء الفعاليات اللامحدودة.';
              final url = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
              
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                if (context.mounted) {
                  AppUtils.showSnackBar(context, 'فشل فتح تطبيق الواتساب. الرقم هو: 738180731', isError: true);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _EventTypeOption extends StatelessWidget {
  final String id;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _EventTypeOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 80,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.goldDark.withOpacity(0.1)
                : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.goldDark
                  : theme.dividerColor.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.goldDark : Colors.grey,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.goldDark : Colors.grey,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _EntryTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.goldDark
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.goldDark
                : Theme.of(context).dividerColor.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.goldDark.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.goldDark,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
