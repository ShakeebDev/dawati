import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

class GradMidnightStarryCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const GradMidnightStarryCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  @override
  Widget build(BuildContext context) {
    const Color deepSpace = Color(0xFF0F0C1B);
    const Color starGold = Color(0xFFFED136);
    const Color nebulaBlue = Color(0xFF38BDF8);
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
          color: deepSpace,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // رسم الفضاء السديمي والشهب والنجوم
              Positioned.fill(
                child: CustomPaint(
                  painter: _MidnightStarryPainter(
                    starColor: starGold,
                    blueColor: nebulaBlue,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 25),
                    
                    // قبعة التخرج الذهبية الساطعة مع هالة نيون سماوية
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: starGold.withOpacity(0.7), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: nebulaBlue.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school,
                        color: starGold,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // التقدير الأكاديمي والتاج
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 25,
                          height: 1,
                          color: nebulaBlue.withOpacity(0.3),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'THE SKY IS THE LIMIT',
                          style: GoogleFonts.cinzel(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: nebulaBlue,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 25,
                          height: 1,
                          color: nebulaBlue.withOpacity(0.3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // عنوان المناسبة الكبير المتوهج باللون الذهبي
                    Text(
                      eventName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: starGold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // التمهيد
                    Text(
                      'بكل طموح يطاول السماء وفخر يُضيء دروبنا، ندعوكم لمشاركتنا فرحة تخرجنا البهيج وبداية انطلاقنا في فضاء المستقبل الرحب',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w300,
                        color: textColor.withOpacity(0.85),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // نص الدعوة المخصص
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: nebulaBlue.withOpacity(0.25), width: 0.8),
                      ),
                      child: Text(
                        invitationText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight: FontWeight.normal,
                          color: textColor.withOpacity(0.95),
                          height: 1.65,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // تفاصيل الوقت والموقع
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: nebulaBlue.withOpacity(0.15), width: 0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem(Icons.calendar_today, 'التاريخ', event.date.toString().split(' ')[0], nebulaBlue),
                          _buildInfoItem(Icons.access_time_filled, 'الوقت', timeText, starGold),
                          _buildInfoItem(Icons.location_on, 'القاعة', location, nebulaBlue),
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
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: guest.qrToken,
                            version: QrVersions.auto,
                            size: 80.0,
                            foregroundColor: deepSpace,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          guest.name,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: starGold,
                          ),
                        ),
                        Text(
                          'كود التحقق لدخول حفل التخرج',
                          style: GoogleFonts.cairo(
                            fontSize: 9.5,
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
          style: GoogleFonts.cairo(fontSize: 8.5, color: Colors.white38),
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

class _MidnightStarryPainter extends CustomPainter {
  final Color starColor;
  final Color blueColor;

  _MidnightStarryPainter({required this.starColor, required this.blueColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. تدرج سديمي (Nebula) لطيف خلفي دائري
    final paintNebula = Paint()
      ..shader = RadialGradient(
        colors: [
          blueColor.withOpacity(0.15),
          Colors.transparent,
        ],
        center: Alignment.center,
        radius: 0.8,
      ).createShader(Rect.fromLTWH(0, size.height * 0.1, size.width, size.width));

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.35), size.width * 0.8, paintNebula);

    // 2. رسم نجوم لامعة ونقاط كوكبة متصلة
    final starPaint = Paint()..style = PaintingStyle.fill;
    
    // نقاط النجوم الثابتة الموزعة
    final List<Offset> stars = [
      Offset(size.width * 0.15, size.height * 0.08),
      Offset(size.width * 0.85, size.height * 0.05),
      Offset(size.width * 0.78, size.height * 0.22),
      Offset(size.width * 0.1, size.height * 0.28),
      Offset(size.width * 0.9, size.height * 0.45),
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.08, size.height * 0.78),
      Offset(size.width * 0.85, size.height * 0.82),
    ];

    for (int i = 0; i < stars.length; i++) {
      final double radius = (i % 3 == 0) ? 2.2 : 1.2;
      starPaint.color = (i % 2 == 0 ? starColor : blueColor).withOpacity(0.6);
      canvas.drawCircle(stars[i], radius, starPaint);
      
      // توهج إضافي للنجوم الكبيرة
      if (radius > 2.0) {
        canvas.drawCircle(stars[i], 5.0, Paint()..color = starColor.withOpacity(0.15)..style = PaintingStyle.fill);
      }
    }

    // 3. رسم خطوط متصلة للشهب الساطعة
    final meteorPaint = Paint()
      ..shader = LinearGradient(
        colors: [blueColor.withOpacity(0.25), Colors.transparent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(size.width * 0.6, 50, 60, 60))
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final pathMeteor = Path()
      ..moveTo(size.width * 0.8, 50)
      ..lineTo(size.width * 0.65, 80);
    canvas.drawPath(pathMeteor, meteorPaint);

    final pathMeteor2 = Path()
      ..moveTo(size.width * 0.35, 120)
      ..lineTo(size.width * 0.2, 150);
    canvas.drawPath(pathMeteor2, meteorPaint..shader = LinearGradient(
        colors: [starColor.withOpacity(0.25), Colors.transparent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(size.width * 0.2, 120, 60, 60)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
