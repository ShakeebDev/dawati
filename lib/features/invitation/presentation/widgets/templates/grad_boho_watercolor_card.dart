import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

class GradBohoWatercolorCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const GradBohoWatercolorCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  @override
  Widget build(BuildContext context) {
    const Color backgroundWarm = Color(0xFFF7F4EF);
    const Color oliveGreen = Color(0xFF7E8F75);
    const Color terracotta = Color(0xFFC88A75);
    const Color deepOlive = Color(0xFF3F4E3F);

    final String invitationText = event.displayInvitationText.isNotEmpty
        ? event.displayInvitationText
        : EventModel.getDefaultText(event.eventType);
    final String timeText = event.displayInvitationTime;
    final String eventName = event.name.isNotEmpty ? event.name : 'حفل التخرج';
    final String location =
        event.location.isNotEmpty ? event.location : 'موقع الحفل';

    return Center(
      child: Container(
        width: width,
        constraints: const BoxConstraints(minHeight: 650),
        decoration: BoxDecoration(
          color: backgroundWarm,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // رسم أوراق زيتون بوهيمية بالخلفية
              Positioned.fill(
                child: CustomPaint(
                  painter: _BohoFloraPainter(
                    leafColor: oliveGreen,
                    flowerColor: terracotta,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 25),
                    
                    // إكليل أوراق الزيتون حول قبعة التخرج
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                        border: Border.all(color: oliveGreen.withOpacity(0.3), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: oliveGreen.withOpacity(0.08),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.school_outlined,
                          color: deepOlive,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // النص البوهيمي الأنيق
                    Text(
                      'CONGRATULATIONS',
                      style: GoogleFonts.cinzel(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: terracotta,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // اسم الخريج / الجهة
                    Text(
                      eventName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: deepOlive,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // الترحيب
                    Text(
                      'بكل حب وامتنان، يسرنا دعوتكم لمشاركتنا البهجة والاحتفال بمناسبة نجاحنا وتخرجنا وتتويج سنين الجد والمثابرة بالحصاد الجميل',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: deepOlive.withOpacity(0.75),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // نص الدعوة المخصص
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: oliveGreen.withOpacity(0.2), width: 0.8),
                      ),
                      child: Text(
                        invitationText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight: FontWeight.normal,
                          color: deepOlive.withOpacity(0.9),
                          height: 1.65,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // التاريخ والوقت والقاعة بتصميم بوهيمي مسطح
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: oliveGreen.withOpacity(0.15), width: 0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoRow(Icons.calendar_month_outlined, 'التاريخ', event.date.toString().split(' ')[0], deepOlive),
                          _buildInfoRow(Icons.access_time, 'الوقت', timeText, deepOlive),
                          _buildInfoRow(Icons.location_on_outlined, 'القاعة', location, deepOlive),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),

                    // رمز الـ QR
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.15)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: guest.qrToken,
                            version: QrVersions.auto,
                            size: 80.0,
                            foregroundColor: deepOlive,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          guest.name,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: deepOlive,
                          ),
                        ),
                        Text(
                          'دعوة شخصية مخصصة للضيف',
                          style: GoogleFonts.cairo(
                            fontSize: 9,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
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

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color.withOpacity(0.7)),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 8.5, color: Colors.grey[600], fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _BohoFloraPainter extends CustomPainter {
  final Color leafColor;
  final Color flowerColor;

  _BohoFloraPainter({required this.leafColor, required this.flowerColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. بقع ألوان مائية لطيفة في الخلفية
    final paintWater = Paint()..style = PaintingStyle.fill;
    
    // بقعة مائية علوية يسار
    paintWater.color = flowerColor.withOpacity(0.06);
    canvas.drawCircle(Offset(0, 60), 100, paintWater);
    
    // بقعة مائية سفلية يمين
    paintWater.color = leafColor.withOpacity(0.06);
    canvas.drawCircle(Offset(size.width, size.height - 80), 120, paintWater);

    // 2. رسم ورقة شجر فنية في الركن العلوي يمين
    final stemPaint = Paint()
      ..color = leafColor.withOpacity(0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    
    // فرع شجرة علوي يمين
    final pathStem = Path()
      ..moveTo(size.width, 0)
      ..quadraticBezierTo(size.width * 0.8, 40, size.width * 0.7, 100);
    canvas.drawPath(pathStem, stemPaint);

    final leafFillPaint = Paint()
      ..color = leafColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // أوراق صغيرة على طول الفرع
    canvas.drawOval(Rect.fromLTWH(size.width * 0.78, 25, 20, 10), leafFillPaint);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.72, 60, 18, 9), leafFillPaint);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.65, 90, 15, 8), leafFillPaint);

    // 3. فرع شجرة بوهيمي في الركن السفلي يسار
    final pathStem2 = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.2, size.height - 40, size.width * 0.3, size.height - 100);
    canvas.drawPath(pathStem2, stemPaint);

    canvas.drawOval(Rect.fromLTWH(size.width * 0.12, size.height - 45, 20, 10), leafFillPaint);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.22, size.height - 75, 18, 9), leafFillPaint);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.28, size.height - 105, 15, 8), leafFillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
