import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/core/utils/app_utils.dart';

class GuestLimitUpgradeDialog extends StatelessWidget {
  final int? currentLimit;

  const GuestLimitUpgradeDialog({
    super.key,
    this.currentLimit,
  });

  /// دالة مساعدة لفتح النافذة المنبثقة بسهولة من أي مكان
  static void show(BuildContext context, {int? currentLimit}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GuestLimitUpgradeDialog(currentLimit: currentLimit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final limit = currentLimit ?? 50;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark 
                  ? AppTheme.goldPrimary.withOpacity(0.15) 
                  : AppTheme.goldPrimary.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.goldPrimary.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // خلفية نيون متوهجة خفيفة في الأعلى
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.goldPrimary.withOpacity(isDark ? 0.08 : 0.12),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    // 1. الأيقونة المتوهجة المتحركة
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.goldPrimary.withOpacity(0.1),
                          border: Border.all(
                            color: AppTheme.goldPrimary.withOpacity(0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.goldPrimary.withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: AppTheme.goldPrimary,
                          size: 42,
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .scale(
                         duration: 1.5.seconds,
                         curve: Curves.easeInOut,
                         begin: const Offset(1.0, 1.0),
                         end: const Offset(1.08, 1.08),
                       ),
                    ),
                    const SizedBox(height: 20),

                    // 2. العنوان الرئيسي
                    Text(
                      'تجاوزت الحد الأقصى للضيوف',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: isDark ? Colors.white : AppTheme.navyPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 3. النص التوضيحي بالحد الفعلي
                    Text(
                      'لقد وصلت للحد الأقصى المسموح به للضيوف في باقتك الحالية (حد باقة Free هو $limit ضيفاً للمناسبة).',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. جدول المقارنة الفاخر للباقات
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.white.withOpacity(0.02) 
                            : Colors.black.withOpacity(0.015),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark 
                              ? Colors.white.withOpacity(0.05) 
                              : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildPlanRow(
                            context: context,
                            feature: 'عدد الضيوف في المناسبة',
                            freeVal: '$limit ضيوف فقط',
                            proVal: 'عدد غير محدود',
                            isHighlight: true,
                          ),
                          const Divider(height: 16),
                          _buildPlanRow(
                            context: context,
                            feature: 'عدد المناسبات النشطة',
                            freeVal: 'مناسبة واحدة',
                            proVal: 'مناسبات غير محدودة',
                          ),
                          const Divider(height: 16),
                          _buildPlanRow(
                            context: context,
                            feature: 'موظفو استقبال لتنظيم البوابات',
                            freeVal: 'غير متاح',
                            proVal: 'متاح (طاقم عمل كامل)',
                          ),
                          const Divider(height: 16),
                          _buildPlanRow(
                            context: context,
                            feature: 'دعم فني متكامل وخاص',
                            freeVal: 'عادي',
                            proVal: 'أولوية 24/7 ⚡',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 5. أزرار الإجراءات
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF25D366),
                                  Color(0xFF128C7E),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF25D366).withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                              label: const Text(
                                'ترقية الباقة الآن',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => _launchUpgradeWhatsApp(context, limit),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanRow({
    required BuildContext context,
    required String feature,
    required String freeVal,
    required String proVal,
    bool isHighlight = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            feature,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            freeVal,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isHighlight ? AppTheme.error : (isDark ? Colors.white38 : Colors.black38),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            proVal,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.success,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchUpgradeWhatsApp(BuildContext context, int limit) async {
    Navigator.pop(context);
    const phoneNumber = '967738180731';
    final message = 'مرحباً، لقد تجاوزت الحد الأقصى للضيوف المسموح به ($limit ضيفاً) في باقتي الحالية على تطبيق دعوتي. أرغب في ترقية حسابي إلى الباقة الاحترافية (Pro Plan) لإتاحة ضيوف غير محدودين للمناسبة.';
    final url = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        AppUtils.showSnackBar(
          context,
          'فشل فتح تطبيق الواتساب. رقم الدعم للترقية: 738180731',
          isError: true,
        );
      }
    }
  }
}
