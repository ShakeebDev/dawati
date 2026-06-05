import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

/// قالب الياسمين الدمشقي (Damask Jasmine) - تصميم شرقي عتيق وفاخر مع نقشات الياسمين والأطر الهندسية الأندلسية
class DamaskJasmineCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const DamaskJasmineCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  static const Color creamBg = Color(0xFFFDFBF7);
  static const Color jasmineGreen = Color(0xFF4A5D4E);
  static const Color jasmineOlive = Color(0xFF8BA88F);
  static const Color goldAccent = Color(0xFFC5A880);
  static const Color charcoalText = Color(0xFF2E3830);

  @override
  Widget build(BuildContext context) {
    final String customText = event.displayInvitationText;
    final String timeText = event.displayInvitationTime;

    return Center(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: creamBg,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: jasmineGreen.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
          border: Border.all(
            color: goldAccent.withOpacity(0.35),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // 1. زخرفة الخلفية الدائرية الأندلسية الخافتة
              Positioned.fill(
                child: CustomPaint(
                  painter: _JasminePatternPainter(),
                ),
              ),

              // 2. إطار ذهبي داخلي مزدوج وأنيق ومزين بالأركان
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: goldAccent.withOpacity(0.4),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: jasmineGreen.withOpacity(0.15),
                        width: 0.8,
                      ),
                    ),
                  ),
                ),
              ),

              // 3. المحتوى الأساسي للبطاقة مرتب كلاسيكياً
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // شارة دمشقية هندسية بالأعلى
                    _buildDamaskTopHeader(),

                    const SizedBox(height: 16),

                    // البسملة
                    Text(
                      'بسم الله الرحمن الرحيم',
                      style: GoogleFonts.amiri(
                        fontSize: 17,
                        color: jasmineGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // خط ياسمين الفاصل
                    _buildJasmineDivider(),

                    const SizedBox(height: 20),

                    // نص الدعوة
                    Text(
                      customText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: charcoalText.withOpacity(0.95),
                        height: 1.65,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // اسم الفعالية بالخط الثلث/الأميري العريض
                    Text(
                      event.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: jasmineGreen,
                        height: 1.25,
                        shadows: [
                          Shadow(
                            color: goldAccent.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // معلومات المناسبة مقسمة
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(
                              color: goldAccent.withOpacity(0.25), width: 0.8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDetailCol(Icons.access_time_filled_rounded,
                              'الاستقبال', timeText),
                          _buildDividerVertical(),
                          _buildDetailCol(Icons.location_on_rounded, 'القاعة',
                              event.location),
                          _buildDividerVertical(),
                          _buildDetailCol(Icons.calendar_month_rounded,
                              'التاريخ', event.date.toString().split(' ')[0]),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // رمز الـ QR Code الشرقي
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: goldAccent.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: jasmineGreen.withOpacity(0.04),
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
                            foregroundColor: charcoalText,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: jasmineGreen.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              guest.name,
                              style: GoogleFonts.cairo(
                                color: jasmineGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // تذييل أندلسي
                    Text(
                      'تبارك ليلتنا بحضوركم ويسعد جمعنا بوجودكم 🌿',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 10.5,
                        color: jasmineGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'حامل هذه البطاقة مدعو بصورة شخصية والرمز مخصص لدخول ضيف واحد',
                      style: GoogleFonts.cairo(
                        fontSize: 8,
                        color: charcoalText.withOpacity(0.45),
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

  Widget _buildDamaskTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.spa_rounded, color: goldAccent, size: 16),
        const SizedBox(width: 8),
        Container(
          width: 30,
          height: 1,
          color: goldAccent,
        ),
        const SizedBox(width: 8),
        Text(
          'دعوة زفاف',
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: jasmineGreen,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 30,
          height: 1,
          color: goldAccent,
        ),
        const SizedBox(width: 8),
        Icon(Icons.spa_rounded, color: goldAccent, size: 16),
      ],
    );
  }

  Widget _buildJasmineDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 30, height: 1, color: goldAccent.withOpacity(0.4)),
        const SizedBox(width: 6),
        Icon(Icons.local_florist_rounded, color: jasmineOlive, size: 14),
        const SizedBox(width: 6),
        Container(width: 30, height: 1, color: goldAccent.withOpacity(0.4)),
      ],
    );
  }

  Widget _buildDividerVertical() {
    return Container(
      width: 0.8,
      height: 32,
      color: goldAccent.withOpacity(0.3),
    );
  }

  Widget _buildDetailCol(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 15, color: jasmineOlive),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 9, color: charcoalText.withOpacity(0.5)),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: charcoalText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// يرسم زخارف خلفية أندلسية مكررة ونبتة ياسمين رقيقة عند الأركان
class _JasminePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final patternPaint = Paint()
      ..color = const Color(0xFFC5A880).withOpacity(0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // رسم شبكة معينات عربسك (Arabesque Grid)
    for (double i = -50; i < size.width + 50; i += 60) {
      for (double j = -50; j < size.height + 50; j += 60) {
        path.moveTo(i, j - 25);
        path.lineTo(i + 30, j);
        path.lineTo(i, j + 25);
        path.lineTo(i - 30, j);
        path.close();
      }
    }
    canvas.drawPath(path, patternPaint);

    // رسم نبتة ياسمين دمشقي خضراء ناعمة في الزاوية العلوية اليسرى والسفلية اليمنى
    final leafPaint = Paint()
      ..color = const Color(0xFF8BA88F).withOpacity(0.18)
      ..style = PaintingStyle.fill;
    final flowerPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    // دالة لرسم فرع ياسمين
    void drawJasmineBranch(double cx, double cy, double scale, double rotation) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rotation);
      canvas.scale(scale);

      // غصن ناعم
      final branchPaint = Paint()
        ..color = const Color(0xFF4A5D4E).withOpacity(0.15)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final bPath = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(20, 20, 10, 60);
      canvas.drawPath(bPath, branchPaint);

      // أوراق شجر خضراء
      void drawLeaf(double lx, double ly, double rot) {
        canvas.save();
        canvas.translate(lx, ly);
        canvas.rotate(rot);
        final lPath = Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(8, -12, 16, 0)
          ..quadraticBezierTo(8, 12, 0, 0);
        canvas.drawPath(lPath, leafPaint);
        canvas.restore();
      }

      drawLeaf(5, 15, 0.4);
      drawLeaf(12, 35, -0.6);
      drawLeaf(10, 55, 0.2);

      // أزهار ياسمين دائرية لطيفة
      void drawFlower(double fx, double fy) {
        canvas.drawCircle(Offset(fx, fy), 4, flowerPaint);
        canvas.drawCircle(Offset(fx - 3, fy - 3), 3, flowerPaint);
        canvas.drawCircle(Offset(fx + 3, fy - 3), 3, flowerPaint);
        canvas.drawCircle(Offset(fx - 3, fy + 3), 3, flowerPaint);
        canvas.drawCircle(Offset(fx + 3, fy + 3), 3, flowerPaint);
        canvas.drawCircle(Offset(fx, fy), 1.5, Paint()..color = const Color(0xFFC5A880));
      }

      drawFlower(6, 12);
      drawFlower(14, 40);

      canvas.restore();
    }

    drawJasmineBranch(24, 24, 0.9, 0.0);
    drawJasmineBranch(size.width - 24, size.height - 24, 0.9, math.pi);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
