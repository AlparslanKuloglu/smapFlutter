import 'package:flutter_test/flutter_test.dart';
import 'package:smap/shared/ui/controls/tab_layout.dart';

void main() {
  group('TabBarLayout.fitsFixed', () {
    test('four short labels fit in a phone width', () {
      expect(TabBarLayout.fitsFixed([46, 62, 64, 58], 370), isTrue);
    });

    test('a long label pushes the bar to scroll', () {
      expect(TabBarLayout.fitsFixed([46, 62, 64, 58, 98], 370), isFalse);
    });

    test('scaled text (1,3) can force scrolling', () {
      expect(TabBarLayout.fitsFixed([60, 81, 83, 75], 330), isFalse);
    });
  });

  group('TabBarLayout.fixedSlots', () {
    test('equal shares with centered labels', () {
      final slots = TabBarLayout.fixedSlots([40, 60], 200);
      expect(slots[0].left, 0);
      expect(slots[0].width, 100);
      expect(slots[0].labelLeft, 30);
      expect(slots[1].labelLeft, 100 + 20);
      expect(slots[1].labelWidth, 60);
    });
  });

  group('TabBarLayout.scrollSlots', () {
    test('16 at the ends, 24 between boxes, 4 inside each box', () {
      final slots = TabBarLayout.scrollSlots([50, 70]);
      expect(slots[0].left, 16);
      expect(slots[0].width, 58);
      expect(slots[0].labelLeft, 20);
      expect(slots[1].left, 16 + 58 + 24);
      expect(TabBarLayout.scrollExtent(slots), 16 + 58 + 24 + 78 + 16);
    });

    test('the accent line is as wide as the label', () {
      final slots = TabBarLayout.scrollSlots([50]);
      expect(slots.single.labelWidth, 50);
    });
  });

  group('TabBarLayout.scrollTarget', () {
    final slots = TabBarLayout.scrollSlots([50, 70, 60, 80, 90]);
    final extent = TabBarLayout.scrollExtent(slots);

    test('keeps the offset when the tab is already inside', () {
      final target = TabBarLayout.scrollTarget(
        slot: slots[0],
        viewport: 300,
        extent: extent,
        current: 0,
      );
      expect(target, 0);
    });

    test('centers a tab that is out of view', () {
      final target = TabBarLayout.scrollTarget(
        slot: slots[3],
        viewport: 200,
        extent: extent,
        current: 0,
      );
      expect(target, slots[3].left + slots[3].width / 2 - 100);
    });

    test('never scrolls past the end', () {
      final target = TabBarLayout.scrollTarget(
        slot: slots[4],
        viewport: 200,
        extent: extent,
        current: 0,
      );
      expect(target, extent - 200);
    });

    test('never scrolls before the start', () {
      final target = TabBarLayout.scrollTarget(
        slot: slots[0],
        viewport: 200,
        extent: extent,
        current: 120,
      );
      expect(target, 0);
    });
  });
}
