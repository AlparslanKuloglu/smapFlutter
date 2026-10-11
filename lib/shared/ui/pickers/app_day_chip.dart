import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';

/// The two sizes of an [AppDayChip].
enum AppDayChipSize {
  /// 48 x 64: the day strip of the program screen (pano 3.4 kare 3).
  regular(width: 48, height: 64),

  /// 56 x 76 with a count line: the grid step of a new program (pano 3.5
  /// kare 2).
  large(width: 56, height: 76);

  const AppDayChipSize({required this.width, required this.height});

  final double width;
  final double height;
}

/// One day of a day strip (C62 "DayChip"; Tur 6 G4; pano 3.4 kare 3, 3.5
/// kare 2).
///
/// A `bgSurface` tile, radius 12: the weekday ("Pzt", 13/20 · 600
/// `textSecondary`) over the day number (17/24 · 700). Selected it turns
/// `primary` with the number in `onPrimary` and the weekday in the soft navy
/// tone. [today] adds a 6 pt orange dot 5 pt above the bottom edge (`accentLine`,
/// `accent` on the selected tile). The [large] size adds one [caption] line
/// ("2 konu", 13/16 · 600) under the number.
///
/// The tile grows with the text scale instead of cutting its text; 7 of them
/// sit apart edge to edge in the strip. Plays `AppHaptics.selection()` on
/// tap. Read as "Cumartesi 10 Ekim, bugün, seçili" and, with a [caption],
/// "… , 2 konu".
class AppDayChip extends StatelessWidget {
  const AppDayChip({
    required this.date,
    required this.onTap,
    this.selected = false,
    this.today = false,
    this.size = AppDayChipSize.regular,
    this.caption,
    this.focusGapColor,
    super.key,
  });

  /// The calendar day the chip stands for.
  final DateTime date;

  /// Null disables the chip.
  final VoidCallback? onTap;
  final bool selected;

  /// The day is today: the orange dot.
  final bool today;
  final AppDayChipSize size;

  /// The count line of the [AppDayChipSize.large] size ("2 konu").
  final String? caption;
  final Color? focusGapColor;

  /// The dot's edge and its distance from the bottom edge (C62).
  static const double _dot = 6;
  static const double _dotBottom = 5;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final dark = Theme.brightnessOf(context) == Brightness.dark;
    final enabled = onTap != null;

    final weekdayInk = selected
        ? (dark ? colors.onPrimary : colors.textOnNavy2)
        : (enabled ? colors.textSecondary : colors.textDisabled);
    final numberInk = selected
        ? colors.onPrimary
        : (enabled ? colors.textPrimary : colors.textDisabled);
    final dotInk = selected ? colors.accent : colors.accentLine;

    final reading = [
      l10n.pickers_a11yDayChip(
        TrFormat.gunAdi(date),
        '${date.day}',
        TrFormat.months[date.month - 1],
      ),
      if (today) l10n.pickers_a11yToday,
      if (selected) l10n.pickers_a11ySelected,
      ?caption,
    ].join(', ');

    return Semantics(
      button: true,
      enabled: enabled,
      label: reading,
      excludeSemantics: true,
      onTap: onTap,
      child: AppPressable(
        onTap: onTap,
        haptic: true,
        builder: (context, states) {
          final pressed = states.contains(WidgetState.pressed);
          final Color fill;
          if (selected) {
            fill = pressed ? colors.primaryPressed : colors.primary;
          } else {
            fill = pressed ? colors.bgSunken : colors.bgSurface;
          }
          return AppFocusRing(
            focused: states.contains(WidgetState.focused),
            gapColor: focusGapColor,
            child: AnimatedContainer(
              duration: context.motion(
                AppMotion.instant,
                reduced: Duration.zero,
              ),
              curve: AppMotion.standard,
              width: size.width,
              constraints: BoxConstraints(minHeight: size.height),
              decoration: BoxDecoration(
                color: fill,
                borderRadius: AppRadius.borderMd,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          TrFormat.gunKisa(date),
                          maxLines: 1,
                          style: text.caption.copyWith(
                            color: weekdayInk,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${date.day}',
                          maxLines: 1,
                          style: text.headline.copyWith(color: numberInk),
                        ),
                        if (caption case final line?)
                          Text(
                            line,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: text.caption.copyWith(
                              color: weekdayInk,
                              fontWeight: FontWeight.w600,
                              height: 16 / 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (today)
                    Positioned(
                      bottom: _dotBottom,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: dotInk,
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox.square(dimension: _dot),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
