import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/exam_cards_model.dart';
import 'package:smap/features/exams/application/exam_question_layout.dart';
import 'package:smap/features/exams/domain/exam_card_counts.dart';

void main() {
  group('ExamCardsModel (pano 5.6)', () {
    test('groups follow the exam order and drop lessons without cards', () {
      final model = ExamCardsModel.of(
        const ExamCardBreakdown([
          LessonCardTally(lessonId: '66b0e7e5c99f8fc189ff35ff', cards: 2),
          LessonCardTally(lessonId: '66b0e776c99f8fc189ff35fd', cards: 20),
          LessonCardTally(lessonId: '66952a89986199d2903227b5'),
          LessonCardTally(
            lessonId: '66214a6982ff212039ea3294',
            cards: 1,
            items: 2,
            mapItems: 1,
          ),
        ]),
      );
      expect(model.total, 26);
      expect(
        [for (final g in model.groups) (g.name, g.count)],
        [('Tarih', 4), ('Türk Dili ve Edebiyatı', 20), ('Tarih', 2)],
      );
      expect(model.groups.first.backendLessonId, '66214a6982ff212039ea3294');
    });

    test('an unknown lesson id counts in the total but has no group', () {
      final model = ExamCardsModel.of(
        const ExamCardBreakdown([
          LessonCardTally(lessonId: 'zzz', cards: 3),
          LessonCardTally(lessonId: '66b0e7e5c99f8fc189ff35ff', cards: 2),
        ]),
      );
      expect(model.total, 5);
      expect(model.groups, hasLength(1));
    });

    test('no card at all is empty', () {
      expect(ExamCardsModel.of(const ExamCardBreakdown([])).isEmpty, isTrue);
    });
  });

  group('ExamQuestionLayout (pano 5.7 data note)', () {
    test(
      'AYT Sosyal Bilimler 1: 1–24 Edebiyat, 25–34 Tarih, 35–40 Coğrafya',
      () {
        String? name(int q) =>
            ExamQuestionLayout.lessonNameOf(NetExamType.ayt, 0, q);
        expect(name(1), 'Türk Dili ve Edebiyatı');
        expect(name(24), 'Türk Dili ve Edebiyatı');
        expect(name(25), 'Tarih');
        expect(name(34), 'Tarih');
        expect(name(35), 'Coğrafya');
        expect(name(40), 'Coğrafya');
        expect(name(41), isNull);
      },
    );

    test('AYT Sosyal Bilimler 2 includes the lessons the catalog lacks', () {
      final names = [
        for (final l in ExamQuestionLayout.lessonsOfTest(NetExamType.ayt, 1))
          (l.name, l.count),
      ];
      expect(names, [
        ('Tarih-2', 11),
        ('Coğrafya-2', 11),
        ('Felsefe Grubu', 12),
        ('Din Kültürü', 6),
      ]);
    });

    test('every test of both exams adds up to its question count', () {
      for (final (exam, sizes) in [
        (NetExamType.tyt, [40, 20, 40, 20]),
        (NetExamType.ayt, [40, 40, 40, 40]),
      ]) {
        for (final (i, size) in sizes.indexed) {
          final total = ExamQuestionLayout.lessonsOfTest(
            exam,
            i,
          ).fold(0, (sum, l) => sum + l.count);
          expect(total, size, reason: '${exam.label} test $i');
        }
      }
    });

    test('TYT: Temel Matematik is 30 Matematik then 10 Geometri', () {
      expect(
        ExamQuestionLayout.lessonNameOf(NetExamType.tyt, 2, 30),
        'Matematik',
      );
      expect(
        ExamQuestionLayout.lessonNameOf(NetExamType.tyt, 2, 31),
        'Geometri',
      );
    });

    test('a test past the fourth has no lessons', () {
      expect(ExamQuestionLayout.lessonsOfTest(NetExamType.tyt, 4), isEmpty);
    });
  });
}
