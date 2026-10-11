import 'package:smap/features/cards/data/dtos/card_answers.dart';
import 'package:smap/features/cards/domain/card_totals.dart';
import 'package:smap/features/cards/domain/lesson_cards.dart';

extension InfoCardsInfoMapping on InfoCardsInfoResponse {
  CardTotals toDomain() => CardTotals({
    for (final lesson in infoData?.lessons ?? const <CardTallyDto>[])
      if (lesson.lessonId != null)
        lesson.lessonId!: LessonCardCounts(
          lessonId: lesson.lessonId!,
          missCount: lesson.missCount,
          trueCount: lesson.trueCount,
          favoriteCount: lesson.favoriteCount,
        ),
  });
}

/// The cards of a deck; an entry without an `item` object is left out (the
/// legacy screen skipped it too).
List<InfoCard> _cardsOf(List<CardEntryDto>? entries) => [
  for (final entry in entries ?? const <CardEntryDto>[])
    if (entry.item case final CardItemDto item)
      InfoCard(
        itemId: item.id,
        name: item.name,
        mainSubjectName: item.mainSubject?.name,
        descriptions: item.desc ?? const [],
        isFavorite: entry.favorite ?? false,
      ),
];

extension LessonInfoCardsMapping on LessonInfoCardsResponse {
  LessonCardDecks toDomain() => LessonCardDecks(
    missing: _cardsOf(data?.failedCards),
    known: _cardsOf(data?.successCards),
    favorites: _cardsOf(data?.favoriteCards),
  );
}
