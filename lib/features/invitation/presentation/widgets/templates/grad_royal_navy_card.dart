import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

class GradRoyalNavyCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const GradRoyalNavyCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  @override
  Widget build(BuildContext context) {
    const Color royalNavy = Color(0xFF0F172A);
    const Color goldAccent = Color(0xFFD4AF37);
    const Color goldLight = Color(0xFFF3E5AB);
    const Color textColor = Colors.white;

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
          color: royalNavy,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // إطار مذهب فخم
              Positioned.fill(
                child: CustomPaint(
                  painter: _NavyGoldFramePainter(),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 25),
                    
                    // أيقونة قبعة تخرج مذهبة تفاعلية مع حلقة توهج
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: goldAccent.withOpacity(0.7), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: goldAccent.withOpacity(0.15),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: goldAccent,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // التقدير الأكاديمي والتاج
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 1,
                          color: goldAccent.withOpacity(0.5),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'GRADUATION DAY',
                          style: GoogleFonts.cinzel(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: goldLight,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 1,
                          color: goldAccent.withOpacity(0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // عنوان المناسبة الكبير
                    Text(
                      eventName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: goldAccent,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // نتشرف بدعوتكم لحضور
                    Text(
                      'بكل فخر واعتزاز، نتشرف بدعوتكم لحضور حفل تخرجنا البهيج ومشاركتنا فرحة النجاح والتميز الأكاديمي',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: textColor.withOpacity(0.9),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // نص الدعوة المخصص
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: goldAccent.withOpacity(0.15), width: 0.8),
                      ),
                      child: Text(
                        invitationText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: textColor.withOpacity(0.95),
                          height: 1.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // تفاصيل الوقت والموقع
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: goldAccent.withOpacity(0.1), width: 0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem(Icons.calendar_today_outlined, 'التاريخ', event.date.toString().split(' ')[0], goldAccent),
                          _buildInfoItem(Icons.access_time_rounded, 'الوقت', timeText, goldAccent),
                          _buildInfoItem(Icons.location_on_outlined, 'القاعة', location, goldAccent),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),

                    // رمز الـ QR وكود حضور الضيف
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: guest.qrToken,
                            version: QrVersions.auto,
                            size: 80.0,
                            foregroundColor: royalNavy,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          guest.name,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: goldLight,
                          ),
                        ),
                        Text(
                          'دعوة شخصية لحضور الحفل',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: textColor.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: accentColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 9, color: Colors.white38),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _NavyGoldFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double margin = 12.0;

    // رسم المستطيل الخارجي
    canvas.drawRect(
      Rect.fromLTWH(margin, margin, size.width - (margin * 2), size.height - (margin * 2)),
      goldPaint,
    );

    // زوايا كلاسيكية مذهبة
    final double cornerSize = 16.0;
    
    // زاوية علوية يسار
    canvas.drawLine(Offset(margin - 4, margin), Offset(margin + cornerSize, margin), goldPaint..strokeWidth = 2.0);
    canvas.drawLine(Offset(margin, margin - 4), Offset(margin, margin + cornerSize), goldPaint);

    // زاوية علوية يمين
    canvas.drawLine(Offset(size.width - margin + 4, margin), Offset(size.width - margin - cornerSize, margin), goldPaint);
    canvas.drawLine(Offset(size.width - margin, margin - 4), Offset(size.width - margin, margin + cornerSize), goldPaint);

    // زاوية سفلية يسار
    canvas.drawLine(Offset(margin - 4, size.height - margin), Offset(margin + cornerSize, size.height - margin), goldPaint);
    canvas.drawLine(Offset(margin, size.height - margin + 4), Offset(margin, size.height - margin - cornerSize), goldPaint);

    // زاوية سفلية يمين
    canvas.drawLine(Offset(size.width - margin + 4, size.height - margin), Offset(size.width - margin - cornerSize, size.height - margin), goldPaint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin + 4), Offset(size.width - margin, size.height - margin - cornerSize), goldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
