import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/topic_numbering.dart';
import 'package:smap/features/lessons/domain/general_lesson.dart';
import 'package:smap/features/lessons/domain/main_subjects.dart';

/// One option of the category segment of Ders Detayı (C04 counter segment;
/// pano 7.2 "Tümü · TYT · AYT", "TYT · AYT · SOS-2").
@immutable
class LessonSegment {
  const LessonSegment({
    required this.value,
    required this.cat,
    this.label,
    this.missing,
  });

  /// The `getItems` filter value of the option (`GeneralLesson.filterValueFor`,
  /// 9 for "Tümü").
  final int value;
  final LessonCat cat;

  /// The name as written ("TYT", "SOS-2"); `null` for "Tümü", which the view
  /// words itself.
  final String? label;

  /// Missing items under the option; `null` when nobody counted them (no
  /// counter line), zero is "eksik yok".
  final int? missing;

  @override
  bool operator ==(Object other) =>
      other is LessonSegment &&
      other.value == value &&
      other.cat == cat &&
      other.label == label &&
      other.missing == missing;

  @override
  int get hashCode => Object.hash(value, cat, label, missing);
}

/// The category segment of a lesson and the choice on it (pano 7.2). Pure and
/// unit-tested.
///
/// - A lesson **with tracks** (Tarih, Coğrafya, Fizik, Kimya, Biyoloji) lists
///   its tracks: TYT, AYT and, for Tarih and Coğrafya, SOS-2; there is no
///   "Tümü" (spec Ç-35). Each track is a backend lesson of its own.
/// - A lesson **without tracks** (Türkçe, Edebiyat) lists "Tümü" and the
///   filters the server names for it; its topics are the same under each
///   option, only the counts change.
/// - The counter of an option is the lesson's count of that track
///   (`getLessonsTotalMissing`); "Tümü" adds them up. A lesson whose counts
///   the server did not list falls back to what `mainSubjects` counts.
abstract final class LessonSegments {
  static const String tytLabel = 'TYT';
  static const String aytLabel = 'AYT';
  static const String sos2Label = 'SOS-2';

  /// The options of [lesson].
  static List<LessonSegment> of(
    GeneralLesson lesson, {
    LessonMissing? missing,
    List<LessonTypeFilter> filters = const [],
    MissingByType? byType,
  }) {
    int? countOf(LessonCat cat, int value) {
      final track = cat.track;
      if (missing != null) {
        return track == null ? missing.total : missing.of(track);
      }
      if (byType == null || byType.byType.isEmpty) return null;
      return byType.totalFor(value);
    }

    if (lesson.hasTrackChoice) {
      return [
        for (final track in lesson.tracks)
          LessonSegment(
            value: lesson.filterValueFor(track),
            cat: LessonCat.ofTrack(track),
            label: labelOf(track),
            missing: countOf(
              LessonCat.ofTrack(track),
              lesson.filterValueFor(track),
            ),
          ),
      ];
    }
    return [
      LessonSegment(
        value: GeneralLesson.allTracksFilter,
        cat: LessonCat.all,
        missing: countOf(LessonCat.all, GeneralLesson.allTracksFilter),
      ),
      for (final filter in filters)
        LessonSegment(
          value: filter.value,
          cat: LessonCat.ofFilterValue(filter.value),
          label: filter.name,
          missing: countOf(LessonCat.ofFilterValue(filter.value), filter.value),
        ),
    ];
  }

  /// The written name of [track].
  static String labelOf(LessonTrack track) => switch (track) {
    LessonTrack.tyt => tytLabel,
    LessonTrack.ayt => aytLabel,
    LessonTrack.sos2 => sos2Label,
  };

  /// The option to open on: the one of [requested]; without it (or when the
  /// lesson does not offer it) the one of [fallback] (the device's last exam
  /// type); and at last the first option.
  static LessonSegment pick(
    List<LessonSegment> segments, {
    LessonCat? requested,
    LessonCat? fallback,
  }) {
    for (final cat in [?requested, ?fallback]) {
      for (final segment in segments) {
        if (segment.cat == cat) return segment;
      }
    }
    return segments.first;
  }

  /// The backend lesson to ask for [segment]: the track's lesson for a lesson
  /// with tracks, the single lesson otherwise (its options only filter).
  static String? backendLessonId(GeneralLesson lesson, LessonSegment segment) =>
      lesson.hasTrackChoice
      ? lesson.ids.forTrack(segment.cat.track)
      : lesson.ids.single;
}

/// A topic of the list with its number and what is missing under it (C22
/// `TopicRow`; pano 7.2).
@immutable
class TopicListItem {
  const TopicListItem({
    required this.number,
    required this.id,
    required this.name,
    this.missing = 0,
  });

  /// The number in the full list, 1 to n without a gap.
  final int number;
  final String id;
  final String name;

  /// Missing items under the topic for the chosen segment; zero draws no tag.
  final int missing;

  @override
  bool operator ==(Object other) =>
      other is TopicListItem &&
      other.number == number &&
      other.id == id &&
      other.name == name &&
      other.missing == missing;

  @override
  int get hashCode => Object.hash(number, id, name, missing);
}

/// The topic list of Ders Detayı for one segment. Pure and unit-tested.
abstract final class LessonTopicList {
  /// Every topic of [subjects] with its number and missing count under the
  /// filter [value]. The server's own count (`MainSubject.missingCount`,
  /// Edebiyat) wins; otherwise `resultByType` is read.
  static List<TopicListItem> of(
    List<MainSubject> subjects,
    MissingByType byType,
    int value,
  ) => [
    for (final numbered in TopicNumbering.number(subjects))
      TopicListItem(
        number: numbered.number,
        id: numbered.topic.id,
        name: numbered.topic.name,
        missing:
            numbered.topic.missingCount ??
            byType.forSubject(numbered.topic.id, value),
      ),
  ];

  /// The topics with something missing, with the numbers they have in the
  /// full list (pano 7.2 kare 2: 8, 9 and 12).
  static List<TopicListItem> onlyMissing(List<TopicListItem> topics) => [
    for (final topic in topics)
      if (topic.missing > 0) topic,
  ];
}
