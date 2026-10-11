import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/shared/ui/inputs/app_field_frame.dart';

/// The multi-line input (C13 "TextArea"; board 1.12 "Çok satırlı"; Tur 9 G7;
/// UI guide §5 #10): the same chrome as `AppTextField` with at least 104
/// pt of height (the meeting note sheet uses 120), 12 / 16 padding, 16/24
/// text, and an optional character counter at the right of the message line
/// ("44/500", 13/20 `textSecondary`) when [maxLength] is set.
///
/// A save that fails keeps the text and the sheet open; the owner toasts
/// (C13 "Davranış").
class AppTextArea extends StatefulWidget {
  const AppTextArea({
    required this.label,
    this.controller,
    this.focusNode,
    this.hintText,
    this.helperText,
    this.errorText,
    this.optional = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.minHeight = defaultMinHeight,
    this.maxLength,
    this.textCapitalization = TextCapitalization.sentences,
    this.onChanged,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Only an example in the form "Örn: …".
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool optional;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  /// Minimum box height (C13: 104 in the kit, 120 in the note sheet).
  final double minHeight;

  /// Maximum characters; shows the counter and limits the input.
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  /// The kit height.
  static const double defaultMinHeight = 104;

  /// Vertical padding inside the box (C13: 12).
  static const double _vertical = AppSpacing.s12;

  @override
  State<AppTextArea> createState() => _AppTextAreaState();
}

class _AppTextAreaState extends State<AppTextArea> {
  TextEditingController? _ownController;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final limit = widget.maxLength;
    return AppFieldFrame(
      label: widget.label,
      optional: widget.optional,
      helperText: widget.helperText,
      errorText: widget.errorText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      focusNode: widget.focusNode,
      minHeight: widget.minHeight,
      verticalPadding: AppTextArea._vertical,
      alignTop: true,
      counter: limit == null
          ? null
          : ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) => Text(
                '${TrFormat.sira(value.text.characters.length)}/'
                '${TrFormat.sira(limit)}',
                style: context.appText.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
      inputBuilder: (context, node, style, cursor) => TextField(
        controller: _controller,
        focusNode: node,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        autofocus: widget.autofocus,
        minLines: 3,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textCapitalization: widget.textCapitalization,
        inputFormatters: [
          if (limit != null) LengthLimitingTextInputFormatter(limit),
        ],
        onChanged: widget.onChanged,
        style: style,
        cursorColor: cursor,
        decoration: bareFieldDecoration(
          hintText: widget.hintText,
          hintStyle: style.copyWith(color: colors.textPlaceholder),
        ),
      ),
    );
  }
}
