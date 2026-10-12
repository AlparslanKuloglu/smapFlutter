import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';

/// The card surface (spec C-card; UI guide §5 #16; board 1.16 "Kartlar ve
/// satırlar"): `bgSurface`, radius 16, padding 16, no edge and no shadow (a
/// surface has an edge or a shadow, never both; cards have neither).
///
/// Cards sit on `bgCanvas` and are told apart by their fill alone. [onTap]
/// makes the card a button: pressed it darkens one step toward `bgSunken`
/// and scales to 0,98 over 100 ms (no scale under "Reduce motion"). Use
/// [clip] when a child (a cover image, a row group) must follow the rounded
/// corners. In dark theme the fill is the lighter `bgSurface`, so elevation
/// reads without a shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.s16),
    this.onTap,
    this.semanticLabel,
    this.radius = AppRadius.borderLg,
    this.clip = false,
    this.color,
    this.focusGapColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Makes the card tappable.
  final VoidCallback? onTap;

  /// The accessible name of a tappable card whose text is not enough. When
  /// given, it is the card's whole reading: the texts inside are not read
  /// again (single reading).
  final String? semanticLabel;
  final BorderRadius radius;

  /// Clips the content to the rounded shape.
  final bool clip;

  /// A fill other than `bgSurface` (on a navy band, for instance).
  final Color? color;
  final Color? focusGapColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fill = color ?? colors.bgSurface;
    Widget surface({required bool pressed, required bool focused}) {
      return AppFocusRing(
        focused: focused,
        borderRadius: radius,
        gapColor: focusGapColor,
        child: AnimatedContainer(
          duration: context.motion(AppMotion.instant, reduced: Duration.zero),
          curve: AppMotion.standard,
          clipBehavior: clip ? Clip.antiAlias : Clip.none,
          decoration: BoxDecoration(
            color: pressed ? Color.lerp(fill, colors.bgSunken, 0.5) : fill,
            borderRadius: radius,
          ),
          child: Padding(padding: padding, child: child),
        ),
      );
    }

    if (onTap == null) return surface(pressed: false, focused: false);
    // A card with a [semanticLabel] reads as that one sentence: its inner
    // texts and the tap node of the gesture detector are left out. Without
    // `excludeSemantics` the two `onTap` actions cannot merge, and the screen
    // reader met the label on one node and an unnamed "button" on another.
    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onTap,
      excludeSemantics: semanticLabel != null,
      child: AppPressable(
        onTap: onTap,
        builder: (context, states) => surface(
          pressed: states.contains(WidgetState.pressed),
          focused: states.contains(WidgetState.focused),
        ),
      ),
    );
  }
}
