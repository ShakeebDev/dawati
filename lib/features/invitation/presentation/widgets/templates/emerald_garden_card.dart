import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

/// قالب الحديقة الزمردية - خضرة فاخرة مع لمسات ذهبية وزخارف نباتية
class EmeraldGardenCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const EmeraldGardenCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  static const Color emeraldDeep = Color(0xFF0D3B2E);
  static const Color emeraldMid = Color(0xFF1A5940);
  static const Color emeraldLight = Color(0xFF2D8A5E);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color creamWhite = Color(0xFFF5F0E8);
  static const Color leafGreen = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    final String customText = event.displayInvitationText;
    final String timeText = event.displayInvitationTime;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: emeraldDeep,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: emeraldMid.withOpacity(0.4),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: goldAccent.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // خلفية تدرج
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [emeraldDeep, emeraldMid, Color(0xFF163D2A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // نقوش نباتية - أوراق كبيرة في الزوايا
            Positioned(
              top: -30,
              right: -30,
              child: CustomPaint(
                size: const Size(160, 160),
                painter: _LeafClusterPainter(
                    color: emeraldLight, rotation: -0.3),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: CustomPaint(
                size: const Size(160, 160),
                painter: _LeafClusterPainter(
                    color: emeraldLight, rotation: 2.5),
              ),
            ),

            // توهج ذهبي خفي في المنتصف
            Positioned(
              top: width * 0.25,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      goldAccent.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // المحتوى
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // شعار الزهرة العلوي
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: goldAccent.withOpacity(0.5), width: 1.5),
                      gradient: RadialGradient(
                        colors: [
                          goldAccent.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: const Icon(Icons.local_florist_rounded,
                        color: goldAccent, size: 26),
                  ),

                  const SizedBox(height: 16),

                  // السطر الأول
                  Text(
                    'بسم الله الرحمن الرحيم',
                    style: GoogleFonts.amiri(
                      fontSize: 16,
                      color: goldAccent.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // فاصل ذهبي
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 0.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                goldAccent.withOpacity(0.6)
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.spa_rounded,
                            color: goldAccent.withOpacity(0.8), size: 18),
                      ),
                      Expanded(
                        child: Container(
                          height: 0.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                goldAccent.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // نص الدعوة
                  Text(
                    customText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: creamWhite.withOpacity(0.85),
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // اسم المناسبة
                  Text(
                    event.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: creamWhite,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // معلومات المناسبة في بطاقات صغيرة
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
                      fullWidth: true),

                  const SizedBox(height: 28),

                  // QR Code في إطار زمردي/ذهبي
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: creamWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: goldAccent.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: emeraldDeep.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: guest.qrToken,
                          version: QrVersions.auto,
                          size: 120.0,
                          foregroundColor: emeraldDeep,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: emeraldDeep.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            guest.name,
                            style: GoogleFonts.cairo(
                              color: emeraldDeep,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // تذييل
                  Text(
                    'الدعوة شخصية • دخول بالرمز فقط',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: goldAccent.withOpacity(0.6),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text,
      {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: emeraldLight.withOpacity(0.25),
        borderRadius: BorderRadius.circular(30),
        border:
            Border.all(color: goldAccent.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: goldAccent),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: creamWhite.withOpacity(0.85),
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

class _LeafClusterPainter extends CustomPainter {
  final Color color;
  final double rotation;

  _LeafClusterPainter({required this.color, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);

    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      canvas.save();
      canvas.rotate(i * (2 * math.pi / 5));
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(20, -40, 0, -70)
        ..quadraticBezierTo(-20, -40, 0, 0);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
