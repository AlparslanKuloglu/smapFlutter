import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/analytics/application/analytics_filter.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';

void main() {
  group('AnalyticsFilter', () {
    test('starts on all of TYT', () {
      expect(AnalyticsFilter.tyt.exam, NetExamType.tyt);
      expect(AnalyticsFilter.tyt.isGeneral, isTrue);
      expect(AnalyticsFilter.tyt.lessonId, isNull);
    });

    test('a TYT filter never keeps a field', () {
      final ayt = AnalyticsFilter.tyt.switchTo(
        NetExamType.ayt,
        field: AytField.numeric,
      );
      expect(ayt.field, AytField.numeric);
      expect(
        ayt.switchTo(NetExamType.tyt, field: AytField.numeric).field,
        isNull,
      );
    });

    test('changing the exam or the field drops the lesson', () {
      final lesson = ExamLessonCatalog.of(NetExamType.ayt).first;
      final withLesson = const AnalyticsFilter(
        exam: NetExamType.ayt,
        field: AytField.verbal,
      ).withLesson(lesson);
      expect(withLesson.lessonId, lesson.id);
      expect(
        withLesson.switchTo(NetExamType.ayt, field: AytField.numeric).lesson,
        isNull,
      );
    });

    test('equality follows exam, field and lesson id', () {
      final lesson = ExamLessonCatalog.of(NetExamType.tyt).first;
      expect(
        AnalyticsFilter.tyt.withLesson(lesson),
        AnalyticsFilter.tyt.withLesson(ExamLessonCatalog.byId(lesson.id)),
      );
      expect(
        AnalyticsFilter.tyt.withLesson(lesson),
        isNot(AnalyticsFilter.tyt),
      );
      expect(
        AnalyticsFilter.tyt.withLesson(lesson).hashCode,
        AnalyticsFilter.tyt.withLesson(lesson).hashCode,
      );
    });
  });

  group('AnalyticsLessons', () {
    List<String> names(NetExamType exam, AytField? field) => [
      for (final lesson in AnalyticsLessons.of(exam, field))
        AnalyticsLessons.shortName(lesson),
    ];

    test('TYT lists its eight lessons', () {
      expect(names(NetExamType.tyt, null), [
        'Türkçe',
        'Tarih',
        'Coğrafya',
        'Matematik',
        'Geometri',
        'Fizik',
        'Kimya',
        'Biyoloji',
      ]);
    });

    test('Eşit Ağırlık lists Matematik too (pano 6.1 kare 3)', () {
      expect(names(NetExamType.ayt, AytField.equalWeight), [
        'Türk Dili ve Edebiyatı',
        'Tarih',
        'Coğrafya',
        'Matematik',
      ]);
    });

    test('Sayısal and Sözel list their own lessons', () {
      expect(names(NetExamType.ayt, AytField.numeric), [
        'Matematik',
        'Geometri',
        'Fizik',
        'Kimya',
        'Biyoloji',
      ]);
      expect(names(NetExamType.ayt, AytField.verbal), [
        'Türk Dili ve Edebiyatı',
        'Tarih',
        'Coğrafya',
        'Tarih-2',
        'Coğrafya-2',
      ]);
    });

    test('an unknown AYT field lists every AYT lesson', () {
      expect(AnalyticsLessons.of(NetExamType.ayt, null), hasLength(10));
    });
  });
}
