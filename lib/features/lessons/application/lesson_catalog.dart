import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';

/// The three tracks a lesson can be studied under: TYT, AYT and the AYT
/// "SOS-2" part of Tarih and Coğrafya.
///
/// [statsKey] is the key under which `getLessonsTotalMissing` counts the
/// missing items of the track (`"1"`, `"2"`, `"3"`).
enum LessonTrack {
  /// TYT.
  tyt('1'),

  /// AYT.
  ayt('2'),

  /// SOS-2 (Tarih-2, Coğrafya-2).
  sos2('3');

  const LessonTrack(this.statsKey);

  /// The key of the track in `getLessonsTotalMissing`'s per-lesson object.
  final String statsKey;
}

/// A lesson's ids on the backend: the single lesson of lessons without
/// tracks (Türkçe, Edebiyat), or one lesson per track.
@immutable
class LessonIds {
  const LessonIds({this.single, this.tyt, this.ayt, this.sos2});

  /// `lessonId`: Türkçe and Edebiyat have one lesson, not a track pair.
  final String? single;

  /// `lessonTyt`.
  final String? tyt;

  /// `lessonAyt`.
  final String? ayt;

  /// `lessonSos2`.
  final String? sos2;

  /// The lesson id to ask the backend for [track]; the single lesson when
  /// [track] is `null` or the lesson has no tracks.
  String? forTrack(LessonTrack? track) {
    final byTrack = switch (track) {
      LessonTrack.tyt => tyt,
      LessonTrack.ayt => ayt,
      LessonTrack.sos2 => sos2,
      null => null,
    };
    return byTrack ?? single;
  }

  /// Tarih and Coğrafya have a SOS-2 lesson.
  bool get hasSos2 => sos2 != null;

  @override
  bool operator ==(Object other) =>
      other is LessonIds &&
      other.single == single &&
      other.tyt == tyt &&
      other.ayt == ayt &&
      other.sos2 == sos2;

  @override
  int get hashCode => Object.hash(single, tyt, ayt, sos2);
}

/// One of the nine lessons of the home screen's "Derslerin" strip, as the
/// legacy app knows it (`AppLessons.generalLessons`): the backend's id, the
/// lesson ids per track and the flags the navigation reads.
@immutable
class GeneralLessonSpec {
  const GeneralLessonSpec({
    required this.id,
    required this.name,
    required this.subject,
    required this.order,
    required this.ids,
    this.hasTrackChoice = false,
    this.isWebOnly = false,
    this.isLiterature = false,
  });

  /// Id of the general lesson (what `getGeneralLessons` and
  /// `getLessonsTotalMissing` key by).
  final String id;

  final String name;

  /// The lesson's color key.
  final SubjectKey subject;

  /// Position on the strip.
  final int order;

  final LessonIds ids;

  /// `tytAyt == 1`: the lesson asks "TYT, AYT or SOS-2" before it opens.
  final bool hasTrackChoice;

  /// `mindMap == 1`: Matematik and Geometri open on the web ("Kavram
  /// Haritan"); the app has no screen for them yet.
  final bool isWebOnly;

  /// `edebiyat == 1`: the lesson has the "Yazar & Eserler" tab.
  final bool isLiterature;
}

/// The nine general lessons, moved from the old app's `AppLessons.generalLessons`
/// (that file is gone). The ids are the backend's ObjectIds, copied unchanged.
abstract final class LessonCatalog {
  static const List<GeneralLessonSpec> generalLessons = [
    GeneralLessonSpec(
      id: '69d3c972fdfe9f2106fa471e',
      name: 'Türkçe',
      subject: SubjectKey.turkce,
      order: 1,
      ids: LessonIds(single: '663e37a24fb443839593141b'),
    ),
    GeneralLessonSpec(
      id: '69d3ccc2fdfe9f2106fa471f',
      name: 'Tarih',
      subject: SubjectKey.tarih,
      order: 2,
      ids: LessonIds(
        tyt: '66214a6982ff212039ea3294',
        ayt: '66b0e7e5c99f8fc189ff35ff',
        sos2: '677ff5bb859149d419363f3d',
      ),
      hasTrackChoice: true,
    ),
    GeneralLessonSpec(
      id: '69d3cccbfdfe9f2106fa4720',
      name: 'Coğrafya',
      subject: SubjectKey.cografya,
      order: 3,
      // The legacy table lists the same id for AYT and SOS-2. The exam table
      // knows a separate "AYT Coğrafya-2" (677ff5d0859149d419363f3e); which
      // one is SOS-2 is an open backend question, so the legacy value stays.
      ids: LessonIds(
        tyt: '6660eec58cf59b23d04006b4',
        ayt: '66952a89986199d2903227b5',
        sos2: '66952a89986199d2903227b5',
      ),
      hasTrackChoice: true,
    ),
    GeneralLessonSpec(
      id: '69d3cce2fdfe9f2106fa4721',
      name: 'Edebiyat',
      subject: SubjectKey.edebiyat,
      order: 4,
      ids: LessonIds(single: '66b0e776c99f8fc189ff35fd'),
      isLiterature: true,
    ),
    GeneralLessonSpec(
      id: '69d3ccf8fdfe9f2106fa4722',
      name: 'Matematik',
      subject: SubjectKey.matematik,
      order: 5,
      ids: LessonIds(
        tyt: '663e387c4fb443839593141c',
        ayt: '665ca77316c299c4d7bd2534',
      ),
      isWebOnly: true,
    ),
    GeneralLessonSpec(
      id: '69d3cd07fdfe9f2106fa4723',
      name: 'Geometri',
      subject: SubjectKey.geometri,
      order: 6,
      ids: LessonIds(
        tyt: '66bfb7a749ecda29c59f556b',
        ayt: '665cb46416c299c4d7bd2539',
      ),
      isWebOnly: true,
    ),
    GeneralLessonSpec(
      id: '69d3cd24fdfe9f2106fa4724',
      name: 'Fizik',
      subject: SubjectKey.fizik,
      order: 7,
      ids: LessonIds(
        tyt: '665c5e80dad9088c202c6c16',
        ayt: '665c5eacdad9088c202c6c17',
      ),
      hasTrackChoice: true,
    ),
    GeneralLessonSpec(
      id: '69d3cd6bfdfe9f2106fa4725',
      name: 'Kimya',
      subject: SubjectKey.kimya,
      order: 8,
      ids: LessonIds(
        tyt: '66604f1b2676809673eb4736',
        ayt: '66604f252676809673eb4737',
      ),
      hasTrackChoice: true,
    ),
    GeneralLessonSpec(
      id: '69d3cd77fdfe9f2106fa4726',
      name: 'Biyoloji',
      subject: SubjectKey.biyoloji,
      order: 9,
      ids: LessonIds(
        tyt: '6654977e17046de7432ed446',
        ayt: '6654978d17046de7432ed448',
      ),
      hasTrackChoice: true,
    ),
  ];

  /// The general lesson with backend id [id], or `null`.
  static GeneralLessonSpec? byId(String? id) {
    if (id == null) return null;
    for (final lesson in generalLessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }
}

/// A lesson of an exam (a TYT or AYT test lesson such as "TYT Türkçe"), moved
/// from the legacy `AppLessons.allLessons`.
@immutable
class ExamLessonSpec {
  const ExamLessonSpec({
    required this.id,
    required this.name,
    required this.exam,
    required this.mexamOrder,
    required this.totalQuestion,
    required this.subject,
  });

  /// The lesson's backend id (what `lessonmockexams[].lesson` holds).
  final String id;

  /// "TYT Türkçe", "AYT Tarih-2".
  final String name;

  final NetExamType exam;

  /// Position of the lesson in its exam.
  final int mexamOrder;

  /// Questions of the lesson in one exam.
  final int totalQuestion;

  final SubjectKey subject;
}

/// The exam lessons by id.
///
/// The legacy `allLessons` repeats two ids: "AYT Matematik" carries TYT
/// Matematik's id and "AYT Geometri" carries TYT Geometri's. The same file's
/// `generalLessons` and the optical-reading screen's own name table agree on
/// the real AYT ids (`665ca77316c299c4d7bd2534`, `665cb46416c299c4d7bd2539`),
/// so those are used here.
abstract final class ExamLessonCatalog {
  static const List<ExamLessonSpec> all = [
    ExamLessonSpec(
      id: '663e37a24fb443839593141b',
      name: 'TYT Türkçe',
      exam: NetExamType.tyt,
      mexamOrder: 1,
      totalQuestion: 40,
      subject: SubjectKey.turkce,
    ),
    ExamLessonSpec(
      id: '66214a6982ff212039ea3294',
      name: 'TYT Tarih',
      exam: NetExamType.tyt,
      mexamOrder: 2,
      totalQuestion: 5,
      subject: SubjectKey.tarih,
    ),
    ExamLessonSpec(
      id: '6660eec58cf59b23d04006b4',
      name: 'TYT Coğrafya',
      exam: NetExamType.tyt,
      mexamOrder: 3,
      totalQuestion: 5,
      subject: SubjectKey.cografya,
    ),
    ExamLessonSpec(
      id: '663e387c4fb443839593141c',
      name: 'TYT Matematik',
      exam: NetExamType.tyt,
      mexamOrder: 6,
      totalQuestion: 30,
      subject: SubjectKey.matematik,
    ),
    ExamLessonSpec(
      id: '66bfb7a749ecda29c59f556b',
      name: 'TYT Geometri',
      exam: NetExamType.tyt,
      mexamOrder: 7,
      totalQuestion: 10,
      subject: SubjectKey.geometri,
    ),
    ExamLessonSpec(
      id: '665c5e80dad9088c202c6c16',
      name: 'TYT Fizik',
      exam: NetExamType.tyt,
      mexamOrder: 8,
      totalQuestion: 7,
      subject: SubjectKey.fizik,
    ),
    ExamLessonSpec(
      id: '66604f1b2676809673eb4736',
      name: 'TYT Kimya',
      exam: NetExamType.tyt,
      mexamOrder: 9,
      totalQuestion: 7,
      subject: SubjectKey.kimya,
    ),
    ExamLessonSpec(
      id: '6654977e17046de7432ed446',
      name: 'TYT Biyoloji',
      exam: NetExamType.tyt,
      mexamOrder: 10,
      totalQuestion: 6,
      subject: SubjectKey.biyoloji,
    ),
    ExamLessonSpec(
      id: '66b0e776c99f8fc189ff35fd',
      name: 'AYT Türk Dili ve Edebiyatı',
      exam: NetExamType.ayt,
      mexamOrder: 1,
      totalQuestion: 24,
      subject: SubjectKey.edebiyat,
    ),
    ExamLessonSpec(
      id: '66b0e7e5c99f8fc189ff35ff',
      name: 'AYT Tarih',
      exam: NetExamType.ayt,
      mexamOrder: 2,
      totalQuestion: 10,
      subject: SubjectKey.tarih,
    ),
    ExamLessonSpec(
      id: '66952a89986199d2903227b5',
      name: 'AYT Coğrafya',
      exam: NetExamType.ayt,
      mexamOrder: 3,
      totalQuestion: 6,
      subject: SubjectKey.cografya,
    ),
    ExamLessonSpec(
      id: '677ff5bb859149d419363f3d',
      name: 'AYT Tarih-2',
      exam: NetExamType.ayt,
      mexamOrder: 4,
      totalQuestion: 11,
      subject: SubjectKey.tarih,
    ),
    ExamLessonSpec(
      id: '677ff5d0859149d419363f3e',
      name: 'AYT Coğrafya-2',
      exam: NetExamType.ayt,
      mexamOrder: 5,
      totalQuestion: 11,
      subject: SubjectKey.cografya,
    ),
    ExamLessonSpec(
      id: '665ca77316c299c4d7bd2534',
      name: 'AYT Matematik',
      exam: NetExamType.ayt,
      mexamOrder: 8,
      totalQuestion: 30,
      subject: SubjectKey.matematik,
    ),
    ExamLessonSpec(
      id: '665cb46416c299c4d7bd2539',
      name: 'AYT Geometri',
      exam: NetExamType.ayt,
      mexamOrder: 9,
      totalQuestion: 10,
      subject: SubjectKey.geometri,
    ),
    ExamLessonSpec(
      id: '665c5eacdad9088c202c6c17',
      name: 'AYT Fizik',
      exam: NetExamType.ayt,
      mexamOrder: 10,
      totalQuestion: 14,
      subject: SubjectKey.fizik,
    ),
    ExamLessonSpec(
      id: '66604f252676809673eb4737',
      name: 'AYT Kimya',
      exam: NetExamType.ayt,
      mexamOrder: 11,
      totalQuestion: 13,
      subject: SubjectKey.kimya,
    ),
    ExamLessonSpec(
      id: '6654978d17046de7432ed448',
      name: 'AYT Biyoloji',
      exam: NetExamType.ayt,
      mexamOrder: 12,
      totalQuestion: 13,
      subject: SubjectKey.biyoloji,
    ),
  ];

  /// The exam lesson with backend id [id], or `null`.
  static ExamLessonSpec? byId(String? id) {
    if (id == null) return null;
    for (final lesson in all) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  /// The lessons of one exam type, in exam order.
  static List<ExamLessonSpec> of(NetExamType exam) => [
    for (final lesson in all)
      if (lesson.exam == exam) lesson,
  ];
}

/// The work types of the "Yazar & Eserler" tab (`work.type` ids), moved from
/// the legacy `EserTypeHelper.types`. The names are content labels of the
/// literature data, not screen copy.
abstract final class AuthorWorkTypes {
  static const Map<String, String> names = {
    '1': 'Şiir',
    '2': 'Roman',
    '3': 'Öykü',
    '4': 'Deneme',
    '5': 'Makale',
    '6': 'Tiyatro',
    '7': 'Hikâye',
    '8': 'Biyografi',
    '9': 'Gezi Yazısı',
    '10': 'Mektup',
    '11': 'Anı',
    '12': 'İnceleme/Araştırma',
    '13': 'Ders Kitabı',
    '14': 'Masal',
    '15': 'Çocuk Kitabı',
    '16': 'Fıkra',
    '17': 'Taşlama',
    '18': 'Röportaj',
    '19': 'Mizah',
    '20': 'Mülakat',
    '21': 'Sohbet',
    '22': 'Senaryo',
    '23': 'Günlük',
    '24': 'Eleştiri',
    '25': 'Mitoloji',
    '26': 'Özdeyiş',
    '27': 'Monografi',
    '28': 'Düzyazı',
    '29': 'Marş',
    '30': 'Şiir Kitabı',
    '31': 'Kitap',
    '32': 'Sözlük',
    '33': 'Mesnevi',
  };

  /// The name of work type [typeId]; `null` for an id outside the table (the
  /// legacy screen grouped those under "Diğer").
  static String? nameOf(String? typeId) =>
      typeId == null ? null : names[typeId];
}
