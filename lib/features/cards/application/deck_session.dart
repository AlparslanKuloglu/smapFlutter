import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable, listEquals;

/// The run through one deck (pano 8.1 "Oturum ilerlemesi", "12/23").
///
/// A session starts when a group opens: its cards in the server's order and
/// their number, the *total* of the progress counter ("Oturum sayacı açılıştaki
/// eksik kart sayısıyla başlar", spec T5.4). The student moves through the
/// cards one by one; a card that is learned leaves the queue but keeps its
/// place in the count, so after "Öğrendim" on card 12 the next card reads
/// "13/23" (pano 8.1 kare 3).
///
/// Swiping only goes on to the next card, never learns it; past the last card
/// the run wraps to the first card that is still in the queue. Immutable: each
/// move returns a new session.
@immutable
class DeckSession {
  const DeckSession._(this._order, this._queue, this._cursor);

  /// A session over [keys], on the first card.
  factory DeckSession.start(List<String> keys) =>
      DeckSession._(List.unmodifiable(keys), List.unmodifiable(keys), 0);

  /// No card.
  static const DeckSession empty = DeckSession._([], [], 0);

  /// The cards in the order the session started with (the count's order).
  final List<String> _order;

  /// The cards still in the run, in that order.
  final List<String> _queue;
  final int _cursor;

  /// The key of the card on top; `null` when the queue is empty.
  String? get front => _queue.isEmpty ? null : _queue[_cursor];

  /// How many cards the session started with (the "23" of "12/23").
  int get total => _order.length;

  /// How many cards are still in the run.
  int get remaining => _queue.length;

  bool get isEmpty => _queue.isEmpty;

  /// The place of the card on top in the starting order, 1 to [total] (the
  /// "12" of "12/23"); 0 when the queue is empty.
  int get position {
    final key = front;
    return key == null ? 0 : _order.indexOf(key) + 1;
  }

  /// The session started with the card [key] (it may have left the queue
  /// since).
  bool has(String key) => _order.contains(key);

  /// The cards can be moved through: more than one is in the queue.
  bool get canMove => _queue.length > 1;

  /// How many cards show behind the one on top: up to two edges (pano 8.1:
  /// "arkada iki kart kenarı").
  int get behind => math.max(0, math.min(2, _queue.length - 1));

  /// The key of the card [offset] places after the one on top (wrapping);
  /// `null` when there is no such card.
  String? peek(int offset) {
    if (_queue.isEmpty || offset >= _queue.length) return null;
    return _queue[(_cursor + offset) % _queue.length];
  }

  /// The next card (swipe, "Sonraki kart"); the same session when there is
  /// no other card.
  DeckSession next() => canMove
      ? DeckSession._(_order, _queue, (_cursor + 1) % _queue.length)
      : this;

  /// The card before (the "Önceki kart" action).
  DeckSession previous() => canMove
      ? DeckSession._(
          _order,
          _queue,
          (_cursor - 1 + _queue.length) % _queue.length,
        )
      : this;

  /// The session without [key] (a learned card); the next card comes to the
  /// top, or the first one when [key] was the last.
  DeckSession without(String key) {
    final index = _queue.indexOf(key);
    if (index < 0) return this;
    final queue = [..._queue]..removeAt(index);
    var cursor = _cursor;
    if (index < cursor) cursor--;
    if (queue.isEmpty || cursor >= queue.length) cursor = 0;
    return DeckSession._(_order, List.unmodifiable(queue), cursor);
  }

  /// The session with [key] back in the run at its own place ("Geri Al") and
  /// on top; the same session for a card the session never had.
  DeckSession restored(String key) {
    final place = _order.indexOf(key);
    if (place < 0 || _queue.contains(key)) return this;
    final queue = [..._queue];
    var at = 0;
    while (at < queue.length && _order.indexOf(queue[at]) < place) {
      at++;
    }
    queue.insert(at, key);
    return DeckSession._(_order, List.unmodifiable(queue), at);
  }

  @override
  bool operator ==(Object other) =>
      other is DeckSession &&
      other._cursor == _cursor &&
      listEquals(other._order, _order) &&
      listEquals(other._queue, _queue);

  @override
  int get hashCode =>
      Object.hash(_cursor, Object.hashAll(_order), Object.hashAll(_queue));
}
