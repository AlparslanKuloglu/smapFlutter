import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/question_status.dart';
import 'package:smap/features/exams/data/dtos/exam_answers.dart';
import 'package:smap/features/exams/data/dtos/mock_exam_dto.dart';
import 'package:smap/features/exams/data/mappers/exam_mappers.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';

import 'exam_fixtures.dart';

void main() {
  group('MockExamDto', () {
    test('reads a TYT result as the list answers it', () {
      final dto = MockExamDto.fromJson(tytResultJson());

      expect(dto.id, 'res-1');
      expect(dto.itemName, 'TYT Genel Deneme 9');
      expect(dto.publisherName, 'Smap Yayınları');
      expect(dto.net, 74.75);
      expect(dto.correct, 80);
      expect(dto.wrong, 21);
      expect(dto.pass, 19);
      expect(dto.mexam?.order, 9);
      expect(dto.mexam?.type, 1);
      expect(dto.mexam?.image, 'cover9.png');
      expect(dto.date, isNotNull);
      expect(dto.isStarred, isFalse);
    });

    test('reads loose number formats', () {
      final dto = MockExamDto.fromJson(tytResultJson(net: '67,5'));

      expect(dto.net, 67.5);
      expect(dto.points, [412.63, null, null, null, null]);
      expect(dto.ranks, [48215, null, null, null, null]);
      expect(dto.pointsHam, [380.5, null, null, null, null]);
      expect(dto.ranksHam, [51000, null, null, null, null]);
    });

    test('decodes the two JSON strings and keeps test positions', () {
      final dto = MockExamDto.fromJson(tytResultJson());

      expect(dto.lessonInfo, hasLength(4));
      expect(dto.lessonInfo![2].correct, 20);
      expect(dto.lessonInfo![2].pass, 10);
      expect(dto.questionGroups, hasLength(4));
      expect(dto.questionGroups![0].cells, hasLength(3));
      expect(dto.questionGroups![2].cells, isEmpty);
    });

    test('keeps the exam object as the server sent it', () {
      final dto = MockExamDto.fromJson(tytResultJson());

      expect(dto.mexam?.raw, containsPair('questionCount', 120));
      expect(dto.mexam?.raw, containsPair('_id', 'exam-9'));
    });

    test('reads both spellings of the lesson list', () {
      final tyt = MockExamDto.fromJson(tytResultJson());
      final ayt = MockExamDto.fromJson(aytResultJson());

      expect(tyt.lessonResults, hasLength(2));
      expect(tyt.lessonResults!.first.lesson, '663e37a24fb443839593141b');
      expect(ayt.lessonResults, hasLength(1));
      expect(ayt.lessonResults!.single.lesson, 'ayt-mat');
    });

    test('an empty object is an empty result', () {
      final dto = MockExamDto.fromJson(const {});

      expect(dto.id, isNull);
      expect(dto.net, isNull);
      expect(dto.points, isNull);
      expect(dto.lessonInfo, isNull);
      expect(dto.questionGroups, isNull);
      expect(dto.toDetail(), isNull, reason: 'no id, nothing to open');
    });

    test('broken fields become null instead of failing the result', () {
      final dto = MockExamDto.fromJson({
        '_id': 77,
        'itemName': {'oops': 1},
        'net': 'abc',
        'true': 'x',
        'wrong': [],
        'mexam': 'not an object',
        'points': 'nope',
        'ranks': {'a': 1},
        'aytNets': ['x'],
        'lessonmockexams': 'x',
        'lessonInfo': 'not json',
        'questionsArrStr': '{"a":1}',
        'date': 'yesterday',
        'isStarred': 'maybe',
      });

      expect(dto.id, '77');
      expect(dto.itemName, isNull);
      expect(dto.net, isNull);
      expect(dto.correct, isNull);
      expect(dto.wrong, isNull);
      expect(dto.mexam, isNull);
      expect(dto.points, isNull);
      expect(dto.ranks, isNull);
      expect(dto.aytNets, isNull);
      expect(dto.lessonResults, isNull);
      expect(dto.lessonInfo, isNull);
      expect(dto.questionGroups, isNull);
      expect(dto.date, isNull);
      expect(dto.isStarred, isNull);
    });

    test('odd elements inside the arrays are skipped or blanked', () {
      final dto = MockExamDto.fromJson({
        '_id': 'r',
        'points': ['x', 3, null, '5,5'],
        'ranks': ['1.000', 'abc', 7.0, null],
        'lessonmockexams': [
          'junk',
          {'lesson': 'a', 'true': 1},
          42,
        ],
        'lessonInfo': '[{"true":1,"wrong":0,"pass":0}, 5, {"true":2}]',
        'questionsArrStr': '[[{"order":1,"type":1}, "x"], "y", [{"order":2}]]',
      });

      expect(dto.points, [null, 3.0, null, 5.5]);
      expect(dto.ranks, [1000, null, 7, null]);
      expect(dto.lessonResults, hasLength(1));
      expect(dto.lessonInfo, hasLength(3));
      expect(dto.lessonInfo![1].correct, isNull);
      expect(dto.questionGroups, hasLength(3));
      expect(dto.questionGroups![0].cells, hasLength(1));
      expect(dto.questionGroups![1].cells, isEmpty);
      expect(dto.questionGroups![2].cells!.single.type, isNull);
    });
  });

  group('MockExamDto to domain', () {
    test('maps the list row', () {
      final summary = MockExamDto.fromJson(tytResultJson()).toSummary()!;

      expect(summary.id, 'res-1');
      expect(summary.name, 'TYT Genel Deneme 9');
      expect(summary.kind, NetExamType.tyt);
      expect(summary.definition.order, 9);
      expect(summary.net, 74.75);
      expect(
        summary.counts,
        const DybCounts(correct: 80, wrong: 21, blank: 19),
      );
      expect(summary.date, isNotNull);
      expect(
        summary.definition.imageUrl('https://smaptr.com.tr'),
        'https://smaptr.com.tr/uploads/cover9.png',
      );
    });

    test('D/Y/B is null unless all three counts came', () {
      final dto = MockExamDto.fromJson({'_id': 'r', 'true': 5, 'wrong': 1});

      expect(dto.toSummary()!.counts, isNull);
    });

    test('maps tests, outcomes and the per-test figures', () {
      final detail = MockExamDto.fromJson(tytResultJson()).toDetail()!;

      expect(detail.tests, hasLength(4));
      final turkish = detail.tests.first;
      expect(turkish.index, 0);
      expect(turkish.kind, ExamTestKind.turkish);
      expect(turkish.counts, const DybCounts(correct: 30, wrong: 6, blank: 4));
      expect(turkish.questions.map((q) => q.outcome), [
        QuestionOutcome.correct,
        QuestionOutcome.wrong,
        QuestionOutcome.blank,
      ]);
      expect(turkish.questions.map((q) => q.order), [1, 2, 3]);
      expect(turkish.questions.first.markedOption, isNull);
      expect(turkish.questions.first.correctOption, isNull);
      expect(
        turkish.questionCounts,
        const DybCounts(correct: 1, wrong: 1, blank: 1),
      );
      expect(detail.tests[2].questions, isEmpty);
      expect(detail.tests[2].kind, ExamTestKind.mathematics);
      expect(detail.tests[3].kind, ExamTestKind.sciences);
    });

    test('counts a test from its questions when lessonInfo is missing', () {
      final detail = MockExamDto.fromJson({
        '_id': 'r',
        'mexam': {'type': 2},
        'questionsArrStr': '[[{"order":5,"type":1},{"order":6,"type":3}]]',
      }).toDetail()!;

      expect(detail.tests.single.kind, ExamTestKind.socialSciences1);
      expect(
        detail.tests.single.counts,
        const DybCounts(correct: 1, wrong: 1, blank: 0),
      );
    });

    test('a question without an order takes its position', () {
      final detail = MockExamDto.fromJson({
        '_id': 'r',
        'questionsArrStr': '[[{"type":1},{"type":1}]]',
      }).toDetail()!;

      expect(detail.tests.single.questions.map((q) => q.order), [1, 2]);
    });

    test('maps the lesson results', () {
      final detail = MockExamDto.fromJson(tytResultJson()).toDetail()!;

      expect(detail.lessons, hasLength(2));
      expect(detail.lessons.first.lessonId, '663e37a24fb443839593141b');
      expect(detail.lessons.first.net, 28.5);
      expect(
        detail.lessons.first.counts,
        const DybCounts(correct: 30, wrong: 6, blank: 4),
      );
    });

    test('maps the AYT nets by field', () {
      final detail = MockExamDto.fromJson(aytResultJson()).toDetail()!;

      expect(detail.kind, NetExamType.ayt);
      expect(detail.aytNets.keys, [
        AytField.equalWeight,
        AytField.numeric,
        AytField.verbal,
      ]);
      expect(detail.aytNets[AytField.numeric]!.net, 50.5);
      expect(detail.aytNets[AytField.verbal]!.net, 40.0);
      expect(
        detail.aytNets[AytField.equalWeight]!.counts,
        const DybCounts(correct: 60, wrong: 20, blank: 80),
      );
    });

    test('reads the score of the slot that counts', () {
      final tyt = MockExamDto.fromJson(tytResultJson()).toDetail()!;
      final ayt = MockExamDto.fromJson(aytResultJson()).toDetail()!;

      final tytScore = tyt.scoreFor(null)!;
      expect(tytScore.point, 412.63);
      expect(tytScore.rank, 48215);
      expect(tytScore.pointHam, 380.5);
      expect(tytScore.rankHam, 51000);

      final numeric = ayt.scoreFor(AytField.numeric)!;
      expect(numeric.point, 395.1);
      expect(numeric.rank, 2345);
      expect(
        numeric.pointHam,
        isNull,
        reason: 'ham points not sent: not drawn',
      );

      expect(ayt.scoreFor(null), isNull, reason: 'AYT without a field');
      expect(ayt.scoreFor(AytField.verbal)!.rank, 3000);
    });

    test('a result without scores has an empty entry', () {
      final detail = MockExamDto.fromJson({
        '_id': 'r',
        'mexam': {'type': 1},
      }).toDetail()!;

      expect(detail.scoreFor(null)!.isEmpty, isTrue);
    });

    test('an exam of an unknown type has no kind and no score entry', () {
      final detail = MockExamDto.fromJson({
        '_id': 'r',
        'mexam': {'type': 9},
      }).toDetail()!;

      expect(detail.kind, isNull);
      expect(detail.scoreFor(AytField.numeric), isNull);
    });
  });

  group('answers', () {
    test('topic analysis keeps the server order and tolerates gaps', () {
      final response = TopicAnalysisResponse.fromBody(topicAnalysisAnswer());
      final analysis = response.toDomain();

      expect(analysis.lessons.map((l) => l.lessonName), ['Türkçe', 'Tarih']);
      final topics = analysis.lessons.first.topics;
      expect(topics.map((t) => t.name), ['Sözcükte Anlam', 'Paragraf']);
      expect(
        topics.first.counts,
        const DybCounts(correct: 3, wrong: 1, blank: 0),
      );
      expect(topics.first.netRate, 0.75);
      expect(topics.last.netRate, isNull);
      expect(
        analysis.lessons.last.topics.single.counts,
        const DybCounts(correct: 2, wrong: 0, blank: 1),
      );
      expect(
        analysis.lessons.first.counts,
        const DybCounts(correct: 8, wrong: 3, blank: 1),
      );
    });

    test('topic analysis survives odd shapes', () {
      final analysis = TopicAnalysisResponse.fromBody({
        'success': true,
        'data': {
          'Türkçe': 'not a map',
          'Fizik': {
            'Kuvvet': {'trueValue': 'x'},
            'Enerji': 5,
          },
        },
      }).toDomain();

      expect(analysis.lessons.map((l) => l.lessonName), ['Türkçe', 'Fizik']);
      expect(analysis.lessons.first.topics, isEmpty);
      expect(analysis.lessons.last.topics.map((t) => t.name), [
        'Kuvvet',
        'Enerji',
      ]);
      expect(
        analysis.lessons.last.topics.first.counts,
        const DybCounts(correct: 0, wrong: 0, blank: 0),
      );
      expect(analysis.isEmpty, isFalse);
    });

    test('a body that is not an object is an empty answer', () {
      expect(MyMockExamsResponse.fromBody(null).success, isNull);
      expect(MyMockExamsResponse.fromBody('<html></html>').exams, isNull);
      expect(TopicAnalysisResponse.fromBody([1]).toDomain().isEmpty, isTrue);
    });

    test('item detail reads the three counters', () {
      final breakdown = ExamItemDetailResponse.fromBody({
        'success': true,
        'data': {
          'lesson-a': {'totalCards': 3, 'totalItems': '2', 'totalMapItems': 1},
          'lesson-b': {'totalCards': 1},
          'lesson-c': 'x',
        },
      }).toDomain();

      expect(breakdown.lessons, hasLength(3));
      expect(breakdown.lessons.first.total, 6);
      expect(breakdown.lessons[1].items, 0);
      expect(breakdown.lessons[2].total, 0);
      expect(breakdown.total, 7);
    });

    test('earned cards are counted per lesson', () {
      final counts = TotalInfoCardResponse.fromBody({
        'success': true,
        'data': [
          {'lesson': 'a'},
          {'lesson': 'b'},
          {'lesson': 'a'},
          {'lesson': null},
          {
            'lesson': {'_id': 'b'},
          },
          'junk',
        ],
      }).toDomain();

      expect(counts.byLesson, {'a': 2, 'b': 2});
      expect(counts.total, 4);
    });

    test('question detail reads the cards', () {
      final detail = QuestionResponse.fromBody({
        'success': true,
        'question': {
          'desc': 'Soru açıklaması',
          'page_info': '5. sayfa, soldan 4. sıra',
          'items': [
            {
              'name': 'Yavuz Selim Dönemi',
              'desc': ['Birinci.', 'İkinci.'],
              'mainSubject': {'name': 'Osmanlı Tarihi'},
            },
            {'name': 'Kartsız', 'desc': 'tek paragraf', 'mainSubject': 'id-1'},
            {'foo': 'bar'},
          ],
        },
      }).toDomain()!;

      expect(detail.description, 'Soru açıklaması');
      expect(detail.pageInfo, '5. sayfa, soldan 4. sıra');
      expect(detail.cards, hasLength(2));
      expect(detail.cards.first.title, 'Yavuz Selim Dönemi');
      expect(detail.cards.first.mainSubjectName, 'Osmanlı Tarihi');
      expect(detail.cards.first.text, 'Birinci. İkinci.');
      expect(detail.cards.last.mainSubjectName, isNull);
      expect(detail.cards.last.paragraphs, ['tek paragraf']);
    });

    test('question detail without a question object is null', () {
      expect(QuestionResponse.fromBody({'success': true}).toDomain(), isNull);
    });
  });

  group('AytField and NetExamType wire values', () {
    test('aim types', () {
      expect(AytField.fromWire(2), AytField.equalWeight);
      expect(AytField.fromWire(3), AytField.numeric);
      expect(AytField.fromWire(4), AytField.verbal);
      expect(AytField.fromWire(1), isNull);
      expect(AytField.fromWire(null), isNull);
    });

    test('exam types', () {
      expect(NetExamType.tyt.wireType, 1);
      expect(NetExamType.ayt.wireType, 2);
      expect(NetExamTypeWire.fromWire(1), NetExamType.tyt);
      expect(NetExamTypeWire.fromWire(2), NetExamType.ayt);
      expect(NetExamTypeWire.fromWire(3), isNull);
    });
  });
}
