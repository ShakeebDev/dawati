import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/core/utils/app_utils.dart';
import 'package:dawati/core/errors/failures.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/guests/data/repositories/guest_repository.dart';
import 'package:dawati/features/guests/presentation/providers/guest_providers.dart';
import 'package:dawati/core/widgets/responsive_wrapper.dart';
import 'package:dawati/features/guests/presentation/widgets/guest_limit_upgrade_dialog.dart';


class AddGuestScreen extends ConsumerStatefulWidget {
  final String eventId;
  const AddGuestScreen({super.key, required this.eventId});

  @override
  ConsumerState<AddGuestScreen> createState() => _AddGuestScreenState();
}

class _AddGuestScreenState extends ConsumerState<AddGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _tableController = TextEditingController();
  final _notesController = TextEditingController();
  int _allowedEntries = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _tableController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final guest = GuestModel(
      id: '',
      eventId: widget.eventId,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      allowedEntries: _allowedEntries,
      currentEntries: 0,
      qrToken: AppUtils.generateSecureToken(), // Use secure token generator
      status: 'pending',
      tableNumber:
          _tableController.text.isEmpty ? null : _tableController.text.trim(),
      notes:
          _notesController.text.isEmpty ? null : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    final result = await ref.read(guestRepositoryProvider).addGuest(guest);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result is Success<GuestModel>) {
        final newGuest = result.data;
        ref.invalidate(guestsListProvider(widget.eventId));

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('تم إضافة الضيف بنجاح'),
              content:
                  Text('هل تريد إرسال بطاقة الدعوة إلى ${newGuest.name} الآن؟'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pop();
                  },
                  child: const Text('لاحقاً'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pop();
                    context.push(
                        '/dashboard/event/${widget.eventId}/invitation/${newGuest.id}');
                  },
                  child: const Text('إرسال الآن'),
                ),
              ],
            ),
          );
        }
      } else if (result is Failure<GuestModel>) {
        final errorMsg = result.failure.message;
        // كشف خطأ تجاوز حد الضيوف القادم من Trigger قاعدة البيانات
        if (errorMsg.contains('Guest limit reached') ||
            errorMsg.contains('limit reached') ||
            errorMsg.contains('Limit reached') ||
            errorMsg.contains('limit_reached')) {
          int? limit;
          final match = RegExp(r'Max:\s*(\d+)').firstMatch(errorMsg);
          if (match != null) {
            limit = int.tryParse(match.group(1) ?? '');
          }
          GuestLimitUpgradeDialog.show(context, currentLimit: limit);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة ضيف جديد')),
      body: ResponsiveWrapper(
        maxWidth: 480,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الضيف',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? 'يرجى إدخال اسم الضيف' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الجوال',
                  prefixIcon: Icon(Icons.phone),
                  hintText: '967xxxxxxxx',
                ),
                validator: (v) => v!.isEmpty ? 'يرجى إدخال رقم الجوال' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tableController,
                      decoration: const InputDecoration(
                        labelText: 'رقم الطاولة (اختياري)',
                        prefixIcon: Icon(Icons.table_restaurant),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'عدد المسموح لهم',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => setState(
                                () => _allowedEntries > 1
                                    ? _allowedEntries--
                                    : null,
                              ),
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                              ),
                            ),
                            Text(
                              '$_allowedEntries',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _allowedEntries++),
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات إضافية',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('إضافة الضيف للقائمة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
