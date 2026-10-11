import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/mappable/hooks.dart';

void main() {
  group('LenientIntHook', () {
    const hook = LenientIntHook();

    test('reads numbers and numeric text as int', () {
      expect(hook.beforeDecode(12), 12);
      expect(hook.beforeDecode(12.0), 12);
      expect(hook.beforeDecode('12'), 12);
      expect(hook.beforeDecode(' 12.0 '), 12);
    });

    test('blank text is null, unreadable values pass through', () {
      expect(hook.beforeDecode(''), isNull);
      expect(hook.beforeDecode('  '), isNull);
      expect(hook.beforeDecode(12.5), 12.5);
      expect(hook.beforeDecode('abc'), 'abc');
      expect(hook.beforeDecode(double.nan), isNaN);
      expect(hook.beforeDecode(null), isNull);
    });
  });

  group('LenientDoubleHook', () {
    const hook = LenientDoubleHook();

    test('reads numbers and text with dot or comma', () {
      expect(hook.beforeDecode(3), 3.0);
      expect(hook.beforeDecode('67.5'), 67.5);
      expect(hook.beforeDecode('67,5'), 67.5);
      expect(hook.beforeDecode(''), isNull);
      expect(hook.beforeDecode('x'), 'x');
    });
  });

  group('LenientBoolHook', () {
    const hook = LenientBoolHook();

    test('reads true/false spellings', () {
      expect(hook.beforeDecode(true), true);
      expect(hook.beforeDecode('TRUE'), true);
      expect(hook.beforeDecode('false'), false);
      expect(hook.beforeDecode(1), true);
      expect(hook.beforeDecode(0), false);
      expect(hook.beforeDecode('1'), true);
      expect(hook.beforeDecode('0'), false);
      expect(hook.beforeDecode('maybe'), 'maybe');
      expect(hook.beforeDecode(2), 2);
    });
  });

  test('LenientStringHook writes numbers as text', () {
    const hook = LenientStringHook();

    expect(hook.beforeDecode(42), '42');
    expect(hook.beforeDecode('a'), 'a');
    expect(hook.beforeDecode(null), isNull);
  });

  test('BlankToNullHook drops empty text only', () {
    const hook = BlankToNullHook();

    expect(hook.beforeDecode(''), isNull);
    expect(hook.beforeDecode('  '), isNull);
    expect(hook.beforeDecode('ada'), 'ada');
    expect(hook.beforeDecode(5), 5);
  });

  group('LenientDateTimeHook', () {
    const hook = LenientDateTimeHook();

    test('blank is null; ISO and epoch become parseable text', () {
      expect(hook.beforeDecode(''), isNull);
      expect(hook.beforeDecode(null), isNull);

      final fromIso = hook.beforeDecode('2026-10-11T09:30:00.000Z')! as String;
      expect(
        DateTime.parse(fromIso).toUtc(),
        DateTime.utc(2026, 10, 11, 9, 30),
      );

      final fromEpoch = hook.beforeDecode(0)! as String;
      expect(DateTime.parse(fromEpoch).millisecondsSinceEpoch, 0);
    });

    test('unreadable text passes through', () {
      expect(hook.beforeDecode('yesterday'), 'yesterday');
    });
  });

  test('IgnoreFieldsHook removes named keys from the encoded map', () {
    const hook = IgnoreFieldsHook(['items']);
    final encoded = <String, dynamic>{'id': 1, 'items': <int>[]};

    expect(hook.afterEncode(encoded), {'id': 1});
    expect(hook.afterEncode('not a map'), 'not a map');
  });
}
