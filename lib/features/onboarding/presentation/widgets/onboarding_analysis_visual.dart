import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/exams/presentation/widgets/dyb_counter.dart';
import 'package:smap/features/onboarding/application/onboarding_samples.dart';
import 'package:smap/features/onboarding/presentation/widgets/onboarding_net_chart.dart';
import 'package:smap/features/onboarding/presentation/widgets/onboarding_visual_frame.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/text/delta_text.dart';

/// The picture of intro page 2, "Netini ve gelişimini gör" (pano 2.1 kare 3,
/// `OnboardingAnalysisVisual`; spec §1 "Diğer").
///
/// A 300 pt wide card (padding 16, radius 16, the 12 % intro shadow) built
/// from the real pieces with the board's example data: the exam name "AYT ·
/// Türkiye Geneli Deneme 6" (13 `textSecondary`), the net "67,5" in
/// `metricLg` with "net" and the change "+8,25" (a `DeltaText` badge), the
/// small D/Y/B counter "86 doğru · 74 yanlış · 0 boş", and the
/// [OnboardingNetChart]. Decoration: the card is one image for the screen
/// reader, named by the chart's description.
class OnboardingAnalysisVisual extends StatelessWidget {
  const OnboardingAnalysisVisual({super.key});

  /// The card's width on the board.
  static const double width = 300;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: AppRadius.borderLg,
          boxShadow: OnboardingShadows.resultCard(colors),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.onboarding_sampleExamTitle,
                style: text.caption.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    TrFormat.net(OnboardingSamples.net),
                    style: text.metricLg.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.exams_netUnit,
                    style: text.bodyStrong.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const DeltaText(
                    value: OnboardingSamples.delta,
                    size: DeltaTextSize.badge,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const DybCounter(
                counts: OnboardingSamples.counts,
                labels: DybCounterLabels.word,
              ),
              const SizedBox(height: 14),
              OnboardingNetChart(
                points: OnboardingSamples.chart,
                semanticLabel: l10n.onboarding_sampleChartA11y,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
