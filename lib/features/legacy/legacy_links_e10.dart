import 'package:flutter/widgets.dart';

import 'package:smap/features/legacy/legacy_links_e12.dart';

/// Where Deneme Detay goes while the screen it links to is not built yet: the
/// card deck of an exam (E13's `CardDeckRoute({lessonId, examId, group})`).
///
/// One function, so E13's integration swaps one call and deletes this file.
/// Until then the legacy deck of a lesson opens on the root navigator (it
/// covers the shell and its bar, like the legacy page's header expects).
abstract final class LegacyLinksE10 {
  /// "Kartları Çalış" (pano 5.6 → 8.1) and a lesson row of the Kartlar tab.
  ///
  /// The legacy deck is per lesson, there is no deck of a whole exam: the
  /// deck of [backendLessonId] (the exam lesson's id `getMexamItemDetail`
  /// names, which `getLessonInfoCards` takes) opens, titled [lessonName]. The
  /// screen passes the first lesson of the exam that earned cards for the
  /// button of the whole exam; without a lesson nothing opens. [examId] is for
  /// E13's deck, which opens on the exam's own cards.
  static Future<void> openExamCardDeck(
    NavigatorState? navigator, {
    required String examId,
    String? backendLessonId,
    String? lessonName,
  }) async {
    final lessonId = backendLessonId;
    if (lessonId == null) return;
    await openLegacyCardDeck(
      navigator,
      lessonId: lessonId,
      lessonName: lessonName ?? '',
    );
  }
}
