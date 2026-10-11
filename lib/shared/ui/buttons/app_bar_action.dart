import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/controls/clear_color.dart';

/// Outlined or filled [AppBarAction].
enum AppBarActionStyle {
  /// Surface fill, 1,5 pt primary edge ("Düzenle", "Yeni Program").
  outlined,

  /// Primary fill ("Kaydet", "Bitti").
  filled,
}

/// The single secondary action on the right of a detail bar (C03; board 1.18;
/// Tur 6 G7, Tur 8 G4; UI guide §5 #2): "Düzenle", "Yeni Program",
/// "Eksiklerim (31)", "Bitti", "Kaydet".
///
/// 40 high, 14 side padding, radius 12, 14/20 · 600, a 20 pt leading
/// [icon] 6 pt from the label; the touch target is padded to 48. [field]
/// makes it the 48 high action beside an input ("Kontrol Et", "Oluştur";
/// board 1.20, 10.3). Disabled is the `borderSubtle` fill with
/// `textDisabled` text and no edge.
class AppBarAction extends StatelessWidget {
  const AppBarAction({
    required this.label,
    required this.onPressed,
    this.style = AppBarActionStyle.outlined,
    this.icon,
    this.field = false,
    this.focusGapColor,
    super.key,
  });

  /// "Düzenle".
  final String label;

  /// Null disables the action.
  final VoidCallback? onPressed;
  final AppBarActionStyle style;

  /// Leading Phosphor icon (`PhosphorIconsRegular.plus`).
  final IconData? icon;

  /// The 48 high variant beside a field.
  final bool field;
  final Color? focusGapColor;

  /// Side padding (C03: 14, not the 16 of a 40 button).
  static const double sidePadding = 14;

  /// Gap between the icon and the label (C03: 6).
  static const double iconGap = 6;

  /// Visible height (48 beside a field).
  double get height => field ? AppSize.touch : AppSize.touchVisible;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dark = Theme.brightnessOf(context) == Brightness.dark;
    final enabled = onPressed != null;
    final filled = style == AppBarActionStyle.filled;
    final ink = !enabled
        ? colors.textDisabled
        : (filled ? colors.onPrimary : colors.primary);
    final fast = context.motion(AppMotion.instant, reduced: Duration.zero);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: AppPressable(
        onTap: onPressed,
        builder: (context, states) {
          final pressed = states.contains(WidgetState.pressed);
          final Color fill;
          if (!enabled) {
            fill = dark ? colors.bgSunken : colors.borderSubtle;
          } else if (filled) {
            fill = pressed ? colors.primaryPressed : colors.primary;
          } else if (pressed) {
            fill = colors.infoBg;
          } else {
            fill = dark ? colors.bgCanvas.clear : colors.bgSurface;
          }
          final edge = enabled && !filled
              ? Border.all(color: colors.primary, width: 1.5)
              : null;
          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSize.touch),
            child: Center(
              widthFactor: 1,
              child: AppFocusRing(
                focused: states.contains(WidgetState.focused),
                gapColor: focusGapColor,
                child: AnimatedContainer(
                  duration: fast,
                  curve: AppMotion.standard,
                  constraints: BoxConstraints(minHeight: height),
                  padding: const EdgeInsets.symmetric(horizontal: sidePadding),
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: AppRadius.borderMd,
                    border: edge,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon case final leading?) ...[
                        PhosphorIcon(
                          leading,
                          size: AppSize.iconInButton,
                          color: ink,
                        ),
                        const SizedBox(width: iconGap),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: context.appText.labelMd.copyWith(color: ink),
                        ),
                      ),
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
