import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/text/delta_text.dart';

/// The statistic box (C27 "StatBox"; board 1.16 "İstatistik kutusu"; Tur 4
/// G3, Tur 10; screens 6.1, 10.4, the score boxes of 5.1; UI guide §5 #19).
///
/// `bgSurface`, radius 16, 16 padding, 2 between the lines: the [value]
/// (24/32 · 700, `metricMd`, tabular), the [label] (13/20 · 600
/// `textSecondary`) and, when there is a [delta], a [DeltaText] line ("+3,25
/// son denemede"). Boxes sit in a two-column grid 8 apart.
///
/// Honest data only: a box with no [value] is not drawn at all, and the delta
/// line is drawn only when [delta] is non-null (the caller computes it from
/// the last two exams of the same filter; with fewer than two there is none).
/// The delta color is `delta`, not green (Tur 10; spec C27 "ÇELİŞKİ").
///
/// Pass [value] already formatted with `TrFormat` ("67,79", "381,40",
/// "182.430"). Read as one phrase: "Ortalama net 67,79, artış +3,25 son
/// denemede".
class AppStatBox extends StatelessWidget {
  const AppStatBox({
    required this.label,
    required this.value,
    this.delta,
    this.deltaSuffix,
    super.key,
  });

  /// "Ortalama net".
  final String label;

  /// The formatted figure; null draws nothing.
  final String? value;

  /// The change; null draws no delta line.
  final num? delta;

  /// "son denemede".
  final String? deltaSuffix;

  /// Gap between the lines (C27: 2).
  static const double lineGap = 2;

  @override
  Widget build(BuildContext context) {
    final figure = value;
    if (figure == null) return const SizedBox.shrink();
    final colors = context.appColors;
    final text = context.appText;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.borderLg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              container: true,
              label: '$label $figure',
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    figure,
                    style: text.metricMd.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: lineGap),
                  Text(
                    label,
                    style: text.caption.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (delta != null) ...[
              const SizedBox(height: lineGap),
              DeltaText(value: delta, suffix: deltaSuffix),
            ],
          ],
        ),
      ),
    );
  }
}
