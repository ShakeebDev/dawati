import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/features/guests/presentation/providers/guest_providers.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/presentation/providers/event_providers.dart';
import 'package:dawati/features/invitation/presentation/widgets/invitation_card.dart';
import 'package:dawati/core/widgets/responsive_wrapper.dart';

class InvitationPreviewScreen extends ConsumerStatefulWidget {
  final String guestId;
  final String eventId;

  const InvitationPreviewScreen({
    super.key,
    required this.guestId,
    required this.eventId,
  });

  @override
  ConsumerState<InvitationPreviewScreen> createState() =>
      _InvitationPreviewScreenState();
}

class _InvitationPreviewScreenState
    extends ConsumerState<InvitationPreviewScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareInvitation(GuestModel guest, event) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('جاري تجهيز بطاقة الدعوة...'),
            duration: Duration(seconds: 1)),
      );

      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 500),
      );

      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath =
            await File('${directory.path}/invitation_${guest.id}.png').create();
        await imagePath.writeAsBytes(imageBytes);

        final xFile = XFile(imagePath.path);
        final message =
            'مرحباً ${guest.name}، نتشرف بدعوتك لحضور ${event.name}.\n\nتجد في الرابط أدناه بطاقة دعوتك الرسمية والمزودة برمز الدخول الخاص بك.';

        await Share.shareXFiles(
          [xFile],
          text: message,
          subject: 'دعوة حضور: ${event.name}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('فشل في مشاركة الدعوة: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final guestsAsync = ref.watch(guestsListProvider(widget.eventId));
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('بطاقة الدعوة الذكية'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.navyPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: guestsAsync.when(
        data: (guests) {
          if (guests.isEmpty) {
            return const Center(child: Text('لا يوجد ضيوف حالياً'));
          }

          final guest = guests.firstWhere(
            (g) => g.id == widget.guestId,
            orElse: () => guests.first,
          );

          return eventAsync.when(
            data: (event) {
              if (event == null)
                return const Center(child: Text('المناسبة غير موجودة'));

              return ResponsiveWrapper(
                maxWidth: 500,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                child: Column(
                  children: [
                    Center(
                      child: RepaintBoundary(
                        child: Screenshot(
                          controller: _screenshotController,
                          child: InvitationCard(guest: guest, event: event),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildSharingOptions(context, guest, event),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                Center(child: Text('خطأ في جلب بيانات المناسبة: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
      ),
    );
  }

  Widget _buildSharingOptions(BuildContext context, GuestModel guest, event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(15),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareInvitation(guest, event),
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('مشاركة الدعوة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navyPrimary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final directory = await getTemporaryDirectory();
                    await _screenshotController.captureAndSave(
                      directory.path,
                      fileName: 'invitation_${guest.id}.png',
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('تم حفظ الدعوة في المعرض')));
                    }
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('حفظ الصورة'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'سيتم إرسال الدعوة إلى: ${guest.phone}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
