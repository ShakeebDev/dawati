import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// أدوات مساعدة عامة للتطبيق
class AppUtils {
  AppUtils._();

  static const _uuid = Uuid();

  /// توليد رمز QR آمن فريد متوافق مع UUID
  static String generateSecureToken() {
    return _uuid.v4();
  }

  /// توليد UUID
  static String generateId() => _uuid.v4();

  /// تنسيق التاريخ بالعربية
  static String formatDateArabic(DateTime date) {
    final formatter = DateFormat('EEEE، d MMMM yyyy', 'ar');
    return formatter.format(date);
  }

  /// تنسيق الوقت
  static String formatTime(DateTime date) {
    final formatter = DateFormat('hh:mm a', 'ar');
    return formatter.format(date);
  }

  /// تنسيق التاريخ والوقت
  static String formatDateTimeArabic(DateTime date) {
    return '${formatDateArabic(date)} - ${formatTime(date)}';
  }

  /// تنسيق الأرقام العربية
  static String formatNumber(int number) {
    return NumberFormat('#,###', 'ar').format(number);
  }

  /// حساب نسبة مئوية
  static double calculatePercentage(int current, int total) {
    if (total == 0) return 0;
    return (current / total * 100).clamp(0, 100);
  }

  /// تقصير النص
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// تحقق من صحة رقم الهاتف السعودي
  static bool isValidSaudiPhone(String phone) {
    final regex = RegExp(r'^(05|5)[0-9]{8}$');
    return regex.hasMatch(phone.replaceAll('+966', '').replaceAll(' ', ''));
  }

  /// تحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  /// تنسيق رقم هاتف واتساب
  static String formatWhatsAppNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('0')) {
      cleaned = '967${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('967')) {
      cleaned = '967$cleaned';
    }
    return cleaned;
  }

  /// رسالة الواتساب للدعوة
  static String buildWhatsAppInviteMessage({
    required String guestName,
    required String eventName,
    required String eventDate,
    required String eventLocation,
  }) {
    return '''
مرحباً $guestName،

يسعدنا دعوتكم لحضور $eventName

📅 التاريخ: $eventDate
📍 الموقع: $eventLocation

رمز الدعوة الخاص بكم مرفق ✨

دعوتك بأناقة… دخول ذكي وآمن
''';
  }

  /// عرض رسالة تنبيه
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo()),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF0D1B3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
