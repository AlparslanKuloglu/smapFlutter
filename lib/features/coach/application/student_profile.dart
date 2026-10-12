import 'package:flutter/foundation.dart';

import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/coach/application/student_rows.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';

/// The three in-screen tabs of Öğrenci Profili (pano 10.4: "Analiz ·
/// Denemeler · Program"); the route's `?tab=analysis|exams|program`.
enum StudentProfileTab {
  analysis('analysis'),
  exams('exams'),
  program('program');

  const StudentProfileTab(this.query);

  /// The `?tab=` value.
  final String query;

  /// The tab named by a `?tab=` value; the first for anything else (no value,
  /// an unknown one).
  static StudentProfileTab parse(String? value) {
    for (final tab in values) {
      if (tab.query == value) return tab;
    }
    return analysis;
  }
}

/// What the profile writes about one student (pano 10.4: "Alparslan
/// Kuloğlu" and "alparslan.k · 10 deneme", and the context strip's "12. Sınıf
/// · EA"): the facts of the coach's student document, as an immutable value.
///
/// A fact the document does not carry is `null` and is not drawn: the last
/// exam date of the design's meta line ("son 5 Eki. 2026") is not in the
/// document (spec §6.3 #29), so there is no field for it.
@immutable
class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.name,
    this.userName,
    this.photo,
    this.grade,
    this.track,
    this.examCount,
    this.aimType,
  });

  /// The profile of [student]; `null` when the document has no id or no name
  /// (nothing can be opened for it, the same rule as the list's row).
  static StudentProfile? of(CoachStudentDto student) {
    final id = student.id;
    final name = StudentRows.fullName(student);
    if (id == null || name == null) return null;
    final grade = student.grade;
    final count = student.totalMexam;
    return StudentProfile(
      id: id,
      name: name,
      userName: _clean(student.userName),
      photo: _clean(student.photo),
      grade: grade,
      track: grade != null && !grade.requiresTrack ? null : student.track,
      examCount: count != null && count > 0 ? count : null,
      aimType: student.aimType,
    );
  }

  static String? _clean(String? text) {
    final value = text?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  /// The student's Mongo id.
  final String id;

  /// "Alparslan Kuloğlu".
  final String name;

  /// "alparslan.k", the login name.
  final String? userName;

  /// The avatar file name; read it through `CoachAvatars.imageOf`.
  final String? photo;

  final SchoolGrade? grade;

  /// `null` for the 9th and 10th grade and when the server holds none.
  final StudyTrack? track;

  /// How many exams the student has read; `null` when none.
  final int? examCount;

  /// The study field as the backend's number (`AytField.fromWire` reads it).
  final int? aimType;

  @override
  bool operator ==(Object other) =>
      other is StudentProfile &&
      other.id == id &&
      other.name == name &&
      other.userName == userName &&
      other.photo == photo &&
      other.grade == grade &&
      other.track == track &&
      other.examCount == examCount &&
      other.aimType == aimType;

  @override
  int get hashCode =>
      Object.hash(id, name, userName, photo, grade, track, examCount, aimType);

  @override
  String toString() => 'StudentProfile($id, $name)';
}
