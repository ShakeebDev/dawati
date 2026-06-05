import 'package:flutter/material.dart';
import 'package:dawati/features/guests/data/models/guest_model.dart';
import 'package:dawati/features/events/data/models/event_model.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/classic_invitation_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/luxury_invitation_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/royal_invitation_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/night_majesty_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/graduation_invitation_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/graduation_modern_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/graduation_watercolor_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/elegant_minimal_graduation_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/emerald_garden_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/golden_arabesque_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/blush_romance_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/midnight_glam_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/desert_sunset_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/sakura_blossom_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/damask_jasmine_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/golden_watercolor_flora_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/grad_royal_navy_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/grad_geom_bright_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/grad_boho_watercolor_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/grad_vintage_parchment_card.dart';
import 'package:dawati/features/invitation/presentation/widgets/templates/grad_midnight_starry_card.dart';

/// المحرك الأساسي لبطاقات الدعوة - يقوم بالتبديل بين القوالب المختلفة
class InvitationCard extends StatelessWidget {
  final GuestModel guest;
  final EventModel event;
  final double width;

  const InvitationCard({
    super.key,
    required this.guest,
    required this.event,
    this.width = 330,
  });

  @override
  Widget build(BuildContext context) {
    final String template = event.invitationTemplate ?? 'classic';

    if (event.eventType == 'graduation') {
      if (template == 'grad_modern') {
        return GraduationModernCard(
          guest: guest,
          event: event,
          width: width,
        );
      }
      if (template == 'grad_watercolor') {
        return GraduationWatercolorCard(
          guest: guest,
          event: event,
          width: width,
        );
      }
      if (template == 'grad_elegant_minimal') {
        return ElegantMinimalGraduationCard(
          guest: guest,
          event: event,
          width: width,
        );
      }
      if (template == 'grad_royal_navy') {
        return GradRoyalNavyCard(
          guest: guest,
          event: event,
          width: width,
        );
      }
      if (template == 'grad_geom_bright') {
        return GradGeomBrightCard(
          guest: guest,
          event: event,
          width: width,
        );
      }
      if (template == 'grad_boho_watercolor') {
        return GradBohoWatercolorCard(
          guest: guest,
          event: event,
          width: width,
        );
      }
      if (template == 'grad_vintage_parchment') {
        return GradVintageParchmentCard(
          guest: guest,
          event: event,
          width: width,
        );
      }
      if (template == 'grad_midnight_starry') {
        return GradMidnightStarryCard(
          guest: guest,
          event: event,
          width: width,
        );
      }
      // قالب 'grad_success' أو أي قالب تخرج آخر
      return GraduationInvitationCard(
        guest: guest,
        event: event,
        width: width,
        templateId: template,
      );
    }

    // الوضع الافتراضي أو حفل الزفاف
    switch (template) {
      case 'sakura_blossom':
        return SakuraBlossomCard(
          guest: guest,
          event: event,
          width: width,
        );
      case 'damask_jasmine':
        return DamaskJasmineCard(
          guest: guest,
          event: event,
          width: width,
        );
      case 'golden_watercolor_flora':
        return GoldenWatercolorFloraCard(
          guest: guest,
          event: event,
          width: width,
        );
      case 'emerald_garden':
        return EmeraldGardenCard(
          guest: guest,
          event: event,
          width: width,
        );
      case 'golden_arabesque':
        return GoldenArabesqueCard(
          guest: guest,
          event: event,
          width: width,
        );
      case 'blush_romance':
        return BlushRomanceCard(
          guest: guest,
          event: event,
          width: width,
        );
      case 'midnight_glam':
        return MidnightGlamCard(
          guest: guest,
          event: event,
          width: width,
        );
      case 'desert_sunset':
        return DesertSunsetCard(
          guest: guest,
          event: event,
          width: width,
        );
      case 'night_majesty':
        return NightMajestyCard(
          guest: guest,
          event: event,
          width: width,
        );
      case 'royal':
        return RoyalInvitationCard(
          guest: guest,
          event: event,
          width: width,
        );
      case 'luxury':
        return LuxuryInvitationCard(
          guest: guest,
          event: event,
          width: width,
        );
      case 'classic':
      default:
        return ClassicInvitationCard(
          guest: guest,
          event: event,
          width: width,
        );
    }
  }
}
