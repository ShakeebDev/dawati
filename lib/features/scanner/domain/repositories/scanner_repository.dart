import 'package:dartz/dartz.dart';
import '../entities/checkin_entity.dart';
import '../entities/scanner_failure.dart';

abstract class IScannerRepository {
  /// التحقق من رمز الـ QR وتسجيل الدخول
  /// يتم معالجة العملية أونلاين أو أوفلاين بناءً على توفر الإنترنت
  Future<Either<ScannerFailure, CheckInEntity>> processCheckIn(String qrToken, {String? gateName});
}
