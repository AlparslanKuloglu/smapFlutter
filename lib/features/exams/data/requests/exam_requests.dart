import 'package:smap/core/network/base_request.dart';
import 'package:smap/features/exams/data/api_support.dart';
import 'package:smap/features/exams/data/dtos/exam_answers.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_page.dart';
import 'package:smap/features/exams/domain/exam_summary.dart';

/// The exam endpoints as typed requests. Paths, verbs and parameters follow
/// the legacy `AnalysisRepository`; a coach reading a student's data adds
/// `studentId` as a query parameter, as the legacy repository did on every
/// call.
abstract final class ExamRequests {
  /// Exams per page of the Denemelerim list (the legacy `perPage`).
  static const int pageSize = 8;

  /// `POST /student/getMyMockExams?page=&perPage=` with
  /// `{filter: {types, nets, dates}}`.
  static BaseRequest<MyMockExamsResponse> myMockExams({
    required int page,
    int perPage = pageSize,
    ExamListFilter filter = ExamListFilter.none,
    String? studentId,
  }) => BaseRequest<MyMockExamsResponse>(
    method: HttpMethod.post,
    path: '/student/getMyMockExams',
    query: compactQuery({
      'page': page,
      'perPage': perPage,
    }, studentId: studentId),
    body: <String, Object>{
      'filter': <String, List<String>>{
        'types': [for (final type in filter.types) '${type.wireType}'],
        'nets': filter.nets,
        'dates': filter.dates,
      },
    },
    decoder: MyMockExamsResponse.fromBody,
  );

  /// `GET /student/getMexamSubjectDetail?mexamId=`: the topic analysis.
  static BaseRequest<TopicAnalysisResponse> subjectDetail({
    required String mexamId,
    String? studentId,
  }) => BaseRequest<TopicAnalysisResponse>(
    method: HttpMethod.get,
    path: '/student/getMexamSubjectDetail',
    query: compactQuery({'mexamId': mexamId}, studentId: studentId),
    decoder: TopicAnalysisResponse.fromBody,
  );

  /// `GET /student/getMexamItemDetail?mexamId=`: card counts per lesson.
  static BaseRequest<ExamItemDetailResponse> itemDetail({
    required String mexamId,
    String? studentId,
  }) => BaseRequest<ExamItemDetailResponse>(
    method: HttpMethod.get,
    path: '/student/getMexamItemDetail',
    query: compactQuery({'mexamId': mexamId}, studentId: studentId),
    decoder: ExamItemDetailResponse.fromBody,
  );

  /// `POST /student/getQuestion` with `{mexam, questionOrder, lessonOrder}`.
  ///
  /// `mexam` is the exam object the result carried, posted back as it came
  /// (the legacy screen does the same); without the original object the
  /// known fields are sent.
  static BaseRequest<QuestionResponse> question({
    required ExamDefinition exam,
    required int questionOrder,
    required int lessonOrder,
    String? studentId,
  }) => BaseRequest<QuestionResponse>(
    method: HttpMethod.post,
    path: '/student/getQuestion',
    query: compactQuery(const {}, studentId: studentId),
    body: <String, Object?>{
      'mexam':
          exam.serverObject ??
          <String, Object?>{
            '_id': exam.id,
            'order': exam.order,
            'type': exam.kind?.wireType,
          },
      'questionOrder': questionOrder,
      'lessonOrder': lessonOrder,
    },
    decoder: QuestionResponse.fromBody,
  );

  /// `GET /student/getTotalInfoCard?mexamId=`: the cards an exam earned.
  static BaseRequest<TotalInfoCardResponse> totalInfoCard({
    required String mexamId,
    String? studentId,
  }) => BaseRequest<TotalInfoCardResponse>(
    method: HttpMethod.get,
    path: '/student/getTotalInfoCard',
    query: compactQuery({'mexamId': mexamId}, studentId: studentId),
    decoder: TotalInfoCardResponse.fromBody,
  );
}
