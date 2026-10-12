import 'package:flutter/foundation.dart';

import 'package:smap/features/cards/application/deck_card.dart';
import 'package:smap/features/cards/application/deck_group.dart';
import 'package:smap/features/cards/application/deck_library.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// The title block of the deck screen (pano 8.1: "Tarih Kartları"): the lesson
/// the deck was opened for, written by the view; `null` for a lesson outside
/// the catalog.
@immutable
class DeckHeaderData {
  const DeckHeaderData({this.lessonName, this.isExam = false});

  /// "Tarih".
  final String? lessonName;

  /// Opened from an exam ("Deneme Kartları").
  final bool isExam;

  @override
  bool operator ==(Object other) =>
      other is DeckHeaderData &&
      other.lessonName == lessonName &&
      other.isExam == isExam;

  @override
  int get hashCode => Object.hash(lessonName, isExam);
}

/// The segment under the title (pano 8.1 y=150): the group on and the three
/// counters. Drawn once the cards are known.
@immutable
class DeckSegmentData {
  const DeckSegmentData({
    required this.state,
    required this.group,
    required this.counts,
  });

  final SectionState state;
  final DeckGroup group;
  final DeckCounts counts;

  /// The segment is drawn: the library has cards.
  bool get visible => state == SectionState.ready;

  @override
  bool operator ==(Object other) =>
      other is DeckSegmentData &&
      other.state == state &&
      other.group == group &&
      other.counts == counts;

  @override
  int get hashCode => Object.hash(state, group, counts);
}

/// The session progress (pano 8.1 y=222): "12/23".
@immutable
class DeckProgressData {
  const DeckProgressData({required this.position, required this.total});

  static const DeckProgressData none = DeckProgressData(position: 0, total: 0);

  final int position;
  final int total;

  /// There is a card to count.
  bool get visible => position > 0 && total > 0;

  @override
  bool operator ==(Object other) =>
      other is DeckProgressData &&
      other.position == position &&
      other.total == total;

  @override
  int get hashCode => Object.hash(position, total);
}

/// Why the deck is empty (pano 8.1 kare 4 and "Boş metinler").
enum DeckEmptyKind {
  /// Eksiklerim with every card learned: the clay picture, "Bu derste eksik
  /// kartın kalmadı." and "Bildiklerime Geç".
  missingDone,

  /// Bildiklerim: "Henüz öğrendiğin kart yok."
  known,

  /// Favorilerim: "Favoriye eklediğin kart yok."
  favorite,

  /// No card in any group.
  noCards,
}

/// What the deck area draws: the skeleton, the error, an empty state, or the
/// cards with the buttons under them.
@immutable
class DeckStageData {
  const DeckStageData({
    required this.state,
    required this.group,
    this.front,
    this.next,
    this.behind = 0,
    this.canSwipe = false,
    this.empty,
    this.knownCount = 0,
    this.isExam = false,
  });

  /// `loading`, `error`/`offline`, `empty` (no card anywhere) or `ready`.
  final SectionState state;
  final DeckGroup group;

  /// The card on top; `null` when the group is empty.
  final DeckCard? front;

  /// The card right behind it.
  final DeckCard? next;

  /// How many cards are behind the top one, 0 to 2.
  final int behind;
  final bool canSwipe;

  /// Set when the group has no card.
  final DeckEmptyKind? empty;

  /// The size of Bildiklerim, for "Bildiklerim'deki 64 kartı...".
  final int knownCount;
  final bool isExam;

  @override
  bool operator ==(Object other) =>
      other is DeckStageData &&
      other.state == state &&
      other.group == group &&
      other.front == front &&
      other.next == next &&
      other.behind == behind &&
      other.canSwipe == canSwipe &&
      other.empty == empty &&
      other.knownCount == knownCount &&
      other.isExam == isExam;

  @override
  int get hashCode => Object.hash(
    state,
    group,
    front,
    next,
    behind,
    canSwipe,
    empty,
    knownCount,
    isExam,
  );
}
