import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/cards/domain/card_totals.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/lesson_rows.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/domain/general_lesson.dart';

import 'lesson_samples.dart';

void main() {
  group('TYT list (pano 7.1 kare 1)', () {
    late List<LessonRow> rows;

    setUp(() {
      rows = LessonRows.build(
        entries: pano71Entries(),
        examType: LessonsExamType.tyt,
        cards: tarihCards(),
      );
    });

    test('lists the TYT lessons in server order, without literature', () {
      expect(rows.map((row) => row.name), [
        'Türkçe',
        'Tarih',
        'Coğrafya',
        'Matematik',
        'Geometri',
        'Fizik',
        'Kimya',
        'Biyoloji',
      ]);
      expect(rows.every((row) => row.cat == LessonCat.tyt), isTrue);
      expect(rows.every((row) => row.nameKind == LessonRowName.server), isTrue);
    });

    test('carries the TYT missing counts', () {
      expect(rows.map((row) => row.missing), [
        28,
        60,
        44,
        null,
        null,
        7,
        9,
        11,
      ]);
    });

    test('marks Matematik and Geometri as web-only, without a count', () {
      final web = rows.where((row) => row.webOnly).toList();
      expect(web.map((row) => row.name), ['Matematik', 'Geometri']);
      expect(web.every((row) => row.missing == null), isTrue);
    });

    test('draws card progress only where the deck is known (Tarih 41/64)', () {
      expect(rows[1].cardsKnown, 41);
      expect(rows[1].cardsTotal, 64);
      expect(rows.where((row) => row.cardsTotal != null), hasLength(1));
    });

    test('takes the subject color of the lesson', () {
      expect(rows.first.subject, SubjectKey.turkce);
      expect(rows[1].subject, SubjectKey.tarih);
    });
  });

  group('AYT list (pano 7.1 kare 2)', () {
    late List<LessonRow> rows;

    setUp(() {
      rows = LessonRows.build(
        entries: pano71Entries(),
        examType: LessonsExamType.ayt,
      );
    });

    test('puts literature first, then splits Tarih and Coğrafya', () {
      expect(rows.map((row) => (row.name, row.nameKind, row.cat)), [
        ('Edebiyat', LessonRowName.literature, LessonCat.ayt),
        ('Tarih', LessonRowName.server, LessonCat.ayt),
        ('Tarih', LessonRowName.sos2, LessonCat.sos2),
        ('Coğrafya', LessonRowName.server, LessonCat.ayt),
        ('Coğrafya', LessonRowName.sos2, LessonCat.sos2),
        ('Matematik', LessonRowName.server, LessonCat.ayt),
        ('Geometri', LessonRowName.server, LessonCat.ayt),
        ('Fizik', LessonRowName.server, LessonCat.ayt),
        ('Kimya', LessonRowName.server, LessonCat.ayt),
        ('Biyoloji', LessonRowName.server, LessonCat.ayt),
      ]);
    });

    test('leaves Türkçe out: it has no AYT lesson of its own', () {
      expect(rows.where((row) => row.name == 'Türkçe'), isEmpty);
    });

    test('names the test of the Tarih and Coğrafya parts', () {
      expect(
        rows
            .where((row) => row.test != LessonRowTest.none)
            .map((row) => (row.name, row.nameKind, row.test)),
        [
          ('Tarih', LessonRowName.server, LessonRowTest.socialSciences1),
          ('Tarih', LessonRowName.sos2, LessonRowTest.socialSciences2),
          ('Coğrafya', LessonRowName.server, LessonRowTest.socialSciences1),
          ('Coğrafya', LessonRowName.sos2, LessonRowTest.socialSciences2),
        ],
      );
    });

    test('tags only what the server counted: no tag, a count, "eksik yok"', () {
      expect(rows.map((row) => row.missing), [
        3, // Edebiyat
        null, // Tarih AYT: not counted
        0, // Tarih-2: counted, nothing missing
        null,
        null,
        null, // Matematik: web
        null, // Geometri: web
        7,
        null,
        null,
      ]);
    });

    test('opens literature with its sections and the others on AYT/SOS-2', () {
      expect(rows.first.isLiterature, isTrue);
      expect(rows[2].cat, LessonCat.sos2);
      expect(rows[2].key, '${generalLesson('Tarih').id}:sos2');
    });
  });

  group('offline (karar 5.9)', () {
    test('hides the web-only lessons', () {
      final rows = LessonRows.build(
        entries: pano71Entries(),
        examType: LessonsExamType.tyt,
        online: false,
      );
      expect(rows.map((row) => row.name), [
        'Türkçe',
        'Tarih',
        'Coğrafya',
        'Fizik',
        'Kimya',
        'Biyoloji',
      ]);
    });
  });

  group('card progress', () {
    List<LessonRow> tyt(CardTotals cards) => LessonRows.build(
      entries: [entryOf('Tarih', missing: const LessonMissing(tyt: 60))],
      examType: LessonsExamType.tyt,
      cards: cards,
    );

    LessonRow withCounts({int? miss, int? known}) {
      final id = generalLesson('Tarih').ids.tyt!;
      return tyt(
        CardTotals({
          id: LessonCardCounts(lessonId: id, missCount: miss, trueCount: known),
        }),
      ).single;
    }

    test('needs both counters', () {
      expect(withCounts(miss: 23).cardsTotal, isNull);
      expect(withCounts(known: 41).cardsTotal, isNull);
    });

    test('is not drawn for an empty deck', () {
      expect(withCounts(miss: 0, known: 0).cardsTotal, isNull);
    });

    test('is not drawn without any card data', () {
      expect(tyt(const CardTotals.empty()).single.cardsKnown, isNull);
    });

    test('adds the missing and the learned cards up', () {
      final row = withCounts(miss: 1, known: 0);
      expect((row.cardsKnown, row.cardsTotal), (0, 1));
    });
  });

  group('LessonRow', () {
    test('is equal by value', () {
      final a = LessonRows.build(
        entries: pano71Entries(),
        examType: LessonsExamType.tyt,
      );
      final b = LessonRows.build(
        entries: pano71Entries(),
        examType: LessonsExamType.tyt,
      );
      expect(a, b);
      expect(a.first.hashCode, b.first.hashCode);
    });
  });
}
