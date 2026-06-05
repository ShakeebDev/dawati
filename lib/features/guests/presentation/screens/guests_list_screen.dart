import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/features/guests/presentation/providers/guest_providers.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/guests/data/repositories/guest_repository.dart';
import 'package:dawati/core/utils/app_utils.dart';
import 'package:dawati/core/errors/failures.dart';

import 'package:dawati/features/guests/data/services/bulk_import_service.dart';
import 'package:dawati/features/guests/presentation/widgets/guest_selection_dialog.dart';
import 'package:dawati/core/widgets/responsive_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dawati/features/guests/presentation/widgets/guest_limit_upgrade_dialog.dart';


class GuestsListScreen extends ConsumerWidget {
  final String eventId;
  const GuestsListScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guests = ref.watch(filteredGuestsProvider(eventId));
    final guestsAsync = ref.watch(guestsListProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الضيوف'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleBulkAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'contacts',
                child: ListTile(
                  leading: Icon(Icons.contacts_outlined),
                  title: Text('استيراد من جهات الاتصال'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'csv',
                child: ListTile(
                  leading: Icon(Icons.file_present_outlined),
                  title: Text('استيراد من ملف CSV'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'bulk_send',
                child: ListTile(
                  leading: Icon(Icons.rocket_launch_outlined,
                      color: AppTheme.goldPrimary),
                  title: Text('بدء الإرسال السريع (Turbo)',
                      style: TextStyle(
                          color: AppTheme.goldDark,
                          fontWeight: FontWeight.bold)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(guestsListProvider(eventId));
          return ref.read(guestsListProvider(eventId).future);
        },
        child: ResponsiveWrapper(
          useScroll: false,
          padding: EdgeInsets.zero,
          maxWidth: 700,
          child: Column(
            children: [
              _buildSummaryHeader(context, guests),
              _buildSearchBox(context, ref),
              Expanded(
                child: guestsAsync.when(
                  data: (_) => guests.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: _buildEmptyState(),
                          ),
                        )
                      : _buildGuestsList(context, ref, guests),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 58,
        decoration: BoxDecoration(
          color: AppTheme.navyPrimary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.navyDark.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () => context.push('/dashboard/event/$eventId/guests/add'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          icon: const Icon(Icons.person_add_alt_1_rounded,
              color: AppTheme.goldPrimary, size: 22),
          label: const Text(
            'دعوة ضيف جديد',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ).animate().scale(delay: 400.ms),
    );
  }

  void _handleBulkAction(
      BuildContext context, WidgetRef ref, String action) async {
    if (action == 'bulk_send') {
      context.push('/dashboard/event/$eventId/invitation/bulk-send');
      return;
    }

    List<GuestModel> importedGuests = [];

    try {
      if (action == 'contacts') {
        // طلب الصلاحية أولاً
        final isPermissionGranted =
            await BulkImportService.requestContactsPermission();
        if (!isPermissionGranted) {
          AppUtils.showSnackBar(context, 'تم رفض صلاحية الوصول لجهات الاتصال',
              isError: true);
          return;
        }

        AppUtils.showSnackBar(context, 'جاري جلب جهات الاتصال...');
        importedGuests = await BulkImportService.importFromContacts(eventId);

        if (importedGuests.isEmpty) {
          AppUtils.showSnackBar(context,
              'لم يتم العثور على جهات اتصال صالحة (يجب وجود اسم ورقم)');
          return;
        }
      } else if (action == 'csv') {
        importedGuests = await BulkImportService.importFromCsv(eventId);
      }

      if (importedGuests.isNotEmpty) {
        final List<GuestModel>? selectedGuests =
            await showModalBottomSheet<List<GuestModel>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => GuestSelectionDialog(guests: importedGuests),
        );

        if (selectedGuests != null && selectedGuests.isNotEmpty) {
          final result =
              await ref.read(guestRepositoryProvider).addGuests(selectedGuests);
          if (result is Success) {
            AppUtils.showSnackBar(
                context, 'تم استيراد ${selectedGuests.length} ضيف بنجاح');
            ref.invalidate(guestsListProvider(eventId));
          } else if (result is Failure) {
            final errorMsg = (result as Failure).failure.message;
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
              AppUtils.showSnackBar(context,
                  'فشل في الاستيراد: $errorMsg',
                  isError: true);
            }
          }
        }
      } else {
        AppUtils.showSnackBar(context, 'لم يتم اختيار أي ضيوف');
      }
    } catch (e) {
      AppUtils.showSnackBar(context, 'خطأ: $e', isError: true);
    }
  }

  Widget _buildSummaryHeader(BuildContext context, List<GuestModel> guests) {
    if (guests.isEmpty) return const SizedBox.shrink();

    final total = guests.length;
    final confirmed = guests.where((g) => g.status == 'confirmed').length;
    final pending = total - confirmed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          _buildStatCard(context, 'الكل', total.toString(), Colors.blue),
          const SizedBox(width: 12),
          _buildStatCard(
              context, 'تم التأكيد', confirmed.toString(), AppTheme.success),
          const SizedBox(width: 12),
          _buildStatCard(
              context, 'بانتظار', pending.toString(), AppTheme.warning),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, String value, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
          boxShadow: theme.brightness == Brightness.dark
              ? null
              : [
                  BoxShadow(
                    color: color.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: theme.hintColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) =>
            ref.read(guestSearchQueryProvider.notifier).state = value,
        decoration: InputDecoration(
          hintText: 'بحث باسم الضيف أو رقم الجوال...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildGuestsList(
    BuildContext context,
    WidgetRef ref,
    List<GuestModel> guests,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: guests.length,
      itemBuilder: (context, index) {
        final guest = guests[index];
        return _GuestTile(guest: guest, eventId: eventId);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'لا يوجد ضيوف مضافين',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _GuestTile extends ConsumerWidget {
  final GuestModel guest;
  final String eventId;
  const _GuestTile({required this.guest, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.02), blurRadius: 10),
              ],
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: AppTheme.goldPrimary.withOpacity(0.1),
          child: Text(
            guest.name[0].toUpperCase(),
            style: const TextStyle(color: AppTheme.goldDark),
          ),
        ),
        title: Text(
          guest.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(guest.phone),
            if (guest.tableNumber != null)
              Text(
                'طاولة: ${guest.tableNumber}',
                style: const TextStyle(fontSize: 12, color: AppTheme.goldDark),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusBadge(
              status: guest.status,
              statusArabic: guest.statusArabic,
            ),
            IconButton(
              icon: const Icon(
                Icons.share_outlined,
                color: AppTheme.goldPrimary,
                size: 20,
              ),
              onPressed: () => context.push(
                '/dashboard/event/$eventId/invitation/${guest.id}',
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
        onTap: () =>
            context.push('/dashboard/event/$eventId/guests/${guest.id}'),
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الضيف'),
        content: Text('هل أنت متأكد من حذف ${guest.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result =
          await ref.read(guestRepositoryProvider).deleteGuest(guest.id);
      if (result is Success) {
        ref.invalidate(guestsListProvider(eventId));
      }
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String statusArabic;
  const _StatusBadge({required this.status, required this.statusArabic});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'confirmed':
        color = AppTheme.success;
        break;
      case 'checked_in':
        color = AppTheme.info;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusArabic,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
