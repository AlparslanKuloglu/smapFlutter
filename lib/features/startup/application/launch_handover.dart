import 'dart:async';

/// Tells the bootstrap when the launch screen has handed over to the first
/// real screen, so the native splash can come down without a flash of the
/// launch screen in between.
///
/// `StartupViewModel` completes it after it replaced the stack (or failed
/// to); `MainInitializer` waits for it, but never longer than
/// `StartupTiming.nativeSplashPatience`.
class LaunchHandover {
  final Completer<void> _done = Completer<void>();

  /// Completes once; later calls do nothing.
  Future<void> get done => _done.future;

  /// Whether the hand-over happened.
  bool get isDone => _done.isCompleted;

  /// Marks the hand-over as done.
  void complete() {
    if (!_done.isCompleted) _done.complete();
  }
}
