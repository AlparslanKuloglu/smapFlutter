import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/feedback/app_toast.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';

/// Puts the toast of a [ToastSlot] on screen. The service talks to this, so
/// it can be tested without a widget tree.
abstract interface class ToastPresenter {
  /// Whether a screen reader is on: the toast then stays until closed.
  bool get screenReaderOn;

  /// Makes sure [slot] is drawn; false when there is nothing to draw on (no
  /// navigator yet).
  bool present(ToastSlot slot, ValueListenable<double?> barHeight);
}

/// Draws toasts in the root navigator's overlay, with no router and no
/// `toastification` involved (Düzeltmeler #9, #22): one `OverlayEntry` that
/// lives while a toast is on screen, inserted on top of whatever route is
/// open, so a toast raised from a sheet shows above it.
class OverlayToastPresenter implements ToastPresenter {
  OverlayToastPresenter(this._overlay);

  /// Draws in the overlay of [key]'s navigator (the app's root navigator).
  OverlayToastPresenter.navigator(GlobalKey<NavigatorState> key)
    : this(() => key.currentState?.overlay);

  /// Draws in the root overlay above [context] (galleries, tests).
  OverlayToastPresenter.context(BuildContext context)
    : this(() => Overlay.maybeOf(context, rootOverlay: true));

  final OverlayState? Function() _overlay;
  OverlayEntry? _entry;

  @override
  bool get screenReaderOn {
    final overlay = _overlay();
    if (overlay == null) return false;
    return MediaQuery.maybeAccessibleNavigationOf(overlay.context) ?? false;
  }

  @override
  bool present(ToastSlot slot, ValueListenable<double?> barHeight) {
    final overlay = _overlay();
    if (overlay == null) return false;
    // Insert again on every toast so it is above routes pushed since.
    _remove();
    final entry = OverlayEntry(
      builder: (context) =>
          ToastHost(slot: slot, barHeight: barHeight, onGone: _remove),
    );
    _entry = entry;
    overlay.insert(entry);
    return true;
  }

  void _remove() {
    final entry = _entry;
    if (entry == null) return;
    _entry = null;
    if (entry.mounted) entry.remove();
    entry.dispose();
  }
}

/// The widget inside the overlay entry: listens to the slot, slides the
/// toast in (16 pt up, 250 ms, `ease-enter`; a 150 ms fade under "Reduce
/// motion"), slides it out (`ease-exit`, 70 % of the entrance) and calls
/// [onGone] when nothing is left. A swipe up closes the toast (C74
/// "Hareket").
class ToastHost extends StatefulWidget {
  const ToastHost({
    required this.slot,
    required this.barHeight,
    required this.onGone,
    super.key,
  });

  final ToastSlot slot;

  /// The bottom bar's height without the safe area, `null` when hidden.
  final ValueListenable<double?> barHeight;

  /// Called after the exit animation when the slot is empty.
  final VoidCallback onGone;

  /// The distance the toast travels while entering.
  static const double travel = 16;

  /// A swipe up of this distance (or a fling) closes the toast.
  static const double swipeClose = 24;
  static const double swipeFlingVelocity = 300;

  @override
  State<ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<ToastHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.base,
    reverseDuration: AppMotion.exitOf(AppMotion.base),
  );
  ToastEntry? _shown;
  double _drag = 0;

  @override
  void initState() {
    super.initState();
    widget.slot.current.addListener(_sync);
    _shown = widget.slot.current.value;
    if (_shown != null) _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller
      ..duration = context.motion(
        AppMotion.base,
        reduced: AppMotion.reducedFade,
      )
      ..reverseDuration = context.motion(
        AppMotion.exitOf(AppMotion.base),
        reduced: AppMotion.reducedFade,
      );
  }

  @override
  void dispose() {
    widget.slot.current.removeListener(_sync);
    _controller.dispose();
    super.dispose();
  }

  void _sync() {
    final entry = widget.slot.current.value;
    if (entry != null) {
      setState(() {
        _shown = entry;
        _drag = 0;
      });
      _controller.forward(from: 0);
    } else if (_shown != null) {
      _controller.reverse().whenComplete(() {
        if (mounted && widget.slot.current.value == null) widget.onGone();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = _shown;
    if (entry == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final reader = widget.slot.current.value?.autoClose == null;
    final reduce = context.reduceMotion;
    final curved = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.enter,
      reverseCurve: AppMotion.exit,
    );

    final toast = AppToast(
      kind: entry.kind,
      message: entry.title(l10n),
      undoLabel: entry.hasUndo ? l10n.common_undo : null,
      onUndo: entry.hasUndo ? () => widget.slot.undo(entry.id) : null,
      closeLabel: reader ? l10n.kit2_a11yToastClose : null,
      onClose: reader ? () => widget.slot.dismiss(entry.id) : null,
    );

    return ValueListenableBuilder<double?>(
      valueListenable: widget.barHeight,
      builder: (context, barHeight, _) => Stack(
        children: [
          Positioned(
            left: ToastPlacement.side,
            right: ToastPlacement.side,
            bottom: ToastPlacement.bottom(
              safeBottom: safeBottom,
              barHeight: barHeight,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: GestureDetector(
                onVerticalDragUpdate: (details) => setState(
                  () => _drag = (_drag + details.delta.dy).clamp(
                    double.negativeInfinity,
                    0,
                  ),
                ),
                onVerticalDragEnd: (details) {
                  final fling =
                      (details.primaryVelocity ?? 0) <
                      -ToastHost.swipeFlingVelocity;
                  if (_drag <= -ToastHost.swipeClose || fling) {
                    widget.slot.dismiss(entry.id);
                  } else {
                    setState(() => _drag = 0);
                  }
                },
                child: AnimatedBuilder(
                  animation: curved,
                  child: toast,
                  builder: (context, child) => Opacity(
                    opacity: curved.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        _drag +
                            (reduce
                                ? 0
                                : (1 - curved.value) * ToastHost.travel),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
