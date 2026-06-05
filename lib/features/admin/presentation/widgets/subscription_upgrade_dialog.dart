import 'package:flutter/material.dart';
import 'package:dawati/core/theme/app_theme.dart';

class SubscriptionUpgradeDialog extends StatefulWidget {
  final String planName;
  final int? currentCustomEvents;
  final int? currentCustomGuests;
  final Function(int? customMaxEvents, int? customMaxGuests) onConfirm;

  const SubscriptionUpgradeDialog({
    super.key,
    required this.planName,
    this.currentCustomEvents,
    this.currentCustomGuests,
    required this.onConfirm,
  });

  @override
  State<SubscriptionUpgradeDialog> createState() => _SubscriptionUpgradeDialogState();
}

class _SubscriptionUpgradeDialogState extends State<SubscriptionUpgradeDialog> {
  late final TextEditingController _eventsController;
  late final TextEditingController _guestsController;

  @override
  void initState() {
    super.initState();
    _eventsController = TextEditingController(
      text: widget.currentCustomEvents?.toString() ?? '',
    );
    _guestsController = TextEditingController(
      text: widget.currentCustomGuests?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _eventsController.dispose();
    _guestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFree = widget.planName == 'Free Plan';
    final accentColor = widget.planName == 'Pro Plan' ? Colors.purple : AppTheme.goldPrimary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? (isDark ? Colors.grey.shade900 : Colors.white),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: accentColor.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.planName == 'Pro Plan' ? Icons.stars_rounded : Icons.card_membership_rounded,
                        color: accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'تعديل وتخصيص باقة الاشتراك',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سيتم تعديل باقة المنظم إلى (${widget.planName}). يمكنك ترك الحقول فارغة لتطبيق الحدود الافتراضية للباقة، أو إدخال قيم مخصصة لتجاوز الحدود الافتراضية:',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Events limit field
                    const Text(
                      'الحد الأقصى للمناسبات تاريخياً:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _eventsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: isFree ? 'الافتراضي: مناسبة واحدة (1)' : 'الافتراضي: غير محدود',
                        hintStyle: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                        prefixIcon: Icon(Icons.event_available_rounded, color: accentColor),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor.withOpacity(0.5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: accentColor, width: 1.5),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Guests limit field
                    const Text(
                      'الحد الأقصى للضيوف لكل مناسبة:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _guestsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: isFree ? 'الافتراضي: 50 ضيفاً' : 'الافتراضي: غير محدود',
                        hintStyle: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                        prefixIcon: Icon(Icons.people_alt_outlined, color: accentColor),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor.withOpacity(0.5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: accentColor, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
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
                            fontFamily: AppTheme.fontFamily,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final customEvents = int.tryParse(_eventsController.text.trim());
                          final customGuests = int.tryParse(_guestsController.text.trim());
                          Navigator.pop(context);
                          widget.onConfirm(customEvents, customGuests);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: accentColor.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'تأكيد التحديث',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
}
