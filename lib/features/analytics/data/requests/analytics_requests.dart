import 'package:smap/core/network/base_request.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/analytics/data/dtos/analytics_answers.dart';
import 'package:smap/features/exams/data/api_support.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';

/// The Analizlerim endpoints as typed requests, with the legacy
/// `AnalysisRepository`'s parameter rules.
abstract final class AnalyticsRequests {
  /// A lesson id is a Mongo ObjectId (24 characters). The legacy repository
  /// dropped any `lesson` value of 12 characters or fewer: the filter
  /// panel's sentinels (`geneltyt`, `genelea`, ...) and the short AYT codes
  /// (`'2'`, `'7'`, `'10'`) never reached the server. Same rule here, so a
  /// caller passes `null` for "Genel".
  static const int _shortestLessonId = 13;

  /// `GET /student/getLineChartData?type=&lesson=&aimType=`.
  static BaseRequest<LineChartResponse> lineChart({
    required NetExamType exam,
    AytField? field,
    String? lessonId,
    String? studentId,
  }) => BaseRequest<LineChartResponse>(
    method: HttpMethod.get,
    path: '/student/getLineChartData',
    query: _query(exam, field, lessonId, studentId),
    decoder: LineChartResponse.fromBody,
  );

  /// `GET /student/getTotal?type=&lesson=&aimType=`.
  static BaseRequest<TotalResponse> total({
    required NetExamType exam,
    AytField? field,
    String? lessonId,
    String? studentId,
  }) => BaseRequest<TotalResponse>(
    method: HttpMethod.get,
    path: '/student/getTotal',
    query: _query(exam, field, lessonId, studentId),
    decoder: TotalResponse.fromBody,
  );

  /// `type` is the exam type as text (`'1'`, `'2'`). `aimType` is sent only
  /// for an AYT with a known field (never for TYT; the constant `aimType = 2`
  /// of the legacy screen is gone).
  static Map<String, dynamic>? _query(
    NetExamType exam,
    AytField? field,
    String? lessonId,
    String? studentId,
  ) {
    final lesson = lessonId?.trim();
    return compactQuery({
      'type': '${exam.wireType}',
      'lesson': lesson != null && lesson.length >= _shortestLessonId
          ? lesson
          : null,
      'aimType': exam == NetExamType.ayt ? field?.wireValue : null,
    }, studentId: studentId);
  }
}
