import 'package:supabase_flutter/supabase_flutter.dart';

/// أنواع الأخطاء في التطبيق
abstract class AppFailure {
  final String message;
  final String? code;

  const AppFailure({required this.message, this.code});

  @override
  String toString() => 'AppFailure(message: $message, code: $code)';

  static String mapMessage(Object e) {
    if (e is PostgrestException) {
      return e.message;
    }
    final errorStr = e.toString();
    if (errorStr.contains('SocketException') ||
        errorStr.contains('Failed host lookup') ||
        errorStr.contains('connection timed out')) {
      return 'تعذر الاتصال بالخادم، يرجى التأكد من تشغيل الإنترنت والمحاولة مرة أخرى.';
    }
    if (errorStr.contains('Connection refused')) {
      return 'الخادم غير متاح حالياً، يرجى المحاولة لاحقاً.';
    }
    if (errorStr.contains('PostgrestException') ||
        errorStr.contains('limit reached') ||
        errorStr.contains('Limit reached') ||
        errorStr.contains('reached')) {
      return errorStr;
    }
    return 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.';
  }
}

/// خطأ في المصادقة
class AuthFailure extends AppFailure {
  const AuthFailure({required super.message, super.code});

  factory AuthFailure.invalidCredentials() => const AuthFailure(
      message: 'بيانات الدخول غير صحيحة', code: 'invalid_credentials');

  factory AuthFailure.userNotFound() =>
      const AuthFailure(message: 'المستخدم غير موجود', code: 'user_not_found');

  factory AuthFailure.emailAlreadyInUse() => const AuthFailure(
      message: 'البريد الإلكتروني مستخدم بالفعل', code: 'email_in_use');

  factory AuthFailure.weakPassword() => const AuthFailure(
      message: 'كلمة المرور ضعيفة جداً', code: 'weak_password');

  factory AuthFailure.networkError() => const AuthFailure(
      message: 'خطأ في الاتصال بالشبكة', code: 'network_error');

  factory AuthFailure.unknown() =>
      const AuthFailure(message: 'حدث خطأ غير متوقع', code: 'unknown');

  factory AuthFailure.fromException(Object e) {
    return AuthFailure(
      message: AppFailure.mapMessage(e),
      code: 'auth_network_error',
    );
  }
}

/// خطأ في قاعدة البيانات
class DatabaseFailure extends AppFailure {
  const DatabaseFailure({required super.message, super.code});

  factory DatabaseFailure.notFound() =>
      const DatabaseFailure(message: 'البيانات غير موجودة', code: 'not_found');

  factory DatabaseFailure.permissionDenied() => const DatabaseFailure(
      message: 'ليس لديك صلاحية الوصول', code: 'permission_denied');

  factory DatabaseFailure.unknown(Object e) =>
      DatabaseFailure(message: AppFailure.mapMessage(e), code: 'db_error');
}

/// خطأ في QR
class QrFailure extends AppFailure {
  const QrFailure({required super.message, super.code});

  factory QrFailure.invalidToken() =>
      const QrFailure(message: 'رمز QR غير صالح', code: 'invalid_token');

  factory QrFailure.alreadyCheckedIn() => const QrFailure(
      message: 'تم تسجيل الدخول مسبقاً', code: 'already_checked_in');

  factory QrFailure.entryLimitReached() => const QrFailure(
      message: 'تم استنفاد عدد الدخولات المسموح بها', code: 'limit_reached');

  factory QrFailure.eventNotFound() =>
      const QrFailure(message: 'المناسبة غير موجودة', code: 'event_not_found');
}

/// خطأ في التخزين
class StorageFailure extends AppFailure {
  const StorageFailure({required super.message, super.code});

  factory StorageFailure.uploadFailed() =>
      const StorageFailure(message: 'فشل رفع الملف', code: 'upload_failed');

  factory StorageFailure.fileTooLarge() => const StorageFailure(
      message: 'حجم الملف كبير جداً', code: 'file_too_large');
}

/// نتيجة العمليات (Either pattern)
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppFailure failure;
  const Failure(this.failure);
}
