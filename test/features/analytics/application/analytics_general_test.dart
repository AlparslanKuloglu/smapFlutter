import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/analytics/application/analytics_filter.dart';
import 'package:smap/features/analytics/application/analytics_general.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/analytics/domain/analytics_summary.dart';
import 'package:smap/features/analytics/domain/analytics_totals.dart';
import 'package:smap/features/analytics/domain/net_series.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_scores.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';

/// The TYT exams of pano 6.1 kare 1 with realistic scores (Ek C): ranks and
/// points in slot 0.
NetSeries _tytSeries() => NetSeries(
  points: [
    for (final (i, net) in [61.5, 64.25, 68.0, 66.75, 71.5, 74.75].indexed)
      NetSeriesPoint(
        net: net,
        date: DateTime(2026, 4 + i, 10 + i),
        name: 'TYT Genel Deneme ${4 + i}',
        scores: ExamScores(
          points: [380.0 + i * 2.2, null],
          ranks: [190000 - i * 4000, null],
        ),
      ),
  ],
);

AnalyticsOverview _overview(
  NetSeries series, {
  required NetExamType exam,
  AytField? field,
  bool lesson = false,
  int? count,
  double? ortNet,
}) {
  final totals = AnalyticsTotals(
    examCount: count ?? series.points.length,
    averageNet: ortNet,
  );
  return AnalyticsOverview(
    totals: totals,
    series: series,
    summary: AnalyticsSummary.compute(
      totals: totals,
      series: series,
      exam: exam,
      field: field,
      lessonScope: lesson,
    ),
  );
}

void main() {
  group('GeneralContent.lastTwoDelta', () {
    NetChartPoint at(int day, double net) =>
        NetChartPoint(date: DateTime(2026, 9, day), net: net);

    test('is the last net minus the one before it', () {
      expect(
        GeneralContent.lastTwoDelta([at(1, 60), at(2, 71.5), at(3, 74.75)]),
        3.25,
      );
    });

    test('can be negative and is rounded to two decimals', () {
      expect(GeneralContent.lastTwoDelta([at(1, 60.1), at(2, 59.9)]), -0.2);
    });

    test('needs two exams (no "geçen ay" and no invented change)', () {
      expect(GeneralContent.lastTwoDelta([at(1, 60)]), isNull);
      expect(GeneralContent.lastTwoDelta(const []), isNull);
    });
  });

  group('GeneralContent.from', () {
    test('TYT: the six exams of pano 6.1 with the +3,25 change', () {
      final content = GeneralContent.from(
        AnalyticsFilter.tyt,
        _overview(_tytSeries(), exam: NetExamType.tyt, ortNet: 67.79),
      );

      expect(content.chartKind, GeneralChartKind.line);
      expect(content.points, hasLength(6));
      expect(content.examCount, 6);
      expect(content.averageNet, 67.79);
      expect(content.netDelta, 3.25);
      expect(content.axisMax, 120);
      expect(content.scopeLabel, 'TYT');
      expect(content.averagePoint, closeTo(385.5, 0.001));
      expect(content.averageRank, 180000);
      expect(content.isEmpty, isFalse);
    });

    test('AYT without scores draws no points or rank box', () {
      final series = NetSeries(
        points: [
          for (final (i, net) in [48.5, 55.0, 59.25, 67.5].indexed)
            NetSeriesPoint(net: net, date: DateTime(2026, 5 + i, 8)),
        ],
      );
      final content = GeneralContent.from(
        const AnalyticsFilter(
          exam: NetExamType.ayt,
          field: AytField.equalWeight,
        ),
        _overview(series, exam: NetExamType.ayt, field: AytField.equalWeight),
      );

      expect(content.axisMax, 160);
      expect(content.examCount, 4);
      expect(content.averageNet, closeTo(57.5625, 0.0001));
      expect(content.netDelta, 8.25);
      expect(content.averagePoint, isNull);
      expect(content.averageRank, isNull);
    });

    test('one exam is the "İlk denemen" card and has no change', () {
      final series = NetSeries(
        points: [NetSeriesPoint(net: 74.75, date: DateTime(2026, 9, 28))],
      );
      final content = GeneralContent.from(
        AnalyticsFilter.tyt,
        _overview(series, exam: NetExamType.tyt),
      );

      expect(content.chartKind, GeneralChartKind.single);
      expect(content.netDelta, isNull);
      expect(content.examCount, 1);
    });

    test('no exam at all is empty', () {
      final content = GeneralContent.from(
        AnalyticsFilter.tyt,
        _overview(const NetSeries(), exam: NetExamType.tyt, count: 0),
      );

      expect(content.isEmpty, isTrue);
      expect(content.chartKind, GeneralChartKind.none);
    });

    test('a lesson filter has the lesson axis and no whole-exam rank', () {
      final lesson = ExamLessonCatalog.of(NetExamType.tyt).first;
      final content = GeneralContent.from(
        AnalyticsFilter.tyt.withLesson(lesson),
        _overview(_tytSeries(), exam: NetExamType.tyt, lesson: true),
      );

      expect(content.axisMax, 40);
      expect(content.scopeLabel, 'TYT Türkçe');
      expect(content.averageRank, isNull);
      expect(content.averagePoint, isNull);
    });

    test('the series question count wins over the lesson table', () {
      final lesson = ExamLessonCatalog.of(NetExamType.tyt).first;
      final series = NetSeries(
        totalQuestion: 30,
        points: [NetSeriesPoint(net: 20, date: DateTime(2026, 9, 1))],
      );
      final content = GeneralContent.from(
        AnalyticsFilter.tyt.withLesson(lesson),
        _overview(series, exam: NetExamType.tyt, lesson: true),
      );
      expect(content.axisMax, 30);
    });

    test('equal inputs give equal content (selectors do not rebuild)', () {
      GeneralContent make() => GeneralContent.from(
        AnalyticsFilter.tyt,
        _overview(_tytSeries(), exam: NetExamType.tyt),
      );
      expect(make(), make());
      expect(make().hashCode, make().hashCode);
    });
  });
}
