import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/data/dtos/lesson_answers.dart';
import 'package:smap/features/lessons/data/mappers/lesson_mappers.dart';
import 'package:smap/features/lessons/domain/general_lesson.dart';
import 'package:smap/features/lessons/domain/main_subjects.dart';

import 'lesson_fixtures.dart';

void main() {
  group('general lessons', () {
    test('reads the six fields the legacy model reads', () {
      final response = GeneralLessonsResponse.fromBody(generalLessonsAnswer());

      expect(response.success, isNull, reason: 'the answer has no flag');
      final lessons = [for (final dto in response.lessons!) dto.toDomain()!];
      expect(lessons.map((l) => l.name), ['Tarih', 'Türkçe', 'Matematik']);
      expect(lessons[0].order, 2);
      expect(lessons[0].hasTrackChoice, isTrue);
      expect(lessons[0].imageFile, '/icons/historybook2.png');
      expect(lessons[2].order, 5, reason: 'order "5" reads as 5');
      expect(lessons[2].isWebOnly, isTrue);
      expect(lessons[1].hasTrackChoice, isFalse);
    });

    test('lesson ids and flags fall back to the catalog', () {
      final tarih = GeneralLessonsResponse.fromBody(
        generalLessonsAnswer(),
      ).lessons!.first.toDomain()!;

      expect(tarih.ids.tyt, '66214a6982ff212039ea3294');
      expect(tarih.ids.ayt, '66b0e7e5c99f8fc189ff35ff');
      expect(tarih.ids.sos2, '677ff5bb859149d419363f3d');
      expect(tarih.tracks, [
        LessonTrack.tyt,
        LessonTrack.ayt,
        LessonTrack.sos2,
      ]);
      expect(tarih.subject, SubjectKey.tarih);
    });

    test('ids the server sends win over the catalog', () {
      final lesson = GeneralLessonDto.fromJson({
        '_id': tarihId,
        'name': 'Tarih',
        'lessonTyt': 'new-tyt',
        'tytAyt': 0,
      }).toDomain()!;

      expect(lesson.ids.tyt, 'new-tyt');
      expect(lesson.ids.ayt, '66b0e7e5c99f8fc189ff35ff');
      expect(lesson.hasTrackChoice, isFalse, reason: 'the answer says 0');
    });

    test('an unknown lesson has no catalog and no tracks', () {
      final lesson = GeneralLessonDto.fromJson({
        '_id': 'x',
        'name': 'Felsefe',
      }).toDomain()!;

      expect(lesson.order, 0);
      expect(lesson.tracks, isEmpty);
      expect(lesson.ids.forTrack(LessonTrack.tyt), isNull);
      expect(lesson.subject, isNull);
    });

    test('entries without an id or a name are dropped', () {
      expect(GeneralLessonDto.fromJson({'name': 'x'}).toDomain(), isNull);
      expect(GeneralLessonDto.fromJson({'_id': 'x'}).toDomain(), isNull);
      expect(GeneralLessonDto.fromJson(const {}).toDomain(), isNull);
    });

    test('filter values follow the legacy dialog', () {
      final tarih = GeneralLessonsResponse.fromBody(
        generalLessonsAnswer(),
      ).lessons!.first.toDomain()!;
      final fizik = GeneralLessonDto.fromJson({
        '_id': LessonCatalog.generalLessons[6].id,
        'name': 'Fizik',
      }).toDomain()!;

      expect(tarih.filterValueFor(LessonTrack.tyt), 1);
      expect(tarih.filterValueFor(LessonTrack.ayt), 3);
      expect(tarih.filterValueFor(LessonTrack.sos2), 4);
      expect(fizik.filterValueFor(LessonTrack.ayt), 2);
      expect(GeneralLesson.allTracksFilter, 9);
    });
  });

  group('missing counts', () {
    test('reads the three tracks per lesson', () {
      final missing = LessonsMissingResponse.fromBody(
        lessonsMissingAnswer(),
      ).toDomain();

      expect(missing.of(tarihId), const LessonMissing(tyt: 3, ayt: 5, sos2: 0));
      expect(missing.of(tarihId)!.total, 8);
      expect(missing.of(turkceId), const LessonMissing(tyt: 12));
      expect(missing.of(turkceId)!.total, 12);
      expect(missing.of(turkceId)!.ayt, isNull, reason: 'not counted, unknown');
      expect(missing.of('other'), isNull);
    });

    test('an untouched lesson has no total', () {
      expect(const LessonMissing().total, isNull);
    });

    test('learning one lowers the track, never below zero', () {
      const missing = LessonMissing(tyt: 1, ayt: 0);

      expect(missing.withOneLearned(LessonTrack.tyt).tyt, 0);
      expect(missing.withOneLearned(LessonTrack.ayt), missing);
      expect(missing.withOneLearned(LessonTrack.sos2), missing);
    });

    test('odd shapes become empty or unknown', () {
      final missing = LessonsMissingResponse.fromBody({
        'success': true,
        'lessonObj': {
          'a': 'x',
          'b': {'1': 'many', '2': null},
          'c': {'1': 4},
        },
      }).toDomain();

      expect(missing.of('a'), const LessonMissing());
      expect(missing.of('b'), const LessonMissing());
      expect(missing.of('c'), const LessonMissing(tyt: 4));
      expect(
        LessonsMissingResponse.fromBody('<html>').toDomain(),
        const LessonsMissing.empty(),
      );
    });
  });

  group('main subjects', () {
    final subjects = MainSubjectsResponse.fromBody(
      mainSubjectsAnswer(),
    ).toDomain();

    test('reads subjects, filters and drops entries without an id', () {
      expect(subjects.subjects.map((s) => s.name), [
        'İslamiyet Öncesi Türk Tarihi',
        'Osmanlı Tarihi',
      ]);
      expect(subjects.subjects.first.order, 1);
      expect(subjects.subjects.last.order, 2);
      expect(
        subjects.subjects.first.imageUrl,
        'https://smaptr.com/subjectIcons/turk.png',
      );
      expect(subjects.subjects.first.imageColorHex, '#ffeed6');
      expect(subjects.subjects.last.imageUrl, isNull);
      expect(subjects.filters.map((f) => (f.name, f.value)), [
        ('TYT', 1),
        ('AYT', 3),
        ('SOS-2', 4),
      ]);
    });

    test('counts missing items like the legacy tab badge', () {
      expect(subjects.missing.totalFor(1), 4);
      expect(subjects.missing.totalFor(3), 2);
      expect(subjects.missing.totalFor(4), 0);
      expect(subjects.missing.totalFor(GeneralLesson.allTracksFilter), 6);
      expect(subjects.missing.totalFor(7), 0);
      expect(subjects.missing.forSubject('sub-1', 1), 3);
      expect(subjects.missing.forSubject('sub-1', 4), 0);
      expect(subjects.missing.forSubject('sub-1', 9), 5);
      expect(subjects.missing.forSubject('nope', 9), 0);
    });

    test('an empty answer is empty', () {
      final empty = MainSubjectsResponse.fromBody({'success': true}).toDomain();

      expect(empty.subjects, isEmpty);
      expect(empty.filters, isEmpty);
      expect(empty.missing, const MissingByType.empty());
      expect(empty.missing.totalFor(9), 0);
    });

    test('missing-by-type compares by value', () {
      expect(
        const MissingByType({
          1: {'a': 1},
        }),
        const MissingByType({
          1: {'a': 1},
        }),
      );
      expect(
        const MissingByType({
          1: {'a': 1},
        }),
        isNot(
          const MissingByType({
            1: {'a': 2},
          }),
        ),
      );
    });
  });
}
