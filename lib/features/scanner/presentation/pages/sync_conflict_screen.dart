import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/local_database_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:dawati/core/widgets/responsive_wrapper.dart';

class SyncConflictScreen extends ConsumerStatefulWidget {
  final String pendingCheckinId;
  final String guestId;
  final String guestName;
  final String conflictReason;

  const SyncConflictScreen({
    super.key,
    required this.pendingCheckinId,
    required this.guestId,
    required this.guestName,
    required this.conflictReason,
  });

  @override
  ConsumerState<SyncConflictScreen> createState() => _SyncConflictScreenState();
}

class _SyncConflictScreenState extends ConsumerState<SyncConflictScreen> {
  bool _isProcessing = false;
  String _notes = '';

  @override
  void initState() {
    super.initState();
    // سيتم جلب الـ role من المزود مباشرة
  }

  Future<void> _handleForceCheckIn(String? userRole) async {
    if (userRole != 'admin' && userRole != 'organizer') return;

    setState(() => _isProcessing = true);
    try {
      // 2. تحديث السجل المحلي ليصبح كحالة تجاوز (Override)
      // سيحتاج الـ Backend لمعالجة الـ Override لاحقاً في API خاص
      await localDatabaseService.updatePendingCheckinStatus(
        widget.pendingCheckinId, 
        'force_sync_pending',
        conflictReason: 'Override: ${_notes.isNotEmpty ? _notes : 'بموافقة المشرف'}',
      );
      
      // 3. كتابة سجل تدقيق للعملية
      await localDatabaseService.writeAuditLog(
        eventId: 'known_event', // يمكن جلبها من الـ guestId
        deviceId: 'device',
        staffId: 'staff',
        action: 'force_checkin_override',
        details: 'تم تجاوز تعارض المزامنة لعملية ${widget.pendingCheckinId} بواسطة المشرف. ملاحظات: $_notes',
        networkState: 'online',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم توجيه العملية لفرض المزامنة.', style: TextStyle(color: Colors.black)), backgroundColor: AppTheme.goldPrimary),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleDiscard() async {
    setState(() => _isProcessing = true);
    try {
      await localDatabaseService.updatePendingCheckinStatus(
        widget.pendingCheckinId, 
        'discarded',
        conflictReason: 'تم التجاهل: ${_notes.isNotEmpty ? _notes : 'بدون سبب'}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إلغاء عملية الدخول المحلية المتعارضة.')),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleReport() async {
    // For staff to report to admin
    setState(() => _isProcessing = true);
    try {
      await localDatabaseService.updatePendingCheckinStatus(
        widget.pendingCheckinId, 
        'reported',
        conflictReason: 'تم الإبلاغ للإدارة: ${_notes.isNotEmpty ? _notes : 'لا توجد ملاحظات'}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفع تقرير للمنظم.')));
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(authProvider).user?.role;
    final isAdmin = userRole == 'admin' || userRole == 'organizer';

    return Scaffold(
      appBar: AppBar(
        title: const Text('معالجة تعارض المزامنة'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      body: ResponsiveWrapper(
        maxWidth: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'اكتشف السيرفر تعارضاً مع عملية الدخول هذه!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('سبب التعارض:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 8),
                  Text(widget.conflictReason, style: const TextStyle(fontSize: 16)),
                  const Divider(),
                  Text('الضيف: ${widget.guestName} (${widget.guestId})', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 32),
            if (isAdmin)
              const Text('ملاحظات إدارية لدعم التجاوز:', style: TextStyle(fontWeight: FontWeight.bold))
            else
              const Text('إضافة تقرير/ملاحظة:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'اكتب ملاحظتك هنا...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
              onChanged: (val) => _notes = val,
            ),

            const SizedBox(height: 32),

            if (_isProcessing)
              const Center(child: CircularProgressIndicator(color: AppTheme.goldPrimary))
            else ...[
              if (isAdmin) ...[
                ElevatedButton.icon(
                  onPressed: () => _handleForceCheckIn(userRole),
                  icon: const Icon(Icons.gpp_good_rounded),
                  label: const Text('فرض الدخول (Force Approve)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldPrimary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: () {
                    // Retry sync
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سيتم إعادة المحاولة بالمزامنة القادمة')));
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة (Retry)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _handleReport,
                  icon: const Icon(Icons.report_problem_rounded),
                  label: const Text('رفع للمنظم (Report)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _handleDiscard,
                icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                label: const Text('تجاهل (Discard)', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
