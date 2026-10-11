import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/features/exams/application/dyb_counts.dart';

/// One topic of an exam (C23 `TopicResultRow`; board 5.5): its name and D/Y/B.
/// The percentage comes from `TopicRanking.percent`.
@immutable
class TopicResult {
  const TopicResult({required this.name, required this.counts, this.netRate});

  final String name;

  /// Questions of the topic in this exam. A count the server left out is 0
  /// here (the answer always names all three; see the mapper's test).
  final DybCounts counts;

  /// The server's own rate (meaning not documented), when sent.
  final double? netRate;

  @override
  bool operator ==(Object other) =>
      other is TopicResult &&
      other.name == name &&
      other.counts == counts &&
      other.netRate == netRate;

  @override
  int get hashCode => Object.hash(name, counts, netRate);
}

/// The topics of one lesson of an exam, as the server sorted them.
@immutable
class LessonTopics {
  const LessonTopics({required this.lessonName, required this.topics});

  /// The lesson's name as the server wrote it ("Türkçe", "Tarih").
  final String lessonName;

  final List<TopicResult> topics;

  /// D/Y/B of the whole lesson: the sum of its topics.
  DybCounts get counts => DybCounts(
    correct: topics.fold(0, (sum, t) => sum + t.counts.correct),
    wrong: topics.fold(0, (sum, t) => sum + t.counts.wrong),
    blank: topics.fold(0, (sum, t) => sum + t.counts.blank),
  );

  @override
  bool operator ==(Object other) =>
      other is LessonTopics &&
      other.lessonName == lessonName &&
      listEquals(other.topics, topics);

  @override
  int get hashCode => Object.hash(lessonName, Object.hashAll(topics));
}

/// The Konu Analizi of an exam (board 5.5): every lesson with its topics.
@immutable
class ExamTopicAnalysis {
  const ExamTopicAnalysis(this.lessons);

  final List<LessonTopics> lessons;

  bool get isEmpty => lessons.every((lesson) => lesson.topics.isEmpty);

  @override
  bool operator ==(Object other) =>
      other is ExamTopicAnalysis && listEquals(other.lessons, lessons);

  @override
  int get hashCode => Object.hashAll(lessons);
}
