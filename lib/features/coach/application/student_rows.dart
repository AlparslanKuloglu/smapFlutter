import 'package:flutter/foundation.dart';

import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';

/// One line of "Öğrencilerim" (pano 10.2; C31 `StudentRow`): the facts the
/// row writes, as an immutable value a selector can compare. The texts are the
/// screen's (l10n); this holds only what the server said.
///
/// What the server did not say is `null` and is not drawn: the design's "son
/// net" is not in the student document (spec §6.3 #29), so there is no field
/// for it here.
@immutable
class StudentRowData {
  const StudentRowData({
    required this.id,
    required this.name,
    this.photo,
    this.grade,
    this.track,
    this.examCount,
  });

  /// The student's Mongo id; every coach-context call takes it.
  final String id;

  /// "Zeynep Kaya": first name and surname as one name.
  final String name;

  /// The avatar file name as the server keeps it; read it through
  /// `AvatarAsset.pathOf`.
  final String? photo;

  final SchoolGrade? grade;

  /// `null` for the 9th and 10th grade (they have no track) and when the
  /// server holds none.
  final StudyTrack? track;

  /// How many exams the student has read; `null` when none (so "0 deneme" is
  /// never written).
  final int? examCount;

  @override
  bool operator ==(Object other) =>
      other is StudentRowData &&
      other.id == id &&
      other.name == name &&
      other.photo == photo &&
      other.grade == grade &&
      other.track == track &&
      other.examCount == examCount;

  @override
  int get hashCode => Object.hash(id, name, photo, grade, track, examCount);

  @override
  String toString() => 'StudentRowData($id, $name)';
}

/// The rows of the coach's student list: building, Turkish alphabetical
/// order and name search (spec 10.2; decisions 9.3 and "Arama"). Pure and
/// unit-tested.
abstract final class StudentRows {
  /// The student's name as one line: the first name and the surname.
  ///
  /// A student the coach added carries `name` = first name and `surname`
  /// apart; a self-registered one carries the whole name in `name` and no
  /// surname. A surname that `name` already ends with is not written twice.
  /// Without any name the login name stands in; `null` when there is none.
  static String? fullName(CoachStudentDto student) {
    final first = _clean(student.name) ?? _clean(student.firstName);
    final surname = _clean(student.surname);
    if (first != null && surname != null) {
      final alreadyThere = TurkishText.fold(
        first,
      ).endsWith(TurkishText.fold(surname));
      return alreadyThere ? first : '$first $surname';
    }
    return first ?? surname ?? _clean(student.userName);
  }

  /// The list rows of [students], in Turkish alphabetical order of their full
  /// name (first name first: "Çağla Şahin" after "Cem Yıldız"); equal names
  /// keep their original order. A student without an id or without any name is
  /// left out: nothing can be opened for it, and a blank row says nothing.
  static List<StudentRowData> build(Iterable<CoachStudentDto> students) {
    final named = <({int index, StudentRowData row})>[];
    var index = 0;
    for (final student in students) {
      final id = student.id;
      final name = fullName(student);
      index++;
      if (id == null || name == null) continue;
      final grade = student.grade;
      final count = student.totalMexam;
      named.add((
        index: index,
        row: StudentRowData(
          id: id,
          name: name,
          photo: _clean(student.photo),
          grade: grade,
          track: grade != null && !grade.requiresTrack ? null : student.track,
          examCount: count != null && count > 0 ? count : null,
        ),
      ));
    }
    named.sort((a, b) {
      final byName = TurkishText.compare(a.row.name, b.row.name);
      return byName != 0 ? byName : a.index.compareTo(b.index);
    });
    return [for (final entry in named) entry.row];
  }

  /// The rows whose name matches [query]: every word of the query starts some
  /// word of the name, in any order, ignoring case and the Turkish marks
  /// ("aydin" finds "Kerem Aydın", "kerem a" too). It searches the name only,
  /// as the screen says ("Ad ve soyadda arar"), so every match has a mark to
  /// draw. A blank query keeps everyone; the order is kept.
  static List<StudentRowData> search(List<StudentRowData> rows, String query) {
    if (query.trim().isEmpty) return rows;
    return [
      for (final row in rows)
        if (TurkishText.matchesTokens(row.name, query)) row,
    ];
  }

  static String? _clean(String? text) {
    final value = text?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}
