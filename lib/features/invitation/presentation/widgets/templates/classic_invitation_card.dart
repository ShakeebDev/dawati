import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassicInvitationCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const ClassicInvitationCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  @override
  Widget build(BuildContext context) {
    // استخدام الحقول المساعدة لجلب البيانات المدمجة
    final String customText = event.displayInvitationText;
    final String timeText = event.displayInvitationTime;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldPrimary.withOpacity(0.12),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Floral Ornaments
            Positioned(
              top: -15,
              right: -15,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.local_florist_rounded,
                    size: 140, color: AppTheme.goldPrimary),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.local_florist_rounded,
                    size: 140, color: AppTheme.goldPrimary),
              ),
            ),

            Positioned.fill(
              child: CustomPaint(
                painter: _FlowerBorderPainter(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. بسم الله الرحمن الرحيم
                  Text(
                    'بسم الله الرحمن الرحيم',
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldDark,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2. نص الدعوة الذي يكتبه المستخدم
                  Text(
                    customText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      height: 1.6,
                      color: AppTheme.navyPrimary.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. عنوان الدعوة (اسم المناسبة)
                  Text(
                    event.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navyPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3. التاريخ والساعة والموقع
                  _buildInfoRow(Icons.calendar_today_rounded,
                      'التاريخ: ${event.date.toString().split(' ')[0]}'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                      Icons.access_time_filled_rounded, 'الساعة: $timeText'),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                      Icons.location_on_rounded, 'الموقع: ${event.location}'),

                  const SizedBox(height: 48),

                  // 4. الباركود (QR Code)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppTheme.goldPrimary.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: guest.qrToken,
                      version: QrVersions.auto,
                      size: 130.0,
                      foregroundColor: AppTheme.navyPrimary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 5. اسم الضيف
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                            color: AppTheme.goldPrimary.withOpacity(0.2),
                            width: 0.5),
                      ),
                    ),
                    child: Text(
                      'المكرم: ${guest.name}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.goldDark,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: AppTheme.goldPrimary),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.navyPrimary.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}

class _FlowerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.goldPrimary.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const m = 18.0; // margin

    final path = Path();
    const l = 40.0; // line length

    path.moveTo(m, m + l);
    path.lineTo(m, m);
    path.lineTo(m + l, m);
    path.moveTo(size.width - m - l, m);
    path.lineTo(size.width - m, m);
    path.lineTo(size.width - m, m + l);
    path.moveTo(size.width - m, size.height - m - l);
    path.lineTo(size.width - m, size.height - m);
    path.lineTo(size.width - m - l, size.height - m);
    path.moveTo(m + l, size.height - m);
    path.lineTo(m, size.height - m);
    path.lineTo(m, size.height - m - l);

    canvas.drawPath(path, paint..strokeWidth = 2.0);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            m + 5, m + 5, size.width - (m + 5) * 2, size.height - (m + 5) * 2),
        const Radius.circular(15),
      ),
      paint..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
