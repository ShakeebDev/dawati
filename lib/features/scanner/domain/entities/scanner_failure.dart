/// أنواع الأخطاء التي قد تحدث أثناء الفحص، يتم تعيين رسائل عامة
/// لكل خطأ لمنع هجمات الـ Enumeration.
enum ScannerFailureType {
  invalidQr('رمز الاستجابة السريعة غير صالح'),
  expiredQr('انتهت صلاحية رمز الاستجابة السريعة'),
  alreadyScanned('تم استخدام هذه الدعوة مسبقاً'),
  entriesExceeded('تم تجاوز عدد الدخول المسموح به لهذه الدعوة'),
  revokedInvitation('تم إلغاء هذه الدعوة من قبل المنظم'),
  offlineNotAllowed('لا يمكن فحص هذا الرمز بدون إنترنت (بيانات غير متوفرة)'),
  networkError('يوجد مشكلة في الاتصال بالشبكة'),
  serverError('حدث خطأ في النظام، يرجى المحاولة لاحقاً'),
  missingPermissions('صلاحيات الكاميرا غير متوفرة');

  final String safeMessage;
  const ScannerFailureType(this.safeMessage);
}

class ScannerFailure implements Exception {
  final ScannerFailureType type;
  final String? internalLog; // تفاصيل إضافية لا تُعرض للمستخدم وتُسجل محلياً فقط

  const ScannerFailure({
    required this.type,
    this.internalLog,
  });

  String get message => type.safeMessage;
}
