import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  static const String _dbEncryptionKeyName = 'db_encryption_key';
  static const String _lastSyncTimeKey = 'last_sync_time';

  SecureStorageService() : _storage = const FlutterSecureStorage();

  Future<void> saveToken(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getToken(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteToken(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// استرجاع أو إنشاء مفتاح تشفير آمن 256-bit لقاعدة البيانات المحلية
  Future<String> getOrCreateDbEncryptionKey() async {
    String? existingKey = await _storage.read(key: _dbEncryptionKeyName);
    
    if (existingKey != null && existingKey.isNotEmpty) {
      return existingKey;
    }

    // إذا لم يكن هناك مفتاح، قم بإنشاء مفتاح آمن عشوائي (32 بايت = 256 بت)
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    final newKey = base64UrlEncode(keyBytes);

    // حفظ المفتاح في التخزين الآمن (Keystore / Keychain)
    await _storage.write(key: _dbEncryptionKeyName, value: newKey);
    
    return newKey;
  }

  /// استرجاع أو إنشاء معرّف الجهاز (Device ID) الموثوق
  Future<String> getOrCreateDeviceId() async {
    const String deviceIdKey = 'trusted_device_id';
    String? deviceId = await _storage.read(key: deviceIdKey);
    
    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }

    // توليد Device ID جديد (UUID)
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    // تنسيق بسيط لـ UUID 
    final newId = base64UrlEncode(bytes).replaceAll('=', '');

    await _storage.write(key: deviceIdKey, value: newId);
    return newId;
  }

  Future<List<String>> getTrustedDevices() async {
    final devicesStr = await _storage.read(key: 'trusted_devices_list');
    if (devicesStr == null || devicesStr.isEmpty) return [];
    return List<String>.from(jsonDecode(devicesStr));
  }

  Future<void> addTrustedDevice(String deviceToken) async {
    final devices = await getTrustedDevices();
    if (!devices.contains(deviceToken)) {
      devices.add(deviceToken);
      await _storage.write(key: 'trusted_devices_list', value: jsonEncode(devices));
    }
  }

  /// تحديث وقت آخر مزامنة للكشف عن التلاعب بالوقت (Clock Drift Protection)
  Future<void> updateLastSyncTime() async {
    await _storage.write(
      key: _lastSyncTimeKey, 
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// الحصول على وقت آخر مزامنة بالملي ثانية
  Future<int?> getLastSyncTime() async {
    final timeStr = await _storage.read(key: _lastSyncTimeKey);
    if (timeStr == null || timeStr.isEmpty) return null;
    return int.tryParse(timeStr);
  }
}


