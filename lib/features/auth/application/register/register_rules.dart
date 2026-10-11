import 'package:flutter/foundation.dart';

import 'package:smap/core/domain/user_role.dart';
import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/application/register/username_live_check.dart';

/// The things on the sign-up form that can carry a message or take focus
/// (pano 2.5, 2.6), in the order they appear from top to bottom.
enum RegisterField {
  fullName,
  username,
  email,
  password,
  passwordRepeat,
  grade,
  track,
  consent,
}

/// What is wrong with a field. The screen turns each into its Turkish line
/// (`register_issue*`); the ViewModel never holds text.
enum RegisterIssue {
  /// "Adını ve soyadını yaz."
  fullNameMissing,

  /// "Bir kullanıcı adı yaz."
  usernameMissing,

  /// "Bu kullanıcı adı alınmış." (pano 2.6 kare 1)
  usernameTaken,

  /// "E-posta adresi eksik görünüyor. Örn: ad@alan.com" (pano 2.6 kare 1)
  emailInvalid,

  /// "Şifren en az 8 karakter olmalı."
  passwordTooShort,

  /// "Şifreler aynı değil." (pano 2.6 kare 2)
  passwordMismatch,

  /// "Sınıfını seç."
  gradeMissing,

  /// "Alanını seç."
  trackMissing,

  /// "Kaydolmak için metinleri onaylaman gerekiyor." (pano 2.6 kare 2)
  consentMissing,
}

/// The values of the form that the rules read. Immutable and comparable.
@immutable
class RegisterFormValues {
  const RegisterFormValues({
    required this.role,
    this.fullName = '',
    this.username = '',
    this.email = '',
    this.password = '',
    this.passwordRepeat = '',
    this.grade,
    this.track,
    this.consent = false,
    this.usernameStatus = UsernameStatus.idle,
  });

  final UserRole role;
  final String fullName;
  final String username;
  final String email;
  final String password;
  final String passwordRepeat;
  final SchoolGrade? grade;
  final StudyTrack? track;
  final bool consent;

  /// What the live check last found out about [username].
  final UsernameStatus usernameStatus;

  bool get isStudent => role == UserRole.student;

  /// Whether the "Alan" field is asked: a student of grade 11 or above.
  bool get asksTrack => isStudent && grade?.requiresTrack == true;
}

/// The sign-up form's rules as pure functions (spec §4.A "2.5–2.6"; decision
/// 7.4 for the user name; 7.5 for the password).
abstract final class RegisterRules {
  /// A password is at least this long (decision 7.5; "En az 8 karakter.").
  static const int minPasswordLength = 8;

  /// A character a user name may hold: a letter, a digit, a dot or an
  /// underscore (decision 7.4).
  static final RegExp _userNameChar = RegExp(r'[\p{L}\p{N}._]', unicode: true);

  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@.]+(\.[^\s@.]+)+$');

  /// The user name as the form keeps it: Turkish lower case ("ALPARSLAN.K" →
  /// "alparslan.k") with every character that is not a letter, digit, dot or
  /// underscore dropped (a space, a dash, an emoji).
  static String normalizeUserName(String raw) {
    final lower = TurkishText.lower(raw);
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      if (_userNameChar.hasMatch(char)) buffer.write(char);
    }
    return buffer.toString();
  }

  /// Whether [userName] is what [normalizeUserName] leaves: not empty and only
  /// allowed characters.
  static bool isValidUserName(String userName) =>
      userName.isNotEmpty && normalizeUserName(userName) == userName;

  /// Whether [email] looks like an address: something, "@", a domain with at
  /// least one dot. Only a form check; the server decides the rest.
  static bool isValidEmail(String email) => _email.hasMatch(email.trim());

  /// The issue of one [field], `null` when it is fine.
  static RegisterIssue? issueOf(RegisterField field, RegisterFormValues v) {
    switch (field) {
      case RegisterField.fullName:
        return v.fullName.trim().isEmpty ? RegisterIssue.fullNameMissing : null;
      case RegisterField.username:
        if (v.usernameStatus == UsernameStatus.taken) {
          return RegisterIssue.usernameTaken;
        }
        return v.username.isEmpty ? RegisterIssue.usernameMissing : null;
      case RegisterField.email:
        return isValidEmail(v.email) ? null : RegisterIssue.emailInvalid;
      case RegisterField.password:
        return v.password.length < minPasswordLength
            ? RegisterIssue.passwordTooShort
            : null;
      case RegisterField.passwordRepeat:
        return v.passwordRepeat == v.password
            ? null
            : RegisterIssue.passwordMismatch;
      case RegisterField.grade:
        return v.isStudent && v.grade == null
            ? RegisterIssue.gradeMissing
            : null;
      case RegisterField.track:
        return v.asksTrack && v.track == null
            ? RegisterIssue.trackMissing
            : null;
      case RegisterField.consent:
        return v.consent ? null : RegisterIssue.consentMissing;
    }
  }

  /// Every issue of the form, in screen order (the first is where focus goes
  /// on a failed submit).
  static Map<RegisterField, RegisterIssue> validate(RegisterFormValues v) {
    final issues = <RegisterField, RegisterIssue>{};
    for (final field in RegisterField.values) {
      final issue = issueOf(field, v);
      if (issue != null) issues[field] = issue;
    }
    return issues;
  }

  /// What a student's [track] becomes when the [grade] changes: kept while
  /// the grade still asks for one, dropped for 9 and 10 (pano 2.6 kare 4: "Alan
  /// pasif").
  static StudyTrack? trackFor(SchoolGrade? grade, StudyTrack? track) =>
      grade?.requiresTrack == true ? track : null;
}
