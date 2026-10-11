import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/features/legacy/legacy_links_e12.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';

/// Where the lesson screens lead (pano 13.8): the ViewModels call this, not a
/// router, so a test can record the calls.
abstract interface class LessonsNavigator {
  /// Ders Detayı of the general lesson [lessonId]; [cat] opens it on a
  /// segment ("Tarih-2 → Tarih detayı SOS-2 seçili", karar 5.8) and
  /// [section] on a section of the Edebiyat detail.
  Future<void> openLesson(
    String lessonId, {
    LessonCat? cat,
    LiteratureSection? section,
  });

  /// Konu Detayı of the main subject [topicId], on the first missing item.
  Future<void> openTopic({
    required String lessonId,
    required String topicId,
    LessonCat? cat,
  });

  /// The card deck of an exam lesson ("Kartlarım"; E13's screen, today the
  /// legacy one).
  Future<void> openCardDeck({
    required String backendLessonId,
    required String lessonName,
  });
}

/// A [LessonsNavigator] on the stack of the page that owns the ViewModel:
/// the lesson screens are pushed on the Derslerim tab's own stack, so the
/// bottom bar stays and Back walks it (pano 1.19 "sekme başına yığın").
class StackLessonsNavigator implements LessonsNavigator {
  const StackLessonsNavigator(this._router);

  final StackRouter _router;

  @override
  Future<void> openLesson(
    String lessonId, {
    LessonCat? cat,
    LiteratureSection? section,
  }) => _router.push(
    LessonDetailRoute(lessonId: lessonId, cat: cat?.key, section: section?.key),
  );

  @override
  Future<void> openTopic({
    required String lessonId,
    required String topicId,
    LessonCat? cat,
  }) => _router.push(
    TopicDetailRoute(
      lessonId: lessonId,
      topicId: topicId,
      cat: cat?.key,
      focus: TopicFocus.firstMissing,
    ),
  );

  @override
  Future<void> openCardDeck({
    required String backendLessonId,
    required String lessonName,
  }) => openLegacyCardDeck(
    _router.root.navigatorKey.currentState,
    lessonId: backendLessonId,
    lessonName: lessonName,
  );
}

/// What Konu Detayı scrolls to on opening (spec §3.6 `focus=`).
abstract final class TopicFocus {
  /// The first item whose card is missing.
  static const String firstMissing = 'firstMissing';
}
