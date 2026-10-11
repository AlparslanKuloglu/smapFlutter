/// A student's study track ("alan"), as the backend's `aimType` number.
///
/// The legacy code held two incompatible tables:
///
/// | screen | Sayısal | Eşit Ağırlık | Sözel | Dil |
/// |---|---|---|---|---|
/// | registration form, home, header, analytics filter | 3 | 2 | 4 | none |
/// | coach "Öğrenci Ekle" dialog | 1 | 2 | 3 | 4 |
///
/// This enum follows the first table, because it is the one the readers use
/// (header, home student cards, analytics `AytGroup`) and the one the
/// registration form writes. Students a coach added through the old dialog may
/// therefore carry a wrong `aimType` (1, 3 or 4 meaning something else); the
/// backend owner has to decide whether to correct that data (spec §6.3 #18).
///
/// `aimType` 0 and 1 are not tracks: the analytics requests drop them
/// ("no track"), so [fromCode] answers `null` for them.
///
/// The enum carries no Turkish text; the UI picks the label from l10n.
enum StudyTrack {
  /// "Eşit Ağırlık".
  esitAgirlik(2),

  /// "Sayısal".
  sayisal(3),

  /// "Sözel".
  sozel(4),

  /// "Dil". The design offers it, but no screen of the legacy app writes a
  /// confirmed code for it (the coach dialog's 4 collides with Sözel), so it
  /// has no [code] until the backend names one.
  dil(null);

  const StudyTrack(this.code);

  /// The `aimType` value on the wire; `null` while the backend has not named
  /// one ([dil]).
  final int? code;

  /// Whether this track can be sent to the backend.
  bool get isConfirmed => code != null;

  /// The tracks a picker can offer today: only those with a confirmed code,
  /// in the design's order (Sayısal, Eşit Ağırlık, Sözel).
  static const List<StudyTrack> selectable = [sayisal, esitAgirlik, sozel];

  /// Reads an `aimType`; `null` for a missing number, 0, 1 or anything the
  /// app does not know.
  static StudyTrack? fromCode(int? code) {
    if (code == null) return null;
    for (final track in values) {
      if (track.code == code) return track;
    }
    return null;
  }
}
