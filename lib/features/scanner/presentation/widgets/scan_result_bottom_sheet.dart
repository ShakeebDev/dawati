import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/checkin_entity.dart';
import '../../../../core/services/sound_service.dart';

class ScanResultBottomSheet extends ConsumerStatefulWidget {
  final bool isSuccess;
  final CheckInEntity? successData;
  final String? errorMessage;
  final bool isOffline;

  const ScanResultBottomSheet({
    super.key,
    required this.isSuccess,
    this.successData,
    this.errorMessage,
    this.isOffline = false,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isSuccess,
    CheckInEntity? successData,
    String? errorMessage,
  }) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScanResultBottomSheet(
        isSuccess: isSuccess,
        successData: successData,
        errorMessage: errorMessage,
        isOffline: successData?.isOffline ?? false,
      ),
    );
  }

  @override
  ConsumerState<ScanResultBottomSheet> createState() => _ScanResultBottomSheetState();
}

class _ScanResultBottomSheetState extends ConsumerState<ScanResultBottomSheet> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    
    // تشغيل التأثير الصوتي المناسب
    SoundType type;
    if (widget.isSuccess) {
      final isVip = widget.successData?.isVip ?? false;
      if (isVip) {
        type = SoundType.vipSuccess;
      } else if (widget.isOffline) {
        type = SoundType.offlineSuccess;
      } else {
        type = SoundType.success;
      }
    } else {
      type = SoundType.failure;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(soundServiceProvider).playFeedback(type);
    });

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // مدة أطول قليلاً للسماح بالقراءة
    );

    _progressController.reverse(from: 1.0).then((_) {
      if (mounted && !_isPaused) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _progressController.stop();
      } else {
        _progressController.reverse(from: _progressController.value).then((_) {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isVip = widget.successData?.isVip ?? false;
    
    final Color baseColor;
    final IconData icon;
    if (!widget.isSuccess) {
      baseColor = Colors.red.shade600;
      icon = Icons.error_outline;
    } else if (isVip) {
      baseColor = const Color(0xFF7C3AED); // Purple VIP color
      icon = Icons.star_rounded;
    } else {
      baseColor = Colors.green.shade600;
      icon = Icons.check_circle_outline;
    }
    
    final Color sheetBackground = isVip ? const Color(0xFF1E0B4B) : Colors.white;
    final Color textColor = isVip ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: _togglePause,
      onVerticalDragDown: (_) => _togglePause(),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: sheetBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isVip ? const Color(0xFF7C3AED).withOpacity(0.4) : Colors.black26,
              blurRadius: isVip ? 35 : 20,
              offset: const Offset(0, 5),
            ),
          ],
          border: isVip ? Border.all(color: const Color(0xFFDBA5FF).withOpacity(0.3), width: 1.5) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // VIP Crown Badge
            if (isVip) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium_rounded, color: Colors.black, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'كبار الشخصيات VIP',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
              const SizedBox(height: 12),
            ],
            
            Icon(icon, color: isVip ? Colors.amber.shade300 : baseColor, size: 64)
                .animate()
                .scale(duration: 400.ms, curve: Curves.easeOutBack)
                .fadeIn(),

            const SizedBox(height: 12),

            Text(
              widget.isSuccess ? (isVip ? 'أهلاً وسهلاً بضيفنا الكريم' : 'تم تسجيل الدخول') : 'فشل الفحص',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isVip ? Colors.amber.shade300 : baseColor,
              ),
            ).animate().slideY(begin: 0.3, end: 0).fadeIn(),

            // حالة الأوفلاين (Sync Pending Badge)
            if (widget.isOffline) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync_rounded, size: 16, color: Colors.orange.shade800),
                    const SizedBox(width: 6),
                    Text(
                      'في انتظار المزامنة',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
            ],

            const SizedBox(height: 16),

            // تفاصيل النجاح
            if (widget.isSuccess && widget.successData != null) ...[
              _buildInfoRow('الضيف', widget.successData!.guestName, textColor: textColor),
              Divider(height: 8, color: isVip ? Colors.white.withOpacity(0.1) : null),
              _buildInfoRow(
                'المتبقي',
                '${widget.successData!.remainingEntries} دخول',
                valueColor: widget.successData!.remainingEntries > 0 ? Colors.green.shade400 : Colors.orange.shade400,
              ),
              if (widget.successData?.gateName != null) ...[
                Divider(height: 8, color: isVip ? Colors.white.withOpacity(0.1) : null),
                _buildInfoRow(
                  'البوابة',
                  widget.successData!.gateName!,
                  textColor: textColor,
                ),
              ],
            ] else if (widget.errorMessage != null) ...[
              Text(
                widget.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: isVip ? Colors.white70 : Colors.black87, height: 1.5),
              ).animate().fadeIn(delay: 200.ms),
            ],

            const SizedBox(height: 20),

            // مؤشر الإغلاق التلقائي تفاعلي (يتوقف عند اللمس)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    minHeight: 4,
                    value: _progressController.value,
                    backgroundColor: Colors.grey.shade200,
                    color: _isPaused ? Colors.grey.shade400 : baseColor.withValues(alpha: 0.6),
                  );
                },
              ),
            ),
            
            if (_isPaused)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'تم الإيقاف المؤقت، اضغط للاستئناف',
                  style: TextStyle(fontSize: 11, color: isVip ? Colors.white38 : Colors.grey.shade500),
                ).animate().fadeIn(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textColor?.withOpacity(0.6) ?? Colors.grey, fontSize: 15)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: valueColor ?? textColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0);
  }
}

