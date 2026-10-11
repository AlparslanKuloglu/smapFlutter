import 'package:flutter/foundation.dart' show immutable, mapEquals;

import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/subject_resolver.dart';

/// One lesson of the "Derslerin" strip (C21 `SubjectTile`; board 3.1), as
/// `getGeneralLessons` lists it. Ids the answer does not carry come from the
/// [LessonCatalog], the way the legacy screens did.
@immutable
class GeneralLesson {
  const GeneralLesson({
    required this.id,
    required this.name,
    required this.order,
    required this.ids,
    this.imageFile,
    this.hasTrackChoice = false,
    this.isWebOnly = false,
    this.isLiterature = false,
  });

  /// Id of the general lesson; the key of `getLessonsTotalMissing`.
  final String id;

  /// "Matematik", "Türkçe".
  final String name;

  /// Position on the strip.
  final int order;

  /// The backend lesson ids (single or per track).
  final LessonIds ids;

  /// Icon file the server names (`/icons/open-book.png`); the app draws its
  /// own glyph, this is kept for completeness.
  final String? imageFile;

  /// The lesson asks "TYT, AYT or SOS-2" before it opens.
  final bool hasTrackChoice;

  /// The lesson opens on the web (Matematik, Geometri).
  final bool isWebOnly;

  /// The lesson has the "Yazar & Eserler" tab (Edebiyat).
  final bool isLiterature;

  /// The lesson's color key; `null` for a lesson outside the nine.
  SubjectKey? get subject =>
      LessonCatalog.byId(id)?.subject ?? SubjectResolver.fromLessonName(name);

  /// The tracks the lesson offers: TYT and AYT, plus SOS-2 for Tarih and
  /// Coğrafya. Empty for a lesson without tracks (Türkçe, Edebiyat).
  List<LessonTrack> get tracks => hasTrackChoice
      ? [LessonTrack.tyt, LessonTrack.ayt, if (ids.hasSos2) LessonTrack.sos2]
      : const [];

  /// The `value` the lesson's type filter uses for [track]
  /// (`mainSubjects`' `filterObjs[].value`, `getItems`' `type`): TYT 1; AYT 2,
  /// or 3 for the lessons that also have SOS-2; SOS-2 4. The legacy dialog's
  /// numbers. 9 is "Tümü" ([allTracksFilter]).
  int filterValueFor(LessonTrack track) => switch (track) {
    LessonTrack.tyt => 1,
    LessonTrack.ayt => ids.hasSos2 ? 3 : 2,
    LessonTrack.sos2 => 4,
  };

  /// The filter value "Tümü" (all tracks): what a lesson without tracks opens
  /// with.
  static const int allTracksFilter = 9;

  @override
  bool operator ==(Object other) =>
      other is GeneralLesson &&
      other.id == id &&
      other.name == name &&
      other.order == order &&
      other.ids == ids &&
      other.imageFile == imageFile &&
      other.hasTrackChoice == hasTrackChoice &&
      other.isWebOnly == isWebOnly &&
      other.isLiterature == isLiterature;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    order,
    ids,
    imageFile,
    hasTrackChoice,
    isWebOnly,
    isLiterature,
  );
}

/// How many items of a lesson are still missing, per track
/// (`getLessonsTotalMissing`; spec §6.3 #21, board 3.1 "Eksik" tags).
///
/// A track the server did not count is `null` (unknown), not 0.
@immutable
class LessonMissing {
  const LessonMissing({this.tyt, this.ayt, this.sos2});

  final int? tyt;
  final int? ayt;
  final int? sos2;

  /// The count of [track]; `null` when unknown.
  int? of(LessonTrack track) => switch (track) {
    LessonTrack.tyt => tyt,
    LessonTrack.ayt => ayt,
    LessonTrack.sos2 => sos2,
  };

  /// All tracks added up; `null` when no track was counted.
  int? get total {
    final counts = [tyt, ayt, sos2].whereType<int>();
    return counts.isEmpty ? null : counts.fold<int>(0, (a, b) => a + b);
  }

  /// A copy with the count of [track] one lower (an item was learned),
  /// never below 0; unchanged when the track is unknown.
  LessonMissing withOneLearned(LessonTrack track) {
    final current = of(track);
    if (current == null || current <= 0) return this;
    return switch (track) {
      LessonTrack.tyt => LessonMissing(tyt: current - 1, ayt: ayt, sos2: sos2),
      LessonTrack.ayt => LessonMissing(tyt: tyt, ayt: current - 1, sos2: sos2),
      LessonTrack.sos2 => LessonMissing(tyt: tyt, ayt: ayt, sos2: current - 1),
    };
  }

  @override
  bool operator ==(Object other) =>
      other is LessonMissing &&
      other.tyt == tyt &&
      other.ayt == ayt &&
      other.sos2 == sos2;

  @override
  int get hashCode => Object.hash(tyt, ayt, sos2);
}

/// The answer of `getLessonsTotalMissing`: [LessonMissing] per general lesson
/// id. A lesson the answer does not list has no entry.
@immutable
class LessonsMissing {
  const LessonsMissing(this.byLesson);

  const LessonsMissing.empty() : byLesson = const {};

  final Map<String, LessonMissing> byLesson;

  LessonMissing? of(String generalLessonId) => byLesson[generalLessonId];

  @override
  bool operator ==(Object other) =>
      other is LessonsMissing && mapEquals(other.byLesson, byLesson);

  @override
  int get hashCode =>
      Object.hashAll(byLesson.entries.map((e) => Object.hash(e.key, e.value)));
}
