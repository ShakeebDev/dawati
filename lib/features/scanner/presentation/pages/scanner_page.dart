import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/offline_sync_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../notifier/scanner_notifier.dart';
import '../states/scanner_state.dart';
import '../widgets/scan_result_bottom_sheet.dart';
import '../providers/gate_provider.dart';


class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  late MobileScannerController _cameraController;
  bool _isManualSyncing = false;
  List<Map<String, dynamic>> _assignedGates = [];
  bool _isLoadingGates = false;
  
  // لترشيد استهلاك البطارية
  Timer? _idleTimer;
  bool _isCameraIdle = false;
  static const int _idleTimeoutSeconds = 60;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
      // Frame Throttling لتقليل استهلاك البطارية وسخونة الجهاز
      // استخدام سرعة عادية مع مهلة 66 ملي ثانية (يعادل ~15 إطار في الثانية)
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 66,
      facing: CameraFacing.back,
      autoStart: true,
    );
    _resetIdleTimer();
    _fetchAssignedGates();
  }

  Future<void> _fetchAssignedGates() async {
    final user = ref.read(authProvider).user;
    if (user == null || user.role != 'staff') return;

    setState(() => _isLoadingGates = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('event_staff')
          .select('gate_name, events:events!event_id(id, name)')
          .eq('staff_id', user.id);

      final List<Map<String, dynamic>> list = [];
      if (response != null) {
        for (var item in response as List) {
          final event = item['events'] as Map<String, dynamic>?;
          if (event != null) {
            list.add({
              'event_id': event['id'],
              'event_name': event['name'] ?? 'مناسبة',
              'gate_name': item['gate_name'] ?? 'Gate A',
            });
          }
        }
      }
      setState(() {
        _assignedGates = list;
        _isLoadingGates = false;
      });
    } catch (e) {
      setState(() => _isLoadingGates = false);
    }
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _cameraController.dispose();
    super.dispose();
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    if (_isCameraIdle && mounted) {
      setState(() => _isCameraIdle = false);
      _cameraController.start();
    }
    
    _idleTimer = Timer(const Duration(seconds: _idleTimeoutSeconds), () async {
      if (mounted && !_isCameraIdle && !_isManualSyncing) {
        setState(() => _isCameraIdle = true);
        await _cameraController.stop();
      }
    });
  }

  void _onDetect(BarcodeCapture capture) {
    _resetIdleTimer();
    // نرسل الطلب للـ Notifier الذي سيعالجه إن لم يكن مشغولاً (Debounce)
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      ref.read(scannerNotifierProvider.notifier).onDetectQr(barcodes.first.rawValue!);
    }
  }

  Future<void> _handleManualSync() async {
    if (_isManualSyncing) return;
    setState(() => _isManualSyncing = true);
    
    // إيقاف الكاميرا مؤقتاً أثناء عملية المزامنة اليدوية لمنع حدوث تداخل
    await _cameraController.stop();

    try {
      final result = await ref.read(offlineSyncServiceProvider).syncPendingCheckins();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.failed > 0 ? Colors.orange.shade800 : Colors.green.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء المزامنة: $e'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isManualSyncing = false);
        await _cameraController.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // الاستماع للتغييرات في الـ State
    ref.listen<ScannerState>(scannerNotifierProvider, (previous, next) async {
      if (next is ScannerProcessing) {
        // إيقاف الكاميرا مؤقتاً أثناء معالجة الطلب لمنع إرسال طلبات متعددة
        await _cameraController.stop();
      } else if (next is ScannerSuccess) {
        await ScanResultBottomSheet.show(
          context,
          isSuccess: true,
          successData: next.result,
        );
        // بعد إغلاق النافذة (سواء يدوياً أو تلقائياً بعد ثانيتين)
        // نعيد ضبط الحالة ونشغل الكاميرا مجدداً
        if (mounted) {
          ref.read(scannerNotifierProvider.notifier).resetScanner();
          await _cameraController.start();
        }
      } else if (next is ScannerFailed) {
        await ScanResultBottomSheet.show(
          context,
          isSuccess: false,
          errorMessage: next.message,
        );
        if (mounted) {
          ref.read(scannerNotifierProvider.notifier).resetScanner();
          await _cameraController.start();
        }
      } else if (next is ScannerRateLimited) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.message), backgroundColor: Colors.orange));
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            ref.read(scannerNotifierProvider.notifier).resetScanner();
            _cameraController.start();
          }
        });
      }
    });

    final isOffline = ref.watch(connectivityStatusProvider).valueOrNull == ConnectivityStatus.offline;
    final state = ref.watch(scannerNotifierProvider);
    final pendingCount = ref.watch(pendingCheckinsCountProvider).valueOrNull ?? 0;
    final currentGate = ref.watch(gateProvider);

    if (currentGate == null) {
      final user = ref.watch(authProvider).user;
      final isStaff = user?.role == 'staff';

      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1B4B),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.goldPrimary.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.goldPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.door_sliding_rounded, color: AppTheme.goldPrimary, size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  'تحديد بوابة الجلسة',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  isStaff
                      ? 'المنظم قام بتعيين البوابة والمناسبة الخاصة بك. يرجى اختيار الجلسة لبدء المسح:'
                      : 'يرجى اختيار البوابة الحالية لبدء جلسة المسح للمناسبة:',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 28),
                if (isStaff) ...[
                  _isLoadingGates
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.goldPrimary))
                      : _assignedGates.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'لم يتم إسنادك لأي مناسبة أو بوابة حالياً من قبل المنظم.',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Container(
                              constraints: const BoxConstraints(maxHeight: 250),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: _assignedGates.map((assign) {
                                    final label = '${assign['event_name']} - ${assign['gate_name']}';
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white.withOpacity(0.05),
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(double.infinity, 56),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                          ),
                                        ),
                                        onPressed: () {
                                          ref.read(gateProvider.notifier).setGate(assign['gate_name']);
                                          _cameraController.start();
                                        },
                                        child: Text(
                                          label,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                ] else ...[
                  ...kAvailableGates.map((gate) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.05),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                        ),
                        onPressed: () {
                          ref.read(gateProvider.notifier).setGate(gate);
                          _cameraController.start();
                        },
                        child: Text(
                          gate,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 12),
                if (isStaff)
                  TextButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                    label: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey, size: 16),
                    label: const Text('رجوع للرئيسية', style: TextStyle(color: Colors.grey)),
                  )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _resetIdleTimer,
        onPanDown: (_) => _resetIdleTimer(),
        child: Stack(
          children: [
            // عدسة الكاميرا
            MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return const Center(
                child: Text('عذراً، حدث خطأ أثناء تشغيل الكاميرا', style: TextStyle(color: Colors.white)),
              );
            },
          ),

          // إطار الـ Overlay (إطار التركيز البصري)
          _buildOverlay(),

          // واجهة إيقاف الكاميرا المؤقت (Idle State)
          if (_isCameraIdle)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_off_rounded, color: Colors.white70, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'الكاميرا في وضع الخمول لتوفير الطاقة',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'المس الشاشة للاستئناف',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // واجهة التحكم (الأزرار والبار العلوي)
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(isOffline, pendingCount, currentGate),
                const Spacer(),
                _buildBottomControls(),
              ],
            ),
          ),

          // مؤشر التحميل أثناء الانتظار للعمليات التلقائية
          if (state is ScannerProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.goldPrimary),
              ),
            ),

          // مؤشر المزامنة اليدوية
          if (_isManualSyncing)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppTheme.goldPrimary),
                    const SizedBox(height: 16),
                    Text(
                      'جاري مزامنة العمليات المعلقة...',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildTopBar(bool isOffline, int pendingCount, String gateName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  ref.watch(authProvider).user?.role == 'staff' ? Icons.logout_rounded : Icons.close_rounded,
                  color: ref.watch(authProvider).user?.role == 'staff' ? Colors.redAccent : Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  final user = ref.read(authProvider).user;
                  if (user?.role == 'staff') {
                    ref.read(authProvider.notifier).logout();
                    context.go('/login');
                  } else {
                    context.pop();
                  }
                },
              ),
              
              // مؤشر الاتصال والعمليات المعلقة المشترك
              _buildConnectionAndSyncBadge(isOffline, pendingCount),
                
              IconButton(
                icon: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 28),
                onPressed: () => _cameraController.toggleTorch(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              ref.read(gateProvider.notifier).setGate(null);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swap_horizontal_circle_outlined, color: AppTheme.goldPrimary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'تغيير البوابة (الحالية: $gateName)',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionAndSyncBadge(bool isOffline, int pendingCount) {
    // 1. لا توجد عمليات معلقة
    if (pendingCount == 0) {
      if (isOffline) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text('وضع عدم الاتصال', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        );
      }
      
      // متصل ولا توجد عمليات معلقة
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_rounded, color: Colors.green, size: 16),
            SizedBox(width: 6),
            Text('متصل بالإنترنت', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      );
    }

    // 2. توجد عمليات معلقة
    if (isOffline) {
      // أوفلاين وتوجد عمليات معلقة (نعرض إشعار تنبيه فقط دون زر تفاعلي للمزامنة اليدوية)
      return InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('يوجد $pendingCount عمليات معلقة. سيتم مزامنتها تلقائياً فور توفر الإنترنت.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.orange.shade800,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.shade600,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sync_problem_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text('معلق: $pendingCount (أوفلاين)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    // أونلاين وتوجد عمليات معلقة (نعرض زر المزامنة اليدوية التفاعلي الذهبي الجذاب)
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleManualSync,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.goldPrimary, Color(0xFFD4AF37)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sync_rounded, color: Colors.black, size: 16),
              const SizedBox(width: 6),
              Text(
                'مزامنة معلقة ($pendingCount)',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final user = ref.read(authProvider).user;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle_outlined, color: AppTheme.goldPrimary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'الموظف: ${user.name}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'وجه الكاميرا نحو رمز الاستجابة السريعة (QR) لمسح التذكرة',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.6), BlendMode.srcOut),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(color: Colors.transparent),
              ),
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.goldPrimary.withValues(alpha: 0.5), width: 2),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ],
    );
  }
}
