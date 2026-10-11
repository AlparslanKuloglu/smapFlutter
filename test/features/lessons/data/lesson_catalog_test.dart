import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/subject_resolver.dart';

void main() {
  group('LessonCatalog', () {
    test('holds the nine lessons once each', () {
      const lessons = LessonCatalog.generalLessons;

      expect(lessons, hasLength(9));
      expect(lessons.map((l) => l.id).toSet(), hasLength(9));
      expect(lessons.map((l) => l.order), [1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(lessons.map((l) => l.subject).toSet(), hasLength(9));
    });

    test('every lesson resolves to its color key by name too', () {
      for (final lesson in LessonCatalog.generalLessons) {
        expect(SubjectResolver.fromLessonName(lesson.name), lesson.subject);
      }
    });

    test('flags follow the legacy table', () {
      final byName = {for (final l in LessonCatalog.generalLessons) l.name: l};

      expect(byName['Matematik']!.isWebOnly, isTrue);
      expect(byName['Geometri']!.isWebOnly, isTrue);
      expect(byName['Tarih']!.isWebOnly, isFalse);
      expect(byName['Edebiyat']!.isLiterature, isTrue);
      expect(byName['Türkçe']!.ids.single, isNotNull);
      expect(byName['Türkçe']!.hasTrackChoice, isFalse);
      for (final name in ['Tarih', 'Coğrafya', 'Fizik', 'Kimya', 'Biyoloji']) {
        expect(byName[name]!.hasTrackChoice, isTrue, reason: name);
      }
      expect(byName['Tarih']!.ids.hasSos2, isTrue);
      expect(byName['Coğrafya']!.ids.hasSos2, isTrue);
      expect(byName['Fizik']!.ids.hasSos2, isFalse);
    });

    test('ids per track', () {
      final tarih = LessonCatalog.generalLessons[1].ids;
      final turkce = LessonCatalog.generalLessons.first.ids;

      expect(tarih.forTrack(LessonTrack.tyt), '66214a6982ff212039ea3294');
      expect(tarih.forTrack(LessonTrack.sos2), '677ff5bb859149d419363f3d');
      expect(tarih.forTrack(null), isNull);
      expect(turkce.forTrack(null), '663e37a24fb443839593141b');
      expect(turkce.forTrack(LessonTrack.tyt), '663e37a24fb443839593141b');
    });

    test('byId finds or says null', () {
      expect(LessonCatalog.byId('69d3cd24fdfe9f2106fa4724')?.name, 'Fizik');
      expect(LessonCatalog.byId('nope'), isNull);
      expect(LessonCatalog.byId(null), isNull);
    });

    test('track stats keys', () {
      expect(LessonTrack.tyt.statsKey, '1');
      expect(LessonTrack.ayt.statsKey, '2');
      expect(LessonTrack.sos2.statsKey, '3');
    });
  });

  group('ExamLessonCatalog', () {
    test('every id is unique (the legacy table repeated two)', () {
      final ids = ExamLessonCatalog.all.map((l) => l.id);

      expect(ids.toSet(), hasLength(ids.length));
      expect(ids, hasLength(18));
    });

    test('AYT Matematik and Geometri carry their own ids', () {
      expect(
        ExamLessonCatalog.byId('665ca77316c299c4d7bd2534')?.name,
        'AYT Matematik',
      );
      expect(
        ExamLessonCatalog.byId('665cb46416c299c4d7bd2539')?.name,
        'AYT Geometri',
      );
      expect(
        ExamLessonCatalog.byId('663e387c4fb443839593141c')?.name,
        'TYT Matematik',
      );
    });

    test('lists lessons per exam type', () {
      expect(ExamLessonCatalog.of(NetExamType.tyt), hasLength(8));
      expect(ExamLessonCatalog.of(NetExamType.ayt), hasLength(10));
      expect(ExamLessonCatalog.byId('x'), isNull);
      expect(ExamLessonCatalog.byId(null), isNull);
    });

    test('lessons resolve to color keys', () {
      expect(
        ExamLessonCatalog.byId('66b0e776c99f8fc189ff35fd')?.subject,
        SubjectKey.edebiyat,
      );
      for (final lesson in ExamLessonCatalog.all) {
        expect(SubjectResolver.fromLessonName(lesson.name), lesson.subject);
      }
    });
  });

  group('AuthorWorkTypes', () {
    test('names the 33 types', () {
      expect(AuthorWorkTypes.names, hasLength(33));
      expect(AuthorWorkTypes.nameOf('2'), 'Roman');
      expect(AuthorWorkTypes.nameOf('33'), 'Mesnevi');
      expect(AuthorWorkTypes.nameOf('34'), isNull);
      expect(AuthorWorkTypes.nameOf(null), isNull);
    });
  });
}
