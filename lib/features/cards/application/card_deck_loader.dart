import 'package:dartz/dartz.dart';

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/features/cards/application/deck_library.dart';
import 'package:smap/features/cards/data/card_repository.dart';
import 'package:smap/features/cards/domain/lesson_cards.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/exam_card_counts.dart';

/// Reads the cards the deck screen shows (pano 8.1; route
/// `/lessons/deck?lessonId=&examId=`).
///
/// - **A lesson** ("Kartlarım" of Ders Detayı, `lessonId`): the three decks of
///   that exam lesson, `getLessonInfoCards`.
/// - **An exam** ("Kartları Çalış" of Deneme Detay, `examId`): the cards the
///   exam earned. `getTotalInfoCard` lists them by lesson (and, when the entry
///   names it, by item); the decks of those lessons are read and cut down to
///   those items. With a `lessonId` too only that lesson's cards stay.
///
/// Every answer is an `Either`; nothing throws.
class CardDeckLoader {
  CardDeckLoader({
    required CardRepository cards,
    required ExamRepository exams,
    this.studentId,
  }) : _cards = cards,
       _exams = exams;

  final CardRepository _cards;
  final ExamRepository _exams;

  /// A coach reading a student's deck; the student's own deck when `null`.
  final String? studentId;

  /// The library for [lessonId] and/or [examId].
  Future<AppResult<DeckLibrary>> load({String? lessonId, String? examId}) {
    final exam = examId;
    if (exam != null && exam.isNotEmpty) {
      return _loadExam(examId: exam, lessonId: lessonId);
    }
    if (lessonId != null && lessonId.isNotEmpty) return _loadLesson(lessonId);
    return Future.value(
      const Left(
        AppException(
          code: AppErrorCode.notFound,
          message: 'The deck was opened without a lesson or an exam.',
        ),
      ),
    );
  }

  Future<AppResult<DeckLibrary>> _loadLesson(String lessonId) async {
    final decks = await _cards.getLessonDecks(
      lessonId: lessonId,
      studentId: studentId,
    );
    return decks.map(
      (value) => DeckLibrary.fromSources([
        DeckSource(lessonId: lessonId, decks: value),
      ]),
    );
  }

  Future<AppResult<DeckLibrary>> _loadExam({
    required String examId,
    String? lessonId,
  }) async {
    final earned = await _exams.getEarnedCardCounts(
      examId: examId,
      studentId: studentId,
    );
    final failure = earned.fold((e) => e, (_) => null);
    final counts = earned.fold<ExamCardCounts?>((_) => null, (c) => c);
    if (failure != null || counts == null) {
      return Left(failure ?? const AppException(code: AppErrorCode.unknown));
    }
    final lessons = [
      for (final id in counts.byLesson.keys)
        if (lessonId == null || lessonId.isEmpty || id == lessonId) id,
    ];
    if (lessons.isEmpty) return const Right(DeckLibrary.empty());
    if (counts.itemIds.isEmpty) {
      // The exam earned cards but the answer does not say which, so the exam's
      // cards cannot be told from the rest of the lesson: no deck rather than
      // a wrong one.
      return const Left(
        AppException(
          code: AppErrorCode.notFound,
          message: 'getTotalInfoCard did not name the earned items.',
        ),
      );
    }
    final answers = await Future.wait([
      for (final id in lessons)
        _cards.getLessonDecks(lessonId: id, studentId: studentId),
    ]);
    final sources = <DeckSource>[];
    for (final (index, answer) in answers.indexed) {
      final error = answer.fold((e) => e, (_) => null);
      if (error != null) return Left(error);
      final decks = answer.getOrElse(LessonCardDecks.new);
      sources.add(
        DeckSource(
          lessonId: lessons[index],
          decks: _only(decks, counts.itemIds),
        ),
      );
    }
    return Right(DeckLibrary.fromSources(sources));
  }

  /// [decks] cut down to the cards of the exam.
  static LessonCardDecks _only(LessonCardDecks decks, Set<String> items) {
    List<InfoCard> keep(List<InfoCard> cards) => [
      for (final card in cards)
        if (card.itemId != null && items.contains(card.itemId)) card,
    ];
    return LessonCardDecks(
      missing: keep(decks.missing),
      known: keep(decks.known),
      favorites: keep(decks.favorites),
    );
  }
}
