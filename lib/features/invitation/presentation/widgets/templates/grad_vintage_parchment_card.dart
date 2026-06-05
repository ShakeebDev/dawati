import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

class GradVintageParchmentCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const GradVintageParchmentCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  @override
  Widget build(BuildContext context) {
    const Color parchmentBg = Color(0xFFF3EAD3);
    const Color borderWine = Color(0xFF6B2D1B);
    const Color goldAccent = Color(0xFFC5A059);
    const Color deepBlack = Color(0xFF2B221E);

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
          color: parchmentBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // رسم الحدود العتيقة للشهادة التقليدية
              Positioned.fill(
                child: CustomPaint(
                  painter: _ParchmentPainter(
                    borderColor: borderWine,
                    goldColor: goldAccent,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 25),
                    
                    // شعار التخرج الكلاسيكي المذهب (شارة ونجمة ثمانية)
                    Icon(
                      Icons.school_outlined,
                      color: borderWine,
                      size: 44,
                    ),
                    const SizedBox(height: 12),

                    // إشارة التقدير الأكاديمي للجامعة / المدرسة
                    Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      style: GoogleFonts.amiri(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: borderWine,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // عنوان التخرج
                    Text(
                      eventName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: borderWine,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // التمهيد
                    Text(
                      'يتشرف خريجونا بدعوتكم لحضور حفل التخرج وتتويج مسيرتنا الأكاديمية بالنجاح الباهر ومشاركتنا فرحة العمر الكبرى',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: deepBlack.withOpacity(0.85),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // نص الدعوة المخصص المكتوب بخط الثلث/الأميري الجميل
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: borderWine.withOpacity(0.2),
                          width: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        invitationText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          fontSize: 17,
                          fontWeight: FontWeight.normal,
                          color: deepBlack,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // جدول التفاصيل
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildRetroItem('التاريخ', event.date.toString().split(' ')[0], borderWine),
                        Container(width: 1, height: 25, color: borderWine.withOpacity(0.15)),
                        _buildRetroItem('الوقت', timeText, borderWine),
                        Container(width: 1, height: 25, color: borderWine.withOpacity(0.15)),
                        _buildRetroItem('المكان', location, borderWine),
                      ],
                    ),
                    const SizedBox(height: 35),

                    // الختم الشمعي التفاعلي والـ QR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // الـ QR
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderWine.withOpacity(0.2)),
                          ),
                          child: QrImageView(
                            data: guest.qrToken,
                            version: QrVersions.auto,
                            size: 72.0,
                            foregroundColor: deepBlack,
                          ),
                        ),

                        // الختم الشمعي الأحمر العتيق
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B0000), // Wax Red
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF6A0000), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.verified_rounded,
                                  color: goldAccent,
                                  size: 26,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'OFFICIAL SEAL',
                              style: GoogleFonts.outfit(
                                fontSize: 7.5,
                                fontWeight: FontWeight.bold,
                                color: borderWine,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // اسم المدعو
                    Text(
                      guest.name,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: borderWine,
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

  Widget _buildRetroItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 8.5, color: color.withOpacity(0.6), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.cairo(fontSize: 11, color: color, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ParchmentPainter extends CustomPainter {
  final Color borderColor;
  final Color goldColor;

  _ParchmentPainter({required this.borderColor, required this.goldColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double margin = 14.0;
    
    // 1. الإطار الداخلي المزدوج
    final linePaint = Paint()
      ..color = borderColor.withOpacity(0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(margin, margin, size.width - (margin * 2), size.height - (margin * 2)),
      linePaint,
    );

    // إطار مذهب رقيق جداً بالداخل
    final goldLinePaint = Paint()
      ..color = goldColor.withOpacity(0.5)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
      Rect.fromLTWH(margin + 4, margin + 4, size.width - ((margin + 4) * 2), size.height - ((margin + 4) * 2)),
      goldLinePaint,
    );

    // 2. نقوش الزوايا الأربع للوثيقة
    final double cornerSize = 15.0;
    
    final cornerPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // علوي يسار
    canvas.drawRect(Rect.fromLTWH(margin, margin, cornerSize, cornerSize), cornerPaint..style = PaintingStyle.stroke);
    // علوي يمين
    canvas.drawRect(Rect.fromLTWH(size.width - margin - cornerSize, margin, cornerSize, cornerSize), cornerPaint);
    // سفلي يسار
    canvas.drawRect(Rect.fromLTWH(margin, size.height - margin - cornerSize, cornerSize, cornerSize), cornerPaint);
    // سفلي يمين
    canvas.drawRect(Rect.fromLTWH(size.width - margin - cornerSize, size.height - margin - cornerSize, cornerSize, cornerSize), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
