import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/controls/clear_color.dart';

/// The checkbox row (C14 "Checkbox"; board 1.13 "Onay kutusu"; UI guide §5
/// #9).
///
/// A 24 pt box (radius 4) in a row at least 48 high; the whole row is the
/// touch target and the label sits 12 pt from the box. Empty: a 2 pt
/// `borderControl` edge inside the box. Checked: `primary` fill with a 16 pt
/// Check in `onPrimary`. Disabled: a `borderStrong` edge and a
/// `textDisabled` label. The fill fades in [AppMotion.fast] (150 ms) and a
/// change plays `AppHaptics.selection()`.
///
/// The label is [label] (15/24 · 400, `textPrimary`) or, when it holds links
/// ("Kullanım Koşulları'nı … okudum"), a [labelChild] built by the caller
/// (underlined, `textAction`, 700; the link opens its text in a sheet). Read
/// as "label, checkbox, checked".
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.value,
    required this.onChanged,
    this.label,
    this.labelChild,
    this.semanticLabel,
    this.focusGapColor,
    super.key,
  }) : assert(
         label != null || labelChild != null || semanticLabel != null,
         'A checkbox needs a visible label or a semanticLabel',
       );

  final bool value;

  /// Null disables the checkbox.
  final ValueChanged<bool>? onChanged;

  /// "Bir daha gösterme".
  final String? label;

  /// A rich label with inline links; wins over [label].
  final Widget? labelChild;

  /// The accessible name when it differs from the visible text.
  final String? semanticLabel;
  final Color? focusGapColor;

  /// The box edge.
  static const double box = 24;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onChanged != null;
    final fade = context.motion(AppMotion.fast, reduced: AppMotion.fast);
    final inkColor = enabled ? colors.textPrimary : colors.textDisabled;

    return Semantics(
      checked: value,
      enabled: enabled,
      label: semanticLabel ?? label,
      excludeSemantics: semanticLabel != null || labelChild == null,
      onTap: enabled ? () => onChanged!(!value) : null,
      child: AppPressable(
        onTap: enabled ? () => onChanged!(!value) : null,
        haptic: true,
        scale: 1,
        builder: (context, states) {
          final Color edge = enabled
              ? colors.borderControl
              : colors.borderStrong;
          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSize.touch),
            child: Row(
              children: [
                AppFocusRing(
                  focused: states.contains(WidgetState.focused),
                  borderRadius: AppRadius.borderXs,
                  gapColor: focusGapColor,
                  child: AnimatedContainer(
                    duration: fade,
                    curve: AppMotion.standard,
                    width: box,
                    height: box,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: value
                          ? (enabled ? colors.primary : colors.borderStrong)
                          : colors.bgSurface.clear,
                      borderRadius: AppRadius.borderXs,
                      border: value ? null : Border.all(color: edge, width: 2),
                    ),
                    child: AnimatedOpacity(
                      duration: fade,
                      opacity: value ? 1 : 0,
                      child: PhosphorIcon(
                        PhosphorIconsBold.check,
                        size: 16,
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                ),
                if (labelChild != null || label != null) ...[
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s12,
                      ),
                      child:
                          labelChild ??
                          Text(
                            label!,
                            style: context.appText.body.copyWith(
                              color: inkColor,
                            ),
                          ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
