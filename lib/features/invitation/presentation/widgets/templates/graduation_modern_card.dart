import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

class GraduationModernCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const GraduationModernCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  @override
  Widget build(BuildContext context) {
    const Color silkWhite = Color(0xFFFCFCFC);
    const Color deepNavy = Color(0xFF0F172A);
    const Color premiumGold = Color(0xFFC5A059);
    const Color softGray = Color(0xFF94A3B8);

    final String invitationText = event.displayInvitationText.isNotEmpty
        ? event.displayInvitationText
        : EventModel.getDefaultText(event.eventType);
    final String timeText = event.displayInvitationTime;
    final String eventName = event.name.isNotEmpty ? event.name : 'حفل التخرج';
    final String location =
        event.location.isNotEmpty ? event.location : 'موقع الحفل';

    return Center(
      child: Container(
        width: width,
        constraints: const BoxConstraints(minHeight: 650),
        decoration: BoxDecoration(
          color: silkWhite,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 35,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // زاوية ذهبية علوية
              Positioned(
                top: -30,
                right: -30,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: premiumGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // أيقونة التخرج المركزية
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: premiumGold, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: premiumGold,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // عنوان المناسبة (اسم الدفعة / الجامعة)
                    Text(
                      eventName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: deepNavy,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // نص تعبيري
                    Text(
                      'وبكل فخر واعتزاز نتشرف بدعوتكم لحضور',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: softGray,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'حفل التخرج السنوي',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: premiumGold,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // إطار نص الدعوة المخصص
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(
                              color: premiumGold.withOpacity(0.2), width: 0.5),
                        ),
                      ),
                      child: Text(
                        invitationText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          color: deepNavy.withOpacity(0.8),
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // تفاصيل الوقت والمكان بتنسيق أفقي أنيق
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoBox(Icons.calendar_month_outlined, 'التاريخ',
                            event.date.toString().split(' ')[0], deepNavy),
                        _buildInfoBox(Icons.access_time_outlined, 'الوقت',
                            timeText, deepNavy),
                        _buildInfoBox(Icons.location_on_outlined, 'الموقع',
                            location, deepNavy),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // رمز QR واسم الضيف
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                )
                              ]),
                          child: QrImageView(
                            data: guest.qrToken,
                            version: QrVersions.auto,
                            size: 90.0,
                            foregroundColor: deepNavy,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          guest.name,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: deepNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              // حافة سفلية فاخرة
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: deepNavy,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color.withOpacity(0.6)),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.cairo(
              fontSize: 10,
              color: color.withOpacity(0.4),
              fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
              fontSize: 11, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
