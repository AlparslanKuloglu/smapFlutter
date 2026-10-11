import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/analytics/data/mappers/analytics_mappers.dart';
import 'package:smap/features/analytics/data/requests/analytics_requests.dart';
import 'package:smap/features/analytics/domain/analytics_summary.dart';
import 'package:smap/features/analytics/domain/analytics_totals.dart';
import 'package:smap/features/analytics/domain/net_series.dart';
import 'package:smap/features/exams/data/api_support.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';

/// Reads the Analizlerim numbers: the headline totals and the net series.
/// Replaces the analytics half of the legacy `AnalysisRepository`
/// (spec §6.3 #26).
///
/// Every method answers `Either<AppException, T>` and never throws. [field] is
/// the student's AYT field (`aimType`); the repository does not guess it (the
/// legacy screen forced 2), pass `AytField.fromWire(user.aimType)` or the
/// user's choice. [lessonId] is a lesson's Mongo id, `null` for "Genel". A
/// coach reading a student's numbers passes the student's id as [studentId].
class AnalyticsRepository {
  AnalyticsRepository(this._network);

  final NetworkService _network;

  /// `getTotal`: solved exams, average net, the distribution.
  Future<AppResult<AnalyticsTotals>> getTotal({
    required NetExamType exam,
    AytField? field,
    String? lessonId,
    String? studentId,
  }) async {
    final result = await _network.send(
      AnalyticsRequests.total(
        exam: exam,
        field: field,
        lessonId: lessonId,
        studentId: studentId,
      ),
    );
    return result
        .requireSuccess('/student/getTotal')
        .map((response) => response.toDomain());
  }

  /// `getLineChartData`: the exams of the scope for the net chart.
  Future<AppResult<NetSeries>> getLineChartData({
    required NetExamType exam,
    AytField? field,
    String? lessonId,
    String? studentId,
  }) async {
    final result = await _network.send(
      AnalyticsRequests.lineChart(
        exam: exam,
        field: field,
        lessonId: lessonId,
        studentId: studentId,
      ),
    );
    return result
        .requireSuccess('/student/getLineChartData')
        .map((response) => response.toDomain());
  }

  /// Both answers of the Genel tab, asked in parallel, with the four boxes
  /// worked out ([AnalyticsSummary.compute]). If either call fails the
  /// failure is returned (the legacy screen showed nothing in that case).
  Future<AppResult<AnalyticsOverview>> getOverview({
    required NetExamType exam,
    AytField? field,
    String? lessonId,
    String? studentId,
  }) async {
    final answers = await (
      getTotal(
        exam: exam,
        field: field,
        lessonId: lessonId,
        studentId: studentId,
      ),
      getLineChartData(
        exam: exam,
        field: field,
        lessonId: lessonId,
        studentId: studentId,
      ),
    ).wait;
    return answers.$1.flatMap(
      (totals) => answers.$2.map(
        (series) => AnalyticsOverview(
          totals: totals,
          series: series,
          summary: AnalyticsSummary.compute(
            totals: totals,
            series: series,
            exam: exam,
            field: field,
            lessonScope: lessonId != null && lessonId.trim().isNotEmpty,
          ),
        ),
      ),
    );
  }
}
