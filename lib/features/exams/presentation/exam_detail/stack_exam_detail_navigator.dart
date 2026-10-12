import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/presentation/exam_detail/exam_detail_navigator.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/presentation/lessons_navigator.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';

/// An [ExamDetailNavigator] on the router of the page that owns the
/// ViewModel (pano 1.19 "sekme başına yığın"): Soru Detay is pushed on the
/// Analizlerim stack so the bottom bar stays and Back walks it; the lesson
/// screens open in the Derslerim tab (`navigate` switches the tab and puts
/// the screens on that tab's stack, as the home screen does).
class StackExamDetailNavigator implements ExamDetailNavigator {
  const StackExamDetailNavigator(this._router);

  final StackRouter _router;

  @override
  Future<void> openQuestion({
    required ExamDetail exam,
    required int testIndex,
    required int questionOrder,
    StudentRef? student,
  }) => _router.push(
    QuestionDetailRoute(
      examId: exam.id,
      lesson: testIndex,
      q: questionOrder,
      exam: exam,
      student: student,
    ),
  );

  @override
  Future<void> openTopic({
    required String lessonId,
    required String topicId,
    LessonCat? cat,
  }) => _router.navigate(
    LessonsTabRoute(
      children: [
        const LessonsRoute(),
        TopicDetailRoute(
          lessonId: lessonId,
          topicId: topicId,
          cat: cat?.key,
          focus: TopicFocus.firstMissing,
        ),
      ],
    ),
  );

  @override
  Future<void> openLesson({required String lessonId, LessonCat? cat}) =>
      _router.navigate(
        LessonsTabRoute(
          children: [
            const LessonsRoute(),
            LessonDetailRoute(lessonId: lessonId, cat: cat?.key),
          ],
        ),
      );

  @override
  Future<void> openCardDeck({
    required String examId,
    String? backendLessonId,
    String? lessonName,
  }) => _router.navigate(
    LessonsTabRoute(
      children: [
        const LessonsRoute(),
        CardDeckRoute(lessonId: backendLessonId, examId: examId),
      ],
    ),
  );
}
