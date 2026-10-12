import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/analytics/application/analytics_filter.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';

/// What the deck writes about the lesson of a card: its name ("Tarih") and its
/// color. Read from the exam-lesson catalog by the backend lesson id the deck
/// was opened with.
abstract final class DeckLessons {
  /// The lesson without its exam prefix: "TYT Tarih" is "Tarih", "AYT Tarih-2"
  /// is "Tarih-2". `null` for an id outside the catalog.
  static String? nameOf(String? lessonId) {
    final lesson = ExamLessonCatalog.byId(lessonId);
    return lesson == null ? null : AnalyticsLessons.shortName(lesson);
  }

  /// The lesson's color key; `null` draws a neutral tile.
  static SubjectKey? subjectOf(String? lessonId) =>
      ExamLessonCatalog.byId(lessonId)?.subject;
}
