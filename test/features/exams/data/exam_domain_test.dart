import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_card_counts.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/domain/exam_page.dart';
import 'package:smap/features/exams/domain/exam_scores.dart';
import 'package:smap/features/exams/domain/exam_summary.dart';
import 'package:smap/features/exams/domain/topic_result.dart';

void main() {
  group('ExamDefinition.imageUrl', () {
    const cdn = 'https://smaptr.com.tr';

    test('puts a file name under /uploads/', () {
      expect(
        const ExamDefinition(imageFile: 'a.png').imageUrl(cdn),
        'https://smaptr.com.tr/uploads/a.png',
      );
      expect(
        const ExamDefinition(imageFile: 'a.png').imageUrl('$cdn/'),
        'https://smaptr.com.tr/uploads/a.png',
      );
    });

    test('keeps a full URL', () {
      expect(
        const ExamDefinition(imageFile: 'https://x.test/c.png').imageUrl(cdn),
        'https://x.test/c.png',
      );
    });

    test('no cover is null', () {
      expect(const ExamDefinition().imageUrl(cdn), isNull);
      expect(const ExamDefinition(imageFile: '  ').imageUrl(cdn), isNull);
    });
  });

  group('ExamScores', () {
    const scores = ExamScores(
      points: [100.0, null, 200.0, 300.0, 400.0],
      ranks: [1, null, 2, 3],
    );

    test('slot 0 is TYT, an AYT field uses its aimType slot', () {
      expect(ExamScores.slotFor(NetExamType.tyt, AytField.verbal), 0);
      expect(ExamScores.slotFor(NetExamType.tyt, null), 0);
      expect(ExamScores.slotFor(NetExamType.ayt, AytField.equalWeight), 2);
      expect(ExamScores.slotFor(NetExamType.ayt, AytField.numeric), 3);
      expect(ExamScores.slotFor(NetExamType.ayt, AytField.verbal), 4);
      expect(ExamScores.slotFor(NetExamType.ayt, null), isNull);
    });

    test('reads what the arrays reach and nothing else', () {
      expect(scores.at(3).point, 300);
      expect(scores.at(3).rank, 3);
      expect(scores.at(4).point, 400);
      expect(scores.at(4).rank, isNull, reason: 'ranks stop at slot 3');
      expect(scores.at(9).isEmpty, isTrue);
      expect(scores.at(-1).isEmpty, isTrue);
      expect(scores.forExam(NetExamType.ayt, null), isNull);
      expect(scores.forExam(NetExamType.tyt, null)!.point, 100);
      expect(ExamScores.none.at(0).isEmpty, isTrue);
    });

    test('compares by value', () {
      expect(
        const ExamScores(points: [1.0], ranks: [2]),
        const ExamScores(points: [1.0], ranks: [2]),
      );
      expect(
        const ExamScores(points: [1.0]),
        isNot(const ExamScores(points: [2.0])),
      );
      expect(
        const ScoreEntry(point: 1, rank: 2),
        const ScoreEntry(point: 1, rank: 2),
      );
    });
  });

  group('ExamTestKind.at', () {
    test('TYT and AYT name their four tests', () {
      expect(
        [for (var i = 0; i < 4; i++) ExamTestKind.at(NetExamType.tyt, i)],
        [
          ExamTestKind.turkish,
          ExamTestKind.socialSciences,
          ExamTestKind.mathematics,
          ExamTestKind.sciences,
        ],
      );
      expect(
        [for (var i = 0; i < 4; i++) ExamTestKind.at(NetExamType.ayt, i)],
        [
          ExamTestKind.socialSciences1,
          ExamTestKind.socialSciences2,
          ExamTestKind.mathematics,
          ExamTestKind.sciences,
        ],
      );
      expect(ExamTestKind.at(NetExamType.tyt, 4), isNull);
      expect(ExamTestKind.at(NetExamType.tyt, -1), isNull);
    });
  });

  group('ExamListFilter', () {
    test('none is empty and equal to a default filter', () {
      expect(ExamListFilter.none.isEmpty, isTrue);
      expect(ExamListFilter.none, const ExamListFilter());
    });

    test('compares types as a set', () {
      expect(
        const ExamListFilter(types: {NetExamType.tyt, NetExamType.ayt}),
        const ExamListFilter(types: {NetExamType.ayt, NetExamType.tyt}),
      );
      expect(
        const ExamListFilter(types: {NetExamType.tyt}),
        isNot(const ExamListFilter(types: {NetExamType.ayt})),
      );
      expect(const ExamListFilter(dates: ['x']).isEmpty, isFalse);
    });
  });

  group('topic and card figures', () {
    test('a lesson adds up its topics', () {
      const lesson = LessonTopics(
        lessonName: 'Türkçe',
        topics: [
          TopicResult(
            name: 'a',
            counts: DybCounts(correct: 1, wrong: 2, blank: 3),
          ),
          TopicResult(
            name: 'b',
            counts: DybCounts(correct: 4, wrong: 5, blank: 6),
          ),
        ],
      );

      expect(lesson.counts, const DybCounts(correct: 5, wrong: 7, blank: 9));
      expect(const ExamTopicAnalysis([lesson]).isEmpty, isFalse);
      expect(const ExamTopicAnalysis([]).isEmpty, isTrue);
    });

    test('card tallies add cards, items and map items', () {
      const tally = LessonCardTally(
        lessonId: 'a',
        cards: 1,
        items: 2,
        mapItems: 3,
      );

      expect(tally.total, 6);
      expect(const ExamCardBreakdown([tally, tally]).total, 12);
      expect(const ExamCardCounts(byLesson: {'a': 2, 'b': 1}).total, 3);
    });
  });

  group('ExamDetail.scoreFor', () {
    test('needs the exam type', () {
      const summary = ExamSummary(id: 'r', definition: ExamDefinition());
      const detail = ExamDetail(summary: summary);

      expect(detail.scoreFor(AytField.numeric), isNull);
      expect(detail.id, 'r');
      expect(detail.kind, isNull);
    });
  });
}
