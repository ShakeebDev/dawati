import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawati/core/storage/secure_storage_service.dart';

/// نتيجة التحقق من التوقيع
class QrSignatureResult {
  final bool isValid;
  final String? errorReason; // expired, invalid_signature, malformed
  final Map<String, dynamic>? payload;

  QrSignatureResult({
    required this.isValid,
    this.errorReason,
    this.payload,
  });
}

/// خدمة التحقق من صحة التوقيع الرقمي وصلاحية رمز الاستجابة السريعة (QR)
/// في وضع الأوفلاين لضمان عدم تزوير الدعوات.
class QrSignatureService {
  final SecureStorageService _secureStorage;

  // مفتاح التوقيع العام للسيرفر (Public Key) - يُجلب وقت الـ Login
  static const String _publicKeyStorageKey = 'server_public_key';

  QrSignatureService(this._secureStorage);

  /// التحقق من الـ QR
  /// الـ QR يجب أن يكون بصيغة JWT (Header.Payload.Signature)
  /// يحتوي على: guest_id, event_id, exp, nonce
  Future<QrSignatureResult> verifyQrToken(String token) async {
    try {
      // 1. جلب المفتاح العام من التخزين الآمن
      // ملاحظة: للـ MVP يمكن استخدام SecretKey متماثل، لكن للإنتاج نستخدم Asymmetric
      final publicKeyStr = await _secureStorage.getToken(_publicKeyStorageKey);
      
      if (publicKeyStr == null) {
        // إذا لم يتم تحميل المفتاح مسبقاً، لا يمكن التحقق أوفلاين
        return QrSignatureResult(
          isValid: false,
          errorReason: 'missing_keys',
        );
      }

      // 2. فحص التلاعب بالوقت (Clock Drift Protection)
      // إذا كان وقت الجهاز الحالي أقل من وقت آخر مزامنة، فهذا يعني أن المستخدم أرجع الوقت للوراء
      final lastSyncTimeMs = await _secureStorage.getLastSyncTime();
      if (lastSyncTimeMs != null) {
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        if (nowMs < lastSyncTimeMs) {
          return QrSignatureResult(
            isValid: false,
            errorReason: 'clock_manipulation_detected',
          );
        }
      }

      // 3. التحقق من التوقيع وتاريخ الانتهاء
      // `checkExpiresIn` سيضمن أن حقل `exp` لم يتجاوز الوقت الحالي
      // تم إضافة 10 ثوانٍ كفترة سماح (Grace Window)
      final jwt = JWT.verify(
        token,
        SecretKey(publicKeyStr), // استبدله بـ RSAPublicKey في بيئة الـ Enterprise الحقيقية
        checkExpiresIn: true,
        issueAt: const Duration(seconds: 10), // Grace window for slight drifts
      );

      final payload = jwt.payload as Map<String, dynamic>? ?? {};

      // 4. التأكد من وجود الحقول الأساسية وجاهزيتها
      if (!payload.containsKey('guest_id') || 
          !payload.containsKey('event_id') || 
          !payload.containsKey('jti')) {
        return QrSignatureResult(
          isValid: false,
          errorReason: 'malformed_payload',
        );
      }

      // 4. التحقق من المصدر (Issuer) والجمهور المستهدف (Audience)
      if (payload['iss'] != 'dawati' || payload['aud'] != 'dawati_scanner') {
        return QrSignatureResult(
          isValid: false,
          errorReason: 'invalid_issuer_or_audience',
        );
      }

      return QrSignatureResult(
        isValid: true,
        payload: payload,
      );
    } on JWTExpiredException {
      return QrSignatureResult(
        isValid: false,
        errorReason: 'expired_qr',
      );
    } on JWTException {
      return QrSignatureResult(
        isValid: false,
        errorReason: 'invalid_signature',
      );
    } catch (e) {
      return QrSignatureResult(
        isValid: false,
        errorReason: 'unknown_error',
      );
    }
  }

  /// (مؤقت) حفظ مفتاح السيرفر للاختبار أو عند الـ Login
  Future<void> saveServerKey(String key) async {
    await _secureStorage.saveToken(_publicKeyStorageKey, key);
  }
}

final qrSignatureServiceProvider = Provider<QrSignatureService>((ref) {
  return QrSignatureService(SecureStorageService());
});
