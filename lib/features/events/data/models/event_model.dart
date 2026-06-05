/// نموذج بيانات المناسبة
class EventModel {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String entryType; // single | multi
  final String createdBy;
  final DateTime createdAt;
  final String eventType; // wedding | graduation | birthday | dinner | other
  final int? totalGuests;
  final int? confirmedGuests;
  final int? checkedInGuests;
  final String? invitationTemplate;
  final String? invitationText;

  const EventModel({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.entryType,
    required this.createdBy,
    required this.createdAt,
    this.eventType = 'other',
    this.totalGuests,
    this.confirmedGuests,
    this.checkedInGuests,
    this.invitationTemplate,
    this.invitationText,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String,
      entryType: json['entry_type'] as String? ?? 'single',
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      eventType: json['event_type'] as String? ?? 'other',
      totalGuests: json['total_guests'] as int?,
      confirmedGuests: json['confirmed_guests'] as int?,
      checkedInGuests: json['checked_in_guests'] as int?,
      invitationTemplate: json['invitation_template'] as String?,
      invitationText: json['invitation_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'entry_type': entryType,
      'event_type': eventType,
      'invitation_template': invitationTemplate,
      'invitation_text': invitationText,
    };

    if (id.isNotEmpty) {
      data['id'] = id;
    }

    if (createdBy.isNotEmpty) {
      data['created_by'] = createdBy;
    }

    return data;
  }

  /// تحويل البيانات لغرض التحديث فقط (تجنب الحقول المحمية)
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'entry_type': entryType,
      'event_type': eventType,
      'invitation_template': invitationTemplate,
      'invitation_text': invitationText,
    };
  }

  bool get isPast => date.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  int get remainingGuests => (totalGuests ?? 0) - (checkedInGuests ?? 0);

  double get attendancePercentage {
    final total = totalGuests ?? 0;
    if (total == 0) return 0;
    return ((checkedInGuests ?? 0) / total * 100).clamp(0, 100);
  }

  EventModel copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? location,
    String? entryType,
    String? createdBy,
    DateTime? createdAt,
    String? eventType,
    int? totalGuests,
    int? confirmedGuests,
    int? checkedInGuests,
    String? invitationTemplate,
    String? invitationText,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      location: location ?? this.location,
      entryType: entryType ?? this.entryType,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      eventType: eventType ?? this.eventType,
      totalGuests: totalGuests ?? this.totalGuests,
      confirmedGuests: confirmedGuests ?? this.confirmedGuests,
      checkedInGuests: checkedInGuests ?? this.checkedInGuests,
      invitationTemplate: invitationTemplate ?? this.invitationTemplate,
      invitationText: invitationText ?? this.invitationText,
    );
  }

  // --- Helper Methods to Handle Combined Data ---

  /// الحصول على نص الدعوة فقط من الحقل المدمج
  String get displayInvitationText {
    if (invitationText == null || invitationText!.isEmpty) {
      return getDefaultText(eventType);
    }
    if (invitationText!.contains('|TIME:')) {
      return invitationText!.split('|TIME:')[0];
    }
    return invitationText!;
  }

  /// الحصول على وقت الدعوة فقط من الحقل المدمج
  String get displayInvitationTime {
    if (invitationText == null) return '8:00 مساءً';
    if (invitationText!.contains('|TIME:')) {
      final parts = invitationText!.split('|TIME:');
      return parts.length > 1 ? parts[1] : '8:00 مساءً';
    }
    return '8:00 مساءً';
  }

  /// دمج النص والوقت في حقل واحد
  static String combineTextAndTime(String text, String time) {
    return '$text|TIME:$time';
  }

  // --- Event Types Config ---

  static String getDefaultText(String type) {
    switch (type) {
      case 'wedding':
        return 'نتشرف بدعوتكم لحضور حفل الزفاف السعيد، وبكم تكتمل أفراحنا';
      case 'graduation':
        return 'نشارككم فرحة النجاح والتخرج، وندعوكم للاحتفال بهذه المناسبة الغالية';
      case 'birthday':
        return 'بمناسبة ذكرى الميلاد السعيد، يسعدنا دعوتكم لمشاركتنا اللحظات الجميلة';
      case 'dinner':
        return 'نتشرف بدعوتكم لتناول طعام العشاء في لقاء يملؤه الود والمحبة';
      case 'other':
      default:
        return 'نتشرف بدعوتكم لحضور مناسبتنا السعيدة، حضوركم يسعدنا';
    }
  }

  static String getEventTypeLabel(String type) {
    switch (type) {
      case 'wedding':
        return 'حفل زفاف';
      case 'graduation':
        return 'حفل تخرج';
      case 'birthday':
        return 'عيد ميلاد';
      case 'dinner':
        return 'مأدبة عشاء';
      case 'other':
      default:
        return 'مناسبة أخرى';
    }
  }
}
