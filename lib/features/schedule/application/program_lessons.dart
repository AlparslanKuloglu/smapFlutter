import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/subject_resolver.dart';

/// What the other SMAP clients draw a program block with: the icon file name
/// and the pale color the legacy editor stored in every task (`mapImage`,
/// `lessonColor`; see `ProgramTaskDraft`).
@immutable
class ProgramLessonStyle {
  const ProgramLessonStyle({required this.mapImage, required this.colorHex});

  /// Icon file name such as `icon1.png`.
  final String mapImage;

  /// `#RRGGBB`.
  final String colorHex;
}

/// The lessons a program topic can belong to, as the program screens need
/// them: the subject color key, a short name and the style the task carries
/// to the server.
///
/// The table is the legacy `AppLessons.allLessons` (`mapImage`, `lessonColor`)
/// keyed by the exam lesson's backend id (`ExamLessonCatalog`), moved here so
/// a new program writes the same values the old editor did.
abstract final class ProgramLessons {
  static const Map<String, ProgramLessonStyle> _styles = {
    // TYT
    '663e37a24fb443839593141b': ProgramLessonStyle(
      mapImage: 'icon1.png',
      colorHex: '#F7EDE4',
    ),
    '66214a6982ff212039ea3294': ProgramLessonStyle(
      mapImage: 'icon2.png',
      colorHex: '#FFEED6',
    ),
    '6660eec58cf59b23d04006b4': ProgramLessonStyle(
      mapImage: 'icon3.png',
      colorHex: '#D7EEFE',
    ),
    '663e387c4fb443839593141c': ProgramLessonStyle(
      mapImage: 'icon3.png',
      colorHex: '#FDE7E8',
    ),
    '66bfb7a749ecda29c59f556b': ProgramLessonStyle(
      mapImage: 'icon3.png',
      colorHex: '#CDE0FE',
    ),
    '665c5e80dad9088c202c6c16': ProgramLessonStyle(
      mapImage: 'icon6.png',
      colorHex: '#DBF4FF',
    ),
    '66604f1b2676809673eb4736': ProgramLessonStyle(
      mapImage: 'icon7.png',
      colorHex: '#FFE5EB',
    ),
    '6654977e17046de7432ed446': ProgramLessonStyle(
      mapImage: 'icon8.png',
      colorHex: '#D5F1CB',
    ),
    // AYT
    '66b0e776c99f8fc189ff35fd': ProgramLessonStyle(
      mapImage: 'icon1.png',
      colorHex: '#F7F5E8',
    ),
    '66b0e7e5c99f8fc189ff35ff': ProgramLessonStyle(
      mapImage: 'icon2.png',
      colorHex: '#FFEED6',
    ),
    '66952a89986199d2903227b5': ProgramLessonStyle(
      mapImage: 'icon3.png',
      colorHex: '#D7EEFE',
    ),
    '677ff5bb859149d419363f3d': ProgramLessonStyle(
      mapImage: 'icon2.png',
      colorHex: '#FFEED6',
    ),
    '677ff5d0859149d419363f3e': ProgramLessonStyle(
      mapImage: 'icon3.png',
      colorHex: '#D7EEFE',
    ),
    '665ca77316c299c4d7bd2534': ProgramLessonStyle(
      mapImage: 'icon3.png',
      colorHex: '#FDE7E8',
    ),
    '665cb46416c299c4d7bd2539': ProgramLessonStyle(
      mapImage: 'icon3.png',
      colorHex: '#CDE0FE',
    ),
    '665c5eacdad9088c202c6c17': ProgramLessonStyle(
      mapImage: 'icon6.png',
      colorHex: '#DBF4FF',
    ),
    '66604f252676809673eb4737': ProgramLessonStyle(
      mapImage: 'icon7.png',
      colorHex: '#FFE5EB',
    ),
    '6654978d17046de7432ed448': ProgramLessonStyle(
      mapImage: 'icon8.png',
      colorHex: '#D5F1CB',
    ),
  };

  /// The stored style of the exam lesson [lessonId], or `null`.
  static ProgramLessonStyle? styleOf(String? lessonId) =>
      lessonId == null ? null : _styles[lessonId];

  /// The subject color key of a lesson: from its backend id, else from its
  /// name; `null` for a lesson outside the nine (drawn neutral).
  static SubjectKey? subjectOf({String? lessonId, String? lessonName}) {
    final exam = ExamLessonCatalog.byId(lessonId);
    if (exam != null) return exam.subject;
    final general = LessonCatalog.byId(lessonId);
    if (general != null) return general.subject;
    if (lessonName == null || lessonName.trim().isEmpty) return null;
    return SubjectResolver.fromLessonName(lessonName);
  }

  /// The lesson's name as the program shows it: the stored [lessonName], else
  /// the catalog's name of [lessonId], else empty.
  static String nameOf({String? lessonId, String? lessonName}) {
    final stored = lessonName?.trim();
    if (stored != null && stored.isNotEmpty) return stored;
    return ExamLessonCatalog.byId(lessonId)?.name ??
        LessonCatalog.byId(lessonId)?.name ??
        '';
  }

  static final RegExp _examPrefix = RegExp(r'^(TYT|AYT)\s+');

  /// [name] without its exam prefix ("TYT Türkçe" is "Türkçe"): the short
  /// name for the week grid's small blocks.
  static String shortName(String name) => name.replaceFirst(_examPrefix, '');
}
