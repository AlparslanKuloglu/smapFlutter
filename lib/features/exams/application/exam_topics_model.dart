import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/topic_ranking.dart';
import 'package:smap/features/exams/domain/topic_result.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/subject_resolver.dart';
import 'package:smap/features/lessons/domain/main_subjects.dart';

/// The topic the student missed most in an exam (pano 5.5 "En çok kaçırdığın
/// konu": "Cumhuriyet Edebiyatı", "12 sorudan 7'sini kaçırdın.").
@immutable
class MostMissedTopic {
  const MostMissedTopic({required this.lessonName, required this.topic});

  /// The lesson the topic is listed under ("Türk Dili ve Edebiyatı").
  final String lessonName;
  final TopicResult topic;

  /// Questions of the topic in the exam: the "12" of "12 sorudan".
  int get total => topic.counts.total;

  /// The wrong ones: the "7'sini" of the sentence.
  int get wrong => topic.counts.wrong;

  @override
  bool operator ==(Object other) =>
      other is MostMissedTopic &&
      other.lessonName == lessonName &&
      other.topic == topic;

  @override
  int get hashCode => Object.hash(lessonName, topic);
}

/// One lesson's topics, weakest first (pano 5.5: "Türk Dili ve Edebiyatı ·
/// zayıftan güçlüye", "12 D 12 Y 0 B · 24 soru").
@immutable
class TopicGroup {
  const TopicGroup({
    required this.lessonName,
    required this.counts,
    required this.topics,
  });

  final String lessonName;

  /// D/Y/B of the lesson: the sum of its topics.
  final DybCounts counts;

  /// The topics, ordered by [TopicRanking.sort].
  final List<TopicResult> topics;

  @override
  bool operator ==(Object other) =>
      other is TopicGroup &&
      other.lessonName == lessonName &&
      other.counts == counts &&
      listEquals(other.topics, topics);

  @override
  int get hashCode => Object.hash(lessonName, counts, Object.hashAll(topics));
}

/// The Konular tab (pano 5.5, 5.10): the card of the most missed topic, then
/// one group per lesson with its topics weakest first. Pure.
@immutable
class ExamTopicsModel {
  const ExamTopicsModel({this.mostMissed, this.groups = const []});

  /// Orders the analysis the server sent. A lesson without topics is left
  /// out; lessons keep the server's order.
  factory ExamTopicsModel.of(ExamTopicAnalysis analysis) {
    final groups = <TopicGroup>[];
    MostMissedTopic? worst;
    for (final lesson in analysis.lessons) {
      if (lesson.topics.isEmpty) continue;
      groups.add(
        TopicGroup(
          lessonName: lesson.lessonName,
          counts: lesson.counts,
          topics: TopicRanking.sort(
            lesson.topics,
            countsOf: (topic) => topic.counts,
          ),
        ),
      );
      for (final topic in lesson.topics) {
        if (topic.counts.wrong <= 0) continue;
        final candidate = MostMissedTopic(
          lessonName: lesson.lessonName,
          topic: topic,
        );
        if (worst == null || _worse(candidate.topic, worst.topic)) {
          worst = candidate;
        }
      }
    }
    return ExamTopicsModel(mostMissed: worst, groups: groups);
  }

  /// `null` when no topic has a wrong answer.
  final MostMissedTopic? mostMissed;
  final List<TopicGroup> groups;

  bool get isEmpty => groups.isEmpty;

  /// The more wrong answers, then the lower success percentage (assumption
  /// 3.6); with a tie the topic listed first stays.
  static bool _worse(TopicResult candidate, TopicResult best) {
    final byWrong = candidate.counts.wrong.compareTo(best.counts.wrong);
    if (byWrong != 0) return byWrong > 0;
    final candidatePercent = TopicRanking.percent(candidate.counts) ?? 100;
    final bestPercent = TopicRanking.percent(best.counts) ?? 100;
    return candidatePercent < bestPercent;
  }

  @override
  bool operator ==(Object other) =>
      other is ExamTopicsModel &&
      other.mostMissed == mostMissed &&
      listEquals(other.groups, groups);

  @override
  int get hashCode => Object.hash(mostMissed, Object.hashAll(groups));
}

/// Where "Bu Konuyu Çalış" leads: the general lesson (the Derslerim route's
/// `lessonId`), the backend lesson whose topics hold it and the category it
/// is read under.
@immutable
class TopicLinkTarget {
  const TopicLinkTarget({
    required this.lesson,
    required this.backendLessonId,
    this.cat,
  });

  final GeneralLessonSpec lesson;

  /// The backend lesson `getMainSubjects` is asked for.
  final String backendLessonId;

  /// `tyt`, `ayt` or `sos2` for a lesson with tracks; `null` for the others.
  final LessonCat? cat;

  @override
  bool operator ==(Object other) =>
      other is TopicLinkTarget &&
      other.lesson.id == lesson.id &&
      other.backendLessonId == backendLessonId &&
      other.cat == cat;

  @override
  int get hashCode => Object.hash(lesson.id, backendLessonId, cat);
}

/// Works out which topic of Derslerim an exam's topic row means. The analysis
/// names lessons and topics but carries no ids, so the lesson comes from its
/// name and the exam's type, and the topic from its name among the lesson's
/// main subjects. Pure.
abstract final class TopicLinks {
  /// The place of the lesson named [lessonName] ("Türk Dili ve Edebiyatı",
  /// "Tarih", "Tarih-2") for an exam of [exam]; `null` for a lesson the app
  /// has no topic screen for (Matematik and Geometri open on the web) or an
  /// unknown name.
  static TopicLinkTarget? resolve({
    required String lessonName,
    NetExamType? exam,
  }) {
    final subject = SubjectResolver.fromLessonName(lessonName);
    if (subject == null) return null;
    GeneralLessonSpec? lesson;
    for (final spec in LessonCatalog.generalLessons) {
      if (spec.subject == subject) lesson = spec;
    }
    if (lesson == null || lesson.isWebOnly) return null;
    if (!lesson.hasTrackChoice) {
      final id = lesson.ids.single;
      return id == null
          ? null
          : TopicLinkTarget(lesson: lesson, backendLessonId: id);
    }
    final key = TurkishText.fold(lessonName);
    final LessonTrack track;
    if (lesson.ids.hasSos2 && _isSecond(key)) {
      track = LessonTrack.sos2;
    } else if (exam == NetExamType.ayt) {
      track = LessonTrack.ayt;
    } else {
      track = LessonTrack.tyt;
    }
    final id = lesson.ids.forTrack(track);
    return id == null
        ? null
        : TopicLinkTarget(
            lesson: lesson,
            backendLessonId: id,
            cat: LessonCat.ofTrack(track),
          );
  }

  /// "tarih-2", "cografya 2": the AYT second part.
  static bool _isSecond(String foldedName) =>
      RegExp(r'[-\s]2$').hasMatch(foldedName.trim());

  /// The main subject of [subjects] named [topicName] (case and Turkish marks
  /// do not matter); `null` when none is.
  static MainSubject? findTopic(
    Iterable<MainSubject> subjects,
    String topicName,
  ) {
    final wanted = _squash(topicName);
    for (final subject in subjects) {
      if (_squash(subject.name) == wanted) return subject;
    }
    return null;
  }

  static String _squash(String text) =>
      TurkishText.fold(text).replaceAll(RegExp(r'\s+'), ' ').trim();
}
