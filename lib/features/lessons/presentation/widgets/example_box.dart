import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The box of an example under an item's definition (C51 "ExampleBox"; pano
/// 7.3 kare 1 to 3, 7.6).
///
/// `bgCanvas` fill, radius 12, padding 12 / 16. "Örnek" 13/20 · 700
/// `textSecondary`, the example 16/26 (`bodyReading`) 2 below it and, when the
/// text has one, the explanation 13/20 `textSecondary` 4 below that. In the
/// dark theme the box on the page is one step lighter than the card
/// (`bgRaised`, #18263D, pano 7.6) and keeps `bgCanvas` inside a sheet, whose
/// own fill is that same `bgRaised` ([onSheet]).
///
/// It is read as one block: "Örnek, Bazı insanlar karanlıktan korkar.,
/// \"Karanlık\" burada ışıksız anlamında…".
class ExampleBox extends StatelessWidget {
  const ExampleBox({
    required this.example,
    this.explanation,
    this.onSheet = false,
    super.key,
  });

  /// "Bazı insanlar karanlıktan korkar."
  final String example;

  /// "\"Karanlık\" burada ışıksız anlamında, temel anlamıyla kullanılmış."
  final String? explanation;

  /// The box sits inside a sheet.
  final bool onSheet;

  /// Gap between the heading and the example.
  static const double _headingGap = 2;

  /// Gap between the example and its explanation.
  static const double _explanationGap = AppSpacing.s4;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final dark = Theme.brightnessOf(context) == Brightness.dark;
    final note = explanation;
    return Semantics(
      container: true,
      label: [l10n.lessons_exampleLabel, example, ?note].join(', '),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dark && !onSheet ? colors.bgRaised : colors.bgCanvas,
          borderRadius: AppRadius.borderMd,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.lessons_exampleLabel,
                  style: text.caption.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: _headingGap),
                Text(
                  example,
                  style: text.bodyReading.copyWith(color: colors.textPrimary),
                ),
                if (note != null) ...[
                  const SizedBox(height: _explanationGap),
                  Text(
                    note,
                    style: text.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
