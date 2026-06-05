abstract class AppException implements Exception {
  final String message;
  final String code;

  const AppException(this.message, this.code);

  @override
  String toString() => '[$code]: $message';
}

class NetworkException extends AppException {
  const NetworkException([String message = 'لا يوجد اتصال بالإنترنت'])
      : super(message, 'NETWORK_ERROR');
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'غير مصرح لك بالدخول'])
      : super(message, 'UNAUTHORIZED');
}

class RateLimitException extends AppException {
  const RateLimitException([String message = 'تم تجاوز الحد المسموح به، يرجى المحاولة لاحقاً'])
      : super(message, 'RATE_LIMITED');
}

class ServerException extends AppException {
  const ServerException([String message = 'حدث خطأ في الخادم'])
      : super(message, 'SERVER_ERROR');
}
