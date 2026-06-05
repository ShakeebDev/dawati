import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';

class ElegantMinimalGraduationCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const ElegantMinimalGraduationCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  @override
  Widget build(BuildContext context) {
    // Colors based on the description
    const Color ivoryBackground = Color(0xFFF9F5F1);
    const Color burgundy = Color(0xFF800020);
    const Color oliveGray = Color(0xFF556B2F);
    const Color darkBrown = Color(0xFF4A3728);
    const Color goldBeige = Color(0xFFD4AF37);
    const Color darkGray = Color(0xFF333333);

    return Center(
      child: Container(
        width: width,
        constraints: const BoxConstraints(minHeight: 650),
        decoration: BoxDecoration(
          color: ivoryBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // 1. الجزء العلوي - أيقونة نباتية للزينة
              Positioned(
                top: -10,
                left: -10,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Icon(
                    Icons.local_florist_outlined,
                    size: 100,
                    color: burgundy.withOpacity(0.08),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 100),

                    // 3. النص الرئيسي للدعوة
                    Text(
                      'ادعوكم لمشاركتي فرحتي',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        color: oliveGray,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Column(
                      children: [
                        Text(
                          'وذلك بمشيئة الله',
                          style: GoogleFonts.amiri(
                            fontSize: 22,
                            color: burgundy,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // خط زخرفي منحني
                        CustomPaint(
                          size: const Size(150, 10),
                          painter: DecorativeCurvePainter(color: burgundy),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 4. قسم معلومات الحدث
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      iconColor: darkBrown,
                      text: 'يوم الاثنين\n14 أبريل 2025',
                      label: 'التاريخ',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.access_time,
                      iconColor: goldBeige,
                      text: 'الساعة 9:00',
                      label: 'الوقت',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.location_on_outlined,
                      iconColor: darkGray,
                      text: 'مسرح المعهد العالي\nأبو سليم والتقنية الطبية',
                      label: 'الموقع',
                    ),

                    const SizedBox(height: 40),

                    // 6. النص الختامي
                    Text(
                      'بحضوركم تكتمل فرحتي',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        color: oliveGray,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // 7. اسم الخريجة
                    Text(
                      'أكريمة',
                      style: GoogleFonts.arefRuqaa(
                        fontSize: 34,
                        color: burgundy,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // 5. أيقونة التخرج التوضيحية (بديلة للصورة المحلية)
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: burgundy.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: burgundy.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String text,
    required String label,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: const Color(0xFF444444),
              height: 1.3,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ],
    );
  }
}

class DecorativeCurvePainter extends CustomPainter {
  final Color color;
  DecorativeCurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height / 2,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      0,
      size.width,
      size.height / 2,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
