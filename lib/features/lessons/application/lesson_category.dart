import 'package:smap/features/lessons/application/lesson_catalog.dart';

/// The category of a lesson the screens carry in a route (`cat=tyt|ayt|sos2|all`,
/// spec §3.6) and in the exam-type choice of Derslerim (pano 7.1, 7.2).
///
/// It is the segment of Ders Detayı ("Tümü", "TYT", "AYT", "SOS-2") as a
/// value, so a link can open a lesson on the right segment ("Tarih-2 → Tarih
/// detayı SOS-2 seçili açılır", karar 5.8).
enum LessonCat {
  /// "Tümü": every track of a lesson without tracks (filter value 9).
  all('all'),

  /// TYT.
  tyt('tyt'),

  /// AYT.
  ayt('ayt'),

  /// SOS-2 (Tarih-2, Coğrafya-2).
  sos2('sos2');

  const LessonCat(this.key);

  /// The route value and the stored value.
  final String key;

  /// The category a route value names; `null` for none or an unknown one.
  static LessonCat? parse(String? key) {
    if (key == null) return null;
    for (final cat in values) {
      if (cat.key == key) return cat;
    }
    return null;
  }

  /// The track the category stands for; `null` for [all].
  LessonTrack? get track => switch (this) {
    all => null,
    tyt => LessonTrack.tyt,
    ayt => LessonTrack.ayt,
    sos2 => LessonTrack.sos2,
  };

  /// The category of [track].
  static LessonCat ofTrack(LessonTrack track) => switch (track) {
    LessonTrack.tyt => tyt,
    LessonTrack.ayt => ayt,
    LessonTrack.sos2 => sos2,
  };

  /// The category a `getItems` filter value stands for: 1 TYT, 2 and 3 AYT
  /// (3 on the lessons that also have SOS-2), 4 SOS-2, 9 and anything else
  /// "Tümü" (the legacy dialog's numbers, `GeneralLesson.filterValueFor`).
  static LessonCat ofFilterValue(int value) => switch (value) {
    1 => tyt,
    2 || 3 => ayt,
    4 => sos2,
    _ => all,
  };
}

/// The two exam types of the Derslerim segment (pano 7.1 "TYT · AYT").
///
/// The choice is kept on the device (karar 5.8, `DevicePreferences.
/// lessonsExamTypeKey`) and opens a lesson on its own category.
enum LessonsExamType {
  tyt('tyt', LessonCat.tyt),
  ayt('ayt', LessonCat.ayt);

  const LessonsExamType(this.key, this.cat);

  /// The stored value.
  final String key;

  /// The category a lesson opens on from this list.
  final LessonCat cat;

  /// The exam type a stored value names; TYT for none or an unknown one.
  static LessonsExamType fromKey(String? key) {
    for (final type in values) {
      if (type.key == key) return type;
    }
    return tyt;
  }
}

/// The two sections of the Edebiyat detail (pano 7.4 "Konular · Yazar ve
/// Eserler"); the choice is kept on the device.
enum LiteratureSection {
  topics('topics'),
  authors('authors');

  const LiteratureSection(this.key);

  /// The route value and the stored value.
  final String key;

  /// The section a value names; `null` for none or an unknown one.
  static LiteratureSection? parse(String? key) {
    if (key == null) return null;
    for (final section in values) {
      if (section.key == key) return section;
    }
    return null;
  }
}
