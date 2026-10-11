import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/controls/clear_color.dart';

/// The on/off switch (C16 "Switch"; board 1.13 "Anahtar"; UI guide §5 #9).
///
/// 52 x 32 (radius full), touch target 48. Off: a see-through track with a 2
/// pt `borderControl` edge and a small 16 pt `borderControl` knob at the left.
/// On: a `primary` track with a 24 pt `onPrimary` knob at the right that
/// carries a 14 pt Check in `primary`, so the state does not rest on color
/// alone. Disabled off: `borderStrong` edge and knob; disabled on: a
/// `borderSubtle` track with a `textDisabled` check.
///
/// The knob slides and grows in [AppMotion.fast] (150 ms, standard curve);
/// a change plays `AppHaptics.selection()`. A change is saved at once (no
/// Save button); if the save fails the owner flips the value back and
/// toasts.
///
/// Put it at the end of an `AppRow`; give it a [semanticLabel] only when no
/// row label sits next to it. Read as "label, on, switch".
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    this.focusGapColor,
    super.key,
  });

  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;

  /// Needed when no row label sits next to the switch.
  final String? semanticLabel;
  final Color? focusGapColor;

  /// Track width and height.
  static const double width = 52;
  static const double height = 32;

  /// Knob edges: small off, large on.
  static const double _knobOff = 16;
  static const double _knobOn = 24;

  /// Offset of the off knob from the track edge, and of the on knob.
  static const double _insetOff = 8;
  static const double _insetOn = AppSpacing.s4;

  /// The track's edge; an on track paints it in its own color, so the knob's
  /// coordinates are the same in both states.
  static const double _edge = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onChanged != null;
    final move = context.motion(AppMotion.fast, reduced: AppMotion.fast);

    final Color track;
    final Color knob;
    final Color check;
    final Color edge;
    if (value) {
      track = enabled ? colors.primary : colors.borderSubtle;
      knob = enabled ? colors.onPrimary : colors.bgSurface;
      check = enabled ? colors.primary : colors.textDisabled;
      edge = track;
    } else {
      track = colors.bgSurface.clear;
      knob = enabled ? colors.borderControl : colors.borderStrong;
      check = colors.bgSurface.clear;
      edge = enabled ? colors.borderControl : colors.borderStrong;
    }

    void toggle() {
      AppHaptics.selection();
      onChanged!(!value);
    }

    return Semantics(
      toggled: value,
      enabled: enabled,
      label: semanticLabel,
      onTap: enabled ? toggle : null,
      child: AppPressable(
        onTap: enabled ? toggle : null,
        scale: 1,
        builder: (context, states) => SizedBox(
          width: width,
          height: AppSize.touch,
          child: Center(
            child: AppFocusRing(
              focused: states.contains(WidgetState.focused),
              borderRadius: AppRadius.borderFull,
              gapColor: focusGapColor,
              child: AnimatedContainer(
                duration: move,
                curve: AppMotion.standard,
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: track,
                  borderRadius: AppRadius.borderFull,
                  border: Border.all(color: edge, width: _edge),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: move,
                      curve: AppMotion.standard,
                      left:
                          (value ? width - _insetOn - _knobOn : _insetOff) -
                          _edge,
                      top: (value ? _insetOn : _insetOff) - _edge,
                      width: value ? _knobOn : _knobOff,
                      height: value ? _knobOn : _knobOff,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: knob,
                        ),
                        child: Center(
                          child: PhosphorIcon(
                            PhosphorIconsBold.check,
                            size: 14,
                            color: check,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
