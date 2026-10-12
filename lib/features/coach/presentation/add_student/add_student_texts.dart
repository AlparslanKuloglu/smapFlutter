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

/// The notice above "Öğrenciyi Kaydet" for a save that failed: what the failure
/// is in plain words, never a server code; a refusal with the backend's own
/// text (`validation`) shows that text.
String addStudentFailureText(AppLocalizations l10n, AppException failure) =>
    switch (failure.code) {
      AppErrorCode.offline => l10n.errors_offline,
      AppErrorCode.network => l10n.errors_network,
      AppErrorCode.timeout => l10n.errors_timeout,
      AppErrorCode.server => l10n.errors_server,
      AppErrorCode.maintenance => l10n.errors_maintenance,
      AppErrorCode.validation =>
        failure.serverMessage ?? l10n.errors_validation,
      _ => l10n.addStudent_saveFailed,
    };
