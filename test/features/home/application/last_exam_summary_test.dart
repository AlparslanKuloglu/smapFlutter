import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/data/dtos/exam_answers.dart';
import 'package:smap/features/exams/data/mappers/exam_mappers.dart';
import 'package:smap/features/exams/domain/topic_result.dart';
import 'package:smap/features/home/application/last_exam_summary.dart';

import 'home_fixtures.dart';

void main() {
  group('the last exam', () {
    test('is the first usable exam of the list with the board values', () {
      final summary = LastExamSummary.of([examDetail(examJson())])!;

      expect(summary.examId, 'res-6');
      expect(summary.name, 'Türkiye Geneli Deneme 6');
      expect(summary.publisher, 'Örnek Yayınları');
      expect(summary.kind, NetExamType.ayt);
      expect(summary.date, DateTime(2026, 10, 5));
      expect(summary.net, 67.5);
      expect(summary.counts, const DybCounts(correct: 86, wrong: 74, blank: 0));
      expect(summary.delta, isNull);
      expect(summary.weakestTopic, isNull);
    });

    test('an empty list has no last exam', () {
      expect(LastExamSummary.of(const []), isNull);
    });

    test('the change is against the next exam of the SAME type (+8,25)', () {
      final summary = LastExamSummary.of([
        examDetail(examJson()),
        examDetail(examJson(id: 'tyt-3', type: 1, net: 90)),
        examDetail(
          examJson(id: 'ayt-5', net: 59.25, correct: 70, wrong: 43, blank: 47),
        ),
      ])!;

      expect(summary.delta, 8.25);
    });

    test('a fall in net is negative', () {
      final summary = LastExamSummary.of([
        examDetail(examJson(net: 50)),
        examDetail(examJson(id: 'ayt-5', net: 52.5)),
      ])!;

      expect(summary.delta, -2.5);
    });

    test('with no earlier exam of its type there is no change', () {
      final summary = LastExamSummary.of([
        examDetail(examJson()),
        examDetail(examJson(id: 'tyt-3', type: 1)),
      ])!;

      expect(summary.delta, isNull);
    });

    test('a missing net is worked out from D and Y (86 - 74 / 4)', () {
      final summary = LastExamSummary.of([examDetail(examJson(net: null))])!;

      expect(summary.net, 67.5);
    });

    test('an exam without a type, date or counts is skipped', () {
      final json = examJson(id: 'no-date', date: null);
      final summary = LastExamSummary.of([
        examDetail(json),
        examDetail(examJson(id: 'usable', net: 40)),
      ])!;

      expect(summary.examId, 'usable');
    });

    test('blank name and publisher are not carried', () {
      final summary = LastExamSummary.of([
        examDetail(examJson(name: '  ', publisher: '')),
      ])!;

      expect(summary.name, isNull);
      expect(summary.publisher, isNull);
    });

    test('has value equality', () {
      expect(
        LastExamSummary.of([examDetail(examJson())]),
        LastExamSummary.of([examDetail(examJson())]),
      );
      expect(
        LastExamSummary.of([examDetail(examJson())]),
        isNot(LastExamSummary.of([examDetail(examJson(net: 60))])),
      );
    });
  });

  group('the weakest topic', () {
    ExamTopicAnalysis analysis(Map<String, Object?> json) =>
        TopicAnalysisResponse.fromBody(json).toDomain();

    test(
      'is the topic with the most wrong answers (13 questions, 9 wrong)',
      () {
        final topic = LastExamSummary.weakestTopicOf(
          analysis(topicAnalysisJson()),
        )!;

        expect(topic.name, 'Kurtuluş Savaşı Hazırlık Dönemi');
        expect(topic.total, 13);
        expect(topic.wrong, 9);
      },
    );

    test('ties go to the lower success percentage', () {
      final topic = LastExamSummary.weakestTopicOf(
        analysis({
          'success': true,
          'data': {
            'Türkçe': {
              'Paragraf': {'trueValue': 10, 'wrongValue': 4, 'passValue': 0},
              'Sözcükte Anlam': {
                'trueValue': 2,
                'wrongValue': 4,
                'passValue': 0,
              },
            },
          },
        }),
      )!;

      expect(topic.name, 'Sözcükte Anlam');
    });

    test('a full tie keeps the topic the server lists first', () {
      final topic = LastExamSummary.weakestTopicOf(
        analysis({
          'success': true,
          'data': {
            'Türkçe': {
              'A': {'trueValue': 2, 'wrongValue': 2, 'passValue': 0},
              'B': {'trueValue': 2, 'wrongValue': 2, 'passValue': 0},
            },
          },
        }),
      )!;

      expect(topic.name, 'A');
    });

    test('is null when nothing was missed', () {
      expect(
        LastExamSummary.weakestTopicOf(
          analysis({
            'success': true,
            'data': {
              'Türkçe': {
                'Paragraf': {'trueValue': 10, 'wrongValue': 0, 'passValue': 2},
              },
            },
          }),
        ),
        isNull,
      );
    });

    test('is carried by withAnalysis', () {
      final summary = LastExamSummary.of([examDetail(examJson())])!;

      final withTopic = summary.withAnalysis(analysis(topicAnalysisJson()));

      expect(withTopic.weakestTopic?.wrong, 9);
      expect(withTopic.net, summary.net);
    });

    test('its sentence takes the Turkish suffixes: Dönemi\'nde ... 9\'unu', () {
      const topic = WeakestTopic(
        name: 'Kurtuluş Savaşı Hazırlık Dönemi',
        total: 13,
        wrong: 9,
      );

      expect(topic.nameLocative, "Kurtuluş Savaşı Hazırlık Dönemi'nde");
      expect(topic.totalText, '13');
      expect(topic.wrongAccusative, "9'unu");
    });

    test('a wrong count after a vowel reading takes -sını (6)', () {
      const topic = WeakestTopic(name: 'Konu', total: 20, wrong: 6);

      expect(topic.wrongAccusative, "6'sını");
    });
  });
}
