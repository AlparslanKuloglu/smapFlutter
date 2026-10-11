import 'dart:async';

/// A hand-driven clock for timer logic: [create] is a `Timer` factory, [advance]
/// moves time and fires what is due, in order.
class FakeTimers {
  final List<_FakeTimer> _timers = [];
  Duration _now = Duration.zero;

  /// Pass as `timerFactory`.
  Timer create(Duration delay, void Function() callback) {
    final timer = _FakeTimer(_now + delay, callback);
    _timers.add(timer);
    return timer;
  }

  /// Timers that are still counting.
  int get pending => _timers.where((t) => t.isActive).length;

  void advance(Duration by) {
    final target = _now + by;
    while (true) {
      final due = _timers.where((t) => t.isActive && t.at <= target).toList()
        ..sort((a, b) => a.at.compareTo(b.at));
      if (due.isEmpty) break;
      final next = due.first;
      _now = next.at;
      next.fire();
    }
    _now = target;
  }
}

class _FakeTimer implements Timer {
  _FakeTimer(this.at, this._callback);

  final Duration at;
  final void Function() _callback;
  bool _active = true;

  void fire() {
    _active = false;
    _callback();
  }

  @override
  void cancel() => _active = false;

  @override
  bool get isActive => _active;

  @override
  int get tick => 0;
}
