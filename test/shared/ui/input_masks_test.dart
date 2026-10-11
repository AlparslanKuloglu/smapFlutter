import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/shared/ui/inputs/input_masks.dart';

void main() {
  group('formatPhone (5XX XXX XX XX)', () {
    const cases = {
      '': '',
      '5': '5',
      '532': '532',
      '5321': '532 1',
      '532123': '532 123',
      '5321234': '532 123 4',
      '532123456': '532 123 45 6',
      '5321234567': '532 123 45 67',
      '532 123 45 67': '532 123 45 67',
      '(532) 123-45-67': '532 123 45 67',
      '53212345678999': '532 123 45 67',
      'abc': '',
    };
    cases.forEach((raw, expected) {
      test('"$raw" -> "$expected"', () {
        expect(AppInputMasks.formatPhone(raw), expected);
      });
    });
  });

  group('formatCoachCode (MOZK-4821)', () {
    const cases = {
      '': '',
      'm': 'M',
      'mozk': 'MOZK',
      'MOZK': 'MOZK',
      'mozk4': 'MOZK-4',
      'mozk4821': 'MOZK-4821',
      'MOZK-4821': 'MOZK-4821',
      'mozk48219999': 'MOZK-4821',
      'mozkabc': 'MOZK',
      'mo1zk': 'MOZK',
      '4821': '',
      'mozk-': 'MOZK',
    };
    cases.forEach((raw, expected) {
      test('"$raw" -> "$expected"', () {
        expect(AppInputMasks.formatCoachCode(raw), expected);
      });
    });

    test('letters are upper-cased without the Turkish i rule', () {
      expect(AppInputMasks.formatCoachCode('ilki'), 'ILKI');
    });
  });

  group('formatters keep the caret after the same character', () {
    TextEditingValue type(TextInputFormatter f, String text, int caret) =>
        f.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: caret),
          ),
        );

    test('phone: caret after the 4th digit lands after "532 1"', () {
      final value = type(AppInputMasks.phone, '5321', 4);
      expect(value.text, '532 1');
      expect(value.selection.baseOffset, 5);
    });

    test('phone: caret in the middle follows its digit', () {
      final value = type(AppInputMasks.phone, '53212', 2);
      expect(value.text, '532 12');
      expect(value.selection.baseOffset, 2);
    });

    test('coach code: caret after the first digit lands after the dash', () {
      final value = type(AppInputMasks.coachCode, 'mozk4', 5);
      expect(value.text, 'MOZK-4');
      expect(value.selection.baseOffset, 6);
    });
  });
}
