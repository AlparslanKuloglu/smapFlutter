import 'package:smap/features/analytics/data/dtos/analytics_answers.dart';
import 'package:smap/features/analytics/domain/analytics_totals.dart';
import 'package:smap/features/analytics/domain/net_series.dart';
import 'package:smap/features/exams/data/dtos/mock_exam_dto.dart';
import 'package:smap/features/exams/data/mappers/exam_mappers.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_scores.dart';

extension TotalResponseMapping on TotalResponse {
  AnalyticsTotals toDomain() {
    final labels = total?.labels ?? const <String?>[];
    final values = total?.values ?? const <double?>[];
    return AnalyticsTotals(
      examCount: total?.count,
      averageNet: total?.averageNet,
      shares: [
        for (var i = 0; i < labels.length; i++)
          if (labels[i] != null && i < values.length && values[i] != null)
            LessonShare(label: labels[i]!, value: values[i]!),
      ],
      subjects: [
        for (final item in items ?? const <TotalItemDto>[])
          if (item.subject?.name != null && item.count != null)
            SubjectTally(
              name: item.subject!.name!,
              count: item.count!,
              correct: item.trueValue ?? 0,
            ),
      ],
    );
  }
}

extension MockExamSeriesMapping on MockExamDto {
  /// The exam as a series point; `null` without a net (nothing to draw).
  NetSeriesPoint? toSeriesPoint() {
    final value = net;
    if (value == null) return null;
    return NetSeriesPoint(
      net: value,
      date: date,
      name: itemName,
      counts: dybOf(correct, wrong, pass),
      scores: ExamScores(
        points: points ?? const [],
        pointsHam: pointsHam ?? const [],
        ranks: ranks ?? const [],
        ranksHam: ranksHam ?? const [],
      ),
    );
  }
}

extension LineChartResponseMapping on LineChartResponse {
  NetSeries toDomain() => NetSeries(
    points: [
      for (final exam in exams ?? const <MockExamDto>[])
        if (exam.toSeriesPoint() case final NetSeriesPoint point) point,
    ],
    totalQuestion: totalQuestion,
    userField: AytField.fromWire(user?.aimType),
  );
}
