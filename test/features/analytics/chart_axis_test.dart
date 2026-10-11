import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/analytics/application/chart_axis.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';

void main() {
  group('axis of the exam types', () {
    test('TYT 0-120, AYT 0-160', () {
      expect(NetExamType.tyt.axisMax, 120);
      expect(NetExamType.ayt.axisMax, 160);
      expect(NetExamType.tyt.label, 'TYT');
      expect(NetExamType.ayt.label, 'AYT');
    });
  });

  group('ChartAxis.stepFor (the old table plus 160)', () {
    final steps = <double, double>{
      160: 40,
      120: 30,
      80: 20,
      40: 5,
      30: 5,
      24: 4,
      7: 1,
      6: 1,
      5: 1,
      100: 20,
      50: 10,
      13: 10,
    };
    steps.forEach((max, step) {
      test('$max -> $step', () => expect(ChartAxis.stepFor(max), step));
    });
  });

  group('ChartAxis.ticks', () {
    test('TYT: 0, 30, 60, 90, 120', () {
      expect(ChartAxis.ticks(120), [0, 30, 60, 90, 120]);
    });
    test('AYT: 0, 40, 80, 120, 160', () {
      expect(ChartAxis.ticks(160), [0, 40, 80, 120, 160]);
    });
    test('a 40 question lesson: steps of 5', () {
      expect(ChartAxis.ticks(40), [0, 5, 10, 15, 20, 25, 30, 35, 40]);
    });
    test('the top is always included, even off the step', () {
      expect(ChartAxis.ticks(45).last, 45);
    });
  });

  group('ChartAxis.clampNet', () {
    test('a value inside the axis is kept', () {
      expect(ChartAxis.clampNet(74.75, 120), 74.75);
    });
    test('a negative net sits on zero', () {
      expect(ChartAxis.clampNet(-3.5, 120), 0);
    });
    test('a value above the axis does not grow it', () {
      expect(ChartAxis.clampNet(130, 120), 120);
    });
  });

  group('ChartAxis.xBounds', () {
    test('padding on both sides', () {
      expect(ChartAxis.xBounds(6), (-0.3, 5.3));
    });
    test('a single point still has a range', () {
      expect(ChartAxis.xBounds(1), (-0.5, 0.5));
      expect(ChartAxis.xBounds(0), (-0.5, 0.5));
    });
  });

  group('ChartAxis.visibleLabelIndices', () {
    test('all labels when they fit', () {
      expect(ChartAxis.visibleLabelIndices(6, 6), {0, 1, 2, 3, 4, 5});
      expect(ChartAxis.visibleLabelIndices(4, 6), {0, 1, 2, 3});
    });
    test('first, last and even ones between when they do not', () {
      final shown = ChartAxis.visibleLabelIndices(10, 4);
      expect(shown, {0, 3, 6, 9});
      expect(shown.contains(0) && shown.contains(9), isTrue);
    });
    test('never more than the limit', () {
      for (var count = 7; count < 40; count++) {
        expect(
          ChartAxis.visibleLabelIndices(count, 5).length,
          lessThanOrEqualTo(5),
          reason: '$count points',
        );
      }
    });
    test('under two labels only the last point is named', () {
      expect(ChartAxis.visibleLabelIndices(8, 1), {7});
    });
    test('no points, no labels', () {
      expect(ChartAxis.visibleLabelIndices(0, 4), isEmpty);
    });
  });

  group('ChartAxis.maxLabelsFor', () {
    test('as many as fit, at least two, at most the point count', () {
      expect(
        ChartAxis.maxLabelsFor(plotWidth: 300, labelWidth: 46, count: 10),
        6,
      );
      expect(
        ChartAxis.maxLabelsFor(plotWidth: 40, labelWidth: 46, count: 10),
        2,
      );
      expect(
        ChartAxis.maxLabelsFor(plotWidth: 300, labelWidth: 46, count: 3),
        3,
      );
    });
    test('a bigger text scale means fewer labels', () {
      final normal = ChartAxis.maxLabelsFor(
        plotWidth: 300,
        labelWidth: 46,
        count: 10,
      );
      final large = ChartAxis.maxLabelsFor(
        plotWidth: 300,
        labelWidth: 46 * 1.3,
        count: 10,
      );
      expect(large, lessThan(normal));
    });
  });

  group('ChartAxis.selectionAfterTap', () {
    test('the tapped point is selected', () {
      expect(ChartAxis.selectionAfterTap(tapped: 2, count: 6), 2);
    });
    test('a tap outside every point returns to the last', () {
      expect(ChartAxis.selectionAfterTap(tapped: null, count: 6), 5);
      expect(ChartAxis.selectionAfterTap(tapped: 9, count: 6), 5);
    });
    test('no points, no selection', () {
      expect(ChartAxis.selectionAfterTap(tapped: null, count: 0), isNull);
    });
  });

  group('Turkish dates on the axis', () {
    test('x label: 22 Nis.', () {
      expect(ChartAxis.dateLabel(DateTime(2026, 4, 22)), '22 Nis.');
      expect(ChartAxis.dateLabel(DateTime(2026, 5, 14)), '14 May.');
    });
    test('reading: 22 Nisan', () {
      expect(ChartAxis.longDayMonth(DateTime(2026, 4, 22)), '22 Nisan');
      expect(ChartAxis.longDayMonth(DateTime(2026, 9, 28)), '28 Eylül');
    });
  });

  group('NetChartPoint.sortedByDate', () {
    test('oldest first; the same day keeps the given order', () {
      final a = NetChartPoint(
        date: DateTime(2026, 9, 28),
        net: 74.75,
        name: 'a',
      );
      final b = NetChartPoint(
        date: DateTime(2026, 4, 22),
        net: 61.5,
        name: 'b',
      );
      final c = NetChartPoint(date: DateTime(2026, 9, 28), net: 70, name: 'c');
      final sorted = NetChartPoint.sortedByDate([a, b, c]);
      expect(sorted.map((p) => p.name), ['b', 'a', 'c']);
    });
  });
}
