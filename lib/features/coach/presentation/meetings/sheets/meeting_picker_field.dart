import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/inputs/app_field_frame.dart';

/// A field that opens a picker sheet (pano 10.5 kare 2: "Öğrenci" with the
/// avatar, "Tarih", "Saat"): the look of `AppSelectField` (label above, 48 pt
/// box, the value, a 20 pt CaretDown), but the sheet it opens is the
/// caller's, so it can be a student list, a calendar or a time wheel.
///
/// An empty field reads [hintText] in `textPlaceholder`. [leading] is a
/// widget at the left inside the box (the student's 28 pt avatar). Read as
/// one button: "Tarih, 12 Ekim 2026 Pzt, düğme, seçenekleri açar".
class MeetingPickerField extends StatelessWidget {
  const MeetingPickerField({
    required this.label,
    required this.onTap,
    this.value,
    this.hintText,
    this.errorText,
    this.leading,
    super.key,
  });

  /// The visible label ("Tarih").
  final String label;

  /// Opens the picker.
  final VoidCallback onTap;

  /// What is chosen; `null` shows [hintText].
  final String? value;
  final String? hintText;
  final String? errorText;

  /// A widget before the value (the avatar), 8 pt from it.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final shown = value ?? hintText ?? '';
    final isHint = value == null;
    return Semantics(
      button: true,
      label: '$label, $shown',
      hint: l10n.kit2_a11ySelectHint,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AppFieldFrame(
          label: label,
          errorText: errorText,
          leading: leading == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.s8),
                  child: leading,
                ),
          trailing: SizedBox.square(
            dimension: AppSize.touch,
            child: Center(
              child: PhosphorIcon(
                PhosphorIconsRegular.caretDown,
                size: AppSize.iconInButton,
                color: colors.textSecondary,
              ),
            ),
          ),
          inputBuilder: (context, node, style, cursor) =>
              FocusableActionDetector(
                focusNode: node,
                actions: {
                  ActivateIntent: CallbackAction<ActivateIntent>(
                    onInvoke: (_) {
                      onTap();
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
