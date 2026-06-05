import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

/// قالب الزهور المائية الذهبية (Golden Watercolor Flora) - تصميم بوهيمي فاخر وعصري يجمع بين خلفية الألوان المائية الخضراء وخطوط أوراق الذهب الدقيقة
class GoldenWatercolorFloraCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const GoldenWatercolorFloraCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  static const Color darkEmerald = Color(0xFF0F2C24);
  static const Color lightEmerald = Color(0xFF1E463C);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color softGold = Color(0xFFF7E7C4);
  static const Color textWhite = Color(0xFFF4F6F4);

  @override
  Widget build(BuildContext context) {
    final String customText = event.displayInvitationText;
    final String timeText = event.displayInvitationTime;

    return Center(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: darkEmerald,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
          border: Border.all(
            color: goldAccent.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // 1. تدرج الألوان المائية الزمردية العميقة في الخلفية
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [darkEmerald, lightEmerald, Color(0xFF081C17)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // 2. تدرج دائري محاكي للألوان المائية الخافتة
              Positioned(
                top: -50,
                left: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF28544B).withOpacity(0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 3. رسم أوراق ونقوش ذهبية رفيعة وفاخرة بوهيمية في الأركان
              Positioned.fill(
                child: CustomPaint(
                  painter: _GoldenFloraPainter(),
                ),
              ),

              // 4. إطار مزدوج داخلي ذهبي دقيق
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: goldAccent.withOpacity(0.28),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

              // 5. المحتوى الرئيسي الأنيق
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // تاج ذهبي/شارة ناعمة
                    Icon(
                      Icons.spa_outlined,
                      color: goldAccent.withOpacity(0.9),
                      size: 24,
                    ),

                    const SizedBox(height: 14),

                    // البسملة
                    Text(
                      'بسم الله الرحمن الرحيم',
                      style: GoogleFonts.amiri(
                        fontSize: 16,
                        color: softGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // فاصل مذهب
                    _buildGoldDivider(),

                    const SizedBox(height: 20),

                    // نص الدعوة
                    Text(
                      customText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: textWhite.withOpacity(0.85),
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // أسماء العروسين بخط ذهبي كبير متوهج
                    Text(
                      event.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: goldAccent,
                        height: 1.25,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.7),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                          Shadow(
                            color: softGold.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // تفاصيل الحفل بتصميم بطاقة عصرية شبه شفافة
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: goldAccent.withOpacity(0.18),
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.calendar_today_rounded,
                              'التاريخ: ${event.date.toString().split(' ')[0]}'),
                          const Divider(color: Colors.white10, height: 12),
                          _buildDetailRow(
                              Icons.access_time_rounded, 'الساعة: $timeText'),
                          const Divider(color: Colors.white10, height: 12),
                          _buildDetailRow(Icons.location_on_rounded,
                              'الموقع: ${event.location}'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // رمز الاستجابة السريعة (QR Code) المتوهج نيونياً
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: goldAccent.withOpacity(0.35),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
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
                            size: 95.0,
                            foregroundColor: darkEmerald,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: darkEmerald.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              guest.name,
                              style: GoogleFonts.cairo(
                                color: darkEmerald,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // تذييل ذهبي
                    Text(
                      'الدخول عبر الرمز المخصص لحامل البطاقة فقط ⚜️',
                      style: GoogleFonts.cairo(
                        fontSize: 9.5,
                        color: softGold.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'حضوركم تشريف يزدان به حفلنا ونرجو لكم قضاء أجمل الأوقات',
                      style: GoogleFonts.cairo(
                        fontSize: 8,
                        color: textWhite.withOpacity(0.4),
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
      width: 110,
      height: 1.2,
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

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: softGold),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: textWhite.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// يرسم فروع أوراق شجر وريش ذهبية بوهيمية رفيعة للغاية لتعبر عن الفخامة اليدوية الفنية
class _GoldenFloraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // دالة لرسم ورقة شجر بوهيمية ذهبية ريشية
    void drawGoldenLeaf(double startX, double startY, double length, double angle, double scale) {
      canvas.save();
      canvas.translate(startX, startY);
      canvas.rotate(angle);
      canvas.scale(scale);

      final leafPath = Path();
      // الغصن الرئيسي
      leafPath.moveTo(0, 0);
      leafPath.lineTo(0, length);
      
      // الأوراق الفرعية الريشية
      for (double y = 10; y < length; y += 12) {
        final double lWidth = (length - y) * 0.35;
        // ورقة يمنى
        leafPath.moveTo(0, y);
        leafPath.quadraticBezierTo(lWidth, y - 6, lWidth * 0.8, y - 12);
        // ورقة يسرى
        leafPath.moveTo(0, y);
        leafPath.quadraticBezierTo(-lWidth, y - 6, -lWidth * 0.8, y - 12);
      }
      canvas.drawPath(leafPath, goldPaint);
      canvas.restore();
    }

    // فرع أوراق ذهبية في الركن العلوي الأيمن متدلي لأسفل
    drawGoldenLeaf(size.width * 0.88, 20, 80, 0.45, 0.95);
    drawGoldenLeaf(size.width * 0.95, 30, 60, 0.15, 0.8);

    // فرع أوراق ذهبية في الركن السفلي الأيسر نبت لأعلى
    drawGoldenLeaf(size.width * 0.12, size.height - 20, 80, -0.45 + math.pi, 0.95);
    drawGoldenLeaf(size.width * 0.05, size.height - 30, 60, -0.15 + math.pi, 0.8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
