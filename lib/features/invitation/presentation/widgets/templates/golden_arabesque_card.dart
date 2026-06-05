import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

/// قالب الزخرفة الذهبية (عربسك) - بطاقة كريمية مع نقوش عربية إسلامية ذهبية ونصوص تراثية
class GoldenArabesqueCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const GoldenArabesqueCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  static const Color ivoryBgStart = Color(0xFFFDFBF7);
  static const Color ivoryBgEnd = Color(0xFFF5EFE2);
  static const Color goldDark = Color(0xFF9E7E38);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color navyAccent = Color(0xFF0F1E36);

  @override
  Widget build(BuildContext context) {
    final String customText = event.displayInvitationText;
    final String timeText = event.displayInvitationTime;

    return Center(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: ivoryBgStart,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: goldDark.withOpacity(0.15),
              blurRadius: 35,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: navyAccent.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // خلفية تدرج عاجي ناعم
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ivoryBgStart, ivoryBgEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // نقوش عربسك في الزاوية العلوية اليمنى
              Positioned(
                top: -40,
                right: -40,
                child: Opacity(
                  opacity: 0.18,
                  child: CustomPaint(
                    size: const Size(200, 200),
                    painter: _ArabesquePainter(color: goldDark),
                  ),
                ),
              ),

              // نقوش عربسك في الزاوية السفلية اليسرى
              Positioned(
                bottom: -40,
                left: -40,
                child: Opacity(
                  opacity: 0.18,
                  child: CustomPaint(
                    size: const Size(200, 200),
                    painter: _ArabesquePainter(color: goldDark),
                  ),
                ),
              ),

              // إطار داخلي رفيع جداً ومزخرف
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: goldAccent.withOpacity(0.35),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // المحتوى الرئيسي
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    
                    // شعار النجمة الثمانية الإسلامية (Islamic Star)
                    CustomPaint(
                      size: const Size(40, 40),
                      painter: _IslamicStarPainter(color: goldAccent),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'بسم الله الرحمن الرحيم',
                      style: GoogleFonts.amiri(
                        fontSize: 17,
                        color: goldDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // فاصل خطي مزخرف
                    _buildDecorativeDivider(),

                    const SizedBox(height: 20),

                    // نص الدعوة
                    Text(
                      customText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: navyAccent.withOpacity(0.85),
                        height: 1.7,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // اسم العروسين / المناسبة بخط عريض وفخم
                    Text(
                      event.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: navyAccent,
                        height: 1.25,
                        shadows: [
                          Shadow(
                            color: goldAccent.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // تفاصيل الحفل
                    _buildDetailRow(Icons.calendar_month_rounded,
                        'التاريخ: ${event.date.toString().split(' ')[0]}'),
                    const SizedBox(height: 10),
                    _buildDetailRow(Icons.access_time_filled_rounded,
                        'الساعة: $timeText'),
                    const SizedBox(height: 10),
                    _buildDetailRow(Icons.location_on_rounded,
                        'المكان: ${event.location}'),

                    const SizedBox(height: 32),

                    // الـ QR Code داخل حاوية مصممة بعناية
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: goldAccent.withOpacity(0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: goldDark.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: guest.qrToken,
                            version: QrVersions.auto,
                            size: 110.0,
                            foregroundColor: navyAccent,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: ivoryBgEnd,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: goldAccent.withOpacity(0.2),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              guest.name,
                              style: GoogleFonts.cairo(
                                color: navyAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // تذييل
                    Text(
                      'دعوتكم تسرنا حضوركم يشرفنا',
                      style: GoogleFonts.amiri(
                        fontSize: 14,
                        color: goldDark,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الدخول عبر الرمز المخصص فقط',
                      style: GoogleFonts.cairo(
                        fontSize: 9,
                        color: navyAccent.withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildDecorativeDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 1,
          color: goldAccent.withOpacity(0.6),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(
            Icons.brightness_5_rounded,
            size: 12,
            color: goldAccent,
          ),
        ),
        Container(
          width: 50,
          height: 1,
          color: goldAccent.withOpacity(0.6),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: goldAccent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: goldAccent.withOpacity(0.15),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: goldDark),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: navyAccent.withOpacity(0.85),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// يرسم زخرفة عربية هندسية رقيقة
class _ArabesquePainter extends CustomPainter {
  final Color color;
  _ArabesquePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // دوائر متداخلة
    for (int r = 20; r <= maxRadius; r += 20) {
      canvas.drawCircle(center, r.toDouble(), paint);
    }

    // خطوط شعاعية
    final int lines = 12;
    for (int i = 0; i < lines; i++) {
      final double angle = (i * 2 * math.pi) / lines;
      final end = Offset(
        center.dx + maxRadius * math.cos(angle),
        center.dy + maxRadius * math.sin(angle),
      );
      canvas.drawLine(center, end, paint);
    }

    // زهور منحنية متداخلة
    final path = Path();
    for (int i = 0; i < lines; i++) {
      final double angle = (i * 2 * math.pi) / lines;
      final cp1 = Offset(
        center.dx + (maxRadius * 0.4) * math.cos(angle - 0.2),
        center.dy + (maxRadius * 0.4) * math.sin(angle - 0.2),
      );
      final dest = Offset(
        center.dx + (maxRadius * 0.8) * math.cos(angle),
        center.dy + (maxRadius * 0.8) * math.sin(angle),
      );
      path.moveTo(center.dx, center.dy);
      path.quadraticBezierTo(cp1.dx, cp1.dy, dest.dx, dest.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// يرسم نجمة ثمانية إسلامية معينات متقاطعة
class _IslamicStarPainter extends CustomPainter {
  final Color color;
  _IslamicStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final double radius = w / 2;

    // المربع الأول (مستقيم)
    final path1 = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy)
      ..close();

    // المربع الثاني (مدور بـ 45 درجة)
    final double offset = radius * math.cos(math.pi / 4);
    final path2 = Path()
      ..moveTo(center.dx - offset, center.dy - offset)
      ..lineTo(center.dx + offset, center.dy - offset)
      ..lineTo(center.dx + offset, center.dy + offset)
      ..lineTo(center.dx - offset, center.dy + offset)
      ..close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);

    // دائرة صغيرة في المنتصف
    canvas.drawCircle(center, 4, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
