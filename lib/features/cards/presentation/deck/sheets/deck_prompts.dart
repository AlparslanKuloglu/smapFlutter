import 'package:smap/features/cards/application/deck_card.dart';
import 'package:smap/features/lessons/application/item_text.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/features/lessons/presentation/topic_detail/sheets/card_sheet.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/sheets/app_confirm_sheet.dart';

/// The two questions the deck asks the student, as sheets (UI guide §6 rule 15:
/// the ViewModel never builds a sheet itself; tests give it a fake).
abstract interface class CardDeckPrompts {
  /// The one-time confirmation of "Öğrendim": "Kartı Bildiklerim'e taşıyalım
  /// mı?" with "Bir daha sorma" (pano 8.1 kare 2).
  Future<ConfirmResult> confirmLearn(String cardTitle);

  /// "Detay": the card sheet of [card] (pano 7.3 kare 3). Completes with the
  /// result of its "Öğrendim" (after the confirmation when [askConfirm]), or
  /// `null` when it was closed. [onFavorite] sends the sheet's star and
  /// answers whether it was saved.
  Future<CardSheetResult?> showDetail({
    required DeckCard card,
    required String? lessonName,
    required bool askConfirm,
    required Future<bool> Function(bool favorite) onFavorite,
  });
}

/// The real sheets: [AppConfirmSheet] and the lesson screens' [CardSheet].
///
/// A ViewModel has no `BuildContext`, so the sheets open on the root
/// navigator (`AppSheet.navigatorKey`); [l10n] gives the words of the
/// confirmation (the app is Turkish only, so they do not depend on a widget).
class SheetCardDeckPrompts implements CardDeckPrompts {
  const SheetCardDeckPrompts({required this.l10n});

  final AppLocalizations l10n;

  @override
  Future<ConfirmResult> confirmLearn(String cardTitle) => AppConfirmSheet.show(
    title: l10n.cardSheet_confirmTitle,
    message: l10n.cardSheet_confirmBody(cardTitle),
    confirmLabel: l10n.cardSheet_learned,
    dontAskAgainLabel: l10n.cardSheet_dontAsk,
  );

  @override
  Future<CardSheetResult?> showDetail({
    required DeckCard card,
    required String? lessonName,
    required bool askConfirm,
    required Future<bool> Function(bool favorite) onFavorite,
  }) {
    final topic = card.card.mainSubjectName;
    return CardSheet.show(
      item: itemOf(card),
      contextLine: (l) => switch ((lessonName, topic)) {
        (final lesson?, final topic?) => l.cardSheet_context(lesson, topic),
        (final lesson?, null) => lesson,
        (null, final topic?) => topic,
        (null, null) => '',
      },
      askConfirm: askConfirm,
      onFavorite: onFavorite,
    );
  }

  /// The sheet reads an [ItemView]; the deck card is one, learned with the
  /// item's own id (`learnedCard?item=`), which the sheet takes as the id of
  /// the record it may send.
  static ItemView itemOf(DeckCard card) => ItemView(
    key: card.key,
    number: 0,
    name: card.title,
    itemId: card.card.itemId,
    progressId: card.card.itemId,
    text: ItemTextParser.parse(card.card.descriptions),
    card: switch (card.status) {
      CardStatus.missing => ItemCardState.missing,
      CardStatus.known => ItemCardState.learned,
      CardStatus.unknown => ItemCardState.unknown,
    },
    isFavorite: card.isFavorite,
  );
}
