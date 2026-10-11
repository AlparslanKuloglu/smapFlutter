import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/shared/ui/identity/avatar_initials.dart';
import 'package:smap/shared/ui/text/delta_direction.dart';
import 'package:smap/shared/ui/text/highlight_text.dart';

void main() {
  group('AvatarInitials.of', () {
    const cases = {
      'Alparslan Kuloğlu': 'AK',
      'Mehmet Özkan': 'MÖ',
      'elif şahin': 'EŞ',
      'ilker çelik': 'İÇ',
      'ışıl yıldız': 'IY',
      'Zeynep Ece Kaya': 'ZK',
      'Zeynep': 'Z',
      '  Mert   Demir  ': 'MD',
      '': '',
      '   ': '',
    };
    cases.forEach((name, expected) {
      test('"$name" -> "$expected"', () {
        expect(AvatarInitials.of(name), expected);
      });
    });
  });

  group('splitByRanges', () {
    test('plain text is one unmatched run', () {
      expect(splitByRanges('Elif Şahin', const []), [
        (text: 'Elif Şahin', matched: false),
      ]);
    });

    test('a match in the middle gives three runs that concatenate back', () {
      final segments = splitByRanges('Mehmet Özkan', [(start: 7, end: 9)]);
      expect(segments, [
        (text: 'Mehmet ', matched: false),
        (text: 'Öz', matched: true),
        (text: 'kan', matched: false),
      ]);
      expect(segments.map((s) => s.text).join(), 'Mehmet Özkan');
    });

    test('a match at both ends', () {
      final segments = splitByRanges('abcdef', [
        (start: 0, end: 2),
        (start: 4, end: 6),
      ]);
      expect(segments.map((s) => s.matched).toList(), [true, false, true]);
    });

    test('out-of-range and empty ranges are ignored', () {
      final segments = splitByRanges('abc', [
        (start: 1, end: 1),
        (start: 2, end: 99),
      ]);
      expect(segments.map((s) => s.text).join(), 'abc');
      expect(segments.last, (text: 'c', matched: true));
    });

    test('works with the Turkish match ranges', () {
      const text = 'Işıl Yıldız';
      final ranges = TurkishText.matchRanges(text, 'isil');
      final segments = splitByRanges(text, ranges);
      expect(segments.first, (text: 'Işıl', matched: true));
      expect(segments.map((s) => s.text).join(), text);
    });

    test('a blank query marks nothing', () {
      final ranges = TurkishText.matchRanges('Elif', '  ');
      expect(splitByRanges('Elif', ranges).single.matched, isFalse);
    });
  });

  group('DeltaDirection.of', () {
    test('sign decides the arrow', () {
      expect(DeltaDirection.of(8.25), DeltaDirection.up);
      expect(DeltaDirection.of(-1.5), DeltaDirection.down);
    });

    test('zero and values that write as 0 carry no arrow', () {
      expect(DeltaDirection.of(0), DeltaDirection.flat);
      expect(DeltaDirection.of(0.001), DeltaDirection.flat);
      expect(DeltaDirection.of(-0.001), DeltaDirection.flat);
    });

    test('a quarter-step change is a real change', () {
      expect(DeltaDirection.of(0.25), DeltaDirection.up);
    });
  });
}
