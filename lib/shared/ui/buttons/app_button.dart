import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mihr_ui/mihr_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button_style.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/press_scale.dart';
import 'package:smap/shared/ui/indicators/app_spinner.dart';

export 'package:smap/shared/ui/buttons/app_button_style.dart'
    show AppButtonSize, AppButtonVariant;

/// The text button of the app (C01 "Button"; board 1.9 "Düğmeler · 5 tür ·
/// 2 boy"; UI guide §5 #1).
///
/// Built on the mihr_ui button family with a full per-instance `style`
/// ([AppButtonStyles]; Düzeltmeler #5, #6, #8): `lg48` is mihr's `xl` (48),
/// `md40` is `md` with a padded 48 touch target, radius 12, flat shadows.
/// What the design adds on top:
///
/// - the pressed tone and a 0,98 [PressScale] (100 ms; none under "Reduce
///   motion");
/// - the focus ring of spec §1.4 (2 pt gap + 2 pt ring, flush for the text
///   kinds);
/// - [loading]: the label stays in the layout (invisible) with a 20 pt
///   spinner over it, so the width does not change; taps are ignored; the
///   accessible name is "Yükleniyor". The text kinds do not load;
/// - [disabledReason]: a caption under a disabled button that also becomes
///   its semantic hint. Prefer validation over a disabled button (C01
///   "Kurallar"): a form with a missing field keeps a live primary button.
///
/// [icon] and [trailingIcon] are Phosphor Regular `IconData` at 20 pt, 8 pt
/// from the label. One primary button per screen; labels in Turkish title
/// case ("Detaylı Analiz"), never all caps.
class AppButton extends StatefulWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg48,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.disabledReason,
    this.onLongPress,
    this.focusNode,
    this.autofocus = false,
    this.focusGapColor,
    super.key,
  });

  /// The label ("Detaylı Analiz").
  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final AppButtonVariant variant;
  final AppButtonSize size;

  /// Leading Phosphor icon (`PhosphorIconsRegular.camera`).
  final IconData? icon;

  /// Trailing Phosphor icon (`PhosphorIconsRegular.arrowSquareOut`).
  final IconData? trailingIcon;

  /// Shows the spinner and ignores taps; keeps the enabled colors and the
  /// width. Ignored by the text variants.
  final bool loading;

  /// Fills the available width (sheet buttons).
  final bool expand;

  /// Why the button is disabled; shown under it and read as its hint.
  final String? disabledReason;
  final FocusNode? focusNode;
  final bool autofocus;

  /// The color of the focus ring's gap; `bgCanvas` by default, pass
  /// `bgRaised` inside a sheet.
  final Color? focusGapColor;

  bool get _isText =>
      variant == AppButtonVariant.text ||
      variant == AppButtonVariant.textDanger;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  final WidgetStatesController _states = WidgetStatesController();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _states.addListener(_onStates);
    FocusManager.instance.addHighlightModeListener(_onHighlightMode);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightMode);
    _states
      ..removeListener(_onStates)
      ..dispose();
    super.dispose();
  }

  /// The ring is for keyboard focus only (spec §1.4): on touch the focus
  /// highlight mode is `touch` and a focused button (autofocus, a sheet's
  /// first action) must not draw it.
  static bool get _keyboardFocusVisible =>
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  void _onHighlightMode(FocusHighlightMode _) {
    if (mounted && _focused) setState(() {});
  }

  void _onStates() {
    final focused = _states.value.contains(WidgetState.focused);
    if (focused == _focused || !mounted) return;
    // mihr_ui updates its states while it builds; wait for the frame to end.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _onStates());
      return;
    }
    setState(() => _focused = focused);
  }

  static void _ignore() {}

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final loading = widget.loading && !widget._isText;
    final style = AppButtonStyles.of(
      colors: colors,
      text: text,
      brightness: Theme.brightnessOf(context),
      variant: widget.variant,
      size: widget.size,
      hasLeading: widget.icon != null,
      hasTrailing: widget.trailingIcon != null,
    );

    final content = _ButtonContent(
      label: widget.label,
      icon: widget.icon,
      trailingIcon: widget.trailingIcon,
      loading: loading,
      trackAlpha: AppButtonStyles.trackAlpha(widget.variant),
    );
    final onPressed = loading ? _ignore : widget.onPressed;

    Widget button = _mihrButton(onPressed, style, content);
    if (widget.expand) button = SizedBox(width: double.infinity, child: button);
    button = AppFocusRing(
      focused: _focused && _keyboardFocusVisible,
      style: widget._isText
          ? AppFocusRingStyle.flush
          : AppFocusRingStyle.gapped,
      gapColor: widget.focusGapColor,
      child: button,
    );
    button = PressScale(states: _states, child: button);

    if (loading) {
      button = Semantics(
        label: AppLocalizations.of(context).kit_loading,
        button: true,
        enabled: false,
        excludeSemantics: true,
        child: button,
      );
    }

    final reason = widget.disabledReason;
    if (widget.onPressed != null || reason == null) return button;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.expand
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.center,
      children: [
        Semantics(hint: reason, child: button),
        const SizedBox(height: AppSpacing.s8),
        ExcludeSemantics(
          child: Text(
            reason,
            textAlign: TextAlign.center,
            style: text.caption.copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _mihrButton(VoidCallback? onPressed, ButtonStyle style, Widget child) {
    final size = widget.size.mihr;
    return switch (widget.variant) {
      AppButtonVariant.primary => MihrPrimaryButton(
        size: size,
        onPressed: onPressed,
        onLongPress: widget.onLongPress,
        statesController: _states,
        style: style,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        child: child,
      ),
      AppButtonVariant.outline => MihrSecondaryButton(
        size: size,
        onPressed: onPressed,
        onLongPress: widget.onLongPress,
        statesController: _states,
        style: style,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        child: child,
      ),
      AppButtonVariant.quiet => MihrSoftPrimaryButton(
        size: size,
        onPressed: onPressed,
        onLongPress: widget.onLongPress,
        statesController: _states,
        style: style,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        child: child,
      ),
      AppButtonVariant.danger => MihrDestructiveButton(
        size: size,
        onPressed: onPressed,
        onLongPress: widget.onLongPress,
        statesController: _states,
        style: style,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        child: child,
      ),
      AppButtonVariant.text ||
      AppButtonVariant.textDanger => MihrTertiaryButton(
        size: size,
        onPressed: onPressed,
        onLongPress: widget.onLongPress,
        statesController: _states,
        style: style,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        child: child,
      ),
    };
  }
}

/// Icon, label and trailing icon in one row. While loading the row stays in
/// the layout (invisible) and the spinner sits over its center, so the
/// button keeps its width.
class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.trailingIcon,
    required this.loading,
    required this.trackAlpha,
  });

  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final double trackAlpha;

  @override
  Widget build(BuildContext context) {
    final data = MihrButtonData.maybeOf(context);
    final ink = data?.iconColor ?? IconTheme.of(context).color;
    Widget glyph(IconData value) =>
        PhosphorIcon(value, size: AppSize.iconInButton, color: ink);
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon case final leading?) ...[
          glyph(leading),
          const SizedBox(width: AppSize.iconGap),
        ],
        Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.fade)),
        if (trailingIcon case final trailing?) ...[
          const SizedBox(width: AppSize.iconGap),
          glyph(trailing),
        ],
      ],
    );
    if (!loading) return row;
    final spinnerInk = data?.foregroundColor ?? ink;
    return Stack(
      alignment: Alignment.center,
      children: [
        Visibility.maintain(visible: false, child: row),
        AppSpinner(
          size: AppSize.iconInButton,
          color: spinnerInk,
          trackColor: spinnerInk?.withValues(alpha: trackAlpha),
        ),
      ],
    );
  }
}
