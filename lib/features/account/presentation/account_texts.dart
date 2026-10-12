import 'package:smap/features/account/application/account_header.dart';
import 'package:smap/features/account/application/legal_entries.dart';
import 'package:smap/features/account/application/profile_draft.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The Turkish lines the account screens write for their domain values
/// (grade, track, legal texts, form issues); the values themselves carry no
/// text (`SchoolGrade`, `StudyTrack`).

/// "12. Sınıf", "Mezun".
String accountGradeLabel(AppLocalizations l10n, SchoolGrade grade) =>
    switch (grade) {
      SchoolGrade.graduate => l10n.account_gradeGraduate,
      _ => l10n.account_gradeValue(grade.code),
    };

/// "Eşit Ağırlık".
String accountTrackLabel(AppLocalizations l10n, StudyTrack track) =>
    switch (track) {
      StudyTrack.sayisal => l10n.account_trackSayisal,
      StudyTrack.esitAgirlik => l10n.account_trackEsitAgirlik,
      StudyTrack.sozel => l10n.account_trackSozel,
      StudyTrack.dil => l10n.account_trackDil,
    };

/// The title of a legal text: the server's own, else the one of its kind.
String legalEntryTitle(AppLocalizations l10n, LegalEntry entry) =>
    entry.title ??
    switch (entry.kind) {
      LegalKind.terms => l10n.account_contractTerms,
      LegalKind.kvkk => l10n.account_contractKvkk,
      LegalKind.privacy => l10n.account_contractPrivacy,
      LegalKind.other => '',
    };

/// The sub text of a legal text: its version, `null` when there is none.
String? legalEntryVersion(AppLocalizations l10n, LegalEntry entry) {
  final version = entry.version;
  return version == null ? null : l10n.account_contractVersion(version);
}

/// The field error of a profile issue (pano 9.2 kare 2).
String profileIssueText(AppLocalizations l10n, ProfileIssue issue) =>
    switch (issue) {
      ProfileIssue.nameMissing => l10n.account_issueNameMissing,
      ProfileIssue.emailInvalid => l10n.account_issueEmailInvalid,
      ProfileIssue.phoneInvalid => l10n.account_issuePhoneInvalid,
    };

/// The lines of the profile summary and the reading of the whole summary
/// (C37; pano 9.1 kare 1 and 4).
typedef SummaryTexts = ({List<String> lines, String semanticLabel});

/// Writes [header] for the summary row.
///
/// Student: "12. Sınıf · Eşit Ağırlık" and "Koçun: Mehmet Özkan" (a part the
/// account has no data for is left out), read as "Profil: Alparslan Kuloğlu,
/// 12. Sınıf, Eşit Ağırlık, koçun Mehmet Özkan". Coach: "Öğrenci koçu" and
/// "Koçluk kodun: MOZK-4821", read as "Profil: Mehmet Özkan, öğrenci koçu,
/// koçluk kodu MOZK-4821".
SummaryTexts accountSummaryTexts(AppLocalizations l10n, AccountHeader header) {
  final lines = <String>[];
  final spoken = <String>[if (header.name.isNotEmpty) header.name];
  if (header.isCoach) {
    lines.add(l10n.account_summaryCoachRole);
    spoken.add(l10n.account_a11yCoachRole);
    final code = header.coachCode;
    if (code != null) {
      lines.add(l10n.account_summaryCoachCode(code));
      spoken.add(l10n.account_a11yCoachCode(code));
    }
  } else {
    final grade = header.grade;
    final track = header.track;
    final gradeText = grade == null ? null : accountGradeLabel(l10n, grade);
    final trackText = track == null ? null : accountTrackLabel(l10n, track);
    if (gradeText != null && trackText != null) {
      lines.add(l10n.account_summaryGradeTrack(gradeText, trackText));
    } else if (gradeText != null || trackText != null) {
      lines.add((gradeText ?? trackText)!);
    }
    spoken.addAll([?gradeText, ?trackText]);
    final coach = header.coachName;
    if (coach != null) {
      lines.add(l10n.account_summaryCoach(coach));
      spoken.add(l10n.account_a11yCoachOf(coach));
    }
  }
  return (
    lines: lines,
    semanticLabel: l10n.account_a11yProfile(spoken.join(', ')),
  );
}
