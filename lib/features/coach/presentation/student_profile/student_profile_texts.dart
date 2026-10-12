import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/account/presentation/account_texts.dart';
import 'package:smap/features/coach/application/student_profile.dart';
import 'package:smap/features/coach/presentation/widgets/coach_avatars.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';

/// The Turkish lines Öğrenci Profili writes for a [StudentProfile] (pano
/// 10.4). The values carry no text (`SchoolGrade`, `StudyTrack`); the labels
/// are the account screens' ("12. Sınıf", "Eşit Ağırlık").
abstract final class StudentProfileTexts {
  /// The meta line under the name, "alparslan.k · 10 deneme": the login name
  /// and the exam count, whichever the document has; `null` when it has
  /// neither (no line is drawn). The design's "son 5 Eki. 2026" is not in the
  /// document, so it is not written.
  static String? meta(AppLocalizations l10n, StudentProfile profile) {
    final count = profile.examCount;
    final parts = [
      ?profile.userName,
      if (count != null) l10n.students_examCount(TrFormat.sira(count)),
    ];
    if (parts.isEmpty) return null;
    return parts.reduce((joined, next) => l10n.students_metaJoin(joined, next));
  }

  /// The short form of [track] in the context strip: "EA", "SAY", "SÖZ", "DİL".
  static String trackShort(AppLocalizations l10n, StudyTrack track) =>
      switch (track) {
        StudyTrack.sayisal => l10n.coachStudentProfile_trackShortSayisal,
        StudyTrack.esitAgirlik =>
          l10n.coachStudentProfile_trackShortEsitAgirlik,
        StudyTrack.sozel => l10n.coachStudentProfile_trackShortSozel,
        StudyTrack.dil => l10n.coachStudentProfile_trackShortDil,
      };

  /// The right side of the context strip, "12. Sınıf · EA"; the part the
  /// document does not have is left out; `null` when neither is known.
  static String? stripDetail(AppLocalizations l10n, StudentProfile profile) {
    final grade = profile.grade;
    final track = profile.track;
    if (grade == null && track == null) return null;
    if (grade == null) return trackShort(l10n, track!);
    final gradeText = accountGradeLabel(l10n, grade);
    if (track == null) return gradeText;
    return l10n.coachStudentProfile_stripDetail(
      gradeText,
      trackShort(l10n, track),
    );
  }

  /// The spoken form of [stripDetail], "12. Sınıf, Eşit Ağırlık".
  static String? stripDetailSemantics(
    AppLocalizations l10n,
    StudentProfile profile,
  ) {
    final grade = profile.grade;
    final track = profile.track;
    if (grade == null && track == null) return null;
    if (grade == null) return accountTrackLabel(l10n, track!);
    final gradeText = accountGradeLabel(l10n, grade);
    if (track == null) return gradeText;
    return l10n.coachStudentProfile_stripDetailA11y(
      gradeText,
      accountTrackLabel(l10n, track),
    );
  }

  /// The student as every coach screen under the profile carries it: id, name,
  /// picture, the strip's class and field and the study field for the exam
  /// scores.
  static StudentRef ref(AppLocalizations l10n, StudentProfile profile) =>
      StudentRef(
        id: profile.id,
        name: profile.name,
        avatar: CoachAvatars.imageOf(profile.photo),
        detail: stripDetail(l10n, profile),
        detailSemantics: stripDetailSemantics(l10n, profile),
        aimType: profile.aimType,
      );
}
