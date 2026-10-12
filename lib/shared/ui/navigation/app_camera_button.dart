import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_shadows.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/navigation/app_nav_tab.dart';

/// The camera button in the middle of the bottom bar (C84 `SmapCameraButton`;
/// pano 1.19 "Kamera"; UI guide §5 #35).
///
/// A 56 x 56 square, radius 16, `accent` (the one orange fill of the app),
/// with a 28 pt Camera icon in `onAccent` navy (never white on orange) and
/// the `raised` shadow. The label "Okut" (12/16 · 700, `textPrimary`) sits
/// 4 pt under it and belongs to the same 72 pt slot; both are tappable. The
/// slot is 76 high: the button rises 16 above the bar, so the widget is
/// placed so its top edge is 16 over the bar's top (`AppBottomBar` does it).
///
/// Not a tab: no position indicator, it opens the full-screen camera flow
/// ([onPressed]). Pressing scales it to 0,92 over 100 ms (not under "Reduce
/// motion") and plays `AppHaptics.medium()` on the tap. Read as
/// [semanticLabel], "Okut: deneme formunu kamerayla okut"; the visible label
/// is hidden from screen readers.
class AppCameraButton extends StatelessWidget {
  const AppCameraButton({
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
    this.labelScale,
    super.key,
  });

  /// The visible label, "Okut".
  final String label;

  /// The accessible name, "Okut: deneme formunu kamerayla okut".
  final String semanticLabel;
  final VoidCallback onPressed;

  /// The bar's shared label shrink factor (0..1) so "Okut" matches the tab
  /// labels at large text; null draws it at the plain text scale, shrunk to
  /// the slot if needed.
  final double? labelScale;

  /// Width of the slot the button lives in.
  static const double slotWidth = 72;

  /// Edge of the button.
  static const double size = AppSize.cameraButton;

  /// Height of the whole control: the button, 4 pt, the 16 pt label.
  static const double height = size + AppSpacing.s4 + 16;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: AppPressable(
        scale: AppMotion.shutterScale,
        onTap: () {
          AppHaptics.medium();
          onPressed();
        },
        builder: (context, states) => SizedBox(
          width: slotWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppFocusRing(
                focused: states.contains(WidgetState.focused),
                borderRadius: AppRadius.borderLg,
                gapColor: colors.bgBar,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: AppRadius.borderLg,
                    boxShadow: AppShadows.raisedOf(context),
                  ),
                  child: SizedBox.square(
                    dimension: size,
                    child: Center(
                      child: PhosphorIcon(
                        PhosphorIconsRegular.camera,
                        size: 28,
                        color: colors.onAccent,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              ExcludeSemantics(
                child: _CameraLabel(label: label, scale: labelScale),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Okut" under the button: like the tab labels, a shared [scale] or a fit
/// to the slot.
class _CameraLabel extends StatelessWidget {
  const _CameraLabel({required this.label, required this.scale});

  final String label;
  final double? scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = context.appText.labelSm.copyWith(
      fontWeight: FontWeight.w700,
      color: colors.textPrimary,
    );
    final shared = scale;
    if (shared == null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, maxLines: 1, style: style),
      );
    }
    return Text(
      label,
      maxLines: 1,
      softWrap: false,
      textScaler: TextScaler.noScaling,
      style: AppNavTab.sharedStyle(
        style,
        MediaQuery.textScalerOf(context),
        shared,
      ),
    );
  }
}
