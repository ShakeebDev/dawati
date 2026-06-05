import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

/// قالب غروب الصحراء (Desert Sunset) - تدرجات غروب الشمس الدافئة (البرتقالي الترابي والبني المهوجني) مع تموجات رملية ذهبية
class DesertSunsetCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const DesertSunsetCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  static const Color orangeTerracotta = Color(0xFFC85A32);
  static const Color brownDeep = Color(0xFF3B1E17);
  static const Color sandWarm = Color(0xFFF4E3C1);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color creamWhite = Color(0xFFFFFDF9);

  @override
  Widget build(BuildContext context) {
    final String customText = event.displayInvitationText;
    final String timeText = event.displayInvitationTime;

    return Center(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: brownDeep,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: brownDeep.withOpacity(0.4),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: orangeTerracotta.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // تدرج غروب الصحراء (برتقالي ترابي إلى بني دافئ عميق)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [orangeTerracotta, Color(0xFF8B3A1C), brownDeep],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // تموجات الكثبان الرملية الذهبية في الأسفل والأعلى
              Positioned.fill(
                child: CustomPaint(
                  painter: _SandDunesPainter(),
                ),
              ),

              // إطار رملي رفيع مزين
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sandWarm.withOpacity(0.25),
                        width: 1.0,
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

                    // أيقونة شمس الغروب التقليدية / زخرفة هندسية دائرية
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: goldAccent.withOpacity(0.4),
                          width: 1.2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.wb_twilight_rounded,
                          color: goldAccent,
                          size: 22,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // البسملة
                    Text(
                      'بسم الله الرحمن الرحيم',
                      style: GoogleFonts.amiri(
                        fontSize: 16,
                        color: sandWarm,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // فاصل مخصص
                    _buildDesertDivider(),

                    const SizedBox(height: 22),

                    // نص الدعوة
                    Text(
                      customText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: creamWhite.withOpacity(0.85),
                        height: 1.7,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // أسماء أصحاب الحفل بخط أميري كلاسيكي أنيق
                    Text(
                      event.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: sandWarm,
                        height: 1.25,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // معلومات المناسبة في بطاقات رملية دافئة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoPill(Icons.calendar_today_rounded,
                            event.date.toString().split(' ')[0]),
                        _buildInfoPill(Icons.access_time_rounded, timeText),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoPill(Icons.location_on_rounded, event.location,
                        isFullWidth: true),

                    const SizedBox(height: 32),

                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: creamWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: goldAccent.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: guest.qrToken,
                            version: QrVersions.auto,
                            size: 110.0,
                            foregroundColor: brownDeep,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: brownDeep.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              guest.name,
                              style: GoogleFonts.cairo(
                                color: brownDeep,
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
                      'أهلاً وسهلاً بالضيوف الكرام',
                      style: GoogleFonts.amiri(
                        fontSize: 15,
                        color: goldAccent,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'يرجى إبراز رمز الدخول عند بوابة القاعة',
                      style: GoogleFonts.cairo(
                        fontSize: 9,
                        color: sandWarm.withOpacity(0.5),
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

  Widget _buildDesertDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 40, height: 1, color: goldAccent.withOpacity(0.4)),
        const SizedBox(width: 8),
        Icon(Icons.filter_hdr_rounded, size: 14, color: goldAccent.withOpacity(0.8)),
        const SizedBox(width: 8),
        Container(width: 40, height: 1, color: goldAccent.withOpacity(0.4)),
      ],
    );
  }

  Widget _buildInfoPill(IconData icon, String text,
      {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: sandWarm.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: sandWarm.withOpacity(0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: goldAccent),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: creamWhite.withOpacity(0.9),
                fontWeight: FontWeight.w500,
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

/// يرسم تموجات وكثبان رملية ناعمة في أسفل وخلفية الكارت
class _SandDunesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // كثيب رملي أول داكن نسبياً في الخلفية السفلية
    paint.color = const Color(0xFF3B1E17).withOpacity(0.25);
    final path1 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.62, size.width, size.height * 0.75)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, paint);

    // كثيب رملي ثانٍ فاتح ومشرق متداخل
    paint.color = const Color(0xFFD4AF37).withOpacity(0.08);
    final path2 = Path()
      ..moveTo(0, size.height * 0.76)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.84, size.width, size.height * 0.68)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, paint);

    // تموج رملي صغير علوي ناعم جداً
    paint.color = const Color(0xFFF4E3C1).withOpacity(0.05);
    final path3 = Path()
      ..moveTo(0, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.18, size.width, size.height * 0.28)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
