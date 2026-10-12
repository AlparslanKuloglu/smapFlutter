import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';

/// Where Deneme Detay leads (flow 13.6): the ViewModel calls this, not a
/// router, so a test can record the calls.
abstract interface class ExamDetailNavigator {
  /// Soru Detay of question [questionOrder] (1-based) of the test
  /// [testIndex] (0-based), on the Analizlerim stack (pano 5.4 → 5.7). The
  /// result goes along so the screen needs no second request.
  Future<void> openQuestion({
    required ExamDetail exam,
    required int testIndex,
    required int questionOrder,
    StudentRef? student,
  });

  /// Konu Detayı of the main subject [topicId] of the general lesson
  /// [lessonId], in the Derslerim tab ("Bu Konuyu Çalış", pano 5.5 → 7.3).
  Future<void> openTopic({
    required String lessonId,
    required String topicId,
    LessonCat? cat,
  });

  /// Ders Detayı of the general lesson [lessonId], in the Derslerim tab: where
  /// "Bu Konuyu Çalış" goes when the topic is not found among the lesson's.
  Future<void> openLesson({required String lessonId, LessonCat? cat});

  /// The card deck of the exam ("Kartları Çalış", pano 5.6 → 8.1), on the
  /// lesson [backendLessonId] (the exam lesson's id, [lessonName] its title)
  /// when given.
  Future<void> openCardDeck({
    required String examId,
    String? backendLessonId,
    String? lessonName,
  });
}
