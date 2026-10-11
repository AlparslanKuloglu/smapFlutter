import 'package:smap/core/network/base_request.dart';
import 'package:smap/features/cards/data/dtos/card_answers.dart';
import 'package:smap/features/exams/data/api_support.dart';
import 'package:smap/features/lessons/data/dtos/lesson_answers.dart';

/// The info-card endpoints as typed requests, with the legacy
/// `CardsRepository`'s paths, verbs and parameter names. All four are GET,
/// including the two writes (the backend takes them that way).
abstract final class CardRequests {
  /// `GET /student/getInfoCardsInfo`.
  static BaseRequest<InfoCardsInfoResponse> info({String? studentId}) =>
      BaseRequest<InfoCardsInfoResponse>(
        method: HttpMethod.get,
        path: '/student/getInfoCardsInfo',
        query: compactQuery(const {}, studentId: studentId),
        decoder: InfoCardsInfoResponse.fromBody,
      );

  /// `GET /student/getLessonInfoCards?lesson=`.
  static BaseRequest<LessonInfoCardsResponse> lessonCards({
    required String lessonId,
    String? studentId,
  }) => BaseRequest<LessonInfoCardsResponse>(
    method: HttpMethod.get,
    path: '/student/getLessonInfoCards',
    query: compactQuery({'lesson': lessonId}, studentId: studentId),
    decoder: LessonInfoCardsResponse.fromBody,
  );

  /// `GET /student/learnedCard?item=`.
  static BaseRequest<SuccessResponse> learned({required String itemId}) =>
      BaseRequest<SuccessResponse>(
        method: HttpMethod.get,
        path: '/student/learnedCard',
        query: compactQuery({'item': itemId}),
        decoder: SuccessResponse.fromBody,
      );

  /// `GET /student/addFavoriteMobil?item=`: the server flips the star.
  static BaseRequest<SuccessResponse> toggleFavorite({
    required String itemId,
  }) => BaseRequest<SuccessResponse>(
    method: HttpMethod.get,
    path: '/student/addFavoriteMobil',
    query: compactQuery({'item': itemId}),
    decoder: SuccessResponse.fromBody,
  );
}
