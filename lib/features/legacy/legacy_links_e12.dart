import 'package:flutter/material.dart';

import 'package:smap/features/legacy/legacy_theme.dart';
import 'package:smap/features/my_card/presentation/screens/my_cards_page/my_card_lesson_detail_page/my_card_lesson_detail_page.dart';
import 'package:smap/repository/cards_repository.dart';

/// Opens the legacy card deck of an exam lesson ("Kartlarım" of Ders Detayı,
/// pano 7.2 → 8.1) until the new `CardDeckView` of E13 exists. The deck
/// opens on the root navigator, so it covers the shell and its bottom bar
/// like the legacy page's own header expects, and it goes away when E13
/// swaps this one call for its route.
///
/// [lessonId] is the backend lesson of the deck (`LessonIds.forTrack`), the
/// id `getLessonInfoCards` takes; [lessonName] is the title the legacy header
/// shows. Does nothing without a [navigator].
Future<void> openLegacyCardDeck(
  NavigatorState? navigator, {
  required String lessonId,
  required String lessonName,
}) async {
  if (navigator == null) return;
  await navigator.push<void>(
    MaterialPageRoute<void>(
      builder: (_) => LegacyTheme(
        child: MyCardLessonDetailPage(
          lessonId: lessonId,
          lessonName: lessonName,
          repository: CardsRepository(),
          lesson: null,
          onCountsChanged: null,
        ),
      ),
    ),
  );
}
