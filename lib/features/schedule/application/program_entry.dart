import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/schedule/application/program_lessons.dart';
import 'package:smap/features/schedule/application/topic_choice.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';

/// One planned topic as the program screens draw it (a row of the day list,
/// a block of the week grid, a filled slot): the editor's task with what the
/// screens read from it already worked out. Immutable with value equality, so
/// a selector can compare lists of them.
@immutable
class ProgramEntry {
  const ProgramEntry({
    required this.id,
    required this.day,
    required this.hour,
    required this.minute,
    required this.lessonId,
    required this.lessonName,
    required this.title,
    this.subject,
    this.mainSubjectId,
    this.itemId,
  });

  /// The entry of [task].
  factory ProgramEntry.of(ProgramTaskDraft task) => ProgramEntry(
    id: task.id,
    day: DateTime(task.day.year, task.day.month, task.day.day),
    hour: task.hour,
    minute: task.minute,
    lessonId: task.lessonId,
    lessonName: ProgramLessons.nameOf(
      lessonId: task.lessonId,
      lessonName: task.lessonName,
    ),
    title: task.title,
    subject: ProgramLessons.subjectOf(
      lessonId: task.lessonId,
      lessonName: task.lessonName,
    ),
    mainSubjectId: task.mainSubjectId,
    itemId: task.itemId,
  );

  /// The task's id (unique inside the program).
  final String id;

  /// The calendar day.
  final DateTime day;
  final int hour;
  final int minute;
  final String lessonId;

  /// "TYT Türkçe"; empty when the lesson is unknown.
  final String lessonName;

  /// "Fiilde Çatı".
  final String title;

  /// The lesson's color key; `null` draws a neutral tile.
  final SubjectKey? subject;

  /// The main subject the topic detail opens; `null` when the task has none.
  final String? mainSubjectId;

  /// The "Çantam" item the topic came from; `null` for a lesson topic.
  final String? itemId;

  /// Minutes since midnight.
  int get minutes => hour * 60 + minute;

  /// "10:00".
  String get timeLabel => TrFormat.saatParcali(hour, minute);

  /// The lesson without its exam prefix: "Türkçe".
  String get shortLesson => ProgramLessons.shortName(lessonName);

  /// Tells this topic from the others a picker offers (`TopicChoice.key`).
  String get topicKey => TopicChoice.keyFor(
    itemId: itemId,
    lessonId: lessonId,
    mainSubjectId: mainSubjectId,
    title: title,
  );

  /// Whether the topic detail can be opened from this entry.
  bool get canOpenTopic => mainSubjectId != null && mainSubjectId!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is ProgramEntry &&
      other.id == id &&
      other.day == day &&
      other.hour == hour &&
      other.minute == minute &&
      other.lessonId == lessonId &&
      other.lessonName == lessonName &&
      other.title == title &&
      other.subject == subject &&
      other.mainSubjectId == mainSubjectId &&
      other.itemId == itemId;

  @override
  int get hashCode => Object.hash(
    id,
    day,
    hour,
    minute,
    lessonId,
    lessonName,
    title,
    subject,
    mainSubjectId,
    itemId,
  );
}

/// Where each topic of [entries] sits, by [ProgramEntry.topicKey]: the
/// earliest slot of a topic planned more than once ("Programda: Pzt 10:00",
/// pano 3.5 kare 3).
Map<String, ProgramEntry> placementsOf(Iterable<ProgramEntry> entries) {
  final sorted = [...entries]
    ..sort((a, b) {
      final byDay = a.day.compareTo(b.day);
      return byDay != 0 ? byDay : a.minutes.compareTo(b.minutes);
    });
  final placed = <String, ProgramEntry>{};
  for (final entry in sorted) {
    placed.putIfAbsent(entry.topicKey, () => entry);
  }
  return placed;
}
