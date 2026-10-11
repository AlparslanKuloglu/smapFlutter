import 'package:smap/core/theme/app_motion.dart';

/// The four screens of the reset flow (pano 2.4 kare 1 to 4).
enum ForgotPasswordStep {
  /// "Şifreni sıfırla": the e-mail address.
  email,

  /// "Kodu gir": the six-digit code.
  code,

  /// "Yeni şifreni belirle": the new password twice.
  newPassword,

  /// "Şifren güncellendi".
  done;

  /// The step "geri" goes to; `null` where it leaves the flow (the first
  /// step) or cannot go back (the end).
  ForgotPasswordStep? get previous => switch (this) {
    email || done => null,
    code => email,
    newPassword => code,
  };
}

/// Pure rules of the reset flow (pano 2.4; spec §4.A "2.4"), unit-tested.
abstract final class ForgotPasswordRules {
  /// "ad@alan.com": something, an at sign, something, a dot, something
  /// (pano 2.4 "E-posta biçimi"). The server has the final say.
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Shortest new password (T7.5; spec Ç-58). The server is asked to check
  /// it too.
  static const int minPasswordLength = 8;

  /// How long "Kodu Tekrar Gönder" stays closed after a code was sent (pano
  /// 2.4 kare 2, T7.8).
  static const Duration resendDelay = SmapDurations.codeResend;

  /// The countdown of the resend button ticks once a second.
  static const Duration tick = Duration(seconds: 1);

  /// Whether [email] (as typed) looks like an address.
  static bool isEmail(String email) => _email.hasMatch(email.trim());

  /// Whether [password] is long enough.
  static bool isLongEnough(String password) =>
      password.length >= minPasswordLength;

  /// Whether the two fields hold the same password.
  static bool matches(String password, String repeat) => password == repeat;

  /// The countdown as the button shows it: "0:24", "0:05", "1:00".
  static String formatCountdown(int seconds) {
    final clamped = seconds < 0 ? 0 : seconds;
    final minutes = clamped ~/ 60;
    final rest = (clamped % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }
}
