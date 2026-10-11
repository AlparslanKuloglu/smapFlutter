import 'package:smap/features/cards/domain/card_totals.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/domain/general_lesson.dart';

/// The general lesson the catalog lists under [name], as `getGeneralLessons`
/// would answer it.
GeneralLesson generalLesson(String name) {
  final spec = LessonCatalog.generalLessons.firstWhere(
    (lesson) => lesson.name == name,
  );
  return GeneralLesson(
    id: spec.id,
    name: spec.name,
    order: spec.order,
    ids: spec.ids,
    hasTrackChoice: spec.hasTrackChoice,
    isWebOnly: spec.isWebOnly,
    isLiterature: spec.isLiterature,
  );
}

LessonEntry entryOf(String name, {LessonMissing? missing}) =>
    LessonEntry(lesson: generalLesson(name), missing: missing);

/// The nine lessons with the missing counts of pano 7.1 and 7.2 (spec Ek C).
List<LessonEntry> pano71Entries() => [
  entryOf('Türkçe', missing: const LessonMissing(tyt: 28, ayt: 3)),
  entryOf('Tarih', missing: const LessonMissing(tyt: 60, sos2: 0)),
  entryOf('Coğrafya', missing: const LessonMissing(tyt: 44)),
  entryOf('Edebiyat', missing: const LessonMissing(ayt: 3)),
  entryOf('Matematik'),
  entryOf('Geometri'),
  entryOf('Fizik', missing: const LessonMissing(tyt: 7, ayt: 7)),
  entryOf('Kimya', missing: const LessonMissing(tyt: 9)),
  entryOf('Biyoloji', missing: const LessonMissing(tyt: 11)),
];

/// The deck counters of TYT Tarih in pano 7.1 (41 of 64 learned).
CardTotals tarihCards() => CardTotals({
  generalLesson('Tarih').ids.tyt!: LessonCardCounts(
    lessonId: generalLesson('Tarih').ids.tyt!,
    missCount: 23,
    trueCount: 41,
  ),
});
