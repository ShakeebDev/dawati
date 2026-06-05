/// نموذج نتيجة التحقق من QR
class QrValidationResult {
  final bool isValid;
  final String
      status; // success | duplicate | limit_reached | invalid | not_found
  final String guestName;
  final String guestId;
  final String eventName;
  final int remainingEntries;
  final int allowedEntries;
  final int currentEntries;
  final String? tableNumber;
  final String? seatNumber;
  final String message;
  /// هل جاءت النتيجة من التحقق المحلي (وضع عدم الاتصال)؟
  final bool isOfflineResult;

  const QrValidationResult({
    required this.isValid,
    required this.status,
    required this.guestName,
    required this.guestId,
    required this.eventName,
    required this.remainingEntries,
    required this.allowedEntries,
    required this.currentEntries,
    this.tableNumber,
    this.seatNumber,
    required this.message,
    this.isOfflineResult = false,
  });

  factory QrValidationResult.fromJson(Map<String, dynamic> json) {
    return QrValidationResult(
      isValid: json['is_valid'] as bool? ?? false,
      status: json['status'] as String? ?? 'invalid',
      guestName: json['guest_name'] as String? ?? '',
      guestId: json['guest_id'] as String? ?? '',
      eventName: json['event_name'] as String? ?? '',
      remainingEntries: json['remaining_entries'] as int? ?? 0,
      allowedEntries: json['allowed_entries'] as int? ?? 0,
      currentEntries: json['current_entries'] as int? ?? 0,
      tableNumber: json['table_number'] as String?,
      seatNumber: json['seat_number'] as String?,
      message: json['message'] as String? ?? '',
      isOfflineResult: false,
    );
  }

  bool get isSuccess => status == 'success';
  bool get isDuplicate => status == 'duplicate';
  bool get isLimitReached => status == 'limit_reached';
}

/// نموذج سجل الدخول
class CheckinModel {
  final String id;
  final String guestId;
  final DateTime scannedAt;
  final String scannedBy;
  final String? guestName;
  final String? staffName;
  final String? gateName;

  const CheckinModel({
    required this.id,
    required this.guestId,
    required this.scannedAt,
    required this.scannedBy,
    this.guestName,
    this.staffName,
    this.gateName,
  });

  factory CheckinModel.fromJson(Map<String, dynamic> json) {
    return CheckinModel(
      id: json['id'] as String,
      guestId: json['guest_id'] as String,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
      scannedBy: json['scanned_by'] as String,
      guestName: json['guests'] != null
          ? (json['guests'] as Map<String, dynamic>)['name'] as String?
          : null,
      staffName: json['profiles'] != null
          ? (json['profiles'] as Map<String, dynamic>)['name'] as String?
          : null,
      gateName: json['gate_name'] as String?,
    );
  }
}
