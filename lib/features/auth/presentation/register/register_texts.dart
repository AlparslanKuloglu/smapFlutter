import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/application/register/register_rules.dart';
import 'package:smap/features/auth/presentation/register/register_notice.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The Turkish line of a field issue (pano 2.6 "Hata metinleri").
String registerIssueText(AppLocalizations l10n, RegisterIssue issue) =>
    switch (issue) {
      RegisterIssue.fullNameMissing => l10n.register_issueFullNameMissing,
      RegisterIssue.usernameMissing => l10n.register_issueUsernameMissing,
      RegisterIssue.usernameTaken => l10n.register_usernameTaken,
      RegisterIssue.emailInvalid => l10n.register_issueEmailInvalid,
      RegisterIssue.passwordTooShort => l10n.register_issuePasswordTooShort,
      RegisterIssue.passwordMismatch => l10n.register_issuePasswordMismatch,
      RegisterIssue.gradeMissing => l10n.register_issueGradeMissing,
      RegisterIssue.trackMissing => l10n.register_issueTrackMissing,
      RegisterIssue.consentMissing => l10n.register_consentRequired,
    };

/// "12. Sınıf", "Mezun".
String registerGradeLabel(AppLocalizations l10n, SchoolGrade grade) =>
    switch (grade) {
      SchoolGrade.graduate => l10n.register_gradeGraduate,
      _ => l10n.register_gradeValue(grade.code),
    };

/// "Eşit Ağırlık".
String registerTrackLabel(AppLocalizations l10n, StudyTrack track) =>
    switch (track) {
      StudyTrack.sayisal => l10n.register_trackSayisal,
      StudyTrack.esitAgirlik => l10n.register_trackEsitAgirlik,
      StudyTrack.sozel => l10n.register_trackSozel,
      StudyTrack.dil => l10n.register_trackDil,
    };

/// The sentence of the notice above "Kayıt Ol" (pano 2.6 "Gönderimde"): the
/// connection-level failures say so; a refusal shows the server's own text
/// when it sent one; everything else is the general "tamamlanamadı".
String registerNoticeText(AppLocalizations l10n, RegisterNotice notice) {
  if (notice.kind == RegisterNoticeKind.signInFailed) {
    return l10n.register_signInFailed;
  }
  return switch (notice.code) {
    AppErrorCode.offline => l10n.errors_offline,
    AppErrorCode.network => l10n.errors_network,
    AppErrorCode.timeout => l10n.errors_timeout,
    AppErrorCode.server => l10n.errors_server,
    AppErrorCode.maintenance => l10n.errors_maintenance,
    AppErrorCode.validation => notice.serverMessage ?? l10n.errors_validation,
    _ => l10n.register_submitFailed,
  };
}
