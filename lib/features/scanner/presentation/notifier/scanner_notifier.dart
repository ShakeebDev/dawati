import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../../../core/services/offline_sync_service.dart';
import '../../domain/usecases/process_qr_usecase.dart';
import '../../domain/entities/scanner_failure.dart';
import '../../data/repositories/scanner_repository_impl.dart';
import '../states/scanner_state.dart';
import '../providers/gate_provider.dart';

class ScannerNotifier extends StateNotifier<ScannerState> {
  final ProcessQrUseCase _processQrUseCase;
  final Ref? _ref;
  bool _isProcessing = false; // لمنع Double Triggers خلال الرد

  ScannerNotifier(this._processQrUseCase, [this._ref]) : super(const ScannerIdle());

  /// معالجة رمز الاستجابة السريعة الذي تم التقاطه من الكاميرا
  Future<void> onDetectQr(String qrToken) async {
    // 1. Debounce & Pause Camera
    // إذا كان هناك طلب قيد المعالجة، يتم تجاهل اللقطات الجديدة
    if (_isProcessing || state is ScannerProcessing) return;

    _isProcessing = true;
    state = const ScannerProcessing();

    // اهتزاز للتأكيد المبدئي على قراءة الكود
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 50);
    }

    // 2. إرسال الطلب لطبقة الدومين (سيتم التوجيه إما أونلاين أو أوفلاين محلياً)
    final gateName = _ref?.read(gateProvider);
    final result = await _processQrUseCase(qrToken, gateName: gateName);

    // 3. تحديث الحالة بناءً على النتيجة
    result.fold(
      (failure) {
        _handleFailure(failure);
      },
      (successResult) {
        // اهتزاز نجاح
        _vibrateSuccess();
        state = ScannerSuccess(successResult);
        if (successResult.isOffline) {
          _ref?.invalidate(pendingCheckinsCountProvider);
        }
      },
    );

    _isProcessing = false;
  }

  void _handleFailure(ScannerFailure failure) {
    _vibrateError();

    if (failure.type == ScannerFailureType.serverError) {
      // قد يكون Rate Limit أو خطأ عام
      state = ScannerRateLimited(failure.message);
    } else if (failure.type == ScannerFailureType.missingPermissions) {
      state = const ScannerCameraDenied();
    } else {
      // الأخطاء الأمنية أو فشل التحقق تُعرض كرسائل عامة Safe Messages
      state = ScannerFailed(failure.message);
    }
  }

  /// العودة لوضع الاستعداد لتلقي رمز جديد (يُستدعى عند إغلاق النتيجة)
  void resetScanner() {
    if (!_isProcessing) {
      state = const ScannerIdle();
    }
  }

  Future<void> _vibrateSuccess() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(pattern: [0, 50, 100, 50]); // نبضتان خفيفتان للنجاح
    }
  }

  Future<void> _vibrateError() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 500); // اهتزاز طويل للخطأ
    }
  }
}

// ─── Providers ───

final processQrUseCaseProvider = Provider<ProcessQrUseCase>((ref) {
  return ProcessQrUseCase(ref.read(scannerRepositoryProvider));
});

final scannerNotifierProvider = StateNotifierProvider<ScannerNotifier, ScannerState>((ref) {
  return ScannerNotifier(ref.read(processQrUseCaseProvider), ref);
});
