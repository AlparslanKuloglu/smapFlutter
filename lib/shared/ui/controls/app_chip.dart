import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/smap_text.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/buttons/press_scale.dart';
import 'package:smap/shared/ui/controls/clear_color.dart';

/// The three heights of a pill chip (C06 "Hap çip, kit ölçüsü" and "Ekran
/// boyları"); the touch target is always 48.
enum AppChipSize {
  /// 36 high, 14 side padding, label-md 14/20 · 600. The kit size (board
  /// 1.11).
  sm36(height: 36, side: 14),

  /// 40 high, 14 side padding, 15/20 · 600. Filter sheet, topic filter,
  /// "Kiminle" (6.1, 7.2, 10.5).
  md40(height: 40, side: 14),

  /// 48 high, 18 side padding, label-lg 16/24 · 600. Field choice (2.2).
  lg48(height: 48, side: 18);

  const AppChipSize({required this.height, required this.side});

  final double height;
  final double side;

  /// The label style of this size.
  TextStyle labelOf(SmapText text) => switch (this) {
    sm36 => text.labelMd,
    md40 => text.bodyStrong.copyWith(height: 20 / 15),
    lg48 => text.labelLg,
  };
}

/// The tappable choice (C06 "Chip"; board 1.11 "Çipler ve Etiketler"; UI
/// guide §5 #7): a pill (radius full) with a 1 pt `borderControl` edge.
///
/// Unselected: `bgSurface` fill (none in dark) and `textPrimary`. Selected:
/// `primary` fill, `onPrimary` label, no edge. Selection is navy, never
/// orange, and a selected chip carries no check icon (the fill and the
/// weight of the choice say it; the kit task drops the Check of board 1.11).
/// Disabled: `textDisabled` label on a `borderStrong` edge; the reason
/// belongs next to the chip in text.
///
/// [dotColor] makes a subject chip: the label plus a 10 pt dot in the
/// subject accent (`context.appSubject(key).fg`); selected, the dot gets a 2
/// pt ring in the label color. "Genel" is not a subject and has no dot.
/// [AppChip.square] is the 48 x 48 choice chip for answer options and
/// grades ("A", "Boş", "12. Sınıf").
///
/// Color and ring change in [AppMotion.fast] (150 ms); a tap plays
/// `AppHaptics.selection()`. Read as a button that is selected or not; put it
/// in an `AppChipGroup` to read as a radio group.
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    required this.onTap,
    this.selected = false,
    this.size = AppChipSize.sm36,
    this.icon,
    this.trailingIcon,
    this.dotColor,
    this.exclusive = false,
    this.focusGapColor,
    super.key,
  }) : _squareWidth = null;

  /// The 48 x 48 square choice chip (answer option, grade): radius 12, label
  /// 16/24 · 700, [width] 48 (the "Boş" chip and "Mezun" are wider).
  const AppChip.square({
    required this.label,
    required this.onTap,
    this.selected = false,
    double width = AppSize.touch,
    this.exclusive = true,
    this.focusGapColor,
    super.key,
  }) : size = AppChipSize.lg48,
       icon = null,
       trailingIcon = null,
       dotColor = null,
       _squareWidth = width;

  final String label;

  /// Null disables the chip.
  final VoidCallback? onTap;
  final bool selected;
  final AppChipSize size;

  /// Leading Phosphor icon, 16 pt (`PhosphorIconsRegular.flag`).
  final IconData? icon;

  /// Trailing Phosphor icon, 18 pt (`PhosphorIconsRegular.caretDown`).
  final IconData? trailingIcon;

  /// The subject accent of the 10 pt dot.
  final Color? dotColor;

  /// Reads as one option of a radio group instead of a toggle.
  final bool exclusive;
  final Color? focusGapColor;
  final double? _squareWidth;

  /// The dot of a subject chip.
  static const double dot = 10;

  /// The ring around a selected chip's dot.
  static const double dotRing = 2;

  /// Gap between the icon or dot and the label.
  static const double _gap = 6;

  bool get _square => _squareWidth != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final dark = Theme.brightnessOf(context) == Brightness.dark;
    final enabled = onTap != null;
    final fade = context.motion(AppMotion.fast, reduced: AppMotion.fast);

    final Color fill;
    final Color ink;
    final Color edge;
    if (selected) {
      fill = colors.primary;
      ink = colors.onPrimary;
      edge = colors.primary;
    } else if (!enabled) {
      fill = dark ? colors.bgCanvas.clear : colors.bgSurface;
      ink = colors.textDisabled;
      edge = colors.borderStrong;
    } else {
      fill = dark ? colors.bgCanvas.clear : colors.bgSurface;
      ink = colors.textPrimary;
      edge = colors.borderControl;
    }
    final radius = _square ? AppRadius.borderMd : AppRadius.borderFull;
    final style =
        (_square
                ? text.labelLg.copyWith(fontWeight: FontWeight.w700)
                : size.labelOf(text))
            .copyWith(color: ink);

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      inMutuallyExclusiveGroup: exclusive,
      excludeSemantics: true,
      label: label,
      onTap: onTap,
      child: AppPressable(
        onTap: onTap,
        haptic: true,
        scale: _square ? PressScale.cellScale : AppMotion.pressedScale,
        builder: (context, states) {
          final pressed = states.contains(WidgetState.pressed);
          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSize.touch),
            child: Center(
              widthFactor: 1,
              child: AppFocusRing(
                focused: states.contains(WidgetState.focused),
                borderRadius: radius,
                gapColor: focusGapColor,
                child: AnimatedContainer(
                  duration: fade,
                  curve: AppMotion.standard,
                  height: size.height,
                  width: _squareWidth,
                  padding: _square
                      ? null
                      : EdgeInsets.symmetric(horizontal: size.side - 1),
                  alignment: _square ? Alignment.center : null,
                  decoration: BoxDecoration(
                    color: pressed && enabled && !selected
                        ? colors.bgSunken
                        : fill,
                    borderRadius: radius,
                    border: Border.all(color: edge),
                  ),
                  child: _square
                      ? Text(label, style: style, maxLines: 1)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (dotColor case final accent?) ...[
                              _Dot(color: accent, ring: selected ? ink : null),
                              const SizedBox(width: _gap),
                            ] else if (icon case final leading?) ...[
                              PhosphorIcon(leading, size: 16, color: ink),
                              const SizedBox(width: _gap),
                            ],
                            Flexible(
                              child: Text(
                                label,
                                style: style,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (trailingIcon case final trailing?) ...[
                              const SizedBox(width: AppSpacing.s4),
                              PhosphorIcon(trailing, size: 18, color: ink),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The 10 pt subject dot; when its chip is selected a 2 pt ring surrounds
/// it. The box is always 14 so the label does not move.
class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.ring});

  final Color color;

  /// Ring color of a selected chip; null draws no ring.
  final Color? ring;

  @override
  Widget build(BuildContext context) {
    final ringColor = ring;
    return SizedBox.square(
      dimension: AppChip.dot + 2 * AppChip.dotRing,
      child: Padding(
        padding: EdgeInsets.all(ringColor == null ? AppChip.dotRing : 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: ringColor == null
                ? null
                : Border.all(color: ringColor, width: AppChip.dotRing),
          ),
        ),
      ),
    );
  }
}
