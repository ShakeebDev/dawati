import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/local_database_service.dart';
import '../../../../core/services/offline_sync_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:dawati/core/widgets/responsive_wrapper.dart';

class OfflinePendingScreen extends ConsumerStatefulWidget {
  const OfflinePendingScreen({super.key});

  @override
  ConsumerState<OfflinePendingScreen> createState() => _OfflinePendingScreenState();
}

class _OfflinePendingScreenState extends ConsumerState<OfflinePendingScreen> {
  bool _isSyncing = false;
  List<Map<String, dynamic>> _pendingCheckins = [];

  @override
  void initState() {
    super.initState();
    _loadPendingCheckins();
  }

  Future<void> _loadPendingCheckins() async {
    final checkins = await localDatabaseService.getPendingCheckins();
    // جلب أسماء الضيوف من الكاش لربط المعرفات بالأسماء
    final enrichedCheckins = <Map<String, dynamic>>[];
    for (final c in checkins) {
      final guest = await localDatabaseService.findGuestByQrToken(c['qr_token'] as String);
      enrichedCheckins.add({
        ...c,
        'guest_name': guest?['name'] ?? 'ضيف غير معروف',
      });
    }

    if (mounted) {
      setState(() {
        _pendingCheckins = enrichedCheckins;
      });
    }
  }

  Future<void> _syncNow() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    try {
      final result = await ref.read(offlineSyncServiceProvider).syncPendingCheckins();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.failed > 0 || result.conflicts > 0 ? Colors.orange.shade800 : Colors.green.shade800,
          ),
        );
      }
    } finally {
      await _loadPendingCheckins();
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _discardCheckin(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: const Text('هل أنت متأكد من إلغاء عملية الدخول هذه محلياً؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('رجوع', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('إلغاء العملية', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // تحديث حالة السجل إلى discard 
      await localDatabaseService.updatePendingCheckinStatus(id, 'discarded', conflictReason: 'تم الإلغاء يدوياً بواسطة المشرف');
      await _loadPendingCheckins();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = ref.watch(connectivityStatusProvider).valueOrNull == ConnectivityStatus.offline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العمليات المعلقة'),
        actions: [
          if (!isOffline)
            IconButton(
              icon: _isSyncing 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppTheme.goldPrimary, strokeWidth: 2))
                  : const Icon(Icons.sync_rounded),
              onPressed: _syncNow,
              tooltip: 'مزامنة الآن',
            ),
        ],
      ),
      body: ResponsiveWrapper(
        useScroll: false,
        padding: EdgeInsets.zero,
        maxWidth: 600,
        child: _pendingCheckins.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_done_rounded, size: 80, color: Colors.green.shade200),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد عمليات معلقة',
                      style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _pendingCheckins.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final checkin = _pendingCheckins[index];
                final date = DateTime.tryParse(checkin['scanned_at'] as String? ?? '');
                final formattedDate = date != null ? DateFormat('hh:mm a').format(date) : 'غير معروف';
                final isConflict = checkin['sync_status'] == 'failed';
                final status = checkin['sync_status'];
                final retryCount = checkin['retry_count'] as int? ?? 0;
                final guestName = checkin['guest_name'] as String;

                Color statusColor;
                String statusText;
                IconData statusIcon;

                if (status == 'pending') {
                  statusColor = Colors.orange;
                  statusText = 'قيد الانتظار';
                  statusIcon = Icons.pending_actions_rounded;
                } else if (status == 'failed') {
                  statusColor = Colors.red;
                  statusText = 'فشل / تعارض';
                  statusIcon = Icons.error_outline;
                } else {
                  statusColor = Colors.grey;
                  statusText = status;
                  statusIcon = Icons.info_outline;
                }

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: statusColor.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              guestName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const Spacer(),
                            if (retryCount > 0)
                              Text(
                                'محاولات: $retryCount',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                          ],
                        ),
                        if (isConflict && checkin['conflict_reason'] != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'السبب: ${checkin['conflict_reason']}',
                              style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _discardCheckin(checkin['id']),
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                              label: const Text('إلغاء', style: TextStyle(color: Colors.red)),
                            ),
                            if (isConflict) ...[
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.push(
                                    '/scanner/conflict', 
                                    extra: {
                                      'pendingCheckinId': checkin['id'],
                                      'guestId': checkin['guest_id'],
                                      'guestName': guestName,
                                      'conflictReason': checkin['conflict_reason'] ?? 'غير معروف',
                                    },
                                  ).then((_) => _loadPendingCheckins()); // تحديث بعد العودة
                                },
                                icon: const Icon(Icons.rule_rounded, size: 18),
                                label: const Text('معالجة التعارض'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.goldPrimary,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ),
    );
  }
}
