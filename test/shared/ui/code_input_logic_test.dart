import 'package:flutter_test/flutter_test.dart';
import 'package:smap/shared/ui/inputs/code_input_logic.dart';

void main() {
  group('sanitize', () {
    const cases = {
      '': '',
      '271524': '271524',
      '271 524': '271524',
      '271-524': '271524',
      'Kod: 271524': '271524',
      '27152499': '271524',
      '12': '12',
      'abc': '',
    };
    cases.forEach((raw, expected) {
      test('"$raw" -> "$expected"', () {
        expect(CodeInputLogic.sanitize(raw), expected);
      });
    });
  });

  group('activeIndex', () {
    test('the first empty box takes the next digit', () {
      expect(CodeInputLogic.activeIndex(0), 0);
      expect(CodeInputLogic.activeIndex(3), 3);
      expect(CodeInputLogic.activeIndex(5), 5);
    });

    test('a complete code stays on the last box', () {
      expect(CodeInputLogic.activeIndex(6), 5);
    });
  });

  test('isComplete is true at six digits only', () {
    expect(CodeInputLogic.isComplete('27152'), isFalse);
    expect(CodeInputLogic.isComplete('271524'), isTrue);
  });

  group('shakeOffset', () {
    test('starts and ends at rest', () {
      expect(
        CodeInputLogic.shakeOffset(0, amplitude: 6, cycles: 3),
        closeTo(0, 1e-9),
      );
      expect(
        CodeInputLogic.shakeOffset(1, amplitude: 6, cycles: 3),
        closeTo(0, 1e-9),
      );
    });

    test('never exceeds the amplitude and dies out', () {
      var peak = 0.0;
      for (var i = 0; i <= 100; i++) {
        final value = CodeInputLogic.shakeOffset(
          i / 100,
          amplitude: 6,
          cycles: 3,
        ).abs();
        if (value > peak) peak = value;
        expect(value, lessThanOrEqualTo(6));
      }
      expect(peak, greaterThan(3));
    });
  });
}
