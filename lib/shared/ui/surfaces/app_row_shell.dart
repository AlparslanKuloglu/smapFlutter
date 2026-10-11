import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';

/// The tappable shell of a row that lives in a card or an `AppRowGroup` and
/// has content of its own (subject, topic, exam, program rows; boards 1.15,
/// 1.16, Tur 3 to 6).
///
/// It draws what `AppRow` draws around its fixed anatomy: [padding] (12 / 16
/// by default), a [minHeight], the `bgSurface` fill that turns `bgSunken`
/// while pressed (100 ms, no scale), and the keyboard focus ring drawn inside
/// the row. With a null [onTap] the row is static: no pressed state, no ring.
///
/// The semantics stay the caller's: it wraps the shell in its own `Semantics`
/// with the reading of the row (a button when [onTap] is set).
class AppRowShell extends StatelessWidget {
  const AppRowShell({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.s16,
      vertical: AppSpacing.s12,
    ),
    this.minHeight = AppSize.rowMin,
    super.key,
  });

  final Widget child;

  /// Null makes the row static.
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// Minimum height; 56 for a one-line row, 72 for two lines.
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final body = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return body;
    final colors = context.appColors;
    return AppPressable(
      onTap: onTap,
      scale: 1,
      builder: (context, states) => AppFocusRing(
        focused: states.contains(WidgetState.focused),
        style: AppFocusRingStyle.inset,
        borderRadius: BorderRadius.zero,
        child: AnimatedContainer(
          duration: context.motion(AppMotion.instant, reduced: Duration.zero),
          color: states.contains(WidgetState.pressed)
              ? colors.bgSunken
              : colors.bgSurface,
          child: body,
        ),
      ),
    );
  }
}
