import 'package:flutter/foundation.dart';

import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/application/register/username_live_check.dart';
import 'package:smap/features/coach/application/student_avatars.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/domain/new_student.dart';

/// The things on "Öğrenci Ekle" that can carry a message or take focus (pano
/// 10.3 kare 1), in the order they appear from top to bottom.
enum AddStudentField { firstName, lastName, username, password, grade, track }

/// What is wrong with a field. The sheet turns each into its Turkish line
/// (`coachStudents_issue*`); the ViewModel never holds text.
enum AddStudentIssue {
  /// "Öğrencinin adını yaz."
  firstNameMissing,

  /// "Öğrencinin soyadını yaz."
  lastNameMissing,

  /// "Bir kullanıcı adı yaz."
  usernameMissing,

  /// "Bu kullanıcı adı alınmış." (the live check or the server said so)
  usernameTaken,

  /// "Bir şifre yaz ya da Oluştur'a dokun."
  passwordMissing,

  /// "Şifre en az 8 karakter olmalı."
  passwordTooShort,

  /// "Sınıfı seç."
  gradeMissing,

  /// "Alanı seç."
  trackMissing,
}

/// The values of the form that the rules read. Immutable and comparable.
@immutable
class AddStudentValues {
  const AddStudentValues({
    this.firstName = '',
    this.lastName = '',
    this.username = '',
    this.password = '',
    this.grade,
    this.track,
    this.avatarIndex = StudentAvatars.initialIndex,
    this.usernameStatus = UsernameStatus.idle,
  });

  final String firstName;
  final String lastName;

  /// Already normalized (lower case; letters, digits, "." and "_").
  final String username;
  final String password;
  final SchoolGrade? grade;
  final StudyTrack? track;

  /// The chosen avatar, an index into [StudentAvatars.files].
  final int avatarIndex;

  /// What the live check last found out about [username].
  final UsernameStatus usernameStatus;

  /// Whether the "Alan" field is asked: 11th grade and above.
  bool get asksTrack => grade?.requiresTrack == true;
}

/// The rules of "Öğrenci Ekle" as pure functions (spec §4.I 10.3 "Kurallar";
/// decision 7.4 for the user name; 7.5 for the password length).
abstract final class AddStudentRules {
  /// A password is at least this long (decision 7.5, as at sign-up).
  static const int minPasswordLength = 8;

  /// The issue of one [field], `null` when it is fine.
  static AddStudentIssue? issueOf(AddStudentField field, AddStudentValues v) {
    switch (field) {
      case AddStudentField.firstName:
        return v.firstName.trim().isEmpty
            ? AddStudentIssue.firstNameMissing
            : null;
      case AddStudentField.lastName:
        return v.lastName.trim().isEmpty
            ? AddStudentIssue.lastNameMissing
            : null;
      case AddStudentField.username:
        if (v.usernameStatus == UsernameStatus.taken) {
          return AddStudentIssue.usernameTaken;
        }
        return v.username.isEmpty ? AddStudentIssue.usernameMissing : null;
      case AddStudentField.password:
        if (v.password.trim().isEmpty) return AddStudentIssue.passwordMissing;
        return v.password.length < minPasswordLength
            ? AddStudentIssue.passwordTooShort
            : null;
      case AddStudentField.grade:
        return v.grade == null ? AddStudentIssue.gradeMissing : null;
      case AddStudentField.track:
        return v.asksTrack && v.track == null
            ? AddStudentIssue.trackMissing
            : null;
    }
  }

  /// Every issue of the form, in screen order (the first is where focus goes
  /// on a failed submit).
  static Map<AddStudentField, AddStudentIssue> validate(AddStudentValues v) {
    final issues = <AddStudentField, AddStudentIssue>{};
    for (final field in AddStudentField.values) {
      final issue = issueOf(field, v);
      if (issue != null) issues[field] = issue;
    }
    return issues;
  }

  /// What the track becomes when the grade changes: kept while the grade
  /// still asks for one, dropped for 9 and 10 (the field turns passive).
  static StudyTrack? trackFor(SchoolGrade? grade, StudyTrack? track) =>
      grade?.requiresTrack == true ? track : null;

  /// The request for [v], `null` while the form has an issue.
  static NewStudent? toNewStudent(AddStudentValues v) {
    final grade = v.grade;
    if (validate(v).isNotEmpty || grade == null) return null;
    return NewStudent(
      firstName: v.firstName.trim(),
      lastName: v.lastName.trim(),
      userName: v.username,
      password: v.password,
      grade: grade,
      track: trackFor(grade, v.track),
      photo: StudentAvatars.fileOf(v.avatarIndex),
    );
  }
}

/// A student the coach has just added, with the login the coach has to pass
/// on (pano 10.3 kare 3 "Eklendi"): the server never sends the password back,
/// so it is the one typed or generated in the form, kept only until the
/// credentials sheet closes.
@immutable
class AddedStudent {
  const AddedStudent({
    required this.student,
    required this.fullName,
    required this.userName,
    required this.password,
    this.avatarIndex,
  });

  /// The student as the server created it (it joins the list).
  final CoachStudentDto student;

  /// "Zeynep Kaya", as the form had it.
  final String fullName;

  final String userName;
  final String password;

  /// The avatar chosen in the form; `null` when the choice is unknown.
  final int? avatarIndex;

  @override
  bool operator ==(Object other) =>
      other is AddedStudent &&
      other.student.id == student.id &&
      other.fullName == fullName &&
      other.userName == userName &&
      other.password == password &&
      other.avatarIndex == avatarIndex;

  @override
  int get hashCode =>
      Object.hash(student.id, fullName, userName, password, avatarIndex);

  /// Leaves the password out: it must not reach a log.
  @override
  String toString() => 'AddedStudent($fullName, $userName, password: ***)';
}
