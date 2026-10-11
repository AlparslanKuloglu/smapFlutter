import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/lessons/presentation/widgets/eksik_tag.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_glyph.dart';
import 'package:smap/features/onboarding/application/onboarding_samples.dart';
import 'package:smap/features/onboarding/presentation/widgets/onboarding_visual_frame.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';

/// The picture of intro page 3, "Eksiklerini konu konu kapat" (pano 2.1 kare
/// 4, `OnboardingGapsVisual`; spec §1 "Diğer").
///
/// A 320 x 350 stage with two cards: the topic card (296 wide, rows with the
/// Türkçe glyph, the topic name and an [EksikTag]: "Fiilde Çatı" 3 eksik,
/// "Noktalama İşaretleri" 3 eksik, "Cümlenin Öğeleri" 2 eksik) and, over its
/// lower right, the info card (236 wide: "Tarih · bilgi kartı",
/// "Edirne-Segedin Antlaşması (1444)", its sentence and a primary
/// "Öğrendim"). The board's example data; decoration for the screen reader
/// (the page's title and sentence say it).
class OnboardingGapsVisual extends StatelessWidget {
  const OnboardingGapsVisual({super.key});

  /// The stage and its two cards, as on the board.
  static const double width = 320;
  static const double height = 350;
  static const double _topicWidth = 296;
  static const double _topicTop = 6;
  static const double _infoWidth = 236;
  static const double _infoTop = 196;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final names = [
      l10n.onboarding_sampleTopic1,
      l10n.onboarding_sampleTopic2,
      l10n.onboarding_sampleTopic3,
    ];
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        // The info card hangs below the stage, as on the board.
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: _topicTop,
              width: _topicWidth,
              child: _TopicCard(names: names),
            ),
            const Positioned(
              right: 0,
              top: _infoTop,
              width: _infoWidth,
              child: _InfoCard(),
            ),
          ],
        ),
      ),
    );
  }
}

/// The topic card: three rows with dividers.
class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.borderLg,
        boxShadow: OnboardingShadows.topicCard(colors),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.borderLg,
        child: Column(
          children: [
            for (final (i, name) in names.indexed) ...[
              if (i > 0)
                Divider(height: 1, thickness: 1, color: colors.bgSunken),
              _TopicRow(name: name, missing: OnboardingSamples.topicMissing[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.name, required this.missing});

  final String name;
  final int missing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const SubjectGlyph(
            subject: OnboardingSamples.topicSubject,
            size: SubjectGlyphSize.preview,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: context.appText.bodyStrong.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          EksikTag(count: missing),
        ],
      ),
    );
  }
}

/// The info card laid over the topic card.
class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.borderLg,
        boxShadow: OnboardingShadows.infoCard(colors),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SubjectGlyph(
                  subject: OnboardingSamples.cardSubject,
                  size: SubjectGlyphSize.card,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.onboarding_sampleCardKicker,
                    style: text.caption.copyWith(color: colors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.onboarding_sampleCardTitle,
              style: text.headline.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              l10n.onboarding_sampleCardBody,
              style: text.caption.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s12),
            // A picture of the card's button: it takes no taps.
            IgnorePointer(
              child: AppButton(
                label: l10n.onboarding_sampleCardAction,
                onPressed: () {},
                size: AppButtonSize.md40,
                expand: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
