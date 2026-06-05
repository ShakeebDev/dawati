import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

class GraduationWatercolorCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const GraduationWatercolorCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  @override
  Widget build(BuildContext context) {
    const Color parchment = Color(0xFFF4EFEA);
    const Color earthyPink = Color(0xFFC9897B);
    const Color brownishPink = Color(0xFF8B6B5C);
    const Color mainText = Color(0xFF333333);

    final String timeText = event.displayInvitationTime;

    return Center(
      child: Container(
        width: width,
        constraints: const BoxConstraints(minHeight: 680),
        decoration: BoxDecoration(
          color: parchment,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // التصميم العلوي
              Column(
                children: [
                  const SizedBox(height: 40),
                  // English Title
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'happy ',
                          style: GoogleFonts.engagement(
                            fontSize: 28,
                            color: mainText,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: 'GRADUATION',
                          style: GoogleFonts.cormorant(
                            fontSize: 24,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w600,
                            color: earthyPink,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // نص تعريفي عربي
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'نتشرف بدعوتكم لمشاركتنا فرحة الإنجاز وحضور الحفل السنوي',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        height: 1.6,
                        color: mainText.withOpacity(0.8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // العنوان الرئيسي العربي مع أيقونة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school_outlined,
                          size: 20, color: earthyPink),
                      const SizedBox(width: 8),
                      Text(
                        event.name,
                        style: GoogleFonts.arefRuqaa(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: earthyPink,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // تفاصيل الحدث
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                            color: brownishPink.withOpacity(0.1), width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildColumnInfo(
                            Icons.access_time, 'الوقت', timeText, brownishPink),
                        _buildDivider(brownishPink),
                        _buildColumnInfo(
                            Icons.calendar_today_outlined,
                            'التاريخ',
                            event.date.toString().split(' ')[0],
                            brownishPink),
                        _buildDivider(brownishPink),
                        _buildColumnInfo(
                            Icons.location_city_outlined,
                            'المكان',
                            event.location.length > 10
                                ? '${event.location.substring(0, 10)}...'
                                : event.location,
                            brownishPink),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: earthyPink.withOpacity(0.2), width: 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: QrImageView(
                      data: guest.qrToken,
                      version: QrVersions.auto,
                      size: 85,
                      foregroundColor: brownishPink,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    guest.name,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: mainText,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // الشخصية (Illustration) - تم تعديل الحجم والموضع للتكامل مع الزهور
                  // SizedBox(
                  //   height: 160,
                  //   child: ColorFiltered(
                  //     colorFilter: ColorFilter.mode(
                  //       earthyPink.withOpacity(0.05),
                  //       BlendMode.colorBurn,
                  //     ),
                  //     child: Image.asset(
                  //       'assets/images/grad_girl_watercolor.png',
                  //       fit: BoxFit.contain,
                  //       errorBuilder: (context, _, __) =>
                  //           const Icon(Icons.person_outline, size: 60),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 30),
                ],
              ),

              // الزهور السفلية
              // Positioned(
              //   bottom: 0,
              //   left: 0,
              //   right: 0,
              //   child: Image.asset(
              //     'assets/images/flowers_border.png',
              //     fit: BoxFit.cover,
              //     height: 100,
              //     alignment: Alignment.bottomCenter,
              //     errorBuilder: (context, _, __) =>
              //         Container(height: 40, color: earthyPink.withOpacity(0.1)),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumnInfo(
      IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color.withOpacity(0.7)),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 9, color: color.withOpacity(0.5)),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
              fontSize: 10, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildDivider(Color color) {
    return Container(
      height: 25,
      width: 0.5,
      color: color.withOpacity(0.2),
    );
  }
}
