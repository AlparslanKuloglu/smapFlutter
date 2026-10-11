import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/stacked_bar_math.dart';

void main() {
  group('StackedBarMath.segments', () {
    test('86 / 74 / 0 draws two parts with a 2 pt gap that fill the bar', () {
      const counts = DybCounts(correct: 86, wrong: 74, blank: 0);
      final parts = StackedBarMath.segments(counts, 322);
      expect(parts.map((p) => p.kind), [DybKind.correct, DybKind.wrong]);
      expect(parts.first.left, 0);
      expect(parts.first.width, closeTo(320 * 86 / 160, 1e-9));
      expect(parts.last.left - parts.first.right, 2);
      expect(parts.last.right, closeTo(322, 1e-9));
    });

    test('three parts, two gaps, order D Y B', () {
      const counts = DybCounts(correct: 80, wrong: 21, blank: 19);
      final parts = StackedBarMath.segments(counts, 304);
      expect(parts.map((p) => p.kind), DybKind.ordered);
      expect(parts[1].left - parts[0].right, 2);
      expect(parts[2].left - parts[1].right, 2);
      expect(parts.last.right, closeTo(304, 1e-9));
    });

    test('a part with a zero count is not drawn', () {
      const counts = DybCounts(correct: 5, wrong: 0, blank: 5);
      final parts = StackedBarMath.segments(counts, 102);
      expect(parts.map((p) => p.kind), [DybKind.correct, DybKind.blank]);
    });

    test('one part has no gap and takes the whole width', () {
      const counts = DybCounts(correct: 0, wrong: 1, blank: 0);
      final parts = StackedBarMath.segments(counts, 200);
      expect(parts.length, 1);
      expect(parts.single.width, 200);
    });

    test('no questions or no width draws nothing', () {
      expect(
        StackedBarMath.segments(
          const DybCounts(correct: 0, wrong: 0, blank: 0),
          200,
        ),
        isEmpty,
      );
      expect(
        StackedBarMath.segments(
          const DybCounts(correct: 1, wrong: 1, blank: 0),
          0,
        ),
        isEmpty,
      );
    });

    test('a bar narrower than its gaps draws nothing', () {
      expect(
        StackedBarMath.segments(
          const DybCounts(correct: 1, wrong: 1, blank: 1),
          3,
        ),
        isEmpty,
      );
    });
  });
}
