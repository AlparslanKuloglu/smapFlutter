/// A student's school year, as the backend's `seasonType` number.
///
/// One mapping for every screen. Where the legacy code disagreed, this is the
/// registration form's reading (9, 10, 11, 12 and "Mezun" = 13). The coach's
/// "Öğrenci Ekle" dialog never offered "Mezun" and defaulted a missing year to
/// 9; that is a screen decision now, not a mapping difference. Spec §6.3 #18
/// and #30 keep "does the server accept 13 from a coach?" open.
///
/// The enum carries no Turkish text: the UI picks the label ("9. Sınıf",
/// "Mezun") from its l10n file.
enum SchoolGrade {
  grade9(9),
  grade10(10),
  grade11(11),
  grade12(12),

  /// "Mezun". The registration form sends 13.
  graduate(13);

  const SchoolGrade(this.code);

  /// The `seasonType` value on the wire.
  final int code;

  /// Reads a `seasonType`; `null` for a missing or unknown number.
  static SchoolGrade? fromCode(int? code) {
    for (final grade in values) {
      if (grade.code == code) return grade;
    }
    return null;
  }

  /// Whether the student also picks a study track ("alan"): 11, 12 and
  /// "Mezun" do; 9 and 10 have none (registration form `_shouldShowField`,
  /// the coach dialog's "> 10").
  bool get requiresTrack => switch (this) {
    grade9 || grade10 => false,
    grade11 || grade12 || graduate => true,
  };

  /// `true` for the numbered school years (9 to 12).
  bool get isSchoolYear => this != graduate;
}
