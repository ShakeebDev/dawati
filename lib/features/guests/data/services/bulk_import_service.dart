import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/core/utils/app_utils.dart';

class BulkImportService {
  /// طلب صلاحية الوصول لجهات الاتصال
  static Future<bool> requestContactsPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  /// استيراد من جهات الاتصال
  static Future<List<GuestModel>> importFromContacts(String eventId) async {
    try {
      // طلب الصلاحية بشكل صريح باستخدام FlutterContacts
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        return [];
      }

      // جلب جهات الاتصال مع الخصائص
      final List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      List<GuestModel> guests = [];

      for (var contact in contacts) {
        if (contact.phones.isNotEmpty && contact.displayName.isNotEmpty) {
          // جلب أول رقم متاح وتصفيته من الرموز والمسافات
          String phone =
              contact.phones.first.number.replaceAll(RegExp(r'[\s\-\(\)]'), '');

          // Ensure the phone number is not empty after sanitization and trim any leading/trailing spaces
          phone = phone.trim();
          if (phone.isEmpty) continue;

          guests.add(GuestModel(
            id: '',
            eventId: eventId,
            name: contact.displayName,
            phone: phone,
            allowedEntries: 1,
            currentEntries: 0,
            qrToken: AppUtils.generateSecureToken(),
            status: 'pending',
            createdAt: DateTime.now(),
          ));
        }
      }
      return guests;
    } catch (e, stack) {
      print('Error during contacts import: $e');
      print(stack);
      return [];
    }
  }

  /// استيراد من ملف Excel/CSV
  static Future<List<GuestModel>> importFromCsv(String eventId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.single.path == null) return [];

    final input = File(result.files.single.path!).readAsStringSync();
    List<List<dynamic>> rows = const CsvToListConverter().convert(input);

    List<GuestModel> guests = [];
    // تخطي الرأس إذا كان موجوداً
    int startIndex = _isHeader(rows[0]) ? 1 : 0;

    for (var i = startIndex; i < rows.length; i++) {
      if (rows[i].length < 2) continue;

      guests.add(GuestModel(
        id: '',
        eventId: eventId,
        name: rows[i][0].toString(),
        phone: rows[i][1].toString(),
        allowedEntries:
            rows[i].length > 2 ? (int.tryParse(rows[i][2].toString()) ?? 1) : 1,
        currentEntries: 0,
        qrToken: AppUtils.generateSecureToken(),
        status: 'pending',
        createdAt: DateTime.now(),
      ));
    }
    return guests;
  }

  static bool _isHeader(List<dynamic> row) {
    if (row.isEmpty) return false;
    final first = row[0].toString().toLowerCase();
    return first.contains('name') ||
        first.contains('الاسم') ||
        first.contains('full name');
  }
}
