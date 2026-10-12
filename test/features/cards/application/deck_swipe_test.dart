import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/cards/application/deck_swipe.dart';

void main() {
  const width = 358.0; // a 390 pt phone with 16 pt gutters

  DeckExit? verdict(double dx, [double velocity = 0]) =>
      DeckSwipe.verdict(dx: dx, velocityX: velocity, width: width);

  group('the distance (30 % of the width)', () {
    test('commits past 30 %', () {
      expect(verdict(108), DeckExit.right);
      expect(verdict(-108), DeckExit.left);
      expect(verdict(300), DeckExit.right);
    });

    test('commits at exactly 30 %', () {
      expect(verdict(width * 0.3), DeckExit.right);
    });

    test('springs back short of 30 %', () {
      expect(verdict(107), isNull);
      expect(verdict(-50), isNull);
      expect(verdict(1), isNull);
    });
  });

  group('the fling (800 px/s)', () {
    test('commits a fast fling in the direction of the drag', () {
      expect(verdict(30, 900), DeckExit.right);
      expect(verdict(-30, -900), DeckExit.left);
      expect(verdict(20, 800), DeckExit.right);
    });

    test('a slow fling does not commit', () {
      expect(verdict(30, 799), isNull);
    });

    test('a fast fling against the drag does not commit', () {
      expect(verdict(30, -2000), isNull);
      expect(verdict(-30, 2000), isNull);
    });
  });

  test('no drag at all is no swipe', () {
    expect(verdict(0, 5000), isNull);
    expect(
      DeckSwipe.verdict(dx: 100, velocityX: 0, width: 0),
      isNull,
      reason: 'an unmeasured card',
    );
  });

  test('the exit sign points the way the card goes', () {
    expect(DeckExit.left.sign, -1);
    expect(DeckExit.right.sign, 1);
  });

  test('the next card comes forward as the top card moves away', () {
    expect(DeckSwipe.reveal(dx: 0, width: width), 0);
    expect(DeckSwipe.reveal(dx: 179, width: width), closeTo(0.5, 0.001));
    expect(DeckSwipe.reveal(dx: -179, width: width), closeTo(0.5, 0.001));
    expect(DeckSwipe.reveal(dx: 900, width: width), 1);
    expect(DeckSwipe.reveal(dx: 50, width: 0), 0);
  });
}
