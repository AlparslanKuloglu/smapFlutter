import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/features/cards/application/deck_card.dart';
import 'package:smap/features/cards/application/deck_group.dart';
import 'package:smap/features/cards/domain/lesson_cards.dart';

/// The three counters of the segment (pano 8.1: "23 kart · 41 kart · 6 kart").
@immutable
class DeckCounts {
  const DeckCounts({this.missing = 0, this.known = 0, this.favorite = 0});

  final int missing;
  final int known;
  final int favorite;

  /// The counter of [group].
  int of(DeckGroup group) => switch (group) {
    DeckGroup.missing => missing,
    DeckGroup.known => known,
    DeckGroup.favorite => favorite,
  };

  /// No card in any group.
  bool get isEmpty => missing == 0 && known == 0 && favorite == 0;

  @override
  bool operator ==(Object other) =>
      other is DeckCounts &&
      other.missing == missing &&
      other.known == known &&
      other.favorite == favorite;

  @override
  int get hashCode => Object.hash(missing, known, favorite);
}

/// Every card the deck screen can show, with its place in the three decks
/// (`getLessonInfoCards`: failedCards, successCards, favoriteCards).
///
/// Immutable: learning, taking a card back and starring return a new library.
/// A card may be in Eksiklerim (or Bildiklerim) and in Favorilerim at once;
/// the counters read the groups, so they follow what the student does ("22 ·
/// 42 · 6" after one "Öğrendim", pano 8.1 kare 3).
@immutable
class DeckLibrary {
  const DeckLibrary._(this._cards, this._missing, this._known, this._favorite);

  /// A library without cards.
  const DeckLibrary.empty()
    : _cards = const {},
      _missing = const [],
      _known = const [],
      _favorite = const [];

  /// Builds the library from decks as the server sent them, each under the
  /// lesson [DeckSource.lessonId] it was read from.
  ///
  /// A card is told apart by its item id (a card without one by its place),
  /// so a card that is in Eksiklerim and in Favorilerim is one card. A card
  /// that came only in the favorites list has an unknown status. Cards with
  /// nothing to read are left out.
  factory DeckLibrary.fromSources(Iterable<DeckSource> sources) {
    final cards = <String, DeckCard>{};
    final missing = <String>[];
    final known = <String>[];
    final favorite = <String>[];
    var anonymous = 0;

    // The key of [card]: its item id, or a made-up one.
    String keyOf(InfoCard card) {
      final id = card.itemId;
      if (id != null && id.isNotEmpty) return id;
      anonymous++;
      return 'card-$anonymous';
    }

    // Adds [card] to [group] once; returns its key, `null` for an empty card.
    String? add(
      InfoCard card,
      String? lessonId,
      CardStatus status,
      List<String> group,
    ) {
      final key = keyOf(card);
      final made = DeckCard(
        key: key,
        card: card,
        lessonId: lessonId,
        status: status,
        isFavorite: card.isFavorite,
      );
      if (!made.hasContent) return null;
      final existing = cards[key];
      cards[key] = existing == null
          ? made
          : existing.copyWith(
              status: existing.status == CardStatus.unknown
                  ? status
                  : existing.status,
              isFavorite: existing.isFavorite || made.isFavorite,
            );
      if (!group.contains(key)) group.add(key);
      return key;
    }

    for (final source in sources) {
      for (final card in source.decks.missing) {
        add(card, source.lessonId, CardStatus.missing, missing);
      }
      for (final card in source.decks.known) {
        add(card, source.lessonId, CardStatus.known, known);
      }
    }
    // An entry of the favorites list is a star, whatever the other lists say;
    // a card that only that list knows has an unknown status.
    for (final source in sources) {
      for (final card in source.decks.favorites) {
        add(
          card.withFavorite(true),
          source.lessonId,
          CardStatus.unknown,
          favorite,
        );
      }
    }
    // A starred card that the favorites list did not repeat.
    for (final entry in cards.entries) {
      if (entry.value.isFavorite && !favorite.contains(entry.key)) {
        favorite.add(entry.key);
      }
    }
    return DeckLibrary._(cards, missing, known, favorite);
  }

  final Map<String, DeckCard> _cards;
  final List<String> _missing;
  final List<String> _known;
  final List<String> _favorite;

  /// The card [key]; `null` for an unknown key.
  DeckCard? cardOf(String key) => _cards[key];

  /// The keys of [group], in the order the deck shows them.
  List<String> keysOf(DeckGroup group) => switch (group) {
    DeckGroup.missing => _missing,
    DeckGroup.known => _known,
    DeckGroup.favorite => _favorite,
  };

  /// The cards of [group], in order.
  List<DeckCard> cardsOf(DeckGroup group) => [
    for (final key in keysOf(group)) ?_cards[key],
  ];

  DeckCounts get counts => DeckCounts(
    missing: _missing.length,
    known: _known.length,
    favorite: _favorite.length,
  );

  /// No card in any group.
  bool get isEmpty => _cards.isEmpty;

  /// Where [key] stands in Eksiklerim; `-1` when it is not there.
  int missingIndexOf(String key) => _missing.indexOf(key);

  /// "Öğrendim": the card moves from Eksiklerim to the front of Bildiklerim.
  DeckLibrary learned(String key) {
    final card = _cards[key];
    if (card == null || card.status != CardStatus.missing) return this;
    return DeckLibrary._(
      {..._cards, key: card.copyWith(status: CardStatus.known)},
      [..._missing]..remove(key),
      [key, ..._known],
      _favorite,
    );
  }

  /// "Geri Al": the card goes back to Eksiklerim at [index] (where it was).
  DeckLibrary unlearned(String key, {int? index}) {
    final card = _cards[key];
    if (card == null || card.status != CardStatus.known) return this;
    final missing = [..._missing];
    final at = (index ?? missing.length).clamp(0, missing.length);
    missing.insert(at, key);
    return DeckLibrary._(
      {..._cards, key: card.copyWith(status: CardStatus.missing)},
      missing,
      [..._known]..remove(key),
      _favorite,
    );
  }

  /// The star of [key] set to [value]; Favorilerim follows.
  DeckLibrary withFavorite(String key, {required bool value}) {
    final card = _cards[key];
    if (card == null || card.isFavorite == value) return this;
    return DeckLibrary._(
      {..._cards, key: card.copyWith(isFavorite: value)},
      _missing,
      _known,
      value ? [..._favorite, key] : ([..._favorite]..remove(key)),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DeckLibrary &&
      listEquals(other._missing, _missing) &&
      listEquals(other._known, _known) &&
      listEquals(other._favorite, _favorite) &&
      _sameCards(other._cards);

  bool _sameCards(Map<String, DeckCard> other) {
    if (other.length != _cards.length) return false;
    for (final entry in _cards.entries) {
      if (other[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(_missing),
    Object.hashAll(_known),
    Object.hashAll(_favorite),
    _cards.length,
  );
}

/// The decks of one lesson as `getLessonInfoCards` answered them.
@immutable
class DeckSource {
  const DeckSource({required this.decks, this.lessonId});

  /// The exam lesson the decks were read under; `null` when unknown.
  final String? lessonId;
  final LessonCardDecks decks;
}
