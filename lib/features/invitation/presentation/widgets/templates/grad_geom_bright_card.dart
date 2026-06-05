import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

class GradGeomBrightCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const GradGeomBrightCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  @override
  Widget build(BuildContext context) {
    const Color backgroundLight = Color(0xFFFAF9F6);
    const Color primaryCyan = Color(0xFF06B6D4);
    const Color orangeGold = Color(0xFFF97316);
    const Color deepSlate = Color(0xFF1E293B);

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
          color: backgroundLight,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // رسم هندسي احتفالي مشرق
              Positioned.fill(
                child: CustomPaint(
                  painter: _GeometricCelebrationPainter(
                    cyanColor: primaryCyan,
                    orangeColor: orangeGold,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 25),
                    
                    // شارة التخرج الحديثة الدائرية مع قبعة تخرج نيونية
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryCyan, orangeGold],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: orangeGold.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // تسمية الفئة
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryCyan.withOpacity(0.2), width: 0.8),
                      ),
                      child: Text(
                        'THE FUTURE BEGINS',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryCyan,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // عنوان التخرج
                    Text(
                      eventName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: deepSlate,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // النص التمهيدي
                    Text(
                      'بمزيج من البهجة والفخر بنهاية الرحلة الأكاديمية وبداية المستقبل المشرق، يسعدنا دعوتكم لمشاركتنا لحظات تخرجنا السعيدة',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: deepSlate.withOpacity(0.7),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // نص الدعوة المخصص
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        invitationText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight: FontWeight.normal,
                          color: deepSlate.withOpacity(0.9),
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // الوقت والتاريخ والقاعة
                    Row(
                      children: [
                        Expanded(child: _buildItem(Icons.calendar_month, 'التاريخ', event.date.toString().split(' ')[0], primaryCyan, deepSlate)),
                        Container(width: 1, height: 35, color: Colors.grey.withOpacity(0.2)),
                        Expanded(child: _buildItem(Icons.access_time_filled, 'الوقت', timeText, orangeGold, deepSlate)),
                        Container(width: 1, height: 35, color: Colors.grey.withOpacity(0.2)),
                        Expanded(child: _buildItem(Icons.location_on, 'القاعة', location, primaryCyan, deepSlate)),
                      ],
                    ),
                    const SizedBox(height: 35),

                    // الـ QR الخاص بالحضور
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: guest.qrToken,
                            version: QrVersions.auto,
                            size: 80.0,
                            foregroundColor: deepSlate,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          guest.name,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: deepSlate,
                          ),
                        ),
                        Text(
                          'تذكرة دخول البوابة الإلكترونية',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, String value, Color iconColor, Color textColor) {
    return Column(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 9, color: Colors.grey[500], fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.cairo(fontSize: 11, color: textColor, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _GeometricCelebrationPainter extends CustomPainter {
  final Color cyanColor;
  final Color orangeColor;

  _GeometricCelebrationPainter({required this.cyanColor, required this.orangeColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. القوس الخلفي العلوي المتدرج
    final topGradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [cyanColor.withOpacity(0.08), orangeColor.withOpacity(0.08)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, 250))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 180)
      ..quadraticBezierTo(size.width * 0.5, 230, 0, 180)
      ..close();
    canvas.drawPath(path, topGradientPaint);

    // 2. دوائر نيونية عائمة خفيفة بالخلفية
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(size.width * 0.1, 80), 30, circlePaint..color = cyanColor.withOpacity(0.12));
    canvas.drawCircle(Offset(size.width * 0.88, 120), 45, circlePaint..color = orangeColor.withOpacity(0.1));
    canvas.drawCircle(Offset(size.width * 0.88, 120), 20, circlePaint..color = cyanColor.withOpacity(0.08));

    // 3. نقاط بريق متناثرة كقصاصات الورق
    final confettiPaint = Paint()..style = PaintingStyle.fill;
    final int confettiCount = 20;
    int seed = 7;
    for (int i = 0; i < confettiCount; i++) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final x = (seed / 0x7fffffff) * size.width;
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final y = (seed / 0x7fffffff) * 150 + 20;
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final isCyan = seed % 2 == 0;
      
      confettiPaint.color = (isCyan ? cyanColor : orangeColor).withOpacity(0.25);
      canvas.drawCircle(Offset(x, y), 2.5, confettiPaint);
    }

    // 4. خطوط مائلة هندسية لملامح عصرية
    final linePaint = Paint()
      ..color = orangeColor.withOpacity(0.15)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, size.height * 0.8), Offset(size.width * 0.25, size.height * 0.88), linePaint);
    canvas.drawLine(Offset(size.width, size.height * 0.84), Offset(size.width * 0.7, size.height * 0.92), linePaint..color = cyanColor.withOpacity(0.15));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
