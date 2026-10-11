import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/cards/application/deck_session.dart';

void main() {
  /// 23 cards, "c1" to "c23" (the session of pano 8.1).
  final keys = [for (var i = 1; i <= 23; i++) 'c$i'];

  test('starts on the first card with the whole count', () {
    final session = DeckSession.start(keys);

    expect(session.front, 'c1');
    expect(session.position, 1);
    expect(session.total, 23);
    expect(session.remaining, 23);
    expect(session.behind, 2);
    expect(session.canMove, isTrue);
    expect(session.peek(1), 'c2');
    expect(session.peek(2), 'c3');
  });

  test('an empty session has no card and no progress', () {
    for (final session in [DeckSession.empty, DeckSession.start(const [])]) {
      expect(session.front, isNull);
      expect(session.position, 0);
      expect(session.total, 0);
      expect(session.behind, 0);
      expect(session.canMove, isFalse);
      expect(session.peek(0), isNull);
      expect(session.next(), session);
      expect(session.previous(), session);
    }
  });

  group('moving', () {
    test('goes on to the next card and back', () {
      var session = DeckSession.start(keys);
      for (var i = 0; i < 11; i++) {
        session = session.next();
      }
      expect(session.front, 'c12');
      expect(session.position, 12, reason: '"12/23"');

      expect(session.previous().front, 'c11');
    });

    test('wraps past the last card to the first', () {
      var session = DeckSession.start(keys);
      for (var i = 0; i < 22; i++) {
        session = session.next();
      }
      expect(session.front, 'c23');
      expect(session.next().front, 'c1');
      expect(DeckSession.start(keys).previous().front, 'c23');
    });

    test('a single card stays where it is', () {
      final session = DeckSession.start(const ['only']);
      expect(session.canMove, isFalse);
      expect(session.behind, 0);
      expect(session.next(), session);
      expect(session.previous(), session);
    });

    test('shows up to two cards behind the top one', () {
      expect(DeckSession.start(const ['a', 'b']).behind, 1);
      expect(DeckSession.start(const ['a', 'b', 'c']).behind, 2);
      expect(DeckSession.start(const ['a', 'b', 'c', 'd']).behind, 2);
    });

    test('peeks past the end around to the start', () {
      var session = DeckSession.start(const ['a', 'b', 'c']);
      session = session.next().next();
      expect(session.front, 'c');
      expect(session.peek(1), 'a');
      expect(session.peek(2), 'b');
      expect(session.peek(3), isNull);
    });
  });

  group('a learned card (pano 8.1 kare 3)', () {
    test('"12/23" becomes "13/23" with the next card on top', () {
      var session = DeckSession.start(keys);
      for (var i = 0; i < 11; i++) {
        session = session.next();
      }
      expect(session.position, 12);

      final after = session.without('c12');

      expect(after.front, 'c13');
      expect(after.position, 13);
      expect(after.total, 23, reason: 'the total stays what the session began');
      expect(after.remaining, 22);
    });

    test('the last card learned wraps to the first one still waiting', () {
      var session = DeckSession.start(const ['a', 'b', 'c']);
      session = session.next().next();
      final after = session.without('c');
      expect(after.front, 'a');
      expect(after.position, 1);
    });

    test('a card before the top one leaves the top card where it is', () {
      var session = DeckSession.start(const ['a', 'b', 'c']).next().next();
      final after = session.without('a');
      expect(after.front, 'c');
      expect(after.remaining, 2);
    });

    test('the last card of the queue empties the session', () {
      final after = DeckSession.start(const ['a']).without('a');
      expect(after.isEmpty, isTrue);
      expect(after.front, isNull);
      expect(after.total, 1);
    });

    test('a card that is not in the queue changes nothing', () {
      final session = DeckSession.start(const ['a', 'b']);
      expect(session.without('z'), session);
    });
  });

  group('"Geri Al"', () {
    test('puts the card back at its own place, on top', () {
      var session = DeckSession.start(keys);
      for (var i = 0; i < 11; i++) {
        session = session.next();
      }
      final learned = session.without('c12');

      final back = learned.restored('c12');

      expect(back, session);
      expect(back.front, 'c12');
      expect(back.position, 12);
      expect(back.remaining, 23);
    });

    test('a card placed earlier goes before the cards after it', () {
      final session = DeckSession.start(const ['a', 'b', 'c', 'd']);
      final learned = session.without('b').without('c');
      expect(learned.restored('b').front, 'b');
      expect(learned.restored('c').front, 'c');
    });

    test('a card the session never had, or still has, changes nothing', () {
      final session = DeckSession.start(const ['a', 'b']);
      expect(session.restored('z'), session);
      expect(session.restored('a'), session);
      expect(session.has('a'), isTrue);
      expect(session.has('z'), isFalse);
      expect(session.without('a').has('a'), isTrue);
    });

    test('restores into an emptied session', () {
      final empty = DeckSession.start(const ['a']).without('a');
      expect(empty.restored('a').front, 'a');
    });
  });
}
