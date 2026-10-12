import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/exam_topics_model.dart';
import 'package:smap/features/exams/domain/topic_result.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/domain/main_subjects.dart';

TopicResult _topic(String name, int d, int y, int b) => TopicResult(
  name: name,
  counts: DybCounts(correct: d, wrong: y, blank: b),
);

/// The literature topics of pano 5.5, in a server order that is not sorted.
ExamTopicAnalysis _analysis() => ExamTopicAnalysis([
  LessonTopics(
    lessonName: 'Türk Dili ve Edebiyatı',
    topics: [
      _topic('Cumhuriyet Edebiyatı', 5, 7, 0),
      _topic('Söz Sanatları', 0, 1, 0),
      _topic('Batı Edebiyatı ve Akımları', 1, 0, 0),
      _topic('Nazım Bilgisi', 0, 1, 0),
      _topic(
        'İslamiyet Etkisindeki Türk Edebiyatı (Divan-Halk Edebiyatı)',
        0,
        2,
        0,
      ),
    ],
  ),
  const LessonTopics(lessonName: 'Tarih', topics: []),
]);

void main() {
  group('ExamTopicsModel (pano 5.5)', () {
    final model = ExamTopicsModel.of(_analysis());

    test('the most missed topic is Cumhuriyet Edebiyatı: 12 sorudan 7', () {
      final worst = model.mostMissed!;
      expect(worst.topic.name, 'Cumhuriyet Edebiyatı');
      expect(worst.lessonName, 'Türk Dili ve Edebiyatı');
      expect(worst.total, 12);
      expect(worst.wrong, 7);
    });

    test('topics go weakest first, ties by more questions', () {
      expect(model.groups.single.topics.map((t) => t.name), [
        'İslamiyet Etkisindeki Türk Edebiyatı (Divan-Halk Edebiyatı)',
        'Söz Sanatları',
        'Nazım Bilgisi',
        'Cumhuriyet Edebiyatı',
        'Batı Edebiyatı ve Akımları',
      ]);
    });

    test('a lesson without topics is left out; counts are the sums', () {
      expect(model.groups, hasLength(1));
      expect(
        model.groups.single.counts,
        const DybCounts(correct: 6, wrong: 11, blank: 0),
      );
      expect(model.isEmpty, isFalse);
    });

    test('equal wrong counts: the lower percentage wins, then the first', () {
      final tied = ExamTopicsModel.of(
        ExamTopicAnalysis([
          LessonTopics(
            lessonName: 'Türkçe',
            topics: [
              _topic('a', 4, 3, 0),
              _topic('b', 1, 3, 0),
              _topic('c', 1, 3, 0),
            ],
          ),
        ]),
      );
      expect(tied.mostMissed!.topic.name, 'b');
    });

    test('no wrong answer: no most-missed card', () {
      final clean = ExamTopicsModel.of(
        ExamTopicAnalysis([
          LessonTopics(lessonName: 'Türkçe', topics: [_topic('a', 4, 0, 1)]),
        ]),
      );
      expect(clean.mostMissed, isNull);
      expect(clean.isEmpty, isFalse);
    });

    test('an analysis with no topic is empty', () {
      expect(ExamTopicsModel.of(const ExamTopicAnalysis([])).isEmpty, isTrue);
    });
  });

  group('TopicLinks.resolve', () {
    test('Edebiyat and Türkçe have one backend lesson and no category', () {
      final edebiyat = TopicLinks.resolve(
        lessonName: 'Türk Dili ve Edebiyatı',
        exam: NetExamType.ayt,
      )!;
      expect(edebiyat.lesson.name, 'Edebiyat');
      expect(edebiyat.backendLessonId, '66b0e776c99f8fc189ff35fd');
      expect(edebiyat.cat, isNull);
      final turkce = TopicLinks.resolve(
        lessonName: 'Türkçe',
        exam: NetExamType.tyt,
      )!;
      expect(turkce.backendLessonId, '663e37a24fb443839593141b');
    });

    test('Tarih follows the exam type; Tarih-2 is SOS-2', () {
      final tyt = TopicLinks.resolve(
        lessonName: 'Tarih',
        exam: NetExamType.tyt,
      )!;
      expect(tyt.backendLessonId, '66214a6982ff212039ea3294');
      expect(tyt.cat, LessonCat.tyt);
      final ayt = TopicLinks.resolve(
        lessonName: 'Tarih',
        exam: NetExamType.ayt,
      )!;
      expect(ayt.backendLessonId, '66b0e7e5c99f8fc189ff35ff');
      expect(ayt.cat, LessonCat.ayt);
      final sos2 = TopicLinks.resolve(
        lessonName: 'Tarih-2',
        exam: NetExamType.ayt,
      )!;
      expect(sos2.backendLessonId, '677ff5bb859149d419363f3d');
      expect(sos2.cat, LessonCat.sos2);
    });

    test('Matematik and unknown lessons have no topic screen', () {
      expect(
        TopicLinks.resolve(
          lessonName: 'Temel Matematik',
          exam: NetExamType.tyt,
        ),
        isNull,
      );
      expect(TopicLinks.resolve(lessonName: 'Felsefe'), isNull);
    });
  });

  group('TopicLinks.findTopic', () {
    const subjects = [
      MainSubject(id: 'a', name: 'Cumhuriyet Edebiyatı'),
      MainSubject(id: 'b', name: 'Nazım Bilgisi'),
    ];

    test('matches ignoring case, Turkish marks and spacing', () {
      expect(TopicLinks.findTopic(subjects, 'CUMHURİYET  edebiyatı')!.id, 'a');
    });

    test('no match is null', () {
      expect(TopicLinks.findTopic(subjects, 'Söz Sanatları'), isNull);
    });
  });
}
