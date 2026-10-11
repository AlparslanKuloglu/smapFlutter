import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';

/// The looks of an [AppIconButton] (C02; board 1.9 "İkonlu ve yalnız ikon").
enum AppIconButtonVariant {
  /// A bare 24 pt icon in `textPrimary` (back, filter, favorite).
  plain,

  /// The sheet close button: a 36 pt `bgSunken` circle with a 20 pt X inside
  /// the 48 pt target ("Kapat (sheet)").
  close,

  /// A bare 24 pt white icon for the navy root band (`textOnNavy`).
  onNavy,
}

/// The icon-only button (C02; UI guide §5 #3).
///
/// The touch target is always 48 x 48. [semanticLabel] is the accessible name
/// and also the tooltip, both required: every icon button has a name in the
/// design ("Geri", "Kapat", "Filtrele", "Favorilere ekle", "Şifreyi göster").
///
/// [selected] turns it into a toggle that swaps [icon] for [selectedIcon]
/// (Phosphor Regular to Fill: favorite Star to Star Fill) and is announced as
/// selected. Pressed: a `bgSunken` 12 pt rounded square under the icon (the
/// close variant darkens its circle) and the 0,98 scale; keyboard focus
/// draws the ring of spec §1.4.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.variant = AppIconButtonVariant.plain,
    this.selected,
    this.selectedIcon,
    this.color,
    this.iconSize,
    this.focusGapColor,
    super.key,
  });

  /// Phosphor Regular icon (`PhosphorIconsRegular.caretLeft`).
  final IconData icon;

  /// Accessible name and tooltip ("Geri").
  final String semanticLabel;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;

  /// Non-null makes it a toggle; true shows [selectedIcon].
  final bool? selected;

  /// The Fill icon of a toggle; [icon] when null.
  final IconData? selectedIcon;

  /// Icon color; the variant's color when null. Low-emphasis icons pass
  /// `textSecondary`.
  final Color? color;

  /// Icon edge; 24 for plain and onNavy, 20 for close.
  final double? iconSize;

  /// Color of the focus ring's gap.
  final Color? focusGapColor;

  /// Edge of the circle behind a close icon.
  static const double closeCircle = 36;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onPressed != null;
    final isSelected = selected ?? false;
    final glyph = isSelected ? (selectedIcon ?? icon) : icon;
    final size =
        iconSize ??
        (variant == AppIconButtonVariant.close ? 20.0 : AppSize.icon);
    final rest = switch (variant) {
      AppIconButtonVariant.onNavy => colors.textOnNavy,
      _ => colors.textPrimary,
    };
    final ink = enabled ? (color ?? rest) : colors.textDisabled;
    final fast = context.motion(AppMotion.instant, reduced: Duration.zero);

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      toggled: selected,
      excludeSemantics: true,
      onTap: onPressed,
      child: Tooltip(
        message: semanticLabel,
        excludeFromSemantics: true,
        child: AppPressable(
          onTap: onPressed,
          builder: (context, states) {
            final pressed = states.contains(WidgetState.pressed);
            final isClose = variant == AppIconButtonVariant.close;
            final well = isClose ? closeCircle : AppSize.touch;
            return SizedBox.square(
              dimension: AppSize.touch,
              child: Center(
                child: AppFocusRing(
                  focused: states.contains(WidgetState.focused),
                  gapColor: focusGapColor,
                  borderRadius: isClose
                      ? AppRadius.borderFull
                      : AppRadius.borderMd,
                  child: AnimatedContainer(
                    duration: fast,
                    curve: AppMotion.standard,
                    width: well,
                    height: well,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isClose
                          ? (pressed ? colors.borderSubtle : colors.bgSunken)
                          : (pressed && variant == AppIconButtonVariant.plain
                                ? colors.bgSunken
                                : null),
                      borderRadius: isClose
                          ? AppRadius.borderFull
                          : AppRadius.borderMd,
                    ),
                    child: PhosphorIcon(glyph, size: size, color: ink),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
