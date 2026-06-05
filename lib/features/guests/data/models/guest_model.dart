/// نموذج بيانات الضيف
class GuestModel {
  final String id;
  final String eventId;
  final String name;
  final String phone;
  final int allowedEntries;
  final int currentEntries;
  final String qrToken;
  final String status; // pending | confirmed | checked_in
  final String? tableNumber;
  final String? seatNumber;
  final String? notes;
  final DateTime createdAt;

  const GuestModel({
    required this.id,
    required this.eventId,
    required this.name,
    required this.phone,
    required this.allowedEntries,
    required this.currentEntries,
    required this.qrToken,
    required this.status,
    this.tableNumber,
    this.seatNumber,
    this.notes,
    required this.createdAt,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      id: json['id'] as String? ?? '',
      eventId: json['event_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      allowedEntries: json['allowed_entries'] as int? ?? 1,
      currentEntries: json['current_entries'] as int? ?? 0,
      qrToken: json['qr_token'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      tableNumber: json['table_number'] as String?,
      seatNumber: json['seat_number'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'event_id': eventId,
      'name': name,
      'phone': phone,
      'allowed_entries': allowedEntries,
      'current_entries': currentEntries,
      'qr_token': qrToken,
      'status': status,
      'table_number': tableNumber,
      'seat_number': seatNumber,
      'notes': notes,
    };

    if (id.isNotEmpty) {
      data['id'] = id;
    }

    return data;
  }

  bool get isCheckedIn =>
      status == 'checked_in' || currentEntries >= allowedEntries;
  bool get hasRemainingEntries => currentEntries < allowedEntries;
  int get remainingEntries => allowedEntries - currentEntries;

  String get statusArabic {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'checked_in':
        return 'تم الدخول';
      default:
        return status;
    }
  }

  GuestModel copyWith({
    String? id,
    String? eventId,
    String? name,
    String? phone,
    int? allowedEntries,
    int? currentEntries,
    String? qrToken,
    String? status,
    String? tableNumber,
    String? seatNumber,
    String? notes,
    DateTime? createdAt,
  }) {
    return GuestModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      allowedEntries: allowedEntries ?? this.allowedEntries,
      currentEntries: currentEntries ?? this.currentEntries,
      qrToken: qrToken ?? this.qrToken,
      status: status ?? this.status,
      tableNumber: tableNumber ?? this.tableNumber,
      seatNumber: seatNumber ?? this.seatNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
