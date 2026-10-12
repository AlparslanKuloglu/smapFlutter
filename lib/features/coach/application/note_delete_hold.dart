import 'dart:async';

import 'package:flutter/foundation.dart';

/// Starts a timer; `Timer.new` in the app, a fake in tests.
typedef HoldTimerFactory = Timer Function(Duration delay, void Function() run);

/// A note whose deletion waits out the "Geri Al" window.
@immutable
class PendingNoteDelete {
  const PendingNoteDelete({required this.index, required this.text});

  /// The note's position in the server's list (`deleteIndex`).
  final int index;

  /// What the note said, to put it back on the screen.
  final String text;

  @override
  bool operator ==(Object other) =>
      other is PendingNoteDelete && other.index == index && other.text == text;

  @override
  int get hashCode => Object.hash(index, text);
}

/// The one note deletion that waits out the "Geri Al" window (pano 10.6 kare
/// 4: toast "Not silindi." with "Geri Al", 6 s; D-31).
///
/// The backend has no endpoint to take a deleted note back (the note's text is
/// gone once `deleteNote` ran; spec §6.4 "geri alma ucu"), so undo cannot be
/// built on the server. The note leaves the screen at once and its request is
/// *held here* for [delay]; when the delay passes the request goes out, and if
/// "Geri Al" came first it never does ([cancel]).
///
/// Notes are addressed by position, so only one deletion can wait: a second
/// write must [flush] the first before it goes out, and the caller reads the
/// meeting again afterwards. [dispose] drops what waits without sending it;
/// call [flush] first when the request must not be lost (the screen is
/// closing).
class NoteDeleteHold {
  NoteDeleteHold({
    required this.delay,
    required Future<void> Function(PendingNoteDelete note) commit,
    HoldTimerFactory? timerFactory,
  }) : _commit = commit,
       _timerFactory = timerFactory ?? Timer.new;

  /// How long the request waits before it goes out.
  final Duration delay;
  final Future<void> Function(PendingNoteDelete note) _commit;
  final HoldTimerFactory _timerFactory;

  PendingNoteDelete? _pending;
  Timer? _timer;

  /// The deletion that waits, `null` when none does.
  PendingNoteDelete? get pending => _pending;

  /// Holds [note]; a deletion that was waiting is sent first (never lost,
  /// never two at once).
  void hold(PendingNoteDelete note) {
    if (_pending != null) unawaited(flush());
    _pending = note;
    _timer = _timerFactory(delay, () {
      _timer = null;
      final due = _pending;
      _pending = null;
      if (due != null) unawaited(_commit(due));
    });
  }

  /// "Geri Al": drops the waiting deletion. Returns it, or `null` when it was
  /// not waiting any more (the request had already gone out).
  PendingNoteDelete? cancel() {
    final note = _pending;
    _timer?.cancel();
    _timer = null;
    _pending = null;
    return note;
  }

  /// Sends the waiting deletion now and completes when it is done. Does
  /// nothing when none waits.
  Future<void> flush() async {
    final due = _pending;
    if (due == null) return;
    _timer?.cancel();
    _timer = null;
    _pending = null;
    await _commit(due);
  }

  /// Drops the waiting deletion without sending it.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _pending = null;
  }
}
