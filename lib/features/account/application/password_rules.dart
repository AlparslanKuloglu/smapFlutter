/// A reason the "Şifre" form cannot be sent (pano 9.3 "Kurallar ve hata
/// metinleri"), each tied to the field that shows it.
enum PasswordIssue {
  /// The server refused the current password: "Mevcut şifren doğru değil."
  /// under the first field (kare 2).
  wrongCurrent(PasswordField.current),

  /// Under eight characters: the rule line "En az 8 karakter." under the new
  /// password turns red.
  tooShort(PasswordField.next),

  /// "Yeni şifre eskisiyle aynı olamaz." under the new password.
  sameAsCurrent(PasswordField.next),

  /// "Şifreler aynı değil." under the repeat field.
  mismatch(PasswordField.repeat);

  const PasswordIssue(this.field);

  /// The field the message is drawn under, and the one that takes the focus.
  final PasswordField field;
}

/// The three fields of "Şifre", top to bottom (pano 9.3 kare 1).
enum PasswordField { current, next, repeat }

/// Pure rules of "Şifre" (pano 9.3; spec §4.C "9.3"), unit-tested.
abstract final class PasswordRules {
  /// Shortest new password (T7.5, "ek şart yok"; spec Ç-58). The server is
  /// asked to check it too.
  static const int minLength = 8;

  /// "Düğme yalnız alanlar doluyken çalışır": all three fields hold
  /// something.
  static bool canSubmit(String current, String next, String repeat) =>
      current.isNotEmpty && next.isNotEmpty && repeat.isNotEmpty;

  /// What is wrong with the typed passwords, `null` when the form can go to
  /// the server. The first problem wins, top field first.
  static PasswordIssue? check(String current, String next, String repeat) {
    if (next.length < minLength) return PasswordIssue.tooShort;
    if (next == current) return PasswordIssue.sameAsCurrent;
    if (next != repeat) return PasswordIssue.mismatch;
    return null;
  }
}
