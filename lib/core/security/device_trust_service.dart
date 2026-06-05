import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawati/core/storage/secure_storage_service.dart';

/// خدمة التحقق من ثقة الجهاز (Device Trust Service)
/// توفر بصمة أمنية للجهاز (Hardware Fingerprint) مع الحفاظ على الخصوصية (Privacy-aware)
/// وتوفر Installation ID فريد لكل عملية تثبيت لربطه بسجلات التدقيق والمزامنة.
class DeviceTrustService {
  final SecureStorageService _secureStorage;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  DeviceTrustService(this._secureStorage);

  /// يحصل على الـ Installation ID الفريد لهذا الجهاز
  /// يتم توليده مرة واحدة وحفظه في SecureStorage
  Future<String> getInstallationId() async {
    return await _secureStorage.getOrCreateDeviceId();
  }

  /// يولد بصمة فريدة للجهاز مبنية على خصائص الهاردوير
  /// البصمة مُشفرة (Hashed) بحيث لا يمكن استرجاع الخصائص الأصلية منها (Privacy-aware)
  Future<String> getSecureHardwareFingerprint() async {
    String rawFingerprint = '';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        rawFingerprint = '${androidInfo.brand}:${androidInfo.model}:${androidInfo.board}:${androidInfo.hardware}:${androidInfo.supportedAbis.join(',')}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        rawFingerprint = '${iosInfo.name}:${iosInfo.systemName}:${iosInfo.systemVersion}:${iosInfo.model}:${iosInfo.identifierForVendor}';
      } else {
        rawFingerprint = 'unsupported_platform_${Platform.operatingSystem}';
      }
    } catch (e) {
      // Fallback in case device_info fails
      rawFingerprint = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }

    // لضمان الخصوصية، لا نرسل الخصائص بشكل صريح، بل نرسل الهاش الخاص بها
    final bytes = utf8.encode(rawFingerprint);
    final digest = sha256.convert(bytes);
    
    return digest.toString();
  }

  /// دمج الـ Installation ID مع Hardware Fingerprint لتكوين بصمة ثقة كاملة
  Future<String> getFullDeviceTrustToken() async {
    final installationId = await getInstallationId();
    final hardwareFingerprint = await getSecureHardwareFingerprint();
    
    return '$installationId.$hardwareFingerprint';
  }
  Future<bool> isDeviceTrusted() async {
    final trustedDevices = await _secureStorage.getTrustedDevices();
    final currentDevice = await getFullDeviceTrustToken();
    return trustedDevices.contains(currentDevice);
  }

  Future<void> registerTrustedDevice() async {
    final currentDevice = await getFullDeviceTrustToken();
    await _secureStorage.addTrustedDevice(currentDevice);
  }
}
final deviceTrustServiceProvider = Provider<DeviceTrustService>((ref) {
  return DeviceTrustService(SecureStorageService());
});
