import 'package:flutter/material.dart';

import 'package:smap/features/cards/presentation/deck/card_deck_view.dart';

/// Opens the card deck of an exam lesson ("Kartlarım" of Ders Detayı, pano 7.2
/// → 8.1). The legacy card pages are gone; this opens the new `CardDeckView`
/// on the root navigator until the coordinator swaps this one call for the
/// `CardDeckRoute` in the Derslerim stack (`cardsTabRoutes`), where the bottom
/// bar stays. On the root navigator the deck covers the shell and its bar.
///
/// [lessonId] is the backend lesson of the deck (`LessonIds.forTrack`), the id
/// `getLessonInfoCards` takes; the deck writes the lesson's name itself, so
/// [lessonName] is not used. Does nothing without a [navigator].
Future<void> openLegacyCardDeck(
  NavigatorState? navigator, {
  required String lessonId,
  required String lessonName,
}) async {
  if (navigator == null) return;
  await navigator.push<void>(
    MaterialPageRoute<void>(builder: (_) => CardDeckView(lessonId: lessonId)),
  );
}
