import 'dart:async';

/// Starts a timer; `Timer.new` in the app, a fake in tests.
typedef TimerFactory = Timer Function(Duration duration, void Function() run);

/// The "Öğrendim" requests that wait out the "Geri Al" window (pano 8.1 kare
/// 3: toast "Kart Bildiklerim'e taşındı." with "Geri Al", 6 s).
///
/// The backend has no endpoint to take a learned card back (spec §6.3 #24),
/// so undo cannot be built on the server. The card is moved on the screen at
/// once, and the request is *held here* for [delay]; when the delay passes the
/// request goes out, and if "Geri Al" came first the request never goes out
/// ([cancel]). On leaving the screen [flush] sends what is still waiting, so
/// a learned card is not lost.
///
/// [send] answers when the request is done; it does its own error handling.
class PendingLearns {
  PendingLearns({
    required this.delay,
    required Future<void> Function(String key) send,
    TimerFactory? timerFactory,
  }) : _send = send,
       _timerFactory = timerFactory ?? Timer.new;

  /// How long a request waits before it goes out.
  final Duration delay;
  final Future<void> Function(String key) _send;
  final TimerFactory _timerFactory;
  final Map<String, Timer> _timers = {};

  /// Whether the request of [key] still waits.
  bool isPending(String key) => _timers.containsKey(key);

  /// How many requests wait.
  int get length => _timers.length;

  /// Holds the request of [key]; it goes out after [delay].
  void schedule(String key) {
    _timers.remove(key)?.cancel();
    _timers[key] = _timerFactory(delay, () {
      _timers.remove(key);
      unawaited(_send(key));
    });
  }

  /// "Geri Al": drops the request of [key]. `true` when it was still waiting
  /// (nothing was sent), `false` when it had already gone out.
  bool cancel(String key) {
    final timer = _timers.remove(key);
    if (timer == null) return false;
    timer.cancel();
    return true;
  }

  /// Sends every waiting request now (the screen is closing).
  Future<void> flush() async {
    final keys = _timers.keys.toList();
    for (final key in keys) {
      _timers.remove(key)?.cancel();
    }
    await Future.wait([for (final key in keys) _send(key)]);
  }

  /// Drops every waiting request without sending it.
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}
