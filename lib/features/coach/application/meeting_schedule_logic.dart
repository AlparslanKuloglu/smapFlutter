import 'package:flutter/foundation.dart';

import 'package:smap/features/coach/domain/interview_type.dart';

/// What the "Yeni görüşme" sheet hands back (pano 10.5 kare 2): the picked
/// student, who the meeting is with, when, and the optional note.
@immutable
class MeetingDraft {
  const MeetingDraft({
    required this.studentId,
    required this.type,
    required this.moment,
    this.note,
  });

  /// The student the meeting is about.
  final String studentId;

  /// "Öğrenci" or "Veli".
  final InterviewType type;

  /// The picked day and time of day, as the coach's wall clock.
  final DateTime moment;

  /// The note, trimmed; `null` when the field was left empty.
  final String? note;

  @override
  bool operator ==(Object other) =>
      other is MeetingDraft &&
      other.studentId == studentId &&
      other.type == type &&
      other.moment == moment &&
      other.note == note;

  @override
  int get hashCode => Object.hash(studentId, type, moment, note);
}

/// The date and time arithmetic of the "Yeni görüşme" sheet (pano 10.5 kare
/// 2), as pure functions.
abstract final class MeetingSchedule {
  /// How far into the past the calendar goes (a coach may log a meeting that
  /// already happened); the board draws no rule.
  static const int pastDays = 365;

  /// Where the sheet starts: [now] rounded up to the next half hour, so the
  /// default is a plausible future time and never a time of the past
  /// ("16:12" opens on "16:30"; "23:40" opens on tomorrow "00:00").
  static DateTime initialMoment(DateTime now) {
    const half = 30;
    final total = now.hour * 60 + now.minute;
    final rounded = (total + half - 1) ~/ half * half;
    // The minutes may run past midnight; `DateTime` carries them to the next
    // day.
    return DateTime(now.year, now.month, now.day, 0, rounded);
  }

  /// [day]'s calendar day at [hour]:[minute].
  static DateTime combine(DateTime day, {required int hour, int minute = 0}) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  /// The first day the calendar lets the coach pick, counted from [today].
  static DateTime firstDay(DateTime today) =>
      DateTime(today.year, today.month, today.day - pastDays);

  /// The note of the form as it goes out: trimmed, `null` when empty.
  static String? noteOf(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
