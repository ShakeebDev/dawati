import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dawati/core/theme/app_theme.dart';
import 'package:dawati/core/utils/app_utils.dart';
import 'package:dawati/features/events/presentation/providers/event_providers.dart';
import 'package:dawati/features/events/data/repositories/event_repository.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/invitation/presentation/widgets/invitation_card.dart';
import 'package:dawati/core/errors/failures.dart';
import 'package:dawati/core/services/ai_text_service.dart'; // استيراد محرك الذكاء الاصطناعي
import 'package:google_fonts/google_fonts.dart';

class InvitationBuilderScreen extends ConsumerStatefulWidget {
  final String eventId;
  const InvitationBuilderScreen({super.key, required this.eventId});

  @override
  ConsumerState<InvitationBuilderScreen> createState() =>
      _InvitationBuilderScreenState();
}

class _InvitationBuilderScreenState
    extends ConsumerState<InvitationBuilderScreen> {
  String _selectedTemplate = 'classic';
  String _customText = 'نتشرف بدعوتكم لحضور مناسبتنا السعيدة';
  String _invitationTime = '8:00 مساءً';
  late TextEditingController _textController;
  late TextEditingController _timeController;
  bool _isSaving = false;
  bool _isAIGenerating = false; // حالة توليد النص بالذكاء الاصطناعي

  int _selectedTab = 0; // 0: القوالب، 1: النصوص والأوقات، 2: مساعد الذكاء الاصطناعي
  String _selectedAITone = 'poetic'; // النبرة الذكية المختارة

  final GuestModel _previewGuest = GuestModel(
    id: 'preview',
    eventId: '',
    name: 'اسم الضيف هنا',
    phone: '',
    qrToken: 'preview-token',
    status: 'pending',
    allowedEntries: 1,
    currentEntries: 0,
    createdAt: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _customText);
    _timeController = TextEditingController(text: _invitationTime);

    Future.microtask(() async {
      final event = await ref.read(eventDetailsProvider(widget.eventId).future);
      if (event != null && mounted) {
        setState(() {
          if (event.invitationTemplate != null) {
            _selectedTemplate = event.invitationTemplate!;
          }

          _customText = event.displayInvitationText;
          _invitationTime = event.displayInvitationTime;

          _textController.text = _customText;
          _timeController.text = _invitationTime;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _saveDesign() async {
    setState(() => _isSaving = true);
    final eventAsync = ref.read(eventDetailsProvider(widget.eventId));
    final event = eventAsync.value;

    if (event != null) {
      // دمج النص والوقت في حقل واحد لتجنب مشكلة قاعدة البيانات
      final combinedText =
          EventModel.combineTextAndTime(_customText, _invitationTime);

      final updatedEvent = event.copyWith(
        invitationTemplate: _selectedTemplate,
        invitationText: combinedText,
      );

      final result =
          await ref.read(eventRepositoryProvider).updateEvent(updatedEvent);

      if (mounted) {
        setState(() => _isSaving = false);
        if (result is Success<EventModel>) {
          ref.invalidate(eventDetailsProvider(widget.eventId));
          AppUtils.showSnackBar(context, 'تم حفظ تصميم الدعوة بنجاح 💾');
        } else if (result is Failure<EventModel>) {
          AppUtils.showSnackBar(
              context, 'فشل حفظ التصميم: ${result.failure.message}',
              isError: true);
        }
      }
    } else {
      setState(() => _isSaving = false);
    }
  }

  /// دالة توليد النص باستخدام محرك الذكاء الاصطناعي وترقية خيارات النبرة
  Future<void> _generateAIContent(EventModel event) async {
    setState(() => _isAIGenerating = true);

    // محاكاة وقت المعالجة
    await Future.delayed(const Duration(milliseconds: 1200));

    final generatedText = AITextService.generateInvitation(
      eventType: event.eventType,
      eventName: event.name,
      tone: _selectedAITone,
    );

    if (mounted) {
      setState(() {
        _customText = generatedText;
        _textController.text = generatedText;
        _isAIGenerating = false;
      });
      AppUtils.showSnackBar(
          context, 'تمت الصياغة بنجاح ✨ ألقِ نظرة على المعاينة بالأعلى.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // اكتشاف ما إذا كانت لوحة المفاتيح مفتوحة
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 100;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'مصمم الدعوات الذكية',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('دليل المصمم الذكي 💡'),
                  content: const Text(
                      'اختر القالب المفضل لديك، قم بتخصيص نص الدعوة والوقت يدوياً أو دع المساعد الذكي يصيغ لك نصاً أدبياً فاخراً، ثم اضغط حفظ لتطبيق التحديثات فوراً على بطاقات الضيوف.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('فهمت'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return const Center(child: Text('المناسبة غير موجودة'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // 1. قسم معاينة الدعوة - تختفي/تنكمش عند فتح لوحة المفاتيح
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    height: isKeyboardOpen ? 0 : constraints.maxHeight * 0.38,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: InvitationCard(
                            guest: _previewGuest,
                            event: event.copyWith(
                              invitationTemplate: _selectedTemplate,
                              invitationText: EventModel.combineTextAndTime(
                                  _customText.isEmpty
                                      ? (event.invitationText?.split('|TIME:')[0] ?? '')
                                      : _customText,
                                  _invitationTime.isEmpty
                                      ? (event.invitationText?.split('|TIME:').last ?? '8:00 مساءً')
                                      : _invitationTime),
                            ),
                            width: 270,
                          )
                              .animate()
                              .scale(duration: 500.ms, curve: Curves.easeOutBack),
                        ),
                      ),
                    ),
                  ),

                  // 2. شريط التبويبات التفاعلي الأنيق
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton(0, 'القالب 🎨', Icons.palette_outlined),
                        _buildTabButton(1, 'النص والوقت ✍️', Icons.edit_note_outlined),
                        _buildTabButton(2, 'المساعد الذكي ✨', Icons.auto_awesome_outlined),
                      ],
                    ),
                  ),

                  // 3. قسم خيارات التخصيص التابع للتبويب المختار
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppTheme.radiusExtraLarge)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _buildSelectedTabContent(event),
                            ),
                          ),

                          // زر حفظ التصميم
                          Padding(
                            padding: EdgeInsets.only(
                              top: 12,
                              bottom: isKeyboardOpen ? 8 : 16,
                            ),
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppTheme.goldPrimary, AppTheme.goldDark],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.goldPrimary.withOpacity(0.35),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _isSaving ? null : _saveDesign,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.5, color: Colors.white))
                                    : const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                label: Text(
                                  _isSaving ? 'جاري حفظ التحديثات...' : 'حفظ التصميم ونشره للضيوف',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }

  /// زر تبويب مخصص وسهل الفهم
  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white.withOpacity(0.08) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppTheme.goldPrimary : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label.split(' ')[0],
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء المحتوى المقترن بالتبويب المختار
  Widget _buildSelectedTabContent(EventModel event) {
    switch (_selectedTab) {
      case 1:
        return _buildDetailsTab();
      case 2:
        return _buildAITab(event);
      case 0:
      default:
        return _buildStyleTab(event);
    }
  }

  /// 1. محتوى تبويب القوالب وأنماط البطاقة
  Widget _buildStyleTab(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'اختر النمط المناسب لبطاقتك 🎨',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildTemplateSelector(event),
                  const SizedBox(height: 12),
                  Text(
                    'تصفح القوالب الإبداعية المتاحة للحفل لسحبها وعرضها فوراً.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 2. محتوى تبويب النصوص والأوقات
  Widget _buildDetailsTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'تعديل نصوص الدعوة يدوياً ✍️',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: 2,
          controller: _textController,
          onChanged: (v) => setState(() => _customText = v),
          style: GoogleFonts.cairo(fontSize: 13),
          decoration: const InputDecoration(
            labelText: 'نص الدعوة الرئيسي',
            hintText: 'مثلاً: نتشرف بدعوتكم الكريمة لحضور زفافنا...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _timeController,
          onChanged: (v) => setState(() => _invitationTime = v),
          style: GoogleFonts.cairo(fontSize: 13),
          decoration: const InputDecoration(
            labelText: 'وقت الحفل والترحيب',
            hintText: 'مثلاً: الساعة 8:00 مساءً',
            prefixIcon: Icon(Icons.access_time_rounded, size: 18),
          ),
        ),
      ],
    );
  }

  /// 3. محتوى تبويب المساعد الذكي المطور (AI Assistant)
  Widget _buildAITab(EventModel event) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.purple, size: 18),
            const SizedBox(width: 8),
            Text(
              'صياغة نصوص الدعوة بالذكاء الاصطناعي ✨',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'اختر النبرة الأدبية المفضلة لديك ليقوم المساعد بصياغة نص فخم لمناسبتك:',
          style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11, height: 1.4),
        ),
        const SizedBox(height: 12),
        
        // خيارات الأسلوب (Tones List)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AITextService.tones.map((tone) {
            final isSelected = _selectedAITone == tone['id'];
            return ChoiceChip(
              label: Text(
                tone['label']!,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : null,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.purple,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedAITone = tone['id']!);
                }
              },
            );
          }).toList(),
        ),
        
        const SizedBox(height: 24),
        
        // زر الصياغة السحرية
        Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isAIGenerating
                  ? [Colors.grey, Colors.grey]
                  : [Colors.purple, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton.icon(
            onPressed: _isAIGenerating ? null : () => _generateAIContent(event),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: _isAIGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
            label: Text(
              _isAIGenerating ? 'جاري صياغة النص السحري...' : 'صياغة النص بالذكاء الاصطناعي',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateSelector(EventModel event) {
    List<Widget> templates = [];

    if (event.eventType == 'wedding') {
      templates = [
        _TemplateOption(
          id: 'classic',
          label: 'كلاسيك 🌸',
          isSelected: _selectedTemplate == 'classic',
          onTap: () => setState(() => _selectedTemplate = 'classic'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'luxury',
          label: 'فاخر ✨',
          isSelected: _selectedTemplate == 'luxury',
          onTap: () => setState(() => _selectedTemplate = 'luxury'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'royal',
          label: 'ملكي 👑',
          isSelected: _selectedTemplate == 'royal',
          onTap: () => setState(() => _selectedTemplate = 'royal'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'night_majesty',
          label: 'جلالة الليل 🎭',
          isSelected: _selectedTemplate == 'night_majesty',
          onTap: () => setState(() => _selectedTemplate = 'night_majesty'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'sakura_blossom',
          label: 'براعم الساكورا 🌸',
          isSelected: _selectedTemplate == 'sakura_blossom',
          onTap: () => setState(() => _selectedTemplate = 'sakura_blossom'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'damask_jasmine',
          label: 'ياسمين دمشقي 🌿',
          isSelected: _selectedTemplate == 'damask_jasmine',
          onTap: () => setState(() => _selectedTemplate = 'damask_jasmine'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'golden_watercolor_flora',
          label: 'زهور مائية ذهبية ⚜️',
          isSelected: _selectedTemplate == 'golden_watercolor_flora',
          onTap: () => setState(() => _selectedTemplate = 'golden_watercolor_flora'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'emerald_garden',
          label: 'حديقة زمردية 🌿',
          isSelected: _selectedTemplate == 'emerald_garden',
          onTap: () => setState(() => _selectedTemplate = 'emerald_garden'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'golden_arabesque',
          label: 'عربسك ذهبي 🕌',
          isSelected: _selectedTemplate == 'golden_arabesque',
          onTap: () => setState(() => _selectedTemplate = 'golden_arabesque'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'blush_romance',
          label: 'رومانسي 🌸',
          isSelected: _selectedTemplate == 'blush_romance',
          onTap: () => setState(() => _selectedTemplate = 'blush_romance'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'midnight_glam',
          label: 'جلامور الليل 🌙',
          isSelected: _selectedTemplate == 'midnight_glam',
          onTap: () => setState(() => _selectedTemplate = 'midnight_glam'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'desert_sunset',
          label: 'غروب الصحراء 🌅',
          isSelected: _selectedTemplate == 'desert_sunset',
          onTap: () => setState(() => _selectedTemplate = 'desert_sunset'),
        ),
      ];
    } else if (event.eventType == 'graduation') {
      templates = [
        _TemplateOption(
          id: 'grad_success',
          label: 'نجاح باهر 🎓',
          isSelected: _selectedTemplate == 'grad_success',
          onTap: () => setState(() => _selectedTemplate = 'grad_success'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'grad_modern',
          label: 'عصري 👨‍🎓',
          isSelected: _selectedTemplate == 'grad_modern',
          onTap: () => setState(() => _selectedTemplate = 'grad_modern'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'grad_watercolor',
          label: 'ألوان مائية 🎨',
          isSelected: _selectedTemplate == 'grad_watercolor',
          onTap: () => setState(() => _selectedTemplate = 'grad_watercolor'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'grad_elegant_minimal',
          label: 'بسيط أنيق ✨',
          isSelected: _selectedTemplate == 'grad_elegant_minimal',
          onTap: () => setState(() => _selectedTemplate = 'grad_elegant_minimal'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'grad_royal_navy',
          label: 'كحلي ملكي 👑',
          isSelected: _selectedTemplate == 'grad_royal_navy',
          onTap: () => setState(() => _selectedTemplate = 'grad_royal_navy'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'grad_geom_bright',
          label: 'هندسي مشرق 🌟',
          isSelected: _selectedTemplate == 'grad_geom_bright',
          onTap: () => setState(() => _selectedTemplate = 'grad_geom_bright'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'grad_boho_watercolor',
          label: 'بوهيمي مائي 🌿',
          isSelected: _selectedTemplate == 'grad_boho_watercolor',
          onTap: () => setState(() => _selectedTemplate = 'grad_boho_watercolor'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'grad_vintage_parchment',
          label: 'وثيقة عتيقة 📜',
          isSelected: _selectedTemplate == 'grad_vintage_parchment',
          onTap: () => setState(() => _selectedTemplate = 'grad_vintage_parchment'),
        ),
        const SizedBox(width: 12),
        _TemplateOption(
          id: 'grad_midnight_starry',
          label: 'نجوم الليل 🌌',
          isSelected: _selectedTemplate == 'grad_midnight_starry',
          onTap: () => setState(() => _selectedTemplate = 'grad_midnight_starry'),
        ),
      ];
    } else {
      templates = [
        _TemplateOption(
          id: 'classic',
          label: 'كلاسيك 🌸',
          isSelected: _selectedTemplate == 'classic',
          onTap: () => setState(() => _selectedTemplate = 'classic'),
        ),
      ];
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: templates,
      ),
    );
  }
}

class _TemplateOption extends StatelessWidget {
  final String id;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateOption({
    required this.id,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.goldPrimary
              : Theme.of(context).dividerColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? null
              : Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.goldPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
