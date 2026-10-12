import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/controls/app_radio.dart';
import 'package:smap/shared/ui/inputs/app_field_frame.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// One choice of an [AppSelectField].
@immutable
class AppSelectOption<T> {
  const AppSelectOption({required this.value, required this.label});

  final T value;

  /// "12. Sınıf".
  final String label;
}

/// The field that picks one of a few values in a sheet (C12 "SelectField";
/// board 1.12 "Girdiler"; board 1.20 kare 3 "Sınıf" and "Alan"; UI guide §5
/// #12).
///
/// It looks like an `AppTextField` (label above, 48 pt box, radius 12, the
/// 16/24 value, a 20 pt CaretDown at the right in `textSecondary`) but acts
/// as a button: it never opens a list in place, it opens an `AppSheet` with
/// one `AppRadioListTile` row (56 pt) per option. Choosing a row closes the
/// sheet at once and calls [onChanged]; there is no separate confirm, and
/// dismissing the sheet changes nothing. A sheet of more than six options is
/// `medium` and scrolls.
///
/// **Disabled** ([enabled] false): `bgCanvas` fill, `borderStrong` edge and
/// `textDisabled` label, value and caret; [helperText] says why ("9. ve 10.
/// sınıfta alan seçilmez."), [disabledValueText] is what the box reads
/// ("Seçilmez"). An empty enabled field reads [hintText] ("Seç") in
/// `textPlaceholder`.
///
/// [sheetNote] is a line under the rows of the sheet (13/20 `textSecondary`,
/// "9. ya da 10. sınıfı seçersen alan kaldırılır."; pano 9.2 kare 4).
///
/// Read as one button: "Sınıf, 10. Sınıf, düğme, seçenekleri açar".
class AppSelectField<T extends Object> extends StatelessWidget {
  const AppSelectField({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.sheetTitle,
    this.sheetNote,
    this.hintText,
    this.helperText,
    this.errorText,
    this.disabledValueText,
    this.optional = false,
    this.enabled = true,
    this.focusNode,
    super.key,
  });

  /// The visible label ("Sınıf").
  final String label;
  final List<AppSelectOption<T>> options;

  /// The chosen value; null shows the hint.
  final T? value;
  final ValueChanged<T>? onChanged;

  /// The sheet's title; [label] when null.
  final String? sheetTitle;

  /// A note under the option rows of the sheet; none when null.
  final String? sheetNote;

  /// Shown while nothing is chosen; "Seç" when null.
  final String? hintText;
  final String? helperText;
  final String? errorText;

  /// What a disabled field reads when it has no value ("Seçilmez").
  final String? disabledValueText;
  final bool optional;
  final bool enabled;
  final FocusNode? focusNode;

  /// A sheet with more rows than this opens at `medium` height.
  static const int smallSheetRows = 6;

  AppSelectOption<T>? get _selected {
    for (final option in options) {
      if (option.value == value) return option;
    }
    return null;
  }

  Future<void> _open(BuildContext context) async {
    final chosen = await AppSheet.show<T>(
      context: context,
      size: options.length > smallSheetRows
          ? AppSheetSize.medium
          : AppSheetSize.small,
      builder: (_) => _SelectSheet<T>(
        title: sheetTitle ?? label,
        note: sheetNote,
        options: options,
        value: value,
      ),
    );
    if (chosen != null) onChanged?.call(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final active = enabled && onChanged != null;
    final selected = _selected;
    final shown =
        selected?.label ??
        (active
            ? (hintText ?? l10n.kit2_selectPlaceholder)
            : (disabledValueText ?? ''));
    final isHint = selected == null && active;
    final hint = [if (active) l10n.kit2_a11ySelectHint, ?helperText].join('. ');

    return Semantics(
      button: true,
      enabled: active,
      label: '$label, $shown',
      hint: hint.isEmpty ? null : hint,
      excludeSemantics: true,
      onTap: active ? () => _open(context) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: active ? () => _open(context) : null,
        child: AppFieldFrame(
          label: label,
          optional: optional,
          helperText: helperText,
          errorText: errorText,
          enabled: active,
          focusNode: focusNode,
          trailing: SizedBox.square(
            dimension: AppSize.touch,
            child: Center(
              child: PhosphorIcon(
                PhosphorIconsRegular.caretDown,
                size: AppSize.iconInButton,
                color: active ? colors.textSecondary : colors.textDisabled,
              ),
            ),
          ),
          inputBuilder: (context, node, style, cursor) =>
              FocusableActionDetector(
                focusNode: node,
                enabled: active,
                actions: {
                  ActivateIntent: CallbackAction<ActivateIntent>(
                    onInvoke: (_) {
                      _open(context);
                      return null;
                    },
                  ),
                },
                child: Text(
                  shown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isHint
                      ? style.copyWith(color: colors.textPlaceholder)
                      : style,
                ),
              ),
        ),
      ),
    );
  }
}

/// The sheet of an [AppSelectField]: a title, the option rows, no buttons.
class _SelectSheet<T extends Object> extends StatelessWidget {
  const _SelectSheet({
    required this.title,
    required this.options,
    required this.value,
    this.note,
  });

  final String title;
  final String? note;
  final List<AppSelectOption<T>> options;
  final T? value;

  @override
  Widget build(BuildContext context) {
    return AppSheetFrame(
      title: title,
      bodyPadding: const EdgeInsets.only(bottom: AppSpacing.s16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final option in options)
            AppRadioListTile<T>(
              value: option.value,
              groupValue: value,
              title: option.label,
              horizontalPadding: AppSpacing.s24,
              focusGapColor: context.appColors.bgRaised,
              onChanged: (chosen) => Navigator.of(context).pop(chosen),
            ),
          if (note case final text?)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s8,
                AppSpacing.s24,
                0,
              ),
              child: Text(
                text,
                style: context.appText.caption.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
