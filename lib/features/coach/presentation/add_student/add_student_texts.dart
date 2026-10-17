import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/features/coach/application/add_student_rules.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The Turkish line of a field issue of "Öğrenci ekle" (pano 10.3 "hata alanın
/// altında gösterilir").
String addStudentIssueText(AppLocalizations l10n, AddStudentIssue issue) =>
    switch (issue) {
      AddStudentIssue.firstNameMissing => l10n.addStudent_issueFirstName,
      AddStudentIssue.lastNameMissing => l10n.addStudent_issueLastName,
      AddStudentIssue.usernameMissing => l10n.addStudent_issueUsername,
      AddStudentIssue.usernameTaken => l10n.addStudent_usernameTaken,
      AddStudentIssue.passwordMissing => l10n.addStudent_issuePasswordMissing,
      AddStudentIssue.passwordTooShort => l10n.addStudent_issuePasswordShort,
      AddStudentIssue.gradeMissing => l10n.addStudent_issueGrade,
      AddStudentIssue.trackMissing => l10n.addStudent_issueTrack,
    };

/// The error toast of a save that failed (pano 14.8 kare 5): "Öğrenci
/// kaydedilemedi. Bağlantını kontrol edip tekrar dene." for a lost connection,
/// a timeout, a server fault or anything unexpected; never a server code. A
/// refusal with the backend's own text (`validation`) shows that text, and a
/// maintenance window says so.
String addStudentFailureText(AppLocalizations l10n, AppException? failure) {
  if (failure == null) return l10n.addStudent_saveFailed;
  return switch (failure.code) {
    AppErrorCode.maintenance => l10n.errors_maintenance,
    AppErrorCode.validation => failure.serverMessage ?? l10n.errors_validation,
    _ => l10n.addStudent_saveFailed,
  };
}
