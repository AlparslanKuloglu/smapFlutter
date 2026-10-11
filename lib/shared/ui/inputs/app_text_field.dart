import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/indicators/app_spinner.dart';
import 'package:smap/shared/ui/inputs/app_field_frame.dart';

/// The single-line input (C09 "TextField"; board 1.12 "Girdiler"; UI guide §5
/// #10).
///
/// The label sits above the field and is always there (a field without a
/// label is not built; a search field names itself with `semanticLabel`).
/// A 48 pt box, radius 12, 16/24 value so iOS does not zoom. States, all of
/// [AppFieldFrame]:
///
/// - empty: [hintText] only as "Örn: Bilgi Sarmal" in `textPlaceholder`;
/// - focus, error ([errorText], with a WarningCircle; the message says the
///   fix, "E-posta adresi eksik görünüyor. Örn: ad@alan.com", never a
///   server code), disabled, [readOnly] (a 20 pt Lock at the right);
/// - live check: [checking] shows a spinner at the right, [successText]
///   ("Bu kullanıcı adı boşta.") shows a 22 pt CheckCircle in `success`;
/// - [password]: a 48 pt Eye / EyeSlash button at the right ("Şifreyi göster"
///   / "Şifreyi gizle"); the text is hidden until toggled;
/// - [optional]: "(isteğe bağlı)" after the label. A required field has no
///   star (forms are mostly required).
///
/// The field does not shake. Validation timing is the caller's: on blur or
/// submit, then while typing after the first error (C09 "Doğrulama"). The
/// masks of phone and coaching code are in [AppInputMasks] (pass as
/// [inputFormatters]). Fields carry no pre-filled value.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.focusNode,
    this.hintText,
    this.helperText,
    this.errorText,
    this.successText,
    this.checking = false,
    this.password = false,
    this.optional = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.prefixText,
    this.suffix,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    super.key,
  });

  /// The visible label ("Ad Soyad").
  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Only an example in the form "Örn: …".
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? successText;

  /// A live check is running: a spinner at the right.
  final bool checking;

  /// A password field with a show/hide button.
  final bool password;
  final bool optional;

  /// Shows the Lock and the read-only look.
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  /// `AutofillHints.username`, `password`, `newPassword`, `oneTimeCode`.
  final Iterable<String>? autofillHints;

  /// Text before the value ("+90").
  final String? prefixText;

  /// A custom widget at the right when no built-in mark applies; give it a
  /// 48 pt square.
  final Widget? suffix;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.password;

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.password != widget.password) _hidden = widget.password;
  }

  Widget? _trailing(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    if (widget.readOnly) {
      return _Slot(
        child: PhosphorIcon(
          PhosphorIconsRegular.lock,
          size: AppSize.iconInButton,
          color: colors.textSecondary,
        ),
      );
    }
    if (widget.checking) {
      return _Slot(
        child: AppSpinner(
          size: AppSize.iconInButton,
          semanticLabel: l10n.kit_checking,
        ),
      );
    }
    if (widget.successText != null) {
      return _Slot(
        child: PhosphorIcon(
          PhosphorIconsRegular.checkCircle,
          size: 22,
          color: colors.success,
        ),
      );
    }
    if (widget.password) {
      return AppIconButton(
        icon: _hidden
            ? PhosphorIconsRegular.eye
            : PhosphorIconsRegular.eyeSlash,
        semanticLabel: _hidden ? l10n.kit_showPassword : l10n.kit_hidePassword,
        color: colors.textSecondary,
        onPressed: widget.enabled
            ? () => setState(() => _hidden = !_hidden)
            : null,
      );
    }
    return widget.suffix;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppFieldFrame(
      label: widget.label,
      optional: widget.optional,
      helperText: widget.helperText,
      errorText: widget.errorText,
      successText: widget.successText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      focusNode: widget.focusNode,
      trailing: _trailing(context),
      inputBuilder: (context, node, style, cursor) => Row(
        children: [
          if (widget.prefixText case final prefix?) ...[
            Text(prefix, style: style.copyWith(color: colors.textSecondary)),
            const SizedBox(width: AppSpacing.s8),
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: node,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              autofocus: widget.autofocus,
              obscureText: _hidden,
              obscuringCharacter: '•',
              autocorrect: !widget.password,
              enableSuggestions: !widget.password,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              inputFormatters: widget.inputFormatters,
              autofillHints: widget.autofillHints,
              maxLength: widget.maxLength,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onEditingComplete: widget.onEditingComplete,
              style: style,
              cursorColor: cursor,
              decoration: bareFieldDecoration(
                hintText: widget.hintText,
                hintStyle: style.copyWith(color: colors.textPlaceholder),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A 48 pt square that centers a non-interactive mark at the right of a
/// field.
class _Slot extends StatelessWidget {
  const _Slot({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: AppSize.touch,
    child: Center(child: child),
  );
}
