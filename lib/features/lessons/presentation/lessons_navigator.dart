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

  /// Dönem detayı of the era [eraId] of Yazar ve Eserler (pano 14.5 kare 2);
  /// [lessonId] is Türk Dili ve Edebiyatı.
  Future<void> openEra({required String lessonId, required String eraId});

  /// The card deck of an exam lesson ("Kartlarım"; E13's screen, today the
  /// legacy one).
  Future<void> openCardDeck({
    required String backendLessonId,
    required String lessonName,
  });
}

/// What Konu Detayı scrolls to on opening (spec §3.6 `focus=`).
abstract final class TopicFocus {
  /// The first item whose card is missing.
  static const String firstMissing = 'firstMissing';
}
