import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

/// قالب زهور الساكورا (Sakura Blossom) - تصميم رائع بألوان وردية وتأثيرات أزهار الكرز المتساقطة ونقوش أغصان دقيقة
class SakuraBlossomCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const SakuraBlossomCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  static const Color sakuraLight = Color(0xFFFFF5F6);
  static const Color sakuraPink = Color(0xFFFFB7C5);
  static const Color sakuraDark = Color(0xFFD65A84);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color charcoalText = Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    final String customText = event.displayInvitationText;
    final String timeText = event.displayInvitationTime;

    return Center(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: sakuraLight,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: sakuraDark.withOpacity(0.12),
              blurRadius: 35,
              offset: const Offset(0, 15),
            ),
          ],
          border: Border.all(
            color: sakuraPink.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // 1. خلفية متدرجة وردية ناعمة للغاية
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [sakuraLight, Color(0xFFFFE3E8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // 2. رسم أغصان زهور الساكورا يدوياً في الأعلى والأسفل
              Positioned.fill(
                child: CustomPaint(
                  painter: _SakuraBranchPainter(),
                ),
              ),

              // 3. لوح زجاجي (Glassmorphism) ناصع وجميل في المنتصف لعرض النصوص
              Positioned(
                top: 40,
                bottom: 40,
                left: 18,
                right: 18,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.9),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: sakuraDark.withOpacity(0.03),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // 4. محتوى البطاقة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // أيقونة شارة ورد الساكورا
                    Icon(
                      Icons.filter_vintage_rounded,
                      color: sakuraDark.withOpacity(0.85),
                      size: 26,
                    ),

                    const SizedBox(height: 14),

                    // البسملة بخط عربي فخم
                    Text(
                      'بسم الله الرحمن الرحيم',
                      style: GoogleFonts.amiri(
                        fontSize: 16,
                        color: sakuraDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // فاصل مذهب
                    _buildGoldDivider(),

                    const SizedBox(height: 20),

                    // نص الدعوة الرئيسي
                    Text(
                      customText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: charcoalText.withOpacity(0.9),
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // أسماء العروسين بخط أميري ملكي كبير
                    Text(
                      event.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: sakuraDark,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: sakuraPink.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // معلومات المناسبة بتصميم شارات وردية
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoBadge(Icons.calendar_today_rounded,
                            event.date.toString().split(' ')[0]),
                        _buildInfoBadge(Icons.access_time_rounded, timeText),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildInfoBadge(Icons.location_on_rounded, event.location,
                        isFullWidth: true),

                    const SizedBox(height: 28),

                    // رمز الاستجابة السريعة (QR Code)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sakuraPink.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: sakuraDark.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: guest.qrToken,
                            version: QrVersions.auto,
                            size: 100.0,
                            foregroundColor: charcoalText,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: sakuraLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              guest.name,
                              style: GoogleFonts.cairo(
                                color: sakuraDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // تذييل لطيف
                    Text(
                      'حضوركم يكلل ليلتنا بالورد والسرور 🌸',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: sakuraDark.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الدخول عبر الرمز الإلكتروني المخصص لشخص واحد',
                      style: GoogleFonts.cairo(
                        fontSize: 8,
                        color: charcoalText.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoldDivider() {
    return Container(
      width: 100,
      height: 1.5,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            goldAccent,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: sakuraLight.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: sakuraPink.withOpacity(0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: sakuraDark),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: charcoalText.withOpacity(0.85),
                fontWeight: FontWeight.bold,
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

/// رسام لرسم أغصان وبتلات زهور الساكورا المبهجة والوردية
class _SakuraBranchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // رسم الأغصان البنية الداكنة
    final branchPaint = Paint()
      ..color = const Color(0xFF5D4037).withOpacity(0.2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // غصن علوي أيمن متفرع
    path.moveTo(size.width, 0);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.1, size.width * 0.7, size.height * 0.05);
    path.moveTo(size.width * 0.85, size.height * 0.075);
    path.quadraticBezierTo(size.width * 0.78, size.height * 0.18, size.width * 0.72, size.height * 0.2);

    // غصن سفلي أيسر متفرع
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.9, size.width * 0.3, size.height * 0.93);
    path.moveTo(size.width * 0.15, size.height * 0.925);
    path.quadraticBezierTo(size.width * 0.22, size.height * 0.82, size.width * 0.26, size.height * 0.8);

    canvas.drawPath(path, branchPaint);

    // رسم زهور الساكورا المتفتحة (نقاط وردية متدرجة بتنسيق فني)
    final flowerPaint = Paint()..style = PaintingStyle.fill;

    // دالة مساعدة لرسم زهرة مفردة من بتلات
    void drawFlower(Offset center, double radius, Color color) {
      flowerPaint.color = color;
      canvas.drawCircle(center, radius, flowerPaint);
      
      // رسم بتلات صغيرة حول مركز الزهرة
      final double petalDist = radius * 0.8;
      for (int i = 0; i < 5; i++) {
        final double angle = i * 2 * math.pi / 5;
        canvas.drawCircle(
          Offset(center.dx + petalDist * math.cos(angle), center.dy + petalDist * math.sin(angle)),
          radius * 0.7,
          Paint()..color = color.withOpacity(0.85),
        );
      }
      
      // نقطة ذهبية صغيرة في المركز
      canvas.drawCircle(center, radius * 0.35, Paint()..color = const Color(0xFFD4AF37));
    }

    // زهور في الفرع العلوي الأيمن
    drawFlower(Offset(size.width * 0.85, size.height * 0.06), 6, const Color(0xFFD65A84));
    drawFlower(Offset(size.width * 0.73, size.height * 0.05), 5, const Color(0xFFFFB7C5));
    drawFlower(Offset(size.width * 0.80, size.height * 0.15), 7, const Color(0xFFFFB7C5));
    drawFlower(Offset(size.width * 0.92, size.height * 0.12), 4, const Color(0xFFD65A84));

    // زهور في الفرع السفلي الأيسر
    drawFlower(Offset(size.width * 0.15, size.height * 0.93), 7, const Color(0xFFD65A84));
    drawFlower(Offset(size.width * 0.26, size.height * 0.92), 5, const Color(0xFFFFB7C5));
    drawFlower(Offset(size.width * 0.22, size.height * 0.83), 6, const Color(0xFFFFB7C5));
    drawFlower(Offset(size.width * 0.08, size.height * 0.86), 4, const Color(0xFFD65A84));

    // بتلات منفردة متساقطة في الخلفية بشكل عشوائي لطيف
    final petalPaint = Paint()
      ..color = const Color(0xFFFFB7C5).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    void drawFallenPetal(Offset pos, double angle, double scale) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle);
      final pPath = Path()
        ..moveTo(0, 0)
        ..cubicTo(4 * scale, -6 * scale, 10 * scale, -4 * scale, 8 * scale, 6 * scale)
        ..cubicTo(6 * scale, 12 * scale, -2 * scale, 10 * scale, 0, 0);
      canvas.drawPath(pPath, petalPaint);
      canvas.restore();
    }

    drawFallenPetal(Offset(size.width * 0.35, size.height * 0.25), 0.5, 0.9);
    drawFallenPetal(Offset(size.width * 0.65, size.height * 0.70), 1.2, 0.8);
    drawFallenPetal(Offset(size.width * 0.12, size.height * 0.38), -0.3, 1.0);
    drawFallenPetal(Offset(size.width * 0.88, size.height * 0.62), 2.1, 0.7);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
