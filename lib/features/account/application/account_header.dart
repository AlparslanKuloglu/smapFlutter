import 'package:flutter/foundation.dart';

import 'package:smap/features/account/application/coach_code_text.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';

/// Whether the student's coach is known yet (pano 9.1 kare 1: "Koçun: Mehmet
/// Özkan", "Koçluk" / "Mehmet Özkan").
enum CoachLinkState {
  /// The coach has not been asked for yet, or the call failed: nothing about
  /// the coach is drawn (the design draws no error for it).
  unknown,

  /// The student has no coach: the "Koçluk" row says "Koçunla bağlan".
  none,

  /// The student has a coach, [AccountHeader.coachName] names them.
  linked,
}

/// What the profile summary of the Hesap band shows (C37 "ProfileSummary";
/// pano 9.1 kare 1 and 4), an immutable value the band's selector compares.
///
/// Student: the name, "12. Sınıf · Eşit Ağırlık" and "Koçun: Mehmet Özkan";
/// coach: the name, "Öğrenci koçu" and "Koçluk kodun: MOZK-4821". A line the
/// account has no data for is not drawn (the grade, the track, the coach, the
/// code); the texts are the screen's (l10n), this holds the facts. Pure and
/// unit-tested.
@immutable
class AccountHeader {
  const AccountHeader({
    required this.name,
    required this.isCoach,
    this.photo,
    this.grade,
    this.track,
    this.coachName,
    this.refCode,
  });

  /// The summary of [user]; [coachName] is the student's coach when known.
  factory AccountHeader.of(UserDto user, {String? coachName}) {
    final grade = SchoolGrade.fromCode(user.seasonType);
    final name = coachName?.trim();
    return AccountHeader(
      name: user.displayName ?? '',
      isCoach: user.userRole.isCoach,
      photo: user.photo,
      grade: grade,
      track: grade != null && !grade.requiresTrack
          ? null
          : StudyTrack.fromCode(user.aimType),
      coachName: name == null || name.isEmpty ? null : name,
      refCode: user.refCode,
    );
  }

  /// The name to show.
  final String name;

  /// Coach side: "Öğrenci koçu" and the coaching code instead of the grade.
  final bool isCoach;

  /// The avatar file name; the initials show when it is empty.
  final String? photo;

  /// Student: the school year.
  final SchoolGrade? grade;

  /// Student: the study track (none in the 9th and 10th grade).
  final StudyTrack? track;

  /// Student: the coach's name once known.
  final String? coachName;

  /// Coach: the code students link with, as the server holds it.
  final String? refCode;

  /// The code as the design writes it, `MOZK-4821`; text of another shape is
  /// shown as it is; `null` without a code.
  String? get coachCode => CoachCodeText.shown(refCode);

  /// How many lines the summary writes under the name: a student's grade and
  /// track line and "Koçun: …", a coach's role and "Koçluk kodun: …". Lines
  /// the account has no data for are not counted (and not drawn).
  int get subLineCount => isCoach
      ? 1 + (coachCode != null ? 1 : 0)
      : (grade != null || track != null ? 1 : 0) + (coachName != null ? 1 : 0);

  @override
  bool operator ==(Object other) =>
      other is AccountHeader &&
      other.name == name &&
      other.isCoach == isCoach &&
      other.photo == photo &&
      other.grade == grade &&
      other.track == track &&
      other.coachName == coachName &&
      other.refCode == refCode;

  @override
  int get hashCode =>
      Object.hash(name, isCoach, photo, grade, track, coachName, refCode);
}
