import 'package:flutter_test/flutter_test.dart';
import 'package:smap/shared/ui/indicators/progress_math.dart';

void main() {
  group('fraction', () {
    test('a share of a real total', () {
      expect(ProgressMath.fraction(41, 64), closeTo(0.640625, 1e-9));
      expect(ProgressMath.fraction(12, 40), 0.3);
    });

    test('no total means nothing to draw', () {
      expect(ProgressMath.fraction(3, null), isNull);
      expect(ProgressMath.fraction(0, 0), isNull);
      expect(ProgressMath.fraction(3, -1), isNull);
    });

    test('is clamped to 0..1', () {
      expect(ProgressMath.fraction(80, 64), 1);
      expect(ProgressMath.fraction(-3, 64), 0);
    });
  });

  group('percent (success ring)', () {
    test('5 of 12 rounds to 42', () {
      expect(ProgressMath.percent(5, 12), 42);
    });

    test('full and empty', () {
      expect(ProgressMath.percent(1, 1), 100);
      expect(ProgressMath.percent(0, 1), 0);
    });

    test('no questions is null, not 0', () {
      expect(ProgressMath.percent(0, 0), isNull);
    });

    test('rounds to the nearest integer', () {
      expect(ProgressMath.percent(1, 3), 33);
      expect(ProgressMath.percent(2, 3), 67);
      expect(ProgressMath.percent(1, 8), 13);
    });

    test('is clamped to 0..100', () {
      expect(ProgressMath.percent(9, 4), 100);
    });
  });
}
