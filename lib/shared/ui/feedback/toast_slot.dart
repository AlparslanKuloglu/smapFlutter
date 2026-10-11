import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The three kinds of toast (C74; board 1.22 kare 1): a neutral note, a
/// success and a transient error. Permanent errors are drawn on the screen
/// as a state, not as a toast.
enum AppToastKind { info, success, error }

/// Builds a localized toast string without a `BuildContext`: ViewModels and
/// services write `(l) => l.schedule_saved` and the toast resolves it where
/// the localizations exist (UI guide §6 rule 16).
typedef ToastText = String Function(AppLocalizations l10n);

/// Creates the timer that closes a toast; tests pass a fake one.
typedef ToastTimerFactory = Timer Function(Duration, void Function());

/// One toast to show.
@immutable
class ToastEntry {
  const ToastEntry({
    required this.id,
    required this.kind,
    required this.title,
    this.onUndo,
    this.autoClose,
  });

  /// Increases with every toast; a late timer or swipe for an older toast
  /// cannot close a newer one.
  final int id;
  final AppToastKind kind;
  final ToastText title;

  /// Set when the toast carries "Geri Al".
  final VoidCallback? onUndo;

  /// How long it stays; `null` means until it is dismissed (a screen reader
  /// is on).
  final Duration? autoClose;

  bool get hasUndo => onUndo != null;
}

/// The one place a toast lives (C74 "Aynı anda tek toast"): the timing and
/// replacement rules apart from any widget, so they run under fake timers.
///
/// - **one at a time**: [show] replaces the toast on screen; the old one's
///   timer is cancelled and its undo can no longer run;
/// - **duration**: [SmapDurations.toast] (4 s), or [SmapDurations.undoToast]
///   (6 s) when it has "Geri Al" ([durationFor]); with [persistent] (a
///   screen reader is on) it has no timer and stays until [dismiss];
/// - **undo** runs the callback once and closes the toast.
class ToastSlot {
  ToastSlot({ToastTimerFactory? timerFactory})
    : _timerFactory = timerFactory ?? Timer.new;

  final ToastTimerFactory _timerFactory;
  final ValueNotifier<ToastEntry?> _current = ValueNotifier<ToastEntry?>(null);
  Timer? _timer;
  int _nextId = 1;

  /// The toast on screen, `null` when none.
  ValueListenable<ToastEntry?> get current => _current;

  /// Whether a toast is on screen.
  bool get isShowing => _current.value != null;

  /// 4 s, or 6 s for a toast with an undo action.
  static Duration durationFor({required bool hasUndo}) =>
      hasUndo ? SmapDurations.undoToast : SmapDurations.toast;

  /// Puts a toast on screen, replacing the current one, and starts its timer.
  ToastEntry show({
    required AppToastKind kind,
    required ToastText title,
    VoidCallback? onUndo,
    bool persistent = false,
  }) {
    _timer?.cancel();
    _timer = null;
    final entry = ToastEntry(
      id: _nextId++,
      kind: kind,
      title: title,
      onUndo: onUndo,
      autoClose: persistent ? null : durationFor(hasUndo: onUndo != null),
    );
    _current.value = entry;
    final delay = entry.autoClose;
    if (delay != null) {
      _timer = _timerFactory(delay, () => dismiss(entry.id));
    }
    return entry;
  }

  /// Closes the toast with [id] (any toast when null). A stale [id] does
  /// nothing.
  void dismiss([int? id]) {
    final entry = _current.value;
    if (entry == null || (id != null && entry.id != id)) return;
    _timer?.cancel();
    _timer = null;
    _current.value = null;
  }

  /// The user pressed "Geri Al" on toast [id]: runs the callback once and
  /// closes the toast. Returns whether it ran.
  bool undo(int id) {
    final entry = _current.value;
    final callback = entry?.onUndo;
    if (entry == null || entry.id != id || callback == null) return false;
    dismiss(id);
    callback();
    return true;
  }

  void dispose() {
    _timer?.cancel();
    _current.dispose();
  }
}

/// Where a toast sits (C74 "Konum").
abstract final class ToastPlacement {
  /// Distance from the screen edge to the toast's side.
  static const double side = 16;

  /// Gap above a visible bottom bar.
  static const double aboveBar = 8;

  /// Gap above the safe area when there is no bar.
  static const double aboveSafeArea = 16;

  /// The toast's distance from the bottom of the screen: [barHeight] is the
  /// bottom bar's height without the safe area (`AppSize.bottomBar`), `null`
  /// when the bar is hidden. With a bar the toast sits 8 above it (and never
  /// covers it); without one, 16 above the bottom safe area.
  static double bottom({required double safeBottom, double? barHeight}) =>
      barHeight == null
      ? safeBottom + aboveSafeArea
      : safeBottom + barHeight + aboveBar;
}
