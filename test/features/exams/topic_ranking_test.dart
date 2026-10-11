import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/topic_ranking.dart';

void main() {
  DybCounts c(int d, int y, int b) => DybCounts(correct: d, wrong: y, blank: b);

  group('percent', () {
    test('5 of 12 is 42', () => expect(TopicRanking.percent(c(5, 7, 0)), 42));
    test('0 of 1 is 0', () => expect(TopicRanking.percent(c(0, 1, 0)), 0));
    test('1 of 1 is 100', () => expect(TopicRanking.percent(c(1, 0, 0)), 100));
    test('blanks count as questions', () {
      expect(TopicRanking.percent(c(1, 0, 1)), 50);
    });
    test('no question is null', () {
      expect(TopicRanking.percent(c(0, 0, 0)), isNull);
    });
  });

  group('isFewQuestions', () {
    test('one or two questions', () {
      expect(TopicRanking.isFewQuestions(c(0, 1, 0)), isTrue);
      expect(TopicRanking.isFewQuestions(c(0, 2, 0)), isTrue);
    });
    test('three or more, or none', () {
      expect(TopicRanking.isFewQuestions(c(1, 2, 0)), isFalse);
      expect(TopicRanking.isFewQuestions(c(0, 0, 0)), isFalse);
    });
  });

  group('sort (weakest first)', () {
    test('the AYT literature topics of Ek C', () {
      final topics = <(String, DybCounts)>[
        ('Cumhuriyet Edebiyatı', c(5, 7, 0)),
        ('Söz Sanatları', c(0, 1, 0)),
        ('Batı Edebiyatı ve Akımları', c(1, 0, 0)),
        ('Nazım Bilgisi', c(0, 1, 0)),
        ('İslamiyet Etkisindeki', c(0, 2, 0)),
      ];
      final sorted = TopicRanking.sort(topics, countsOf: (t) => t.$2);
      expect(sorted.map((t) => t.$1), [
        'İslamiyet Etkisindeki',
        'Söz Sanatları',
        'Nazım Bilgisi',
        'Cumhuriyet Edebiyatı',
        'Batı Edebiyatı ve Akımları',
      ]);
    });

    test('a topic without questions goes last; ties keep the given order', () {
      final topics = <(String, DybCounts)>[
        ('a', c(0, 0, 0)),
        ('b', c(1, 1, 0)),
        ('c', c(1, 1, 0)),
        ('d', c(0, 0, 0)),
      ];
      final sorted = TopicRanking.sort(topics, countsOf: (t) => t.$2);
      expect(sorted.map((t) => t.$1), ['b', 'c', 'a', 'd']);
    });

    test('returns a new list and leaves the input alone', () {
      final topics = [c(5, 0, 0), c(0, 5, 0)];
      final sorted = TopicRanking.sort(topics, countsOf: (t) => t);
      expect(sorted, [c(0, 5, 0), c(5, 0, 0)]);
      expect(topics.first, c(5, 0, 0));
    });
  });
}
