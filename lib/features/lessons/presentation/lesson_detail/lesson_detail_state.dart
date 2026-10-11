import 'package:flutter/foundation.dart';

import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/lesson_rows.dart';
import 'package:smap/features/lessons/application/lesson_segments.dart';
import 'package:smap/features/lessons/application/literature_authors.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// The title block of Ders Detayı: the glyph and the name (pano 7.2, 7.4).
@immutable
class LessonHeaderData {
  const LessonHeaderData({
    required this.name,
    required this.nameKind,
    required this.subject,
  });

  /// The lesson's own name.
  final String name;

  /// [LessonRowName.literature] words the name itself ("Türk Dili ve
  /// Edebiyatı").
  final LessonRowName nameKind;
  final SubjectKey? subject;

  @override
  bool operator ==(Object other) =>
      other is LessonHeaderData &&
      other.name == name &&
      other.nameKind == nameKind &&
      other.subject == subject;

  @override
  int get hashCode => Object.hash(name, nameKind, subject);
}

/// The "Eksiklerim" chip and "Kartlarım" button row (pano 7.2 y=158).
@immutable
class LessonFilterBarData {
  const LessonFilterBarData({
    this.visible = false,
    this.missingTotal,
    this.onlyMissing = false,
    this.cardsKnown,
    this.cardsTotal,
  });

  /// The row shows only on the topics section with its data loaded.
  final bool visible;

  /// The lesson's missing items over all tracks; `null` draws no chip.
  final int? missingTotal;
  final bool onlyMissing;

  /// The deck's progress for "Kartlarım · 41/64"; `null` without card data.
  final int? cardsKnown;
  final int? cardsTotal;

  @override
  bool operator ==(Object other) =>
      other is LessonFilterBarData &&
      other.visible == visible &&
      other.missingTotal == missingTotal &&
      other.onlyMissing == onlyMissing &&
      other.cardsKnown == cardsKnown &&
      other.cardsTotal == cardsTotal;

  @override
  int get hashCode =>
      Object.hash(visible, missingTotal, onlyMissing, cardsKnown, cardsTotal);
}

/// The category segment (pano 7.2 y=214).
@immutable
class LessonSegmentBarData {
  const LessonSegmentBarData({this.segments = const [], this.selected});

  /// Fewer than two options draw no segment.
  final List<LessonSegment> segments;

  /// The filter value of the chosen option.
  final int? selected;

  bool get visible => segments.length >= 2 && selected != null;

  @override
  bool operator ==(Object other) =>
      other is LessonSegmentBarData &&
      other.selected == selected &&
      listEquals(other.segments, segments);

  @override
  int get hashCode => Object.hash(selected, Object.hashAll(segments));
}

/// The topic list section (pano 7.2, 7.5 kare 1 and 2).
@immutable
class LessonTopicsData {
  const LessonTopicsData({
    required this.state,
    this.topics = const [],
    this.onlyMissing = false,
    this.segmentLabel,
    this.isAllSegment = false,
  });

  final SectionState state;

  /// The topics to draw, after the missing filter.
  final List<TopicListItem> topics;
  final bool onlyMissing;

  /// The chosen segment's name ("SOS-2") for the empty filter card.
  final String? segmentLabel;

  /// The chosen segment is "Tümü".
  final bool isAllSegment;

  @override
  bool operator ==(Object other) =>
      other is LessonTopicsData &&
      other.state == state &&
      other.onlyMissing == onlyMissing &&
      other.segmentLabel == segmentLabel &&
      other.isAllSegment == isAllSegment &&
      listEquals(other.topics, topics);

  @override
  int get hashCode => Object.hash(
    state,
    onlyMissing,
    segmentLabel,
    isAllSegment,
    Object.hashAll(topics),
  );
}

/// The author list section of the Edebiyat detail (pano 7.4 kare 1).
@immutable
class LessonAuthorsData {
  const LessonAuthorsData({
    required this.state,
    this.authors = const LiteratureAuthors([]),
  });

  final SectionState state;
  final LiteratureAuthors authors;

  @override
  bool operator ==(Object other) =>
      other is LessonAuthorsData &&
      other.state == state &&
      other.authors == authors;

  @override
  int get hashCode => Object.hash(state, authors);
}

/// What the Edebiyat section segment shows: its choice; `null` for a lesson
/// that has no sections.
@immutable
class LessonSectionData {
  const LessonSectionData(this.section);

  final LiteratureSection? section;

  @override
  bool operator ==(Object other) =>
      other is LessonSectionData && other.section == section;

  @override
  int get hashCode => section.hashCode;
}
