import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/features/legacy/legacy_links_e12.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/presentation/lessons_navigator.dart';

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
