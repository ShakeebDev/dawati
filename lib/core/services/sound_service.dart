import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// حالة النغمة المراد تشغيلها
enum SoundType {
  success,
  failure,
  offlineSuccess,
  syncStarted,
  syncCompleted,
  vipSuccess,
}

/// خدمة التأثيرات الصوتية والاهتزاز (Acoustic Feedback System)
class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;

  /// كتم الصوت (للحالات التي تتطلب هدوء)
  void setMuted(bool muted) {
    _isMuted = muted;
  }

  /// تشغيل تأثير صوتي واهتزاز متوافق مع الحالة
  Future<void> playFeedback(SoundType type) async {
    // 1. تشغيل الاهتزاز (Haptic/Vibration Feedback)
    _playVibration(type);

    // 2. تشغيل الصوت إذا لم يكن مكتوماً
    if (!_isMuted) {
      await _playSound(type);
    }
  }

  Future<void> _playVibration(SoundType type) async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) return;

    switch (type) {
      case SoundType.success:
        // اهتزاز خفيف وناعم للنجاح
        if (await Vibration.hasCustomVibrationsSupport() ?? false) {
          Vibration.vibrate(pattern: [0, 50, 50, 50], intensities: [0, 100, 0, 255]);
        } else {
          HapticFeedback.lightImpact();
        }
        break;
      case SoundType.failure:
        // اهتزاز طويل وعنيف للفشل/الرفض
        if (await Vibration.hasCustomVibrationsSupport() ?? false) {
          Vibration.vibrate(pattern: [0, 200, 100, 300], intensities: [0, 255, 0, 255]);
        } else {
          HapticFeedback.heavyImpact();
        }
        break;
      case SoundType.offlineSuccess:
        // اهتزاز ثلاثي هادئ للأوفلاين
        if (await Vibration.hasCustomVibrationsSupport() ?? false) {
          Vibration.vibrate(pattern: [0, 40, 40, 40, 40, 40]);
        } else {
          HapticFeedback.mediumImpact();
        }
        break;
      case SoundType.syncStarted:
      case SoundType.syncCompleted:
        // اهتزاز سريع جداً للمزامنة
        HapticFeedback.selectionClick();
        break;
      case SoundType.vipSuccess:
        // اهتزاز مميز وقوي لكبار الشخصيات
        if (await Vibration.hasCustomVibrationsSupport() ?? false) {
          Vibration.vibrate(pattern: [0, 80, 50, 80, 50, 150]);
        } else {
          HapticFeedback.heavyImpact();
        }
        break;
    }
  }

  Future<void> _playSound(SoundType type) async {
    try {
      // TODO: إضافة ملفات mp3 في مجلد assets/sounds/ وتحديث pubspec.yaml
      // حالياً سنستخدم أصوات النظام الافتراضية كبديل مؤقت (Fallback)
      switch (type) {
        case SoundType.success:
          // await _audioPlayer.play(AssetSource('sounds/success_beep.mp3'));
          SystemSound.play(SystemSoundType.click);
          break;
        case SoundType.failure:
          // await _audioPlayer.play(AssetSource('sounds/error_alert.mp3'));
          SystemSound.play(SystemSoundType.alert);
          break;
        case SoundType.offlineSuccess:
          // await _audioPlayer.play(AssetSource('sounds/offline_beep.mp3'));
          SystemSound.play(SystemSoundType.click);
          break;
        case SoundType.syncStarted:
        case SoundType.syncCompleted:
          // await _audioPlayer.play(AssetSource('sounds/sync_chime.mp3'));
          break;
        case SoundType.vipSuccess:
          // VIP double click fallback
          SystemSound.play(SystemSoundType.click);
          await Future.delayed(const Duration(milliseconds: 100));
          SystemSound.play(SystemSoundType.click);
          break;
      }
    } catch (e) {
      // التجاهل بصمت في حال عدم توفر الصوت
    }
  }
}

final soundServiceProvider = Provider<SoundService>((ref) {
  return SoundService();
});
