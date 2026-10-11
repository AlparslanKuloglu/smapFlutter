import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/net_math.dart';

void main() {
  group('net = D - Y / 4, shown through TrFormat', () {
    final cases = <(int, int, double, String)>[
      (86, 74, 67.5, '67,5'),
      (80, 21, 74.75, '74,75'),
      (23, 17, 18.75, '18,75'),
      (17, 23, 11.25, '11,25'),
      (25, 15, 21.25, '21,25'),
      (21, 19, 16.25, '16,25'),
      (32, 6, 30.5, '30,5'),
      (40, 0, 40, '40'),
      (0, 0, 0, '0'),
      (0, 10, -2.5, '−2,5'),
    ];
    for (final (d, y, net, text) in cases) {
      test('$d D, $y Y -> $text', () {
        expect(NetMath.net(d, y), net);
        expect(NetMath.format(NetMath.net(d, y)), text);
      });
    }

    test('four wrong cancel one correct, blanks have no effect', () {
      expect(NetMath.net(10, 4), 9);
      expect(
        const DybCounts(correct: 10, wrong: 4, blank: 30).net,
        const DybCounts(correct: 10, wrong: 4, blank: 0).net,
      );
    });
  });

  group('blank', () {
    test('is the rest of the questions', () {
      expect(NetMath.blank(total: 120, correct: 80, wrong: 21), 19);
    });

    test('never goes below zero', () {
      expect(NetMath.blank(total: 10, correct: 8, wrong: 5), 0);
    });
  });

  group('DybCounts', () {
    const counts = DybCounts(correct: 86, wrong: 74, blank: 0);

    test('total adds the three', () => expect(counts.total, 160));

    test('of() follows the fixed order D, Y, B', () {
      expect(DybKind.ordered, [DybKind.correct, DybKind.wrong, DybKind.blank]);
      expect(DybKind.ordered.map(counts.of), [86, 74, 0]);
    });

    test('equality is by value', () {
      expect(counts, const DybCounts(correct: 86, wrong: 74, blank: 0));
      expect(
        counts == const DybCounts(correct: 86, wrong: 74, blank: 1),
        isFalse,
      );
    });
  });
}
