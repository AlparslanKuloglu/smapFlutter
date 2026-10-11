import 'package:flutter/foundation.dart' show immutable, listEquals, mapEquals;

import 'package:smap/features/lessons/domain/general_lesson.dart';

/// Where the subject icons live (`<host>/subjectIcons/<file>`). The legacy
/// screens hard-code this host; whether it is the CDN host is an open
/// question (spec §6.3 #41).
const String kSubjectIconBaseUrl = 'https://smaptr.com/subjectIcons/';

/// A main subject ("ana konu") of a lesson: a row of the lesson screen
/// (C22 `TopicRow`; board 7.2).
@immutable
class MainSubject {
  const MainSubject({
    required this.id,
    required this.name,
    this.order,
    this.imageFile,
    this.imageColorHex,
    this.barColorHex,
    this.missingCount,
  });

  final String id;
  final String name;

  /// The subject's number in the lesson ("1. Sözcükte Anlam").
  final int? order;

  /// Icon file name under [kSubjectIconBaseUrl].
  final String? imageFile;

  /// The icon tile's color as the server wrote it (`#RRGGBB`). The new
  /// screens use the lesson's subject tone instead; kept so nothing is lost.
  final String? imageColorHex;

  /// The bar's color as the server wrote it (`#RRGGBB`).
  final String? barColorHex;

  /// Missing items under this subject, when the answer counts them itself
  /// (`itemDataCount`: the Yazar & Eserler list and Edebiyat's subjects).
  /// For other lessons use [MissingByType].
  final int? missingCount;

  /// The icon's full URL, `null` without an icon.
  String? get imageUrl {
    final file = imageFile;
    return file == null || file.isEmpty ? null : '$kSubjectIconBaseUrl$file';
  }

  @override
  bool operator ==(Object other) =>
      other is MainSubject &&
      other.id == id &&
      other.name == name &&
      other.order == order &&
      other.imageFile == imageFile &&
      other.imageColorHex == imageColorHex &&
      other.barColorHex == barColorHex &&
      other.missingCount == missingCount;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    order,
    imageFile,
    imageColorHex,
    barColorHex,
    missingCount,
  );
}

/// One segment of a lesson's type filter ("TYT", "AYT", "SOS-2"):
/// `filterObjs[]` of `mainSubjects`.
@immutable
class LessonTypeFilter {
  const LessonTypeFilter({required this.name, required this.value});

  /// The segment's label as the server wrote it.
  final String name;

  /// The filter value: what `getItems` takes as `type` and what
  /// [MissingByType] is keyed by.
  final int value;

  @override
  bool operator ==(Object other) =>
      other is LessonTypeFilter && other.name == name && other.value == value;

  @override
  int get hashCode => Object.hash(name, value);
}

/// Missing items per filter value and main subject (`resultByType`), with the
/// legacy `getMissingCountForTab` rule.
@immutable
class MissingByType {
  const MissingByType(this.byType);

  const MissingByType.empty() : byType = const {};

  /// Filter value to (main subject id to missing count).
  final Map<int, Map<String, int>> byType;

  /// Missing items under the filter [value]; [GeneralLesson.allTracksFilter]
  /// ("Tümü") adds all filters up.
  int totalFor(int value) {
    if (value == GeneralLesson.allTracksFilter) {
      return byType.values.fold(
        0,
        (sum, subjects) => sum + subjects.values.fold(0, (a, b) => a + b),
      );
    }
    final subjects = byType[value];
    return subjects == null ? 0 : subjects.values.fold(0, (a, b) => a + b);
  }

  /// Missing items of one main subject under the filter [value] ("Tümü"
  /// reads the filter the subject is listed under).
  int forSubject(String subjectId, int value) {
    if (value == GeneralLesson.allTracksFilter) {
      return byType.values.fold(
        0,
        (sum, subjects) => sum + (subjects[subjectId] ?? 0),
      );
    }
    return byType[value]?[subjectId] ?? 0;
  }

  @override
  bool operator ==(Object other) {
    if (other is! MissingByType || other.byType.length != byType.length) {
      return false;
    }
    for (final entry in byType.entries) {
      final theirs = other.byType[entry.key];
      if (theirs == null || !mapEquals(theirs, entry.value)) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAllUnordered(
    byType.entries.map(
      (type) => Object.hash(
        type.key,
        Object.hashAllUnordered(
          type.value.entries.map((e) => Object.hash(e.key, e.value)),
        ),
      ),
    ),
  );
}

/// The answer of `mainSubjects`: a lesson's main subjects, its type filter and
/// the missing counts.
@immutable
class MainSubjects {
  const MainSubjects({
    this.subjects = const [],
    this.filters = const [],
    this.missing = const MissingByType.empty(),
  });

  final List<MainSubject> subjects;

  /// The type segments the server offers for the lesson, without "Tümü" (the
  /// legacy screen put "Tümü" (value 9) in front itself; whether to show it is
  /// a screen rule, spec §6.5 #4).
  final List<LessonTypeFilter> filters;

  final MissingByType missing;

  @override
  bool operator ==(Object other) =>
      other is MainSubjects &&
      other.missing == missing &&
      listEquals(other.subjects, subjects) &&
      listEquals(other.filters, filters);

  @override
  int get hashCode =>
      Object.hash(missing, Object.hashAll(subjects), Object.hashAll(filters));
}
