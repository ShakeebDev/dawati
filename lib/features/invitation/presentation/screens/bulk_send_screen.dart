import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/core/widgets/responsive_wrapper.dart';
import 'package:dawati/features/guests/presentation/providers/guest_providers.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/presentation/providers/event_providers.dart';
import 'package:dawati/features/guests/data/repositories/guest_repository.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:dawati/features/invitation/presentation/widgets/invitation_card.dart';

class BulkSendScreen extends ConsumerStatefulWidget {
  final String eventId;

  const BulkSendScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<BulkSendScreen> createState() => _BulkSendScreenState();
}

class _BulkSendScreenState extends ConsumerState<BulkSendScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  int _currentIndex = 0;
  bool _isProcessing = false;

  Future<void> _sendInvitation(GuestModel guest, EventModel event) async {
    setState(() => _isProcessing = true);
    try {
      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 500),
      );

      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath =
            await File('${directory.path}/invite_${guest.id}.png').create();
        await imagePath.writeAsBytes(imageBytes);

        final xFile = XFile(imagePath.path);
        final message =
            'مرحباً ${guest.name}،  نتشرف بدعوتك لحضور حفل \n ${event.name}.\nتجد مرفقاً بطاقة دعوتك الرسمية.';

        await Share.shareXFiles(
          [xFile],
          text: message,
          subject: 'دعوة حضور: ${event.name}',
        );

        // تحديث حالة الضيف كـ "مؤكد" (معناه تم الإرسال)
        await ref.read(guestRepositoryProvider).updateGuest(
              guest.copyWith(status: 'confirmed'),
            );

        ref.invalidate(guestsListProvider(widget.eventId));

        _nextGuest();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('فشل في الإرسال: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _nextGuest() {
    setState(() {
      _currentIndex++;
    });
  }

  void _previousGuest() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final guestsAsync = ref.watch(guestsListProvider(widget.eventId));
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإرسال الجماعي السريع'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: guestsAsync.when(
                data: (guests) =>
                    Text('${_currentIndex + 1} / ${guests.length}'),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ),
          ),
        ],
      ),
      body: guestsAsync.when(
        data: (allGuests) {
          final guests = allGuests.where((g) => g.status == 'pending').toList();
          if (guests.isEmpty) {
            return _buildAllSentState();
          }

          if (_currentIndex >= guests.length) {
            return _buildAllSentState();
          }

          final guest = guests[_currentIndex];

          return eventAsync.when(
            data: (event) {
              if (event == null)
                return const Center(child: Text('المناسبة غير موجودة'));

              return Column(
                children: [
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / guests.length,
                    backgroundColor:
                        Theme.of(context).dividerColor.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.goldPrimary),
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text(
                                'يرجى الضغط على "إرسال" ثم العودة للتطبيق للانتقال للضيف التالي',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                              Screenshot(
                                controller: _screenshotController,
                                child: InvitationCard(guest: guest, event: event),
                              ),
                              const SizedBox(height: 30),
                              _buildGuestInfo(guest),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(child: _buildActionBar(guest, event)),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('خطأ: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }

  Widget _buildGuestInfo(GuestModel guest) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(15),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.goldPrimary.withOpacity(0.1),
            child: Text(guest.name[0],
                style: const TextStyle(color: AppTheme.goldDark)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(guest.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(guest.phone, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(GuestModel guest, EventModel event) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _currentIndex > 0 ? _previousGuest : null,
            icon: const Icon(Icons.arrow_back_ios),
          ),
          Expanded(
            child: ElevatedButton.icon(
              onPressed:
                  _isProcessing ? null : () => _sendInvitation(guest, event),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded),
              label:
                  Text(_isProcessing ? 'جاري التجهيز...' : 'إرسال عبر واتساب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.navyPrimary,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: _nextGuest,
            child: const Text('تخطي'),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSentState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
          const SizedBox(height: 20),
          const Text('تم إرسال جميع الدعوات المتبقية!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('العودة للقائمة'),
          ),
        ],
      ),
    );
  }
}
