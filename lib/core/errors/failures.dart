import 'package:supabase_flutter/supabase_flutter.dart';

/// أنواع الأخطاء في التطبيق
abstract class AppFailure {
  final String message;
  final String? code;

  const AppFailure({required this.message, this.code});

  @override
  String toString() => 'AppFailure(message: $message, code: $code)';

  static String mapMessage(Object e) {
    if (e is String) {
      return e;
    }
    if (e is PostgrestException) {
      final msg = e.message.toLowerCase();
      final code = e.code;
      
      if (code == '42501' || msg.contains('violates row-level security')) {
        return 'عذراً، ليس لديك الصلاحية المطلوبة لإتمام هذه العملية.';
      }
      if (code == '23505' || msg.contains('duplicate key') || msg.contains('already exists')) {
        return 'هذه البيانات مسجلة بالفعل في النظام.';
      }
      if (code == '23503' || msg.contains('foreign key violation') || msg.contains('violates foreign key')) {
        return 'فشلت العملية لارتباطها ببيانات أخرى غير صحيحة.';
      }
      if (msg.contains('limit reached') || msg.contains('max limit') || msg.contains('limit_reached') || msg.contains('reached')) {
        return 'تم الوصول إلى الحد الأقصى المسموح به للباقة الخاصة بك. يرجى الترقية لإضافة المزيد.';
      }
      return 'خطأ في معالجة البيانات: ${e.message}';
    }
    
    if (e is AuthException) {
      final msg = e.message.toLowerCase();
      
      if (msg.contains('invalid login credentials') || msg.contains('invalid credentials')) {
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة. يرجى المحاولة مجدداً.';
      }
      if (msg.contains('already registered') || msg.contains('signup_email_exists') || msg.contains('email already exists')) {
        return 'هذا البريد الإلكتروني مسجل بالفعل. يرجى تسجيل الدخول.';
      }
      if (msg.contains('password should be') || msg.contains('weak password')) {
        return 'يجب أن تكون كلمة المرور مكونة من 6 خانات على الأقل.';
      }
      if (msg.contains('email not confirmed') || msg.contains('confirm your email')) {
        return 'يرجى تأكيد حسابك بالضغط على الرابط المرسل إلى بريدك الإلكتروني.';
      }
      if (msg.contains('user not found')) {
        return 'عذراً، هذا المستخدم غير مسجل لدينا.';
      }
      if (msg.contains('too many requests') || msg.contains('rate limit') || msg.contains('over_limit')) {
        return 'لقد قمت بمحاولات كثيرة جداً. يرجى الانتظار دقيقة والمحاولة مجدداً.';
      }
      if (msg.contains('invalid email')) {
        return 'البريد الإلكتروني المدخل غير صالح.';
      }
      if (msg.contains('network') || msg.contains('connection')) {
        return 'فشل الاتصال بالشبكة أثناء محاولة التوثيق. يرجى المحاولة مجدداً.';
      }
      return e.message;
    }
    
    final errorStr = e.toString().toLowerCase();
    if (errorStr.contains('socketexception') ||
        errorStr.contains('failed host lookup') ||
        errorStr.contains('connection timed out') ||
        errorStr.contains('network_error')) {
      return 'تعذر الاتصال بالخادم، يرجى التأكد من تشغيل الإنترنت والمحاولة مرة أخرى.';
    }
    if (errorStr.contains('connection refused')) {
      return 'الخادم غير متاح حالياً، يرجى المحاولة لاحقاً.';
    }
    if (errorStr.contains('limit reached') ||
        errorStr.contains('reached') ||
        errorStr.contains('limit_reached')) {
      return 'تم الوصول إلى الحد الأقصى المسموح به للباقة الخاصة بك. يرجى الترقية لإضافة المزيد.';
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
      code: 'auth_error',
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
