import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

/// قالب جلامور الليل (Midnight Glam) - تصميم أسود فاخر وعصري مع خطوط فضية وبراقة هندسية
class MidnightGlamCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const MidnightGlamCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  static const Color darkBgStart = Color(0xFF0A0D14);
  static const Color darkBgEnd = Color(0xFF161C27);
  static const Color silverPrimary = Color(0xFFE2E8F0);
  static const Color silverAccent = Color(0xFFCBD5E1);
  static const Color silverDark = Color(0xFF64748B);
  static const Color accentBlue = Color(0xFF38BDF8);

  @override
  Widget build(BuildContext context) {
    final String customText = event.displayInvitationText;
    final String timeText = event.displayInvitationTime;

    return Center(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: darkBgStart,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.65),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: silverAccent.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // تدرج أسود رمادي داكن عميق جداً
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [darkBgStart, darkBgEnd],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // خطوط فضية هندسية رفيعة متقاطعة
              Positioned.fill(
                child: CustomPaint(
                  painter: _SilverLinesPainter(),
                ),
              ),

              // توهج ضوئي خفيف في الزاوية
              Positioned(
                top: -80,
                left: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        silverAccent.withOpacity(0.04),
                        silverAccent.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // إطار داخلي فضي أنيق
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: silverAccent.withOpacity(0.15),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

              // المحتوى الرئيسي
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),

                    // أيقونة شارة فضية هندسية
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: silverAccent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.all_inclusive_rounded,
                          color: silverPrimary,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // البسملة بخط ذهبي خافت/فضي
                    Text(
                      'بسم الله الرحمن الرحيم',
                      style: GoogleFonts.amiri(
                        fontSize: 16,
                        color: silverAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // فاصل فضي دقيق جداً
                    Container(
                      width: 80,
                      height: 1,
                      color: silverAccent.withOpacity(0.3),
                    ),

                    const SizedBox(height: 24),

                    // نص الدعوة
                    Text(
                      customText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: silverPrimary.withOpacity(0.9),
                        height: 1.7,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // اسم العروسين / الفعالية بخط أميري ملكي
                    Text(
                      event.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                          Shadow(
                            color: silverAccent.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // تفاصيل الحفل بتصميم بطاقة عصرية شبه شفافة
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: silverAccent.withOpacity(0.1),
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

                    const SizedBox(height: 32),

                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: silverAccent.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
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
                            foregroundColor: darkBgStart,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: darkBgStart.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              guest.name,
                              style: GoogleFonts.cairo(
                                color: darkBgStart,
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
                      'الدخول عبر الرمز المخصص لحامل البطاقة',
                      style: GoogleFonts.cairo(
                        fontSize: 9,
                        color: silverDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: silverAccent),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: silverPrimary.withOpacity(0.85),
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

/// يرسم شبكة خطوط فضية رفيعة وأشكال ماسية لتعطي طابع هندسي فاخر وعصري
class _SilverLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1).withOpacity(0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();

    // خطوط قطرية متقاطعة
    for (double i = -size.width; i < size.width * 2; i += 60) {
      path.moveTo(i, 0);
      path.lineTo(i + size.height, size.height);

      path.moveTo(i + size.height, 0);
      path.lineTo(i, size.height);
    }

    canvas.drawPath(path, paint);

    // رسم ماسة كبيرة خافتة في منتصف الجزء العلوي والسفلي
    final centerTop = Offset(size.width / 2, size.height * 0.15);
    final diamondPath = Path()
      ..moveTo(centerTop.dx, centerTop.dy - 30)
      ..lineTo(centerTop.dx + 30, centerTop.dy)
      ..lineTo(centerTop.dx, centerTop.dy + 30)
      ..lineTo(centerTop.dx - 30, centerTop.dy)
      ..close();

    canvas.drawPath(
        diamondPath, paint..color = const Color(0xFFCBD5E1).withOpacity(0.04));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
