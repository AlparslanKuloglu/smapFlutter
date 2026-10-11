import 'package:flutter/foundation.dart'
    show immutable, listEquals, mapEquals, setEquals;

/// The info cards an exam earned, per lesson (`getTotalInfoCard`): the "Toplam
/// N bilgi kartı kazandın" line of the result moment (board 5.1).
@immutable
class ExamCardCounts {
  const ExamCardCounts({this.byLesson = const {}, this.itemIds = const {}});

  /// Cards per lesson id (a catalog lesson id), in the order the server first
  /// named them.
  final Map<String, int> byLesson;

  /// The item ids of the earned cards, for the entries that named their item;
  /// empty when the answer did not (whether it does is an open backend
  /// question). The card deck of an exam keeps these cards only.
  final Set<String> itemIds;

  /// All earned cards.
  int get total => byLesson.values.fold(0, (sum, count) => sum + count);

  @override
  bool operator ==(Object other) =>
      other is ExamCardCounts &&
      mapEquals(other.byLesson, byLesson) &&
      setEquals(other.itemIds, itemIds);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(byLesson.entries.map((e) => Object.hash(e.key, e.value))),
    Object.hashAllUnordered(itemIds),
  );
}

/// The card figures of one lesson of an exam (`getMexamItemDetail`): the
/// Bilgi Kartları tab (board 5.3).
@immutable
class LessonCardTally {
  const LessonCardTally({
    required this.lessonId,
    this.cards = 0,
    this.items = 0,
    this.mapItems = 0,
  });

  final String lessonId;

  /// `totalCards`.
  final int cards;

  /// `totalItems`.
  final int items;

  /// `totalMapItems` (concept-map items).
  final int mapItems;

  /// What the legacy screen showed per lesson: cards + items + map items.
  int get total => cards + items + mapItems;

  @override
  bool operator ==(Object other) =>
      other is LessonCardTally &&
      other.lessonId == lessonId &&
      other.cards == cards &&
      other.items == items &&
      other.mapItems == mapItems;

  @override
  int get hashCode => Object.hash(lessonId, cards, items, mapItems);
}

/// [LessonCardTally] for every lesson of an exam.
@immutable
class ExamCardBreakdown {
  const ExamCardBreakdown(this.lessons);

  final List<LessonCardTally> lessons;

  int get total => lessons.fold(0, (sum, lesson) => sum + lesson.total);

  @override
  bool operator ==(Object other) =>
      other is ExamCardBreakdown && listEquals(other.lessons, lessons);

  @override
  int get hashCode => Object.hashAll(lessons);
}
