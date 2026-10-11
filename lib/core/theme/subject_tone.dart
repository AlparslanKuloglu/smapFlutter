import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

/// The nine school subjects that carry their own color (board 1.5 "Ders
/// renkleri", handoff 11.12).
///
/// The spec leaves the enum value names open; these are the lowercase ASCII
/// Turkish names. Mapping a server lesson id to a key is lesson data and
/// lives in the lessons feature, not here. Glyphs (Phosphor `TextAa`,
/// `Feather`, `Bank`, `Globe`, `MathOperations`, `Angle`, `Atom`, `Flask`,
/// `Dna`) are also feature data (`SubjectGlyph`).
enum SubjectKey {
  /// Türkçe
  turkce,

  /// Edebiyat (Türk Dili ve Edebiyatı)
  edebiyat,

  /// Tarih
  tarih,

  /// Coğrafya
  cografya,

  /// Matematik
  matematik,

  /// Geometri
  geometri,

  /// Fizik
  fizik,

  /// Kimya
  kimya,

  /// Biyoloji
  biyoloji,
}

/// The two colors a subject takes in one theme: [bg] is the glyph tile and
/// tint, [fg] is the accent for the glyph, the 10 pt dot and the progress
/// fill (handoff 11.12: `Map<Subject, (Color bg, Color fg)>`).
///
/// The subject name is always `textPrimary`; [fg] never colors text (one
/// exception: the 13/700 subject name in a program block, spec §1.9). A
/// subject color never carries a correct/wrong/blank meaning.
@immutable
class SubjectTone {
  const SubjectTone(this.bg, this.fg);

  /// Tile and tint background.
  final Color bg;

  /// Glyph, dot and progress accent (at least 4,49:1 on [bg]).
  final Color fg;

  /// Light-theme tones, board 1.5 (open column).
  static const Map<SubjectKey, SubjectTone> light = {
    SubjectKey.turkce: SubjectTone(Color(0xFFF6ECE6), Color(0xFF93573C)),
    SubjectKey.edebiyat: SubjectTone(Color(0xFFF6E7EC), Color(0xFF8A2F4E)),
    SubjectKey.tarih: SubjectTone(Color(0xFFFBF1DA), Color(0xFF8C6106)),
    SubjectKey.cografya: SubjectTone(Color(0xFFE1EFFA), Color(0xFF1E6FAE)),
    SubjectKey.matematik: SubjectTone(Color(0xFFFDE8E8), Color(0xFFC42A36)),
    SubjectKey.geometri: SubjectTone(Color(0xFFE7E9FB), Color(0xFF4450BE)),
    SubjectKey.fizik: SubjectTone(Color(0xFFDDF2F2), Color(0xFF08737A)),
    SubjectKey.kimya: SubjectTone(Color(0xFFF7E8F7), Color(0xFF93359A)),
    SubjectKey.biyoloji: SubjectTone(Color(0xFFE4F3E3), Color(0xFF2B7A35)),
  };

  /// Dark-theme tones, board 1.5 (dark column).
  static const Map<SubjectKey, SubjectTone> dark = {
    SubjectKey.turkce: SubjectTone(Color(0xFF2D211C), Color(0xFFE2A98D)),
    SubjectKey.edebiyat: SubjectTone(Color(0xFF301A27), Color(0xFFE494BE)),
    SubjectKey.tarih: SubjectTone(Color(0xFF2C2513), Color(0xFFE3B651)),
    SubjectKey.cografya: SubjectTone(Color(0xFF12293C), Color(0xFF7DB9EC)),
    SubjectKey.matematik: SubjectTone(Color(0xFF341B1B), Color(0xFFF7847F)),
    SubjectKey.geometri: SubjectTone(Color(0xFF1D2144), Color(0xFFA3ABF4)),
    SubjectKey.fizik: SubjectTone(Color(0xFF0E2B2D), Color(0xFF5FCBD0)),
    SubjectKey.kimya: SubjectTone(Color(0xFF271B33), Color(0xFFC89AE3)),
    SubjectKey.biyoloji: SubjectTone(Color(0xFF16291A), Color(0xFF80CC89)),
  };

  /// Interpolates two tones, for theme animations.
  static SubjectTone lerp(SubjectTone a, SubjectTone b, double t) =>
      SubjectTone(Color.lerp(a.bg, b.bg, t)!, Color.lerp(a.fg, b.fg, t)!);

  @override
  bool operator ==(Object other) =>
      other is SubjectTone && other.bg == bg && other.fg == fg;

  @override
  int get hashCode => Object.hash(bg, fg);

  @override
  String toString() => 'SubjectTone(bg: $bg, fg: $fg)';
}
