/// يمثل النتيجة الناجحة لعملية التحقق من الدعوة
class CheckInEntity {
  final String guestName;
  final String eventName;
  final int remainingEntries;
  final String message;
  final bool isOffline; // هل تم الفحص أوفلاين وتم وضعه في الطابور؟
  final String? gateName;
  final bool isVip;

  CheckInEntity({
    required this.guestName,
    required this.eventName,
    required this.remainingEntries,
    required this.message,
    this.isOffline = false,
    this.gateName,
    this.isVip = false,
  });
}
