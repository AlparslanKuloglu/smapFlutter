import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/utils/turkish_text.dart';

/// Finds the subject color of a lesson from its name (C58 `SubjectGlyph`;
/// pano 1.5 "Ders Renkleri").
///
/// The server sends lesson names, not a fixed key ("Türk Dili ve Edebiyatı",
/// "Tarih-2", "Coğrafya-2", "Temel Matematik"). Names are matched through
/// `TurkishText.fold`, so case and Turkish marks do not matter. A lesson with
/// no subject color of its own (a name outside the nine) gets null and is
/// drawn neutral. Pure and unit-tested.
abstract final class SubjectResolver {
  /// The subject of [lessonName], or null when it is none of the nine.
  ///
  /// Rules, first match wins (the order matters: "Türk Dili ve Edebiyatı"
  /// contains "turk", "Temel Matematik" contains "matematik"):
  /// `edebiyat` → Edebiyat; `turkce` → Türkçe; `tarih` → Tarih; `cografya`
  /// → Coğrafya; `matematik` → Matematik; `geometri` → Geometri; `fizik`,
  /// `kimya`, `biyoloji` → themselves.
  static SubjectKey? fromLessonName(String lessonName) {
    final key = TurkishText.fold(lessonName);
    for (final (needle, subject) in _rules) {
      if (key.contains(needle)) return subject;
    }
    return null;
  }

  static const List<(String, SubjectKey)> _rules = [
    ('edebiyat', SubjectKey.edebiyat),
    ('turkce', SubjectKey.turkce),
    ('tarih', SubjectKey.tarih),
    ('cografya', SubjectKey.cografya),
    ('matematik', SubjectKey.matematik),
    ('geometri', SubjectKey.geometri),
    ('fizik', SubjectKey.fizik),
    ('kimya', SubjectKey.kimya),
    ('biyoloji', SubjectKey.biyoloji),
  ];
}
