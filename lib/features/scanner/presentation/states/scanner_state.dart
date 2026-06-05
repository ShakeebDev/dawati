import '../../domain/entities/checkin_entity.dart';

sealed class ScannerState {
  const ScannerState();
}

/// حالة الكاميرا تعمل وتنتظر مسح رمز (مستعدة)
class ScannerIdle extends ScannerState {
  const ScannerIdle();
}

/// جاري الاتصال بالسيرفر أو التحقق من التوقيع (إيقاف الكاميرا مؤقتاً)
class ScannerProcessing extends ScannerState {
  const ScannerProcessing();
}

/// نجاح عملية الفحص والدخول (أونلاين أو أوفلاين)
class ScannerSuccess extends ScannerState {
  final CheckInEntity result;
  
  const ScannerSuccess(this.result);
}

/// فشل عملية الفحص لأي سبب كان (صلاحية، دعوة مزورة، إلخ)
class ScannerFailed extends ScannerState {
  final String message;
  
  const ScannerFailed(this.message);
}

/// المستخدم رفض إعطاء صلاحية الكاميرا
class ScannerCameraDenied extends ScannerState {
  const ScannerCameraDenied();
}

/// تم تجاوز الحد المسموح من الطلبات السريعة
class ScannerRateLimited extends ScannerState {
  final String message;
  
  const ScannerRateLimited(this.message);
}
