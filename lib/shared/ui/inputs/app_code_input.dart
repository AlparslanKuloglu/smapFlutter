import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/controls/clear_color.dart';
import 'package:smap/shared/ui/inputs/app_field_frame.dart';
import 'package:smap/shared/ui/inputs/code_input_logic.dart';

/// The six-box one-time code input (C11 "CodeInput"; board 1.12 "6 haneli
/// kod"; UI guide §5 #13; sign-up and reset code screens 2.4).
///
/// Six boxes of 48 x 56 (narrowing together on a narrow screen), radius 12, 8
/// apart, digit 24/32 · 700 in `textPrimary`, centered. The box that takes
/// the next digit has the 2 pt `textAction` edge while the field has focus.
/// One hidden number field behind the boxes carries the keyboard, the one-time
/// code autofill ([AutofillHints.oneTimeCode]) and the paste: pasting or
/// autofilling a code fills all six boxes at once ([CodeInputLogic.sanitize]),
/// and a long press on the boxes pastes the clipboard.
///
/// A wrong code: set [errorText] (and keep the code, or clear it, as the
/// screen decides). The boxes get the 2 pt `error` edge, shake [AppMotion.fast]
/// (150 ms; 6 pt, three swings; not under "Reduce motion") and play
/// `AppHaptics.error()`; the message line appears below. The shake restarts
/// every time [errorShake] changes, so a second wrong code shakes again even
/// though [errorText] did not change.
///
/// Read as one field: "Doğrulama kodu, 6 hane".
class AppCodeInput extends StatefulWidget {
  const AppCodeInput({
    required this.label,
    this.controller,
    this.focusNode,
    this.helperText,
    this.errorText,
    this.errorShake = 0,
    this.enabled = true,
    this.autofocus = false,
    this.onChanged,
    this.onCompleted,
    super.key,
  });

  /// The group label ("Doğrulama kodu").
  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// "Kodu ad@ornek.com adresine gönderdik."
  final String? helperText;
  final String? errorText;

  /// Increment to replay the error shake for a repeated error.
  final int errorShake;
  final bool enabled;
  final bool autofocus;

  /// Called with the digits typed so far.
  final ValueChanged<String>? onChanged;

  /// Called once with the six digits when the code is complete.
  final ValueChanged<String>? onCompleted;

  /// Box size (C11: 48 x 56).
  static const double boxWidth = 48;
  static const double boxHeight = 56;

  /// Space between boxes (C11: 8).
  static const double gap = AppSpacing.s8;

  @override
  State<AppCodeInput> createState() => _AppCodeInputState();
}

class _AppCodeInputState extends State<AppCodeInput>
    with SingleTickerProviderStateMixin {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: AppMotion.fast,
  );

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _focus.addListener(_refresh);
  }

  @override
  void didUpdateWidget(AppCodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_refresh);
      _controller.addListener(_refresh);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocus)?.removeListener(_refresh);
      _focus.addListener(_refresh);
    }
    final becameWrong = oldWidget.errorText == null && widget.errorText != null;
    if (becameWrong || oldWidget.errorShake != widget.errorShake) {
      AppHaptics.error();
      if (!context.reduceMotion) unawaited(_shake.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _focus.removeListener(_refresh);
    _ownController?.dispose();
    _ownFocus?.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _set(String raw) {
    final code = CodeInputLogic.sanitize(raw);
    if (code != _controller.text) {
      _controller.value = TextEditingValue(
        text: code,
        selection: TextSelection.collapsed(offset: code.length),
      );
    }
    widget.onChanged?.call(code);
    if (CodeInputLogic.isComplete(code)) widget.onCompleted?.call(code);
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || !mounted) return;
    _set(text);
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final code = _controller.text;
    final active = CodeInputLogic.activeIndex(code.length);
    final hasError = widget.errorText != null;
    final focused = _focus.hasFocus && widget.enabled;

    final boxes = LayoutBuilder(
      builder: (context, constraints) {
        const total = CodeInputLogic.length;
        final fit =
            (constraints.maxWidth - (total - 1) * AppCodeInput.gap) / total;
        final width = fit < AppCodeInput.boxWidth ? fit : AppCodeInput.boxWidth;
        return Stack(
          children: [
            AnimatedBuilder(
              animation: _shake,
              builder: (context, child) => Transform.translate(
                offset: Offset(
                  CodeInputLogic.shakeOffset(
                    _shake.value,
                    amplitude: AppMotion.shakeAmplitude,
                    cycles: AppMotion.shakeCycles,
                  ),
                  0,
                ),
                child: child,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < total; i++) ...[
                    if (i > 0) const SizedBox(width: AppCodeInput.gap),
                    _CodeBox(
                      width: width,
                      digit: i < code.length ? code[i] : null,
                      emphasized: hasError || (focused && i == active),
                      error: hasError,
                      enabled: widget.enabled,
                    ),
                  ],
                ],
              ),
            ),
            // The real field: invisible text, no caret, same area as the
            // boxes, so a tap anywhere on them focuses it.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.enabled ? _focus.requestFocus : null,
                onLongPress: widget.enabled ? _paste : null,
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  expands: true,
                  maxLines: null,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\-]')),
                  ],
                  onChanged: _set,
                  style: text.bodyLg.copyWith(color: colors.bgSurface.clear),
                  cursorColor: colors.bgSurface.clear,
                  decoration: bareFieldDecoration(),
                ),
              ),
            ),
          ],
        );
      },
    );

    final message = widget.errorText ?? widget.helperText;
    return Semantics(
      container: true,
      label: '${widget.label}, ${l10n.kit_codeDigits(CodeInputLogic.length)}',
      textField: true,
      enabled: widget.enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Text(
              widget.label,
              style: text.labelMd.copyWith(
                color: widget.enabled
                    ? colors.textPrimary
                    : colors.textDisabled,
              ),
            ),
          ),
          const SizedBox(height: AppFieldFrame.labelGap),
          SizedBox(height: AppCodeInput.boxHeight, child: boxes),
          if (message != null) ...[
            const SizedBox(height: AppFieldFrame.messageGap),
            AppFieldMessage(
              message: message,
              tone: hasError
                  ? AppFieldMessageTone.error
                  : AppFieldMessageTone.help,
            ),
          ],
        ],
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.width,
    required this.digit,
    required this.emphasized,
    required this.error,
    required this.enabled,
  });

  final double width;
  final String? digit;
  final bool emphasized;
  final bool error;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final Color edge;
    if (error) {
      edge = colors.error;
    } else if (!enabled) {
      edge = colors.borderStrong;
    } else if (emphasized) {
      edge = colors.textAction;
    } else {
      edge = colors.borderControl;
    }
    return AnimatedContainer(
      duration: context.motion(AppMotion.fast, reduced: AppMotion.fast),
      curve: AppMotion.standard,
      width: width,
      height: AppCodeInput.boxHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: enabled ? colors.bgSurface : colors.bgCanvas,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: edge, width: emphasized ? 2 : 1),
      ),
      child: digit == null
          ? null
          : Text(
              digit!,
              style: context.appText.metricMd.copyWith(
                color: enabled ? colors.textPrimary : colors.textDisabled,
              ),
            ),
    );
  }
}
