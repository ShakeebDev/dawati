import 'package:dartz/dartz.dart';
import '../entities/checkin_entity.dart';
import '../entities/scanner_failure.dart';
import '../repositories/scanner_repository.dart';

class ProcessQrUseCase {
  final IScannerRepository _repository;

  ProcessQrUseCase(this._repository);

  Future<Either<ScannerFailure, CheckInEntity>> call(String qrToken, {String? gateName}) async {
    if (qrToken.trim().isEmpty) {
      return Left(ScannerFailure(type: ScannerFailureType.invalidQr));
    }
    return await _repository.processCheckIn(qrToken.trim(), gateName: gateName);
  }
}
