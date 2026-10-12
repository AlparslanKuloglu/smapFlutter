import 'package:flutter/foundation.dart';

import 'package:smap/features/coach/data/dtos/interview_dtos.dart';
import 'package:smap/features/coach/domain/interview_type.dart';

/// Who the list is narrowed to (pano 10.5 kare 1: the "Kiminle" chips
/// "Tümü", "Öğrenci", "Veli").
enum MeetingWith {
  /// "Tümü": no narrowing.
  all(null),

  /// "Öğrenci".
  student(InterviewType.student),

  /// "Veli".
  parent(InterviewType.parent);

  const MeetingWith(this.type);

  /// The interview kind this choice keeps; `null` keeps every kind.
  final InterviewType? type;

  /// The choice that keeps [type].
  static MeetingWith of(InterviewType? type) => switch (type) {
    InterviewType.student => MeetingWith.student,
    InterviewType.parent => MeetingWith.parent,
    null => MeetingWith.all,
  };
}

/// One note of a meeting (pano 10.6 "Not kartı").
///
/// The server has no note ids: a note is addressed by its [index] in the
/// meeting's list, so the index kept here must be the one the server holds
/// (every write is followed by a fresh read of the meeting).
@immutable
class MeetingNote {
  const MeetingNote({required this.index, required this.text, this.date});

  /// Position in the server's list (`editIndex`, `deleteIndex`).
  final int index;

  /// What the coach wrote.
  final String text;

  /// When the note was written or last edited, as the server sent it.
  final DateTime? date;

  @override
  bool operator ==(Object other) =>
      other is MeetingNote &&
      other.index == index &&
      other.text == text &&
      other.date == date;

  @override
  int get hashCode => Object.hash(index, text, date);
}

/// The wall-clock time of a meeting: the fields the server sent, read as the
/// coach's own clock.
///
/// The legacy screens sent the picked time without a zone and showed the
/// fields they got back unchanged; this keeps that (DATA2 open question 1).
/// A time the server returned in UTC ("…Z") is therefore not shifted by the
/// device's offset.
abstract final class MeetingMoment {
  /// [date] as a zoneless local `DateTime`; `null` stays `null`.
  static DateTime? wallClock(DateTime? date) => date == null
      ? null
      : DateTime(date.year, date.month, date.day, date.hour, date.minute);
}

/// A meeting of the coach's list or detail: an `InterviewDto` read into what
/// the screens show (pano 10.5).
///
/// Nothing is made up: a meeting the server gave no student name for has a
/// null [studentName] and the screens fall back to the kind of meeting, and a
/// missing [moment] is left out of the row.
@immutable
class MeetingEntry {
  const MeetingEntry({
    required this.id,
    this.type,
    this.moment,
    this.studentId,
    this.studentName,
    this.photo,
    this.notes = const [],
  });

  /// Reads [dto]; `null` for a document without an id (it cannot be opened).
  static MeetingEntry? fromDto(InterviewDto dto) {
    final id = dto.id;
    if (id == null || id.isEmpty) return null;
    final student = dto.student;
    final name = student?.displayName?.trim();
    final notes = <MeetingNote>[];
    for (final (index, note) in dto.notes.indexed) {
      final text = note.note?.trim();
      if (text == null || text.isEmpty) continue;
      notes.add(MeetingNote(index: index, text: text, date: note.date));
    }
    return MeetingEntry(
      id: id,
      type: dto.interviewType,
      moment: MeetingMoment.wallClock(dto.date),
      studentId: student?.id,
      studentName: name == null || name.isEmpty ? null : name,
      photo: student?.photo,
      notes: List.unmodifiable(notes),
    );
  }

  /// Mongo `_id`.
  final String id;

  /// Who the meeting is with; `null` when the server sent an unknown number.
  final InterviewType? type;

  /// When it is, as the coach's wall clock.
  final DateTime? moment;

  /// The student the meeting is about.
  final String? studentId;
  final String? studentName;

  /// The student's avatar file name or path.
  final String? photo;

  /// The notes that have text, with their server positions.
  final List<MeetingNote> notes;

  /// The same meeting with other [notes].
  MeetingEntry withNotes(List<MeetingNote> notes) => MeetingEntry(
    id: id,
    type: type,
    moment: moment,
    studentId: studentId,
    studentName: studentName,
    photo: photo,
    notes: List.unmodifiable(notes),
  );

  @override
  bool operator ==(Object other) =>
      other is MeetingEntry &&
      other.id == id &&
      other.type == type &&
      other.moment == moment &&
      other.studentId == studentId &&
      other.studentName == studentName &&
      other.photo == photo &&
      listEquals(other.notes, notes);

  @override
  int get hashCode => Object.hash(
    id,
    type,
    moment,
    studentId,
    studentName,
    photo,
    Object.hashAll(notes),
  );
}

/// The list split as the design draws it (pano 10.5 kare 1): "Yaklaşan · 2"
/// and, under it, the past meetings.
@immutable
class MeetingSections {
  const MeetingSections({this.upcoming = const [], this.past = const []});

  /// Meetings from now on, the nearest first.
  final List<MeetingEntry> upcoming;

  /// Meetings that have passed, the newest first (a meeting without a time
  /// goes last).
  final List<MeetingEntry> past;

  bool get isEmpty => upcoming.isEmpty && past.isEmpty;

  int get length => upcoming.length + past.length;

  @override
  bool operator ==(Object other) =>
      other is MeetingSections &&
      listEquals(other.upcoming, upcoming) &&
      listEquals(other.past, past);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(upcoming), Object.hashAll(past));
}
