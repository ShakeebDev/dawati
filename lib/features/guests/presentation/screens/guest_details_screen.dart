import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/guests/presentation/providers/guest_providers.dart';
import 'package:dawati/core/widgets/responsive_wrapper.dart';

import 'package:dawati/features/events/presentation/providers/event_providers.dart';
import 'package:dawati/features/invitation/presentation/widgets/invitation_card.dart';

class GuestDetailsScreen extends ConsumerWidget {
  final String guestId;
  final String eventId;

  const GuestDetailsScreen({
    super.key,
    required this.guestId,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guestsAsync = ref.watch(guestsListProvider(eventId));
    final eventAsync = ref.watch(eventDetailsProvider(eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الضيف')),
      body: guestsAsync.when(
        data: (guests) {
          final guest = guests.firstWhere((g) => g.id == guestId);
          return eventAsync.when(
            data: (event) {
              if (event == null) {
                return const Center(child: Text('حدث خطأ في تحميل بيانات المناسبة'));
              }
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: ResponsiveWrapper(
                    maxWidth: 480,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        InvitationCard(
                          guest: guest,
                          event: event,
                          width: 340,
                        ),
                        const SizedBox(height: 24),
                        _buildInfoCard(context, guest),
                        const SizedBox(height: 32),
                        _buildShareButton(context, guest),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('خطأ في تحميل المناسبة: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ في تحميل الضيف: $err')),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, GuestModel guest) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.phone,
            label: 'رقم الجوال',
            value: guest.phone,
          ),
          const Divider(height: 30),
          _DetailRow(
            icon: Icons.people,
            label: 'عدد المسموح لهم',
            value: '${guest.allowedEntries}',
          ),
          const Divider(height: 30),
          _DetailRow(
            icon: Icons.table_restaurant,
            label: 'رقم الطاولة',
            value: guest.tableNumber ?? 'غير محدد',
          ),
          const Divider(height: 30),
          _DetailRow(
            icon: Icons.info_outline,
            label: 'الحالة',
            value: guest.statusArabic,
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context, GuestModel guest) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.share),
        label: const Text('مشاركة بطاقة الدعوة'),
        onPressed: () {
          Share.share(
            'دعوة حضور خاصة للضيف: ${guest.name}\nرمز الدخول: ${guest.qrToken}',
            subject: 'دعوة حضور',
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.goldDark, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
