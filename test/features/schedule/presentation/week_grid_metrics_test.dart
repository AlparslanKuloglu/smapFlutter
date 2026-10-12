import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/schedule/presentation/widgets/week_grid.dart';

void main() {
  group('WeekGridMetrics (text scale 1,3 rule)', () {
    test('at scale 1 the sizes are the board\'s (C63)', () {
      const m = WeekGridMetrics(1);
      expect(m.hourColumn, 44);
      expect(m.dayColumn, 84);
      expect(m.hourRow, 40);
      expect(m.headerRow, 44);
      expect(m.blockHeight, 36);
    });

    test('a smaller text scale never shrinks the grid', () {
      expect(WeekGridMetrics.forTextScale(0.8).scale, 1);
    });

    test('the sizes grow with the text so a label keeps its room', () {
      final m = WeekGridMetrics.forTextScale(1.35);
      expect(m.hourColumn, closeTo(59.4, 0.01));
      expect(m.hourRow, closeTo(54, 0.01));
      expect(m.headerRow, closeTo(59.4, 0.01));
      expect(m.blockHeight, closeTo(48.6, 0.01));
    });

    test('the growth stops at the cap', () {
      expect(WeekGridMetrics.forTextScale(3).scale, WeekGridMetrics.maxScale);
    });
  });
}
