import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/home/application/subject_strip.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/domain/general_lesson.dart';

/// The nine lessons of the catalog as the home strip gets them, with the
/// missing counts of the design's Ek C (pano 3.1: Tarih 60, Coğrafya 44,
/// Türkçe 31, Fizik 14, Biyoloji 11, Kimya 9, Edebiyat 3).
List<LessonEntry> _entries(Map<String, int?> missingByName) => [
  for (final spec in LessonCatalog.generalLessons)
    LessonEntry(
      lesson: GeneralLesson(
        id: spec.id,
        name: spec.name,
        order: spec.order,
        ids: spec.ids,
        hasTrackChoice: spec.hasTrackChoice,
        isWebOnly: spec.isWebOnly,
        isLiterature: spec.isLiterature,
      ),
      missing: missingByName[spec.name] == null
          ? null
          : LessonMissing(tyt: missingByName[spec.name]),
    ),
];

const _boardCounts = {
  'Tarih': 60,
  'Coğrafya': 44,
  'Türkçe': 31,
  'Fizik': 14,
  'Biyoloji': 11,
  'Kimya': 9,
  'Edebiyat': 3,
};

void main() {
  group('the strip of the board', () {
    late SubjectStrip strip;

    setUp(() => strip = SubjectStrip.of(_entries(_boardCounts)));

    test('starts with the lesson that misses the most, web lessons last', () {
      expect(strip.tiles.map((t) => t.name), [
        'Tarih',
        'Coğrafya',
        'Türkçe',
        'Fizik',
        'Biyoloji',
        'Kimya',
        'Edebiyat',
        'Matematik',
        'Geometri',
      ]);
    });

    test('carries the missing counts and the web flag', () {
      expect(strip.tiles.first.missing, 60);
      expect(strip.tiles.first.webOnly, isFalse);
      expect(strip.tiles[7].webOnly, isTrue);
      expect(strip.tiles[8].webOnly, isTrue);
      expect(strip.hasMissingData, isTrue);
    });

    test('carries the subject colors and the lesson ids', () {
      expect(strip.tiles.first.subject, SubjectKey.tarih);
      expect(strip.tiles[6].subject, SubjectKey.edebiyat);
      expect(strip.tiles.first.lessonId, '69d3ccc2fdfe9f2106fa471f');
    });
  });

  group('a student with no missing data (pano 3.1 kare 3)', () {
    test('has no missing data when no lesson was counted', () {
      final strip = SubjectStrip.of(_entries(const {}));

      expect(strip.hasMissingData, isFalse);
      expect(strip.tiles, hasLength(9));
      // The catalog order stays; web lessons still go last.
      expect(strip.tiles.map((t) => t.name).take(3), [
        'Türkçe',
        'Tarih',
        'Coğrafya',
      ]);
    });

    test('counts of zero are no data either', () {
      expect(
        SubjectStrip.of(_entries({'Tarih': 0, 'Türkçe': 0})).hasMissingData,
        isFalse,
      );
    });
  });

  test('web-only comes from the catalog even if the server says no', () {
    final entries = _entries(_boardCounts);
    final math = entries.firstWhere((e) => e.lesson.name == 'Matematik');
    final fixed = LessonEntry(
      lesson: GeneralLesson(
        id: math.lesson.id,
        name: math.lesson.name,
        order: math.lesson.order,
        ids: math.lesson.ids,
      ),
    );

    final strip = SubjectStrip.of([fixed]);

    expect(strip.tiles.single.webOnly, isTrue);
  });

  test('has value equality', () {
    expect(
      SubjectStrip.of(_entries(_boardCounts)),
      SubjectStrip.of(_entries(_boardCounts)),
    );
    expect(
      SubjectStrip.of(_entries(_boardCounts)),
      isNot(SubjectStrip.of(_entries({..._boardCounts, 'Tarih': 59}))),
    );
  });
}
