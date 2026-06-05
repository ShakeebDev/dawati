import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../../core/security/device_trust_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class DeviceTrustScreen extends ConsumerStatefulWidget {
  const DeviceTrustScreen({super.key});

  @override
  ConsumerState<DeviceTrustScreen> createState() => _DeviceTrustScreenState();
}

class _DeviceTrustScreenState extends ConsumerState<DeviceTrustScreen> {
  bool _isLoading = true;
  bool _isTrusting = false;
  String _deviceName = 'جاري التحقق...';
  bool _isTrusted = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final trustService = ref.read(deviceTrustServiceProvider);
    
    // Check trust status
    final isTrusted = await trustService.isDeviceTrusted();
    
    // Get device name
    final deviceInfo = DeviceInfoPlugin();
    String name = 'جهاز غير معروف';
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        name = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        name = iosInfo.name;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _deviceName = name;
        _isTrusted = isTrusted;
        _isLoading = false;
      });
    }
  }

  Future<void> _trustDevice() async {
    setState(() => _isTrusting = true);
    final trustService = ref.read(deviceTrustServiceProvider);
    
    try {
      await trustService.registerTrustedDevice();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم توثيق الجهاز بنجاح.'), backgroundColor: Colors.green),
        );
        final user = ref.read(authProvider).user;
        context.go(user?.isStaff == true ? '/scanner' : '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء توثيق الجهاز: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isTrusting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.goldPrimary)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('أمان الجهاز'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(
              _isTrusted ? Icons.verified_user_rounded : Icons.shield_rounded,
              size: 100,
              color: _isTrusted ? Colors.green : AppTheme.goldPrimary,
            ),
            const SizedBox(height: 24),
            const Text(
              'توثيق الجهاز',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'لأسباب أمنية، يجب توثيق هذا الجهاز قبل استخدامه في النظام. سيتم ربط هذا الجهاز بحسابك.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildInfoRow('اسم الجهاز:', _deviceName),
                  const Divider(),
                  _buildInfoRow('حالة الثقة:', _isTrusted ? 'موثوق' : 'غير موثوق', 
                    valueColor: _isTrusted ? Colors.green : Colors.red),
                ],
              ),
            ),
            const Spacer(),
            if (_isTrusted)
              ElevatedButton(
                onPressed: () {
                  final user = ref.read(authProvider).user;
                  context.go(user?.isStaff == true ? '/scanner' : '/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldPrimary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('متابعة'),
              )
            else
              ElevatedButton.icon(
                onPressed: _isTrusting ? null : _trustDevice,
                icon: _isTrusting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.verified_user_outlined),
                label: Text(_isTrusting ? 'جاري التوثيق...' : 'توثيق هذا الجهاز'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldPrimary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: valueColor ?? Colors.black)),
      ],
    );
  }
}
