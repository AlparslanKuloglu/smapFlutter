import 'package:dartz/dartz.dart';

import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/cards/data/mappers/card_mappers.dart';
import 'package:smap/features/cards/data/requests/card_requests.dart';
import 'package:smap/features/cards/domain/card_totals.dart';
import 'package:smap/features/cards/domain/lesson_cards.dart';
import 'package:smap/features/exams/data/api_support.dart';

/// Reads and changes the student's info cards. Replaces the legacy
/// `CardsRepository` (spec §6.3 #22, #24).
///
/// Every method answers `Either<AppException, T>` and never throws. The two
/// reads take an optional `studentId` for a coach looking at a student (sent
/// as the `studentId` query parameter; the legacy repository never sent it
/// for cards, so whether these endpoints honour it is an open question, spec
/// §6.3 #33). The writes are the student's own and take none.
///
/// **There is no undo.** The backend has no endpoint to un-learn a card or to
/// set the star explicitly, so "Geri Al" (spec §6.3 #24) cannot be built on
/// the server; the screen would have to delay the write itself.
class CardRepository {
  CardRepository(this._network);

  final NetworkService _network;

  /// `getInfoCardsInfo`: the three counters of every lesson (Kartlar tab,
  /// board 8.1).
  Future<AppResult<CardTotals>> getTotals({String? studentId}) async {
    final result = await _network.send(CardRequests.info(studentId: studentId));
    return result
        .requireSuccess('/student/getInfoCardsInfo')
        .map((response) => response.toDomain());
  }

  /// `getLessonInfoCards`: the three decks of the exam lesson [lessonId]
  /// (Eksiklerim, Bildiklerim, Favorilerim).
  Future<AppResult<LessonCardDecks>> getLessonDecks({
    required String lessonId,
    String? studentId,
  }) async {
    final result = await _network.send(
      CardRequests.lessonCards(lessonId: lessonId, studentId: studentId),
    );
    return result
        .requireSuccess('/student/getLessonInfoCards')
        .map((response) => response.toDomain());
  }

  /// `learnedCard`: moves the card [itemId] (`InfoCard.itemId`) from
  /// Eksiklerim to Bildiklerim ("Öğrendim").
  Future<AppResult<Unit>> markLearned({required String itemId}) async {
    final result = await _network.send(CardRequests.learned(itemId: itemId));
    return result.requireSuccess('/student/learnedCard').map((_) => unit);
  }

  /// `addFavoriteMobil`: flips the star of the card [itemId]. The endpoint is
  /// a toggle: calling it on a starred card un-stars it, so the caller keeps
  /// the card's current state and flips its own copy after a success.
  Future<AppResult<Unit>> toggleFavorite({required String itemId}) async {
    final result = await _network.send(
      CardRequests.toggleFavorite(itemId: itemId),
    );
    return result.requireSuccess('/student/addFavoriteMobil').map((_) => unit);
  }
}
