import 'package:flutter/foundation.dart' show immutable, mapEquals;

/// The three piles of one lesson's info cards (`getInfoCardsInfo`'s
/// `infoObj[lessonId]`; board 8.1): Eksiklerim, Bildiklerim, Favorilerim.
///
/// A count the server did not send is `null` (unknown), not 0. The lesson's
/// total number of cards is **not** in this answer (spec §6.3 #22: "Ders
/// başına öğrenilen/toplam": the field is not confirmed), so no total is
/// offered.
@immutable
class LessonCardCounts {
  const LessonCardCounts({
    required this.lessonId,
    this.missCount,
    this.trueCount,
    this.favoriteCount,
  });

  /// The exam lesson's id (`ExamLessonCatalog`), e.g. TYT Türkçe.
  final String lessonId;

  /// Cards still missing (Eksiklerim, `missCount`).
  final int? missCount;

  /// Cards learned (Bildiklerim, `trueCount`).
  final int? trueCount;

  /// Cards the student starred (Favorilerim, `favoriteCount`).
  final int? favoriteCount;

  @override
  bool operator ==(Object other) =>
      other is LessonCardCounts &&
      other.lessonId == lessonId &&
      other.missCount == missCount &&
      other.trueCount == trueCount &&
      other.favoriteCount == favoriteCount;

  @override
  int get hashCode =>
      Object.hash(lessonId, missCount, trueCount, favoriteCount);
}

/// [LessonCardCounts] for every lesson the answer lists.
@immutable
class CardTotals {
  const CardTotals(this.byLesson);

  const CardTotals.empty() : byLesson = const {};

  final Map<String, LessonCardCounts> byLesson;

  /// The counts of [lessonId]; `null` when the answer does not list it (a
  /// lesson without cards yet).
  LessonCardCounts? of(String lessonId) => byLesson[lessonId];

  /// Missing cards over all lessons the answer lists.
  int get totalMissing =>
      byLesson.values.fold(0, (sum, lesson) => sum + (lesson.missCount ?? 0));

  @override
  bool operator ==(Object other) =>
      other is CardTotals && mapEquals(other.byLesson, byLesson);

  @override
  int get hashCode =>
      Object.hashAll(byLesson.entries.map((e) => Object.hash(e.key, e.value)));
}
