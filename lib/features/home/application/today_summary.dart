import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/subject_resolver.dart';
import 'package:smap/features/schedule/application/schedule_snapshot.dart';

/// One planned topic of today (pano 3.1 kare 1 "Bugün": "10:00 · Türkçe ·
/// Fiilde Çatı"), the data of a `ProgramItemRow`.
@immutable
class TodayRow {
  const TodayRow({
    required this.hour,
    required this.minute,
    required this.subjectName,
    required this.topic,
    this.subject,
    this.lessonId,
    this.mainSubjectId,
  });

  /// 0 to 23.
  final int hour;

  /// 0 to 59.
  final int minute;

  /// "Türkçe".
  final String subjectName;

  /// "Fiilde Çatı".
  final String topic;

  /// The subject color; `null` for a lesson outside the nine.
  final SubjectKey? subject;

  /// The general lesson's id (what the lesson screens open by).
  final String? lessonId;

  /// The main subject's id: the topic the row opens.
  final String? mainSubjectId;

  @override
  bool operator ==(Object other) =>
      other is TodayRow &&
      other.hour == hour &&
      other.minute == minute &&
      other.subjectName == subjectName &&
      other.topic == topic &&
      other.subject == subject &&
      other.lessonId == lessonId &&
      other.mainSubjectId == mainSubjectId;

  @override
  int get hashCode => Object.hash(
    hour,
    minute,
    subjectName,
    topic,
    subject,
    lessonId,
    mainSubjectId,
  );
}

/// "Bugün" of the home screen (pano 3.1 kare 1; spec §4.B "(b) Bugün"): the
/// day, the name of the program it belongs to and the tasks of the day,
/// earliest first. Immutable with value equality, so the section rebuilds
/// only when something it shows changed.
///
/// A task shows only when it has a topic: a row without a topic would be an
/// empty line (nothing is faked to fill it).
@immutable
class TodaySummary {
  const TodaySummary({required this.day, required this.rows, this.programName});

  /// The calendar day (local midnight).
  final DateTime day;

  /// The tasks of [day], earliest first; empty when programs exist but none
  /// has a task today.
  final List<TodayRow> rows;

  /// The program the first task belongs to ("Ekim 2. Hafta"); `null` when
  /// there is no task or the program has no name.
  final String? programName;

  /// "Bugün" of [now] from the loaded [snapshot].
  static TodaySummary of(ScheduleSnapshot snapshot, DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    final rows = <TodayRow>[];
    String? programName;
    for (final scheduled in snapshot.tasksOn(day)) {
      final task = scheduled.task;
      final topic = task.title?.trim();
      if (topic == null || topic.isEmpty) continue;
      final catalog = LessonCatalog.byId(task.lesson);
      final writtenName = task.lessonName?.trim();
      final subjectName = writtenName != null && writtenName.isNotEmpty
          ? writtenName
          : (catalog?.name ?? '');
      rows.add(
        TodayRow(
          hour: task.hour!,
          minute: task.minute!,
          subjectName: subjectName,
          topic: topic,
          subject:
              catalog?.subject ?? SubjectResolver.fromLessonName(subjectName),
          lessonId: task.lesson,
          mainSubjectId: task.mainSubject,
        ),
      );
      final name = scheduled.weekly.name?.trim();
      if (programName == null && name != null && name.isNotEmpty) {
        programName = name;
      }
    }
    return TodaySummary(
      day: day,
      rows: List.unmodifiable(rows),
      programName: programName,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TodaySummary &&
      other.day == day &&
      other.programName == programName &&
      listEquals(other.rows, rows);

  @override
  int get hashCode => Object.hash(day, programName, Object.hashAll(rows));
}
