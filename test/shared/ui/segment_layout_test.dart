import 'package:flutter_test/flutter_test.dart';
import 'package:smap/shared/ui/controls/segment_layout.dart';

void main() {
  group('SegmentCounter.format (11.13: an empty counter is not drawn)', () {
    test('a count and its unit', () {
      expect(SegmentCounter.format(count: 28, unit: 'eksik'), '28 eksik');
      expect(SegmentCounter.format(count: 1, unit: 'kart'), '1 kart');
    });

    test('zero is not drawn (no "eksik yok")', () {
      expect(SegmentCounter.format(count: 0, unit: 'eksik'), isNull);
    });

    test('no data is not drawn', () {
      expect(SegmentCounter.format(count: null, unit: 'eksik'), isNull);
    });

    test('negative is not drawn', () {
      expect(SegmentCounter.format(count: -2, unit: 'soru'), isNull);
    });

    test('large counts use thousands dots (TrFormat)', () {
      expect(SegmentCounter.format(count: 1234, unit: 'soru'), '1.234 soru');
    });
  });

  group('SegmentLayout.slots', () {
    test('shares the width in proportion to the labels', () {
      final slots = SegmentLayout.slots([100, 100, 200], 400);
      expect(slots.map((s) => s.width).toList(), [100.0, 100.0, 200.0]);
      expect(slots.map((s) => s.left).toList(), [0.0, 100.0, 200.0]);
    });

    test('gaps are taken out before sharing and added to the offsets', () {
      final slots = SegmentLayout.slots([1, 1], 104, gap: 4);
      expect(slots[0].width, 50);
      expect(slots[1].width, 50);
      expect(slots[1].left, 54);
    });

    test('a long label gets more room than a short one', () {
      final slots = SegmentLayout.slots([60, 120], 300);
      expect(slots[1].width, greaterThan(slots[0].width));
      expect(slots.fold<double>(0, (s, e) => s + e.width), closeTo(300, 1e-9));
    });

    test('equal naturals give equal widths', () {
      final slots = SegmentLayout.slots([50, 50, 50, 50], 320);
      expect(slots.every((s) => (s.width - 80).abs() < 1e-9), isTrue);
    });

    test('zero naturals fall back to equal shares', () {
      final slots = SegmentLayout.slots([0, 0], 100);
      expect(slots.map((s) => s.width).toList(), [50.0, 50.0]);
    });

    test('a track narrower than the gaps yields zero widths', () {
      final slots = SegmentLayout.slots([10, 10], 2, gap: 4);
      expect(slots.every((s) => s.width == 0), isTrue);
    });

    test('empty input gives no slots', () {
      expect(SegmentLayout.slots([], 100), isEmpty);
    });
  });

  group('SegmentLayout.counterInline', () {
    test('two segments that fit go on one line', () {
      expect(
        SegmentLayout.counterInline(
          segmentCount: 2,
          inlineWidths: [90, 90],
          available: 200,
          gap: 4,
        ),
        isTrue,
      );
    });

    test('two segments that do not fit stack the counter', () {
      expect(
        SegmentLayout.counterInline(
          segmentCount: 2,
          inlineWidths: [90, 140],
          available: 200,
          gap: 4,
        ),
        isFalse,
      );
    });

    test('three or four segments always stack', () {
      expect(
        SegmentLayout.counterInline(
          segmentCount: 3,
          inlineWidths: [10, 10, 10],
          available: 400,
        ),
        isFalse,
      );
    });
  });
}
