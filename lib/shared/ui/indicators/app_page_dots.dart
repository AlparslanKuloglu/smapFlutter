import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The page dots of the onboarding carousel (C60 `SmapPageDots`; screen 2.1;
/// the dot part of C60 only; the page itself belongs to the onboarding
/// feature).
///
/// The current page is a 24 x 8 `accentLine` pill (orange is for position and
/// progress); the others are 8 x 8 `borderStrong` dots, 6 apart. The pill
/// slides between pages in [AppMotion.base] and is immediate under "Reduce
/// motion". Read as "3 ekrandan 1." ([count] pages, [index] current).
class AppPageDots extends StatelessWidget {
  const AppPageDots({required this.count, required this.index, super.key});

  /// Number of pages.
  final int count;

  /// Current page, 0-based.
  final int index;

  /// Dot sizes and spacing (C60).
  static const double dot = 8;
  static const double currentWidth = 24;
  static const double gap = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final move = context.motion(AppMotion.base, reduced: Duration.zero);
    return Semantics(
      label: l10n.kit_pageDotsA11y(count, index + 1),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: gap),
            AnimatedContainer(
              duration: move,
              curve: AppMotion.standard,
              width: i == index ? currentWidth : dot,
              height: dot,
              decoration: BoxDecoration(
                color: i == index ? colors.accentLine : colors.borderStrong,
                borderRadius: AppRadius.borderFull,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
