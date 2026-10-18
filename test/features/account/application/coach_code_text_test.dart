import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/application/coach_code_text.dart';

void main() {
  group('CoachCodeText.shown', () {
    test('writes the code as AAAA-0000', () {
      expect(CoachCodeText.shown('MOZK-4821'), 'MOZK-4821');
      expect(CoachCodeText.shown(' mozk4821 '), 'MOZK-4821');
    });

    test('text of another shape is shown as it is', () {
      expect(CoachCodeText.shown('KOÇ-1'), 'KOÇ-1');
    });

    test('a missing or blank code is none', () {
      expect(CoachCodeText.shown(null), isNull);
      expect(CoachCodeText.shown('  '), isNull);
    });
  });

  group('CoachCodeText.spoken (pano 14.11 Erişilebilirlik)', () {
    test('reads the code letter by letter with "tire"', () {
      expect(
        CoachCodeText.spoken('MOZK-4821', dash: 'tire'),
        'M O Z K tire 4 8 2 1',
      );
    });

    test('a code without a dash is still read apart', () {
      expect(CoachCodeText.spoken('MOZK4821', dash: 'tire'), 'M O Z K 4 8 2 1');
    });
  });
}
