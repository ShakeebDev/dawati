import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:google_fonts/google_fonts.dart';

class RoyalInvitationCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const RoyalInvitationCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  @override
  Widget build(BuildContext context) {
    // الحصول على البيانات من خلال الحقول المساعدة
    final String customText = event.displayInvitationText;
    final String timeText = event.displayInvitationTime;

    return Center(
      child: Container(
        width: width,
        constraints: const BoxConstraints(minHeight: 560),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFBF7),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(Icons.auto_awesome,
                      size: 180, color: AppTheme.goldPrimary),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.eco, size: 200, color: AppTheme.goldDark),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'بسم الله الرحمن الرحيم',
                      style: GoogleFonts.amiri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.goldDark,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      customText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: AppTheme.navyPrimary.withOpacity(0.8),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      event.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navyPrimary,
                        height: 1.2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          const Expanded(
                              child: Divider(
                                  color: AppTheme.goldPrimary,
                                  thickness: 0.5,
                                  indent: 40)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(_getEventTypeIcon(event.eventType),
                                color: AppTheme.goldPrimary, size: 24),
                          ),
                          const Expanded(
                              child: Divider(
                                  color: AppTheme.goldPrimary,
                                  thickness: 0.5,
                                  endIndent: 40)),
                        ],
                      ),
                    ),
                    _buildDetailRow(Icons.calendar_today_outlined,
                        'التاريخ: ${event.date.toString().split(' ')[0]}'),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        Icons.access_time_outlined, 'الساعة: $timeText'),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.location_on_outlined,
                        'الموقع: ${event.location}'),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: guest.qrToken,
                            version: QrVersions.auto,
                            size: 110.0,
                            foregroundColor: AppTheme.navyPrimary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            guest.name,
                            style: GoogleFonts.cairo(
                              color: AppTheme.navyPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'الدعوة شخصية – الدخول عبر رمز QR فقط',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppTheme.goldDark),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.navyPrimary.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
