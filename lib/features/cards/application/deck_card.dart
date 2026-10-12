import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/features/cards/domain/lesson_cards.dart';

/// Where a card stands for the student.
enum CardStatus {
  /// In Eksiklerim: "Öğrendim" is offered and the card wears the "Eksik" tag.
  missing,

  /// In Bildiklerim.
  known,

  /// The card came only in the favorites list, so the server did not say
  /// whether it is learned. It is read and starred but wears no tag and has no
  /// "Öğrendim" ("Bilinmeyen kart durumu çizilmez", spec 7.3).
  unknown,
}

/// One card of the deck screen (C52 "StudyCard"; pano 8.1): an [InfoCard]
/// with the lesson it belongs to and what the student did with it this
/// session.
///
/// [lessonId] is the exam lesson the card was read under (`ExamLessonCatalog`
/// id); the card face writes the lesson's name and wears its color. The
/// [status] and the star are the live state: they change as the student
/// learns and stars, the rest is what the server sent.
@immutable
class DeckCard {
  const DeckCard({
    required this.key,
    required this.card,
    this.lessonId,
    this.status = CardStatus.unknown,
    this.isFavorite = false,
  });

  /// Identifies the card inside the deck: its item id, or a made-up key for a
  /// card without one.
  final String key;

  final InfoCard card;

  /// The exam lesson of the deck the card was read from.
  final String? lessonId;

  final CardStatus status;
  final bool isFavorite;

  /// The card's title (`item.name`), "Edirne-Segedin Antlaşması (1444)".
  String get title => (card.name ?? '').trim();

  /// The card text, one paragraph per line; empty when the card has none.
  String get body => [
    for (final paragraph in card.descriptions)
      if (paragraph.trim().isNotEmpty) paragraph.trim(),
  ].join('\n');

  /// "Öğrendim" can be sent: the card is missing and has an id.
  bool get canLearn => status == CardStatus.missing && card.canAct;

  /// The star can be pressed.
  bool get canFavorite => card.canAct;

  /// Whether there is anything to read (an empty card is left out).
  bool get hasContent => title.isNotEmpty || body.isNotEmpty;

  DeckCard copyWith({CardStatus? status, bool? isFavorite}) => DeckCard(
    key: key,
    card: card,
    lessonId: lessonId,
    status: status ?? this.status,
    isFavorite: isFavorite ?? this.isFavorite,
  );

  @override
  bool operator ==(Object other) =>
      other is DeckCard &&
      other.key == key &&
      other.card == card &&
      other.lessonId == lessonId &&
      other.status == status &&
      other.isFavorite == isFavorite;

  @override
  int get hashCode => Object.hash(key, card, lessonId, status, isFavorite);
}
