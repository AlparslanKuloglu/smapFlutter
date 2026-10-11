import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/lesson_segments.dart';
import 'package:smap/features/lessons/domain/general_lesson.dart';
import 'package:smap/features/lessons/domain/main_subjects.dart';

import 'lesson_samples.dart';

void main() {
  group('LessonSegments.of', () {
    test('a lesson without tracks offers "Tümü" and the server filters', () {
      final segments = LessonSegments.of(
        generalLesson('Türkçe'),
        missing: const LessonMissing(tyt: 28, ayt: 3),
        filters: const [
          LessonTypeFilter(name: 'TYT', value: 1),
          LessonTypeFilter(name: 'AYT', value: 2),
        ],
      );

      expect(segments.map((s) => (s.value, s.cat, s.label, s.missing)), [
        (9, LessonCat.all, null, 31),
        (1, LessonCat.tyt, 'TYT', 28),
        (2, LessonCat.ayt, 'AYT', 3),
      ]);
    });

    test('a lesson with tracks offers its tracks, without "Tümü"', () {
      final segments = LessonSegments.of(
        generalLesson('Fizik'),
        missing: const LessonMissing(tyt: 7, ayt: 4),
      );

      expect(segments.map((s) => (s.value, s.cat, s.label, s.missing)), [
        (1, LessonCat.tyt, 'TYT', 7),
        (2, LessonCat.ayt, 'AYT', 4),
      ]);
    });

    test('Tarih and Coğrafya add SOS-2 and use the filter values 1, 3, 4', () {
      final segments = LessonSegments.of(
        generalLesson('Tarih'),
        missing: const LessonMissing(tyt: 60, sos2: 0),
      );

      expect(segments.map((s) => (s.value, s.label, s.missing)), [
        (1, 'TYT', 60),
        (3, 'AYT', null),
        (4, 'SOS-2', 0),
      ]);
    });

    test('a counter is absent when nobody counted: null, not zero', () {
      final segments = LessonSegments.of(
        generalLesson('Tarih'),
        missing: const LessonMissing(tyt: 60),
      );
      expect(segments[1].missing, isNull);
      expect(segments[2].missing, isNull);
    });

    test(
      'without the lesson counts it falls back to what mainSubjects says',
      () {
        final segments = LessonSegments.of(
          generalLesson('Türkçe'),
          filters: const [LessonTypeFilter(name: 'TYT', value: 1)],
          byType: const MissingByType({
            1: {'a': 2, 'b': 3},
          }),
        );
        expect(segments.map((s) => s.missing), [5, 5]);
      },
    );

    test('without any count there is no counter line', () {
      final segments = LessonSegments.of(
        generalLesson('Türkçe'),
        filters: const [LessonTypeFilter(name: 'TYT', value: 1)],
      );
      expect(segments.map((s) => s.missing), [null, null]);
    });

    test('maps a filter value to its category', () {
      expect(LessonCat.ofFilterValue(1), LessonCat.tyt);
      expect(LessonCat.ofFilterValue(2), LessonCat.ayt);
      expect(LessonCat.ofFilterValue(3), LessonCat.ayt);
      expect(LessonCat.ofFilterValue(4), LessonCat.sos2);
      expect(LessonCat.ofFilterValue(9), LessonCat.all);
    });
  });

  group('LessonSegments.pick', () {
    final tarih = LessonSegments.of(generalLesson('Tarih'));

    test('takes the requested category', () {
      expect(
        LessonSegments.pick(tarih, requested: LessonCat.sos2).cat,
        LessonCat.sos2,
      );
    });

    test('falls back to the device choice when the link names none', () {
      expect(
        LessonSegments.pick(tarih, fallback: LessonCat.ayt).cat,
        LessonCat.ayt,
      );
    });

    test('skips a category the lesson does not offer ("Tümü" on Tarih)', () {
      expect(
        LessonSegments.pick(
          tarih,
          requested: LessonCat.all,
          fallback: LessonCat.ayt,
        ).cat,
        LessonCat.ayt,
      );
    });

    test('ends on the first option', () {
      expect(LessonSegments.pick(tarih).cat, LessonCat.tyt);
    });
  });

  group('LessonSegments.backendLessonId', () {
    test('is the track lesson for a lesson with tracks', () {
      final tarih = generalLesson('Tarih');
      final segments = LessonSegments.of(tarih);
      expect(
        [for (final s in segments) LessonSegments.backendLessonId(tarih, s)],
        [tarih.ids.tyt, tarih.ids.ayt, tarih.ids.sos2],
      );
    });

    test('is the single lesson for a lesson without tracks', () {
      final turkce = generalLesson('Türkçe');
      final segments = LessonSegments.of(
        turkce,
        filters: const [LessonTypeFilter(name: 'TYT', value: 1)],
      );
      expect(
        {for (final s in segments) LessonSegments.backendLessonId(turkce, s)},
        {turkce.ids.single},
      );
    });
  });

  group('LessonTopicList', () {
    const subjects = [
      MainSubject(id: 's1', name: 'Sözcükte Anlam'),
      MainSubject(id: 's2', name: 'Cümlede Anlam'),
      MainSubject(id: 's3', name: 'Ses Bilgisi'),
      MainSubject(id: 's4', name: 'Yazım Kuralları'),
    ];
    const byType = MissingByType({
      1: {'s2': 2, 's4': 3},
      2: {'s2': 1},
    });

    test('numbers the topics 1 to n and counts under the segment', () {
      final topics = LessonTopicList.of(subjects, byType, 1);
      expect(topics.map((t) => (t.number, t.name, t.missing)), [
        (1, 'Sözcükte Anlam', 0),
        (2, 'Cümlede Anlam', 2),
        (3, 'Ses Bilgisi', 0),
        (4, 'Yazım Kuralları', 3),
      ]);
    });

    test('"Tümü" adds the types up', () {
      final topics = LessonTopicList.of(subjects, byType, 9);
      expect(topics.map((t) => t.missing), [0, 3, 0, 3]);
    });

    test('the server count of a subject wins', () {
      final topics = LessonTopicList.of(
        const [MainSubject(id: 'e1', name: 'Tanzimat', missingCount: 4)],
        const MissingByType.empty(),
        9,
      );
      expect(topics.single.missing, 4);
    });

    test(
      'the missing filter keeps the numbers of the full list (7.2 kare 2)',
      () {
        final topics = LessonTopicList.of(subjects, byType, 1);
        expect(
          LessonTopicList.onlyMissing(topics).map((t) => (t.number, t.name)),
          [(2, 'Cümlede Anlam'), (4, 'Yazım Kuralları')],
        );
      },
    );
  });
}
