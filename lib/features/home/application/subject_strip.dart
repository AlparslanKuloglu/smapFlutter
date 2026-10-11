import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/application/subject_ordering.dart';
import 'package:smap/features/lessons/application/subject_resolver.dart';

/// One tile of "Derslerin" (C21 `SubjectTile`; pano 3.1 kare 1).
@immutable
class SubjectTileData {
  const SubjectTileData({
    required this.lessonId,
    required this.name,
    this.subject,
    this.missing,
    this.webOnly = false,
  });

  /// The general lesson's id.
  final String lessonId;

  /// The name the server sent ("Tarih"); the screen writes "Türk Dili ve
  /// Edebiyatı" for the literature lesson.
  final String name;

  /// The subject color; `null` for a lesson outside the nine.
  final SubjectKey? subject;

  /// Missing items over all tracks; `null` when the server did not count
  /// the lesson (no tag is drawn for unknown or zero).
  final int? missing;

  /// The lesson opens on the web (Matematik, Geometri): the "Web'de" tag.
  final bool webOnly;

  @override
  bool operator ==(Object other) =>
      other is SubjectTileData &&
      other.lessonId == lessonId &&
      other.name == name &&
      other.subject == subject &&
      other.missing == missing &&
      other.webOnly == webOnly;

  @override
  int get hashCode => Object.hash(lessonId, name, subject, missing, webOnly);
}

/// The tile strip of "Derslerin" (pano 3.1; assumption 6.5): the lesson with
/// the most missing items first, Matematik and Geometri last. Immutable with
/// value equality.
@immutable
class SubjectStrip {
  const SubjectStrip({required this.tiles, required this.hasMissingData});

  final List<SubjectTileData> tiles;

  /// At least one lesson has missing items. Without any the strip is the
  /// "yeni kullanıcı" one (pano 3.1 kare 3): no sub line, tiles with the
  /// glyph and the name only, no "eksik" and no "Web'de" tag.
  final bool hasMissingData;

  /// The strip of [entries] (`LessonsService.entries`).
  static SubjectStrip of(List<LessonEntry> entries) {
    final ordered = SubjectOrdering.tileOrder<LessonEntry>(
      entries,
      missingOf: (entry) => entry.totalMissing,
      isWebOnly: _isWebOnly,
    );
    final tiles = [
      for (final entry in ordered)
        SubjectTileData(
          lessonId: entry.lesson.id,
          name: entry.lesson.name,
          subject:
              entry.lesson.subject ??
              SubjectResolver.fromLessonName(entry.lesson.name),
          missing: entry.totalMissing,
          webOnly: _isWebOnly(entry),
        ),
    ];
    return SubjectStrip(
      tiles: List.unmodifiable(tiles),
      hasMissingData: tiles.any((tile) => (tile.missing ?? 0) > 0),
    );
  }

  /// The "Web'de" flag: the catalog's (Matematik, Geometri), else the
  /// server's `mindMap`.
  static bool _isWebOnly(LessonEntry entry) =>
      LessonCatalog.byId(entry.lesson.id)?.isWebOnly ?? entry.lesson.isWebOnly;

  @override
  bool operator ==(Object other) =>
      other is SubjectStrip &&
      other.hasMissingData == hasMissingData &&
      listEquals(other.tiles, tiles);

  @override
  int get hashCode => Object.hash(hasMissingData, Object.hashAll(tiles));
}
