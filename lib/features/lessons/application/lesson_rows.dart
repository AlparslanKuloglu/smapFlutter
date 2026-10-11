import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/cards/domain/card_totals.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';

/// How the name of a row is written (the words are the view's).
enum LessonRowName {
  /// The lesson's own name ("Türkçe", "Tarih").
  server,

  /// "Türk Dili ve Edebiyatı" for the literature lesson.
  literature,

  /// "Tarih-2": the SOS-2 part of a lesson.
  sos2,
}

/// The test line under a row (pano 7.1 kare 2).
enum LessonRowTest {
  /// No line.
  none,

  /// "Türk Dili ve Edebiyatı–Sosyal Bilimler 1 testi": the AYT part of Tarih
  /// and Coğrafya.
  socialSciences1,

  /// "Sosyal Bilimler 2 testi": the SOS-2 part of Tarih and Coğrafya.
  socialSciences2,
}

/// One row of the Derslerim list (C20 `SubjectRow`; pano 7.1, 7.5): a lesson
/// as it is listed under TYT or AYT, with what the row says about it.
///
/// The words are not here: a row names how its name and test line are written
/// ([nameKind], [test]) and the view turns them into text.
@immutable
class LessonRow {
  const LessonRow({
    required this.key,
    required this.lessonId,
    required this.name,
    required this.nameKind,
    required this.cat,
    this.subject,
    this.test = LessonRowTest.none,
    this.missing,
    this.webOnly = false,
    this.isLiterature = false,
    this.cardsKnown,
    this.cardsTotal,
  });

  /// Identifies the row in its list.
  final String key;

  /// The general lesson's id: what `LessonDetailView` takes.
  final String lessonId;

  /// The lesson's own name.
  final String name;
  final LessonRowName nameKind;

  /// The category the lesson opens on from this row.
  final LessonCat cat;

  /// The subject color; `null` draws a neutral tile.
  final SubjectKey? subject;
  final LessonRowTest test;

  /// Missing items under this row's track; `null` when the server has not
  /// counted it (no tag), zero is "eksik yok".
  final int? missing;

  /// The lesson opens on the web: the "Web'de" row and its sheet.
  final bool webOnly;

  /// The lesson is Türk Dili ve Edebiyatı: it opens with its sections.
  final bool isLiterature;

  /// Cards learned and the whole of the deck; both `null` without card data.
  final int? cardsKnown;
  final int? cardsTotal;

  @override
  bool operator ==(Object other) =>
      other is LessonRow &&
      other.key == key &&
      other.lessonId == lessonId &&
      other.name == name &&
      other.nameKind == nameKind &&
      other.cat == cat &&
      other.subject == subject &&
      other.test == test &&
      other.missing == missing &&
      other.webOnly == webOnly &&
      other.isLiterature == isLiterature &&
      other.cardsKnown == cardsKnown &&
      other.cardsTotal == cardsTotal;

  @override
  int get hashCode => Object.hash(
    key,
    lessonId,
    name,
    nameKind,
    cat,
    subject,
    test,
    missing,
    webOnly,
    isLiterature,
    cardsKnown,
    cardsTotal,
  );
}

/// Builds the rows of Derslerim (pano 7.1) from the lessons the session holds.
/// Pure and unit-tested.
///
/// - **TYT:** every lesson that has a TYT lesson, plus the lessons without
///   tracks that are not literature (Türkçe). Server order.
/// - **AYT:** Türk Dili ve Edebiyatı first, then the lessons that have an AYT
///   lesson, in server order. Tarih and Coğrafya give two rows, the AYT part
///   and the SOS-2 part ("Tarih-2"), each with its test line.
/// - A row's missing count is the one of its track (`getLessonsTotalMissing`);
///   an uncounted track has no tag. The card progress is `known / (missing +
///   known)` of the track's lesson (`getInfoCardsInfo`) and exists only when
///   both counts are known and the deck is not empty.
/// - While the device is offline the web-only lessons are left out (karar
///   5.9).
abstract final class LessonRows {
  static List<LessonRow> build({
    required List<LessonEntry> entries,
    required LessonsExamType examType,
    CardTotals cards = const CardTotals.empty(),
    bool online = true,
  }) {
    final rows = <LessonRow>[];
    for (final entry in entries) {
      final lesson = entry.lesson;
      if (lesson.isWebOnly && !online) continue;
      switch (examType) {
        case LessonsExamType.tyt:
          final lessonId = lesson.ids.tyt ?? lesson.ids.single;
          if (lessonId == null || lesson.isLiterature) continue;
          rows.add(
            _row(
              entry,
              nameKind: LessonRowName.server,
              cat: LessonCat.tyt,
              missing: entry.missingOf(LessonTrack.tyt),
              backendLessonId: lessonId,
              cards: cards,
            ),
          );
        case LessonsExamType.ayt:
          if (lesson.isLiterature) {
            rows.add(
              _row(
                entry,
                nameKind: LessonRowName.literature,
                cat: LessonCat.ayt,
                missing: entry.missingOf(LessonTrack.ayt) ?? entry.totalMissing,
                backendLessonId: lesson.ids.single,
                cards: cards,
              ),
            );
            continue;
          }
          final aytId = lesson.ids.ayt;
          if (aytId == null) continue;
          final split = lesson.ids.hasSos2;
          rows.add(
            _row(
              entry,
              nameKind: LessonRowName.server,
              cat: LessonCat.ayt,
              test: split ? LessonRowTest.socialSciences1 : LessonRowTest.none,
              missing: entry.missingOf(LessonTrack.ayt),
              backendLessonId: aytId,
              cards: cards,
            ),
          );
          if (split) {
            rows.add(
              _row(
                entry,
                nameKind: LessonRowName.sos2,
                cat: LessonCat.sos2,
                test: LessonRowTest.socialSciences2,
                missing: entry.missingOf(LessonTrack.sos2),
                backendLessonId: lesson.ids.sos2,
                cards: cards,
              ),
            );
          }
      }
    }
    if (examType == LessonsExamType.ayt) {
      // Literature heads the AYT list (pano 7.1 kare 2); the rest keep their
      // order.
      final literature = [
        for (final row in rows)
          if (row.isLiterature) row,
      ];
      final others = [
        for (final row in rows)
          if (!row.isLiterature) row,
      ];
      return [...literature, ...others];
    }
    return rows;
  }

  static LessonRow _row(
    LessonEntry entry, {
    required LessonRowName nameKind,
    required LessonCat cat,
    required int? missing,
    required String? backendLessonId,
    required CardTotals cards,
    LessonRowTest test = LessonRowTest.none,
  }) {
    final lesson = entry.lesson;
    final counts = backendLessonId == null ? null : cards.of(backendLessonId);
    final miss = counts?.missCount;
    final known = counts?.trueCount;
    final total = miss == null || known == null ? null : miss + known;
    final hasDeck = total != null && total > 0;
    return LessonRow(
      key: '${lesson.id}:${cat.key}',
      lessonId: lesson.id,
      name: lesson.name,
      nameKind: nameKind,
      cat: cat,
      subject: lesson.subject,
      test: test,
      missing: lesson.isWebOnly ? null : missing,
      webOnly: lesson.isWebOnly,
      isLiterature: lesson.isLiterature,
      cardsKnown: hasDeck ? known : null,
      cardsTotal: hasDeck ? total : null,
    );
  }
}
