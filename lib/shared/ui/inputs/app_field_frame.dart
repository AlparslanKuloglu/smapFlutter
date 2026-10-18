import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';

/// Builds the editable part of a field: a `TextField` that uses [focusNode],
/// [style] and [cursorColor] and the [bareFieldDecoration].
typedef AppFieldInputBuilder =
    Widget Function(
      BuildContext context,
      FocusNode focusNode,
      TextStyle style,
      Color cursorColor,
    );

/// A decoration with no border, fill or padding of its own: the frame draws
/// all of it. `InputDecoration.collapsed` is not enough because the theme's
/// enabled and focused borders and fill would still apply.
InputDecoration bareFieldDecoration({String? hintText, TextStyle? hintStyle}) {
  return InputDecoration(
    isCollapsed: true,
    hintText: hintText,
    hintStyle: hintStyle,
    filled: false,
    counterText: '',
    contentPadding: EdgeInsets.zero,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
  );
}

/// The shared chrome of every input (C09 "TextField"; board 1.12 "Girdiler ·
/// 6 tür · 5 durum"): the label above, the field box, the help or error line
/// below. [AppTextField], [AppTextArea] and [AppSearchField] are built on it.
///
/// Measures (C09): the label is 8 above the box; the box is at least 48 high,
/// radius 12, with 16 side padding; the message is 6 below it. Fields are 24
/// apart (the caller's gap). The box edge, drawn inside:
///
/// | state | box |
/// |---|---|
/// | rest | 1 pt `borderControl`, `bgSurface` fill |
/// | focus | 2 pt `textAction` |
/// | error | 2 pt `error`; message 13/20 · 600 `error` with a WarningCircle 16 |
/// | success | message 13/20 · 600 `success`, the check is the caller's trailing |
/// | disabled | `bgCanvas` fill, 1 pt `borderStrong`, `textDisabled` text and label |
/// | read only | `bgSunken` fill, no edge, full-contrast text, the lock is the caller's trailing |
///
/// The text inside never shifts when the edge grows from 1 to 2: the side
/// padding gives the extra point back. A field does not shake; the edge turns
/// in [AppMotion.fast] (150 ms) and an error that appears plays
/// `AppHaptics.error()` once (C09 "Hareket").
///
/// Keyboard focus is the edge turning navy; no separate ring is drawn.
class AppFieldFrame extends StatefulWidget {
  const AppFieldFrame({
    required this.inputBuilder,
    this.focusNode,
    this.label,
    this.optional = false,
    this.semanticLabel,
    this.helperText,
    this.errorText,
    this.successText,
    this.enabled = true,
    this.readOnly = false,
    this.minHeight = AppSize.input,
    this.verticalPadding = 0,
    this.leading,
    this.trailing,
    this.counter,
    this.alignTop = false,
    super.key,
  });

  final AppFieldInputBuilder inputBuilder;
  final FocusNode? focusNode;

  /// The visible label above the box.
  final String? label;

  /// Adds the "(isteğe bağlı)" tail to the label.
  final bool optional;

  /// The accessible name when there is no visible label ("Öğrenci ara"); with
  /// a label it replaces the label's reading ("Koçluk kodu, 4 harf ve 4
  /// rakam").
  final String? semanticLabel;

  /// Help line under the box (13/20 · 500 `textSecondary`).
  final String? helperText;

  /// Error line; wins over [helperText] and [successText].
  final String? errorText;

  /// Live-check success line ("Bu kullanıcı adı boşta.").
  final String? successText;
  final bool enabled;
  final bool readOnly;
  final double minHeight;

  /// Vertical padding inside the box (a text area uses 12).
  final double verticalPadding;

  /// Widget before the input, inside the box (the search magnifier).
  final Widget? leading;

  /// Widget after the input, flush to the right edge of the box: an icon
  /// button, the lock, the live-check mark or spinner. Give it its own 48
  /// pt square.
  final Widget? trailing;

  /// Right-aligned text on the message line (the "44/500" counter).
  final Widget? counter;

  /// Aligns [leading] and [trailing] to the top (a multi-line field).
  final bool alignTop;

  /// Side padding of the box (C09: 16).
  static const double sidePadding = AppSpacing.s16;

  /// Gap between the label and the box (C09: 8).
  static const double labelGap = AppSpacing.s8;

  /// Gap between the box and its message (C09: 6).
  static const double messageGap = 6;

  @override
  State<AppFieldFrame> createState() => _AppFieldFrameState();
}

class _AppFieldFrameState extends State<AppFieldFrame> {
  FocusNode? _ownFocus;
  bool _focused = false;

  FocusNode get _node => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(AppFieldFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocus)?.removeListener(_onFocus);
      _node.addListener(_onFocus);
    }
    if (oldWidget.errorText == null && widget.errorText != null) {
      AppHaptics.error();
    }
  }

  @override
  void dispose() {
    _node.removeListener(_onFocus);
    _ownFocus?.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (_focused == _node.hasFocus) return;
    setState(() => _focused = _node.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final enabled = widget.enabled;
    final error = widget.errorText;
    final hasError = error != null;
    final editable = enabled && !widget.readOnly;
    final emphasized = hasError || (_focused && editable);

    final Color edge;
    final Color fill;
    if (hasError) {
      edge = colors.error;
      fill = colors.bgSurface;
    } else if (!enabled) {
      edge = colors.borderStrong;
      fill = colors.bgCanvas;
    } else if (widget.readOnly) {
      edge = colors.bgSunken;
      fill = colors.bgSunken;
    } else if (_focused) {
      edge = colors.textAction;
      fill = colors.bgSurface;
    } else {
      edge = colors.borderControl;
      fill = colors.bgSurface;
    }
    final edgeWidth = emphasized ? 2.0 : 1.0;
    final ink = enabled ? colors.textPrimary : colors.textDisabled;
    final inputStyle = text.bodyLg.copyWith(color: ink);
    final fast = context.motion(AppMotion.fast, reduced: AppMotion.fast);

    final input = widget.inputBuilder(
      context,
      _node,
      inputStyle,
      colors.textAction,
    );
    final name = widget.semanticLabel ?? widget.label;
    final box = AnimatedContainer(
      duration: fast,
      curve: AppMotion.standard,
      constraints: BoxConstraints(minHeight: widget.minHeight),
      padding: EdgeInsets.only(
        left: AppFieldFrame.sidePadding - edgeWidth,
        right: widget.trailing == null
            ? AppFieldFrame.sidePadding - edgeWidth
            : 0,
        top: widget.verticalPadding,
        bottom: widget.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: edge, width: edgeWidth),
      ),
      child: Row(
        crossAxisAlignment: widget.alignTop
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          ?widget.leading,
          Expanded(
            child: MergeSemantics(
              child: Semantics(label: name, child: input),
            ),
          ),
          ?widget.trailing,
        ],
      ),
    );

    final String? message = error ?? widget.successText ?? widget.helperText;
    final label = widget.label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          ExcludeSemantics(
            child: Text.rich(
              TextSpan(
                text: label,
                children: [
                  if (widget.optional)
                    TextSpan(
                      text: ' ${l10n.kit_optionalSuffix}',
                      style: text.labelMd.copyWith(
                        fontWeight: FontWeight.w500,
                        color: enabled
                            ? colors.textSecondary
                            : colors.textDisabled,
                      ),
                    ),
                ],
              ),
              style: text.labelMd.copyWith(color: ink),
            ),
          ),
          const SizedBox(height: AppFieldFrame.labelGap),
        ],
        box,
        if (message != null || widget.counter != null) ...[
          const SizedBox(height: AppFieldFrame.messageGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: message == null
                    ? const SizedBox.shrink()
                    : AppFieldMessage(
                        message: message,
                        tone: hasError
                            ? AppFieldMessageTone.error
                            : (widget.successText != null
                                  ? AppFieldMessageTone.success
                                  : AppFieldMessageTone.help),
                      ),
              ),
              if (widget.counter case final counter?) ...[
                const SizedBox(width: AppSpacing.s8),
                counter,
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// How a field's message line reads.
enum AppFieldMessageTone {
  /// A hint under the box: 13/20 · 500 `textSecondary`.
  help,

  /// A failed check: 13/20 · 600 `error` with a 16 pt WarningCircle. The
  /// message names the fix ("E-posta adresi eksik görünüyor. Örn:
  /// ad@alan.com"), never a code. Announced as a live region.
  error,

  /// A passed live check: 13/20 · 600 `success` ("Bu kullanıcı adı boşta.").
  success,
}

/// The message line under a field box (C09 "Yardım / hata metni"; board 1.12
/// "Hata metni çözüm söyler"); shared by [AppFieldFrame] and the code input.
class AppFieldMessage extends StatelessWidget {
  const AppFieldMessage({
    required this.message,
    this.tone = AppFieldMessageTone.help,
    super.key,
  });

  final String message;
  final AppFieldMessageTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final caption = context.appText.caption;
    final isError = tone == AppFieldMessageTone.error;
    final style = switch (tone) {
      AppFieldMessageTone.help => caption.copyWith(color: colors.textSecondary),
      AppFieldMessageTone.error => caption.copyWith(
        color: colors.error,
        fontWeight: FontWeight.w600,
      ),
      AppFieldMessageTone.success => caption.copyWith(
        color: colors.success,
        fontWeight: FontWeight.w600,
      ),
    };
    return Semantics(
      liveRegion: isError,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isError) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: PhosphorIcon(
                PhosphorIconsRegular.warningCircle,
                size: 16,
                color: colors.error,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Expanded(child: Text(message, style: style)),
        ],
      ),
    );
  }
}
