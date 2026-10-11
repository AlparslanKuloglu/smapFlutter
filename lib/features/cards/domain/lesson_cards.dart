import 'package:flutter/foundation.dart' show immutable, listEquals;

/// One info card (C52 `InfoCardFace`; boards 8.3 and 8.4): a short topic note
/// with the main subject it belongs to.
@immutable
class InfoCard {
  const InfoCard({
    this.itemId,
    this.name,
    this.mainSubjectName,
    this.descriptions = const [],
    this.isFavorite = false,
  });

  /// Id of the item (`item._id`): what learning and starring take. A card
  /// without one can be read but not acted on.
  final String? itemId;

  /// The card's title (`item.name`).
  final String? name;

  /// The main subject's name ("Osmanlı Tarihi"); `null` when the server did
  /// not populate it.
  final String? mainSubjectName;

  /// The card text, paragraph by paragraph (`item.desc`).
  final List<String> descriptions;

  /// The student starred it (`favorite == 1`).
  final bool isFavorite;

  /// The text as one block (the legacy screen joined paragraphs with a
  /// space).
  String get text => descriptions.join(' ');

  /// Learning and starring work.
  bool get canAct => itemId != null && itemId!.isNotEmpty;

  /// A copy with the star set to [value].
  InfoCard withFavorite(bool value) => InfoCard(
    itemId: itemId,
    name: name,
    mainSubjectName: mainSubjectName,
    descriptions: descriptions,
    isFavorite: value,
  );

  @override
  bool operator ==(Object other) =>
      other is InfoCard &&
      other.itemId == itemId &&
      other.name == name &&
      other.mainSubjectName == mainSubjectName &&
      other.isFavorite == isFavorite &&
      listEquals(other.descriptions, descriptions);

  @override
  int get hashCode => Object.hash(
    itemId,
    name,
    mainSubjectName,
    isFavorite,
    Object.hashAll(descriptions),
  );
}

/// The three decks of one lesson (`getLessonInfoCards`): Eksiklerim,
/// Bildiklerim and Favorilerim.
@immutable
class LessonCardDecks {
  const LessonCardDecks({
    this.missing = const [],
    this.known = const [],
    this.favorites = const [],
  });

  /// Eksiklerim (`failedCards`).
  final List<InfoCard> missing;

  /// Bildiklerim (`successCards`).
  final List<InfoCard> known;

  /// Favorilerim (`favoriteCards`).
  final List<InfoCard> favorites;

  bool get isEmpty => missing.isEmpty && known.isEmpty && favorites.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is LessonCardDecks &&
      listEquals(other.missing, missing) &&
      listEquals(other.known, known) &&
      listEquals(other.favorites, favorites);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(missing),
    Object.hashAll(known),
    Object.hashAll(favorites),
  );
}
