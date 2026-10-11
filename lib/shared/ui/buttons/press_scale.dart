import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smap/core/theme/app_motion.dart';

/// Scales [child] down while it is pressed (handoff 11.15 "Basılı ölçek";
/// board 1.8; UI guide §5 #4).
///
/// Three scales exist: [AppMotion.pressedScale] 0,98 for buttons and rows
/// (the default), [cellScale] 0,97 for question cells and chips in a grid, and
/// [AppMotion.shutterScale] 0,92 for the camera shutter. The scale takes
/// [AppMotion.instant] (100 ms, standard curve). Under "Reduce motion" there is
/// no scale at all; the pressed color of the control is the only feedback
/// (spec §1.13).
///
/// Feed it a pressed state one of three ways: [states] (the
/// `WidgetStatesController` of a mihr_ui button), [pressed] (a flag the
/// parent owns), or neither, in which case it listens to raw pointers
/// itself and gives up once the pointer moves past the touch slop (so a
/// scroll does not leave it pressed).
class PressScale extends StatefulWidget {
  const PressScale({
    required this.child,
    this.states,
    this.pressed,
    this.scale = AppMotion.pressedScale,
    super.key,
  });

  /// Pressed scale for a cell or chip inside a grid (0,97).
  static const double cellScale = 0.97;

  final Widget child;

  /// A button's states controller; the scale follows `WidgetState.pressed`.
  final WidgetStatesController? states;

  /// The parent's own pressed flag; wins over [states].
  final bool? pressed;

  /// Scale while pressed.
  final double scale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;
  Offset? _downAt;

  @override
  void initState() {
    super.initState();
    widget.states?.addListener(_onStates);
  }

  @override
  void didUpdateWidget(PressScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.states != widget.states) {
      oldWidget.states?.removeListener(_onStates);
      widget.states?.addListener(_onStates);
    }
  }

  @override
  void dispose() {
    widget.states?.removeListener(_onStates);
    super.dispose();
  }

  void _onStates() => _set(widget.states!.value.contains(WidgetState.pressed));

  void _set(bool value) {
    if (value == _pressed || !mounted) return;
    // A mihr_ui button sets its states while it is being built; a rebuild
    // cannot be asked for in that phase, so it waits for the frame to end.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _set(value));
      return;
    }
    setState(() => _pressed = value);
  }

  void _onMove(PointerMoveEvent event) {
    final start = _downAt;
    if (start != null && (event.position - start).distance > kTouchSlop) {
      _downAt = null;
      _set(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selfDriven = widget.pressed == null && widget.states == null;
    final active = widget.pressed ?? _pressed;
    final reduced = context.reduceMotion;
    final scaled = AnimatedScale(
      scale: active && !reduced ? widget.scale : 1,
      duration: context.motion(AppMotion.instant, reduced: Duration.zero),
      curve: AppMotion.standard,
      child: widget.child,
    );
    if (!selfDriven) return scaled;
    return Listener(
      onPointerDown: (event) {
        _downAt = event.position;
        _set(true);
      },
      onPointerMove: _onMove,
      onPointerUp: (_) {
        _downAt = null;
        _set(false);
      },
      onPointerCancel: (_) {
        _downAt = null;
        _set(false);
      },
      child: scaled,
    );
  }
}
