import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/shared/ui/controls/app_chip.dart';

/// One chip of an [AppChipGroup].
class AppChipItem<T> {
  const AppChipItem({
    required this.value,
    required this.label,
    this.icon,
    this.dotColor,
    this.enabled = true,
  });

  final T value;
  final String label;
  final IconData? icon;

  /// The subject accent of a subject chip.
  final Color? dotColor;
  final bool enabled;
}

/// A wrapping set of [AppChip]s (C06 `SmapChipGroup`; board 1.11 "Filtre
/// çipi", "Seçim çipi", "Ders çipi").
///
/// [exclusive] true is a single choice (a radio group: "Tümü / Yanlışlar /
/// Boşlar" is a segment now, but the grade and subject filters are single
/// choice chips) and reads as one; false is a multiple choice filter where
/// each chip toggles. The group only reports the tapped value through
/// [onChanged]; the caller owns the selection ([selected]).
///
/// Chips sit 8 apart; each chip's own 48 pt target supplies the vertical
/// rhythm, so the rows need no extra spacing.
class AppChipGroup<T> extends StatelessWidget {
  const AppChipGroup({
    required this.items,
    required this.selected,
    required this.onChanged,
    this.size = AppChipSize.sm36,
    this.exclusive = true,
    this.focusGapColor,
    super.key,
  });

  final List<AppChipItem<T>> items;

  /// The selected values.
  final Set<T> selected;

  /// Called with the tapped chip's value.
  final ValueChanged<T>? onChanged;
  final AppChipSize size;
  final bool exclusive;
  final Color? focusGapColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Wrap(
        spacing: AppSpacing.s8,
        children: [
          for (final item in items)
            AppChip(
              label: item.label,
              size: size,
              icon: item.icon,
              dotColor: item.dotColor,
              selected: selected.contains(item.value),
              exclusive: exclusive,
              focusGapColor: focusGapColor,
              onTap: onChanged == null || !item.enabled
                  ? null
                  : () => onChanged!(item.value),
            ),
        ],
      ),
    );
  }
}

/// The 40 pt filter pill (C06 `SmapFilterPill`; 6.1, 7.2): a [AppChipSize.md40]
/// chip that either opens a sheet or toggles a filter.
///
/// Opening a sheet ("TYT · Genel"): [opensSheet] adds the CaretDown 18 at the
/// end. Toggling ("Eksiklerim (31)"): pass [icon] (Flag 16) and [selected];
/// it is navy when on.
class AppFilterPill extends StatelessWidget {
  const AppFilterPill({
    required this.label,
    required this.onTap,
    this.selected = false,
    this.icon,
    this.opensSheet = false,
    this.focusGapColor,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final bool selected;

  /// Leading icon, 16 pt (`PhosphorIconsRegular.flag`).
  final IconData? icon;

  /// Shows the trailing CaretDown that marks a pill opening a sheet.
  final bool opensSheet;
  final Color? focusGapColor;

  @override
  Widget build(BuildContext context) {
    return AppChip(
      label: label,
      onTap: onTap,
      selected: selected,
      size: AppChipSize.md40,
      icon: icon,
      trailingIcon: opensSheet ? PhosphorIconsRegular.caretDown : null,
      focusGapColor: focusGapColor,
    );
  }
}
