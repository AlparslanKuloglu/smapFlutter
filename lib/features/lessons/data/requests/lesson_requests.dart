import 'package:smap/core/network/base_request.dart';
import 'package:smap/features/exams/data/api_support.dart';
import 'package:smap/features/lessons/data/dtos/lesson_answers.dart';

/// The lesson-content endpoints as typed requests, with the paths, verbs and
/// parameters of the legacy `AnalysisRepository` and `HomeRepository`. A coach
/// reading a student's data adds `studentId` to the query.
abstract final class LessonRequests {
  /// `GET /ajax/getGeneralLessons`.
  static BaseRequest<GeneralLessonsResponse> generalLessons() =>
      const BaseRequest<GeneralLessonsResponse>(
        method: HttpMethod.get,
        path: '/ajax/getGeneralLessons',
        decoder: GeneralLessonsResponse.fromBody,
      );

  /// `GET /student/getLessonsTotalMissing`.
  static BaseRequest<LessonsMissingResponse> lessonsTotalMissing({
    String? studentId,
  }) => BaseRequest<LessonsMissingResponse>(
    method: HttpMethod.get,
    path: '/student/getLessonsTotalMissing',
    query: compactQuery(const {}, studentId: studentId),
    decoder: LessonsMissingResponse.fromBody,
  );

  /// `GET /student/mainSubjects?lessonId=`.
  static BaseRequest<MainSubjectsResponse> mainSubjects({
    required String lessonId,
    String? studentId,
  }) => BaseRequest<MainSubjectsResponse>(
    method: HttpMethod.get,
    path: '/student/mainSubjects',
    query: compactQuery({'lessonId': lessonId}, studentId: studentId),
    decoder: MainSubjectsResponse.fromBody,
  );

  /// `GET /student/yazarEserMainSubjects`.
  static BaseRequest<YazarMainSubjectsResponse> yazarEserMainSubjects({
    String? studentId,
  }) => BaseRequest<YazarMainSubjectsResponse>(
    method: HttpMethod.get,
    path: '/student/yazarEserMainSubjects',
    query: compactQuery(const {}, studentId: studentId),
    decoder: YazarMainSubjectsResponse.fromBody,
  );

  /// `GET /student/getSubSubjects?mainSubjectId=`.
  static BaseRequest<SubSubjectsResponse> subSubjects({
    required String mainSubjectId,
    String? studentId,
  }) => BaseRequest<SubSubjectsResponse>(
    method: HttpMethod.get,
    path: '/student/getSubSubjects',
    query: compactQuery({'mainSubjectId': mainSubjectId}, studentId: studentId),
    decoder: SubSubjectsResponse.fromBody,
  );

  /// `POST /student/getItems?edebiyat=&yazarEserMode=&type=` with
  /// `{subjectIds, type}`. The legacy call sends `type` in the query and in
  /// the body; `edebiyat` and `yazarEserMode` (`"true"`) only for the
  /// Yazar & Eserler tab.
  static BaseRequest<ItemsResponse> items({
    required List<String> subjectIds,
    int? type,
    bool authorMode = false,
    String? studentId,
  }) => BaseRequest<ItemsResponse>(
    method: HttpMethod.post,
    path: '/student/getItems',
    query: compactQuery({
      'edebiyat': authorMode ? 'true' : null,
      'yazarEserMode': authorMode ? 'true' : null,
      'type': type,
    }, studentId: studentId),
    body: <String, Object?>{'subjectIds': subjectIds, 'type': type},
    decoder: ItemsResponse.fromBody,
  );

  /// `GET /student/getSubjectAuthors?itemId=`: the authors of an era.
  static BaseRequest<SubjectAuthorsResponse> subjectAuthors({
    required String itemId,
    String? studentId,
  }) => BaseRequest<SubjectAuthorsResponse>(
    method: HttpMethod.get,
    path: '/student/getSubjectAuthors',
    query: compactQuery({'itemId': itemId}, studentId: studentId),
    decoder: SubjectAuthorsResponse.fromBody,
  );

  /// `GET /student/learnedItem?itemId=`: marks a work or item learned (a
  /// write, so no `studentId`). There is no undo endpoint (spec §6.3 #24).
  static BaseRequest<SuccessResponse> learnedItem({required String itemId}) =>
      BaseRequest<SuccessResponse>(
        method: HttpMethod.get,
        path: '/student/learnedItem',
        query: compactQuery({'itemId': itemId}),
        decoder: SuccessResponse.fromBody,
      );
}
