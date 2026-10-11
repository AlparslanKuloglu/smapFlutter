import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';

/// The radio mark (C15 "Radio"; board 1.13 "Radyo"; UI guide §5 #9): a 24 pt
/// circle.
///
/// Unselected: a 2 pt `borderControl` edge. Selected: a 7 pt `primary` ring
/// drawn inward, leaving a 10 pt hole (`inset 0 0 0 7px`, the RoleOption
/// radio of board 2.2, which wins over the 2 pt ring plus 12 pt dot of 1.13;
/// spec §5 #8). The ring grows in [AppMotion.fast]. Disabled: `borderStrong`.
///
/// [AppRadio] is only the mark; sheets use [AppRadioListTile], which makes the
/// whole row the target. A standalone [AppRadio] has a 48 pt target and needs
/// a [semanticLabel].
class AppRadio<T> extends StatelessWidget {
  const AppRadio({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.semanticLabel,
    this.focusGapColor,
    super.key,
  });

  final T value;
  final T? groupValue;

  /// Null disables the radio.
  final ValueChanged<T>? onChanged;
  final String semanticLabel;
  final Color? focusGapColor;

  /// The mark's edge.
  static const double mark = 24;

  /// Ring width of the selected mark.
  static const double _selectedRing = 7;

  /// Edge width of the unselected mark.
  static const double _restRing = 2;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    final enabled = onChanged != null;
    return Semantics(
      label: semanticLabel,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: enabled,
      excludeSemantics: true,
      onTap: enabled ? () => onChanged!(value) : null,
      child: AppPressable(
        onTap: enabled ? () => onChanged!(value) : null,
        haptic: true,
        scale: 1,
        builder: (context, states) => SizedBox.square(
          dimension: AppSize.touch,
          child: Center(
            child: _RadioMark(
              selected: selected,
              enabled: enabled,
              focused: states.contains(WidgetState.focused),
              focusGapColor: focusGapColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// The painted circle of [AppRadio] and [AppRadioListTile].
class _RadioMark extends StatelessWidget {
  const _RadioMark({
    required this.selected,
    required this.enabled,
    required this.focused,
    this.focusGapColor,
  });

  final bool selected;
  final bool enabled;
  final bool focused;
  final Color? focusGapColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final move = context.motion(AppMotion.fast, reduced: AppMotion.fast);
    final Color edge;
    if (!enabled) {
      edge = colors.borderStrong;
    } else {
      edge = selected ? colors.primary : colors.borderControl;
    }
    return AppFocusRing(
      focused: focused,
      borderRadius: AppRadius.borderFull,
      gapColor: focusGapColor,
      child: AnimatedContainer(
        duration: move,
        curve: AppMotion.standard,
        width: AppRadio.mark,
        height: AppRadio.mark,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: edge,
            width: selected ? AppRadio._selectedRing : AppRadio._restRing,
          ),
        ),
      ),
    );
  }
}

/// A selectable row of a sheet (C15 "Sheet içi satır"; board 1.13): label
/// 16/24 · 600 on the left, the radio mark on the right, at least 56 high,
/// 16 pt side padding, 12 between. The whole row is the target.
///
/// Selecting is immediate; the sheet closes on the choice and there is no
/// separate confirm. For a sheet screen (3.5 topic sheet) pass
/// `horizontalPadding: 24`. Read as "label, radio, selected".
class AppRadioListTile<T> extends StatelessWidget {
  const AppRadioListTile({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    this.horizontalPadding = AppSpacing.s16,
    this.focusGapColor,
    super.key,
  });

  final T value;
  final T? groupValue;

  /// Null disables the row.
  final ValueChanged<T>? onChanged;

  /// "12. Sınıf".
  final String title;
  final double horizontalPadding;
  final Color? focusGapColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final selected = value == groupValue;
    final enabled = onChanged != null;
    return Semantics(
      label: title,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: enabled,
      excludeSemantics: true,
      onTap: enabled ? () => onChanged!(value) : null,
      child: AppPressable(
        onTap: enabled ? () => onChanged!(value) : null,
        haptic: true,
        scale: 1,
        builder: (context, states) => ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSize.rowMin),
          child: ColoredBox(
            color: states.contains(WidgetState.pressed)
                ? colors.bgSunken
                : colors.bgSurface.withValues(alpha: 0),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: AppSpacing.s12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: context.appText.titleSm.copyWith(
                        color: enabled
                            ? colors.textPrimary
                            : colors.textDisabled,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  _RadioMark(
                    selected: selected,
                    enabled: enabled,
                    focused: states.contains(WidgetState.focused),
                    focusGapColor: focusGapColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A rounded card of [AppRadioListTile] rows with 1 pt `bgSunken` rules
/// between them (C15 "Sheet içi satır · Kap"): radius 16, a 1 pt
/// `borderSubtle` edge, clipped. The sheet's choice list.
class AppRadioGroup<T> extends StatelessWidget {
  const AppRadioGroup({
    required this.options,
    required this.groupValue,
    required this.onChanged,
    this.semanticLabel,
    super.key,
  });

  /// Value and title of each row.
  final List<({T value, String title})> options;
  final T? groupValue;
  final ValueChanged<T>? onChanged;

  /// Names the group ("Sınıf"); the options read "n seçenekten m" through
  /// their order.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      container: true,
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: AppRadius.borderLg,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: colors.borderSubtle),
            borderRadius: AppRadius.borderLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, option) in options.indexed) ...[
                if (i > 0)
                  Divider(height: 1, thickness: 1, color: colors.bgSunken),
                AppRadioListTile<T>(
                  value: option.value,
                  groupValue: groupValue,
                  onChanged: onChanged,
                  title: option.title,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
