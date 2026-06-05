import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

/// قالب رومانسي ناعم (Blush Romance) - ألوان وردية هادئة وزخارف بتلات متطايرة مع واجهة زجاجية
class BlushRomanceCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const BlushRomanceCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  static const Color blushPinkStart = Color(0xFFFFF0F2);
  static const Color blushPinkEnd = Color(0xFFFFD1D8);
  static const Color roseDark = Color(0xFFC06C84);
  static const Color roseLight = Color(0xFFF8B195);
  static const Color slateBlue = Color(0xFF355C7D);

  @override
  Widget build(BuildContext context) {
    final String customText = event.displayInvitationText;
    final String timeText = event.displayInvitationTime;

    return Center(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: blushPinkStart,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: roseDark.withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // تدرج وردي ناعم
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [blushPinkStart, blushPinkEnd],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // بتلات ورد متطايرة
              Positioned.fill(
                child: CustomPaint(
                  painter: _PetalsPainter(),
                ),
              ),

              // هالة بيضاء ناعمة في المركز لزيادة المقروئية
              Positioned(
                top: 80,
                bottom: 80,
                left: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // المحتوى
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),

                    // أيقونة القلبين المتشابكين
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_rounded, color: roseDark.withOpacity(0.5), size: 16),
                        const SizedBox(width: 6),
                        Icon(Icons.favorite_rounded, color: roseDark, size: 24),
                        const SizedBox(width: 6),
                        Icon(Icons.favorite_rounded, color: roseDark.withOpacity(0.5), size: 16),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // البسملة
                    Text(
                      'بسم الله الرحمن الرحيم',
                      style: GoogleFonts.amiri(
                        fontSize: 16,
                        color: roseDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // خط فاصل لطيف
                    _buildSoftDivider(),

                    const SizedBox(height: 20),

                    // نص الدعوة
                    Text(
                      customText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: slateBlue.withOpacity(0.9),
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // أسماء العروسين
                    Text(
                      event.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: slateBlue,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // معلومات المناسبة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoBadge(Icons.calendar_today_rounded,
                            event.date.toString().split(' ')[0]),
                        _buildInfoBadge(Icons.access_time_rounded, timeText),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoBadge(Icons.location_on_rounded, event.location,
                        isFullWidth: true),

                    const SizedBox(height: 32),

                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: roseDark.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: roseDark.withOpacity(0.06),
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
                            size: 110.0,
                            foregroundColor: slateBlue,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: blushPinkStart,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              guest.name,
                              style: GoogleFonts.cairo(
                                color: slateBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // تذييل الحفل
                    Text(
                      'حضوركم بهجة لأيامنا ومشاركتكم فرحتنا 🌸',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: roseDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الرمز مخصص لضيف واحد فقط',
                      style: GoogleFonts.cairo(
                        fontSize: 9,
                        color: slateBlue.withOpacity(0.6),
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

  Widget _buildSoftDivider() {
    return Container(
      width: 120,
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            roseDark.withOpacity(0.4),
            roseDark,
            roseDark.withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text,
      {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: roseDark.withOpacity(0.15),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: roseDark),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: slateBlue.withOpacity(0.85),
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

/// يرسم بتلات زهور متطايرة بشكل ناعم وجميل
class _PetalsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC06C84).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // بتلة علوية يمنى
    canvas.save();
    canvas.translate(size.width * 0.85, size.height * 0.12);
    canvas.rotate(-0.4);
    _drawPetal(canvas, paint);
    canvas.restore();

    // بتلة أخرى قريبة
    canvas.save();
    canvas.translate(size.width * 0.92, size.height * 0.2);
    canvas.rotate(0.2);
    _drawPetal(canvas, paint, scale: 0.7);
    canvas.restore();

    // بتلات سفلية يسرى
    canvas.save();
    canvas.translate(size.width * 0.12, size.height * 0.85);
    canvas.rotate(2.3);
    _drawPetal(canvas, paint, scale: 1.1);
    canvas.restore();

    canvas.save();
    canvas.translate(size.width * 0.08, size.height * 0.75);
    canvas.rotate(1.8);
    _drawPetal(canvas, paint, scale: 0.6);
    canvas.restore();
  }

  void _drawPetal(Canvas canvas, Paint paint, {double scale = 1.0}) {
    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(10 * scale, -15 * scale, 25 * scale, -10 * scale, 20 * scale, 15 * scale)
      ..cubicTo(15 * scale, 30 * scale, -5 * scale, 25 * scale, 0, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
