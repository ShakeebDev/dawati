import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

class NightMajestyCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const NightMajestyCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  @override
  Widget build(BuildContext context) {
    const Color roseGold = Color(0xFFB76E79);
    const Color deepBackground = Color(0xFF1A1412);
    const Color lightRoseGold = Color(0xFFE0BFB8);

    final String customText = event.displayInvitationText;
    final String timeText = event.displayInvitationTime;

    return Center(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: deepBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. Velvet Curtain Effect
              Positioned.fill(
                child: CustomPaint(
                  painter: _VelvetCurtainPainter(),
                ),
              ),

              // 2. Stars / Glitter
              Positioned.fill(
                child: CustomPaint(
                  painter: _StarGlitterPainter(),
                ),
              ),

              // 3. Flower Decorations & Candles at the bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildFooterDecorations(),
              ),

              // 4. Content
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // العنوان العلوي
                    Text(
                      'بطاقة دخول',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        letterSpacing: 3,
                        color: lightRoseGold.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 30,
                      height: 1,
                      color: roseGold.withOpacity(0.4),
                    ),

                    const SizedBox(height: 16),

                    // نص الدعوة المخصص (أعلى العبارة الرئيسية)
                    if (customText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          customText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // أيقونة نوع الحفل
                    Icon(
                      _getEventTypeIcon(event.eventType),
                      color: lightRoseGold.withOpacity(0.6),
                      size: 26,
                    ),

                    const SizedBox(height: 8),

                    // اسم المناسبة (تحت نص الدعوة والضيف)
                    Text(
                      event.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 30,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                        color: roseGold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // المعلومات التنظيمية
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(
                              color: roseGold.withOpacity(0.2), width: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoItem(Icons.access_time_rounded,
                              'الاستقبال', timeText),
                          _buildDivider(),
                          _buildInfoItem(Icons.location_on_outlined, 'القاعة',
                              event.location),
                          _buildDivider(),
                          _buildInfoItem(Icons.calendar_month_outlined,
                              'التاريخ', event.date.toString().split(' ')[0]),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: roseGold.withOpacity(0.15)),
                      ),
                      child: QrImageView(
                        data: guest.qrToken,
                        version: QrVersions.auto,
                        size: 90.0,
                        foregroundColor: lightRoseGold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      guest.name,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'الدعوة شخصية – الدخول بالرمز فقط',
                      style: GoogleFonts.cairo(
                        fontSize: 9,
                        color: roseGold.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Minimal Logo
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: roseGold.withOpacity(0.3), width: 1),
                      ),
                      child: Center(
                        child: Text(
                          'M',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: roseGold,
                          ),
                        ),
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

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFB76E79)),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 10, color: Colors.white38),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 0.5,
      height: 30,
      color: const Color(0xFFB76E79).withOpacity(0.2),
    );
  }

  Widget _buildFooterDecorations() {
    return SizedBox(
      height: 140,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Background Glow for Flowers
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFFB76E79).withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Flowers (Stylized Icons)
          Positioned(
            bottom: -10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(8, (i) {
                final colors = [
                  const Color(0xFFB76E79), // Pink
                  const Color(0xFFE8B4A2), // Peach
                  const Color(0xFFF5EDD8), // Beige
                  const Color(0xFF8B5E5E), // Rose Brown
                ];
                return Transform.translate(
                  offset: Offset(0, i % 2 == 0 ? 10 : 0),
                  child: Icon(
                    Icons.filter_vintage_rounded,
                    size: 50 + (i % 3) * 10.0,
                    color: colors[i % colors.length].withOpacity(0.8),
                  ),
                );
              }),
            ),
          ),

          // Candles
          Positioned(
            bottom: 20,
            left: 40,
            child: _buildCandle(40),
          ),
          Positioned(
            bottom: 20,
            left: 60,
            child: _buildCandle(60),
          ),
          Positioned(
            bottom: 20,
            right: 50,
            child: _buildCandle(50),
          ),
        ],
      ),
    );
  }

  Widget _buildCandle(double height) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Flame
        Container(
          width: 8,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFFFDB933),
            borderRadius: BorderRadius.all(Radius.elliptical(4, 6)),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFDB933),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        // Wax
        Container(
          width: 14,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5DC), // Cream
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            gradient: LinearGradient(
              colors: [
                const Color(0xFFF5F5DC),
                const Color(0xFFE5E5C0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getEventTypeIcon(String type) {
    switch (type) {
      case 'wedding':
        return Icons.favorite_rounded;
      case 'graduation':
        return Icons.school_rounded;
      case 'birthday':
        return Icons.cake_rounded;
      case 'dinner':
        return Icons.restaurant_rounded;
      default:
        return Icons.celebration_rounded;
    }
  }
}

class _VelvetCurtainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.black.withOpacity(0.8),
          Colors.black.withOpacity(0.4),
          Colors.black.withOpacity(0.8),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        tileMode: TileMode.repeated,
      ).createShader(Rect.fromLTWH(0, 0, 40, size.height));

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawRect(Rect.fromLTWH(i, 0, 40, size.height), paint);
    }

    // Smooth top glow
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFB76E79).withOpacity(0.15),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, 200));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 200), glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarGlitterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Basic LCG random for deterministic glitter
    int seed = 42;
    final paint = Paint()..color = const Color(0xFFD4AF37).withOpacity(0.4);

    for (int i = 0; i < 50; i++) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final x = (seed / 0x7fffffff) * size.width;
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final y = (seed / 0x7fffffff) * (size.height * 0.4);
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final radius = (seed / 0x7fffffff) * 1.5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
