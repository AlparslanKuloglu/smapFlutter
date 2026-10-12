import 'package:flutter/foundation.dart';

import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/data/dtos/interview_dtos.dart';
import 'package:smap/features/coach/domain/interview_type.dart';
import 'package:smap/features/coach/application/meeting_models.dart';

/// The student's whole name for the coach's screens.
///
/// A student the coach added has the first name alone in `name` and the
/// surname in its own field (`CoachStudentDto.displayName` is `name` first), so
/// a list built from it would read "Elif" where the board says "Elif Şahin".
/// A `name` that already holds the surname (a student who signed up) is kept
/// as it is.
extension CoachStudentFullName on CoachStudentDto {
  /// "Elif Şahin"; falls back to what [displayName] gives; `null` when the
  /// document has no name at all.
  String? get fullName {
    final base = displayName;
    final last = surname?.trim();
    if (base == null || last == null || last.isEmpty) return base;
    if (TurkishText.fold(base).contains(TurkishText.fold(last))) return base;
    return '$base $last';
  }
}

/// One tile of "Öğrencilerin" (C32 `StudentTile`; pano 10.1 kare 1): what the
/// tile draws of a student. Value equality, so the section's selector
/// rebuilds only when a tile really changed.
///
/// The last exam date the board draws under the name ("Son deneme 5 Eki.") is
/// not part of the student document (spec §6.3 #29), so it is not here: the
/// tile draws it only once the server sends it.
@immutable
class StripStudent {
  const StripStudent({required this.id, required this.name, this.photo});

  /// The student's id; what the profile screen is opened with.
  final String id;

  /// "Alparslan Kuloğlu".
  final String name;

  /// The avatar file name or path; the initials show without it.
  final String? photo;

  @override
  bool operator ==(Object other) =>
      other is StripStudent &&
      other.id == id &&
      other.name == name &&
      other.photo == photo;

  @override
  int get hashCode => Object.hash(id, name, photo);
}

/// The student strip of the coach home: the students in Turkish alphabetical
/// order (pano 10.1; the order of "Öğrencilerim" too). A student the server
/// sent without an id or any name has no tile to draw and is left out.
@immutable
class StudentStrip {
  const StudentStrip(this.students);

  /// The strip of [students] (already sorted by the caller).
  factory StudentStrip.of(Iterable<CoachStudentDto> students) => StudentStrip([
    for (final student in students)
      if (student.id case final id? when id.isNotEmpty)
        if (student.fullName case final name?)
          StripStudent(id: id, name: name, photo: student.photo),
  ]);

  final List<StripStudent> students;

  bool get isEmpty => students.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is StudentStrip && listEquals(other.students, students);

  @override
  int get hashCode => Object.hashAll(students);
}

/// One row of "Yaklaşan görüşmeler" (C34 `MeetingRow.dateBlock`; pano 10.1).
@immutable
class HomeMeeting {
  const HomeMeeting({
    required this.id,
    required this.studentName,
    required this.date,
    this.studentId,
    this.photo,
    this.type,
  });

  /// The interview's id.
  final String id;

  /// With whom: "Alparslan Kuloğlu".
  final String studentName;

  final String? studentId;

  /// The student's avatar file name or path.
  final String? photo;

  /// When it is (local time).
  final DateTime date;

  /// "Öğrenci" or "Veli"; `null` when the server sent neither.
  final InterviewType? type;

  @override
  bool operator ==(Object other) =>
      other is HomeMeeting &&
      other.id == id &&
      other.studentName == studentName &&
      other.studentId == studentId &&
      other.photo == photo &&
      other.date == date &&
      other.type == type;

  @override
  int get hashCode =>
      Object.hash(id, studentName, studentId, photo, date, type);
}

/// The coach's interviews of the next seven days: the rows of "Yaklaşan
/// görüşmeler" and the count in the band ("önümüzdeki 7 günde 2 görüşme").
@immutable
class UpcomingMeetings {
  const UpcomingMeetings(this.items);

  /// The window of the band's count and of the section: now to seven days
  /// on.
  static const Duration window = Duration(days: 7);

  /// The rows the section draws at most; the rest are in "Görüşmelerim".
  static const int maxRows = 5;

  /// Keeps the [interviews] that fall in the next seven days from [now]
  /// (the instant of an interview in the past, an interview with no date or
  /// with nobody to name does not count), earliest first.
  ///
  /// A name the interview document does not carry is looked up with
  /// [studentOf] (the coach's student list) by the student's id.
  factory UpcomingMeetings.of(
    Iterable<InterviewDto> interviews,
    DateTime now, {
    CoachStudentDto? Function(String id)? studentOf,
  }) {
    final end = now.add(window);
    final items = <HomeMeeting>[];
    final seen = <String>{};
    for (final interview in interviews) {
      // The coach's wall clock, as the meetings tab reads it (no zone shift;
      // the app sends dates zoneless, DATA2).
      final date = MeetingMoment.wallClock(interview.date);
      final id = interview.id;
      if (date == null || id == null || id.isEmpty) continue;
      if (date.isBefore(now) || date.isAfter(end)) continue;
      if (!seen.add(id)) continue;
      final studentId = interview.student?.id;
      final known = studentId == null ? null : studentOf?.call(studentId);
      final name = interview.student?.displayName ?? known?.fullName;
      if (name == null) continue;
      items.add(
        HomeMeeting(
          id: id,
          studentName: name,
          studentId: studentId,
          photo: interview.student?.photo ?? known?.photo,
          date: date,
          type: interview.interviewType,
        ),
      );
    }
    items.sort((a, b) => a.date.compareTo(b.date));
    return UpcomingMeetings(List.unmodifiable(items));
  }

  /// All of them, earliest first.
  final List<HomeMeeting> items;

  /// How many there are in the window (the band's count).
  int get count => items.length;

  /// The rows the section draws.
  List<HomeMeeting> get rows => items.take(maxRows).toList(growable: false);

  /// The calendar days (midnight, local) the window touches, today first: the
  /// `filter.dates` of `POST /coach/getInterviews`.
  static List<DateTime> daysOf(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var i = 0; i <= window.inDays; i++)
        DateTime(today.year, today.month, today.day + i),
    ];
  }

  @override
  bool operator ==(Object other) =>
      other is UpcomingMeetings && listEquals(other.items, items);

  @override
  int get hashCode => Object.hashAll(items);
}
