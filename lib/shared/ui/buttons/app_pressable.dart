import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/shared/ui/buttons/press_scale.dart';

/// Builds a control from its interaction states (`pressed`, `focused`,
/// `disabled`).
typedef AppPressableBuilder =
    Widget Function(BuildContext context, Set<WidgetState> states);

/// The interaction shell of every custom-drawn control of the kit (chip,
/// checkbox, radio, switch, row, tag-like tiles): a tap and long-press
/// target with a pressed state, keyboard focus (Enter and Space activate),
/// the 0,98 [PressScale] and an optional selection haptic.
///
/// It draws nothing itself; [builder] draws the control from the states, so
/// the pressed tone and the focus ring stay the control's own business (UI
/// guide §5 "Basılı, odak, pasif"). The semantics stay the caller's: wrap it
/// in `Semantics` with the control's role and label.
///
/// [focused] is true only for keyboard focus (the focus highlight mode), so
/// a tap does not leave a ring behind.
class AppPressable extends StatefulWidget {
  const AppPressable({
    required this.builder,
    this.onTap,
    this.onLongPress,
    this.scale = AppMotion.pressedScale,
    this.haptic = false,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  final AppPressableBuilder builder;

  /// Null (together with a null [onLongPress]) disables the control.
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Pressed scale; 1 turns the scale off.
  final double scale;

  /// Plays `AppHaptics.selection()` on tap: a choice changed.
  final bool haptic;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  void _activate() {
    final onTap = widget.onTap;
    if (onTap == null) return;
    if (widget.haptic) AppHaptics.selection();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final states = <WidgetState>{
      if (!_enabled) WidgetState.disabled,
      if (_pressed) WidgetState.pressed,
      if (_focused) WidgetState.focused,
    };
    Widget content = widget.builder(context, states);
    if (widget.scale != 1) {
      content = PressScale(
        pressed: _pressed,
        scale: widget.scale,
        child: content,
      );
    }
    return FocusableActionDetector(
      enabled: _enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _activate();
            return null;
          },
        ),
      },
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => _setPressed(true) : null,
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap == null ? null : _activate,
        onLongPress: widget.onLongPress,
        child: content,
      ),
    );
  }
}
