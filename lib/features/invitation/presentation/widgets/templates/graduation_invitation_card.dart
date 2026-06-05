import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

class GraduationInvitationCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;
  final String templateId;

  const GraduationInvitationCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
    required this.templateId,
  });

  @override
  Widget build(BuildContext context) {
    const Color backgroundWhite = Color(0xFFF9F9F9);
    const Color deepNavy = Color(0xFF0A1D37);
    const Color goldAccent = Color(0xFFD4B062);
    const Color darkGray = Color(0xFF333333);

    // استخراج النصوص المخصصة
    final String invitationText = event.displayInvitationText;
    final String timeText = event.displayInvitationTime;

    return Center(
      child: Container(
        width: width,
        constraints: const BoxConstraints(minHeight: 620),
        decoration: BoxDecoration(
          color: backgroundWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 25),

                  // الصورة المركزية (إطار بيضاوي مع رسمة التخرج) - تم نقله للأعلى وتصغيره
                  Container(
                    width: width * 0.45,
                    height: width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(width * 0.3),
                      border: Border.all(color: deepNavy, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: deepNavy.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(width * 0.3),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // تم حذف الصورة واستبدالها بأيقونة رسمية أنيقة
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: deepNavy.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.school_rounded,
                                size: 80, color: deepNavy),
                          ),
                          // زخارف خطية خفيفة في الخلفية
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.05,
                              child: CustomPaint(
                                  painter: _BackgroundPatternPainter()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  // شعار أو أيقونة ذهبية
                  const Icon(Icons.auto_awesome, color: goldAccent, size: 20),
                  const SizedBox(height: 10),

                  // عنوان الدعوة
                  Text(
                    'بطاقة دعوة',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkGray,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // نص الدعوة الرسمي
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'دعوة لحضور حفل تخرج الدفعة ${event.name}\n$invitationText',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: darkGray.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // تفاصيل الحدث (تاريخ | وقت | مكان)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                            color: deepNavy.withOpacity(0.1), width: 1),
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDetailItem('التاريخ',
                              event.date.toString().split(' ')[0], deepNavy),
                          _buildVerticalDivider(deepNavy),
                          _buildDetailItem('الوقت', timeText, deepNavy),
                          _buildVerticalDivider(deepNavy),
                          _buildDetailItem('المكان', event.location, deepNavy),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // رمز QR
                  QrImageView(
                    data: guest.qrToken,
                    version: QrVersions.auto,
                    size: 100.0,
                    foregroundColor: deepNavy,
                  ),

                  const SizedBox(height: 8),

                  // اسم الطالبة
                  Text(
                    'الطالبة: ${guest.name}',
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: deepNavy,
                    ),
                  ),

                  const SizedBox(height: 60), // مساحة للتصميم المتموج السفلي
                ],
              ),

              // التصميم المتموج السفلي (Footer)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 100,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CustomPaint(
                        size: Size(width, 100),
                        painter: _WavyFooterPainter(color: deepNavy),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'يرجى حضور شخص واحد فقط',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'إبراز الباركود عند الدخول',
                              style: GoogleFonts.cairo(
                                color: Colors.white70,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
                fontSize: 10,
                color: color.withOpacity(0.5),
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
                fontSize: 11, color: color, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(Color color) {
    return VerticalDivider(
      color: color.withOpacity(0.1),
      thickness: 1,
      width: 1,
      indent: 5,
      endIndent: 5,
    );
  }
}

class _WavyFooterPainter extends CustomPainter {
  final Color color;
  _WavyFooterPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.4);

    // موجة ناعمة
    var firstControlPoint = Offset(size.width * 0.25, size.height * 0.2);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.6);
    var secondEndPoint = Offset(size.width, size.height * 0.4);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 10; i++) {
      canvas.drawLine(
        Offset(0, i * 20.0),
        Offset(size.width, i * 25.0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
