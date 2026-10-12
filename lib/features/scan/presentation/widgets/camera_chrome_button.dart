import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/scan/presentation/widgets/camera_tones.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';

/// The round button over the camera (spec C67; pano 4.2, 4.3 "Üst bar:
/// Kapat ve ?, 48 hedef, 40 daire rgba(10,20,36,.64)"): a 40 pt translucent
/// circle with a white icon, in a 48 pt touch target.
///
/// Its name is the accessible name and the tooltip, like every icon button.
class CameraChromeButton extends StatelessWidget {
  const CameraChromeButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.iconSize = 20,
    super.key,
  });

  /// Phosphor Regular icon (`PhosphorIconsRegular.x`).
  final IconData icon;

  /// "Kapat", "Nasıl çekilir?".
  final String semanticLabel;

  /// Null disables the button.
  final VoidCallback? onPressed;

  /// 20 for Kapat, 22 for the question mark.
  final double iconSize;

  /// The circle's edge.
  static const double circle = AppSize.touchVisible;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      excludeSemantics: true,
      onTap: onPressed,
      child: Tooltip(
        message: semanticLabel,
        excludeFromSemantics: true,
        child: AppPressable(
          onTap: onPressed,
          builder: (context, states) => SizedBox.square(
            dimension: AppSize.touch,
            child: Center(
              child: AppFocusRing(
                focused: states.contains(WidgetState.focused),
                borderRadius: AppRadius.borderFull,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.cameraChrome,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: circle,
                    child: Center(
                      child: PhosphorIcon(
                        icon,
                        size: iconSize,
                        color: onPressed == null
                            ? colors.textDisabled
                            : colors.textOnNavy,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
