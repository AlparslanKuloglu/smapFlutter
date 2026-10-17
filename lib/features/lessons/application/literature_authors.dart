import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/features/lessons/domain/lesson_content.dart';

/// One work of an author with what the student knows of it (pano 14.6
/// "Eserleri"; `works[]`: `eser`, `type`, `itemData{_id, status}`).
@immutable
class WorkView {
  const WorkView({
    required this.title,
    this.progressId,
    this.card = ItemCardState.unknown,
  });

  final String title;

  /// The progress record's id: what "Öğrendim" takes.
  final String? progressId;

  /// Missing, learned, or unknown when the server sent no status (T12.14:
  /// only the title is drawn then).
  final ItemCardState card;

  bool get isMissing => card == ItemCardState.missing;
  bool get isLearned => card == ItemCardState.learned;

  /// "Öğrendim" can be sent: the work is missing and its record has an id.
  bool get canLearn => isMissing && (progressId ?? '').isNotEmpty;

  WorkView withCard(ItemCardState card) =>
      WorkView(title: title, progressId: progressId, card: card);

  @override
  bool operator ==(Object other) =>
      other is WorkView &&
      other.title == title &&
      other.progressId == progressId &&
      other.card == card;

  @override
  int get hashCode => Object.hash(title, progressId, card);
}

/// The works of one type under their heading ("Roman · 2": İntibah · Cezmi).
@immutable
class WorkGroup {
  const WorkGroup({required this.typeName, required this.works});

  /// "Roman", "Tiyatro"; `null` for a type code outside the table of 33,
  /// which the sheet heads "Diğer".
  final String? typeName;
  final List<WorkView> works;

  @override
  bool operator ==(Object other) =>
      other is WorkGroup &&
      other.typeName == typeName &&
      listEquals(other.works, works);

  @override
  int get hashCode => Object.hash(typeName, Object.hashAll(works));
}

/// An author of an era's sub-subject (C28 `AuthorRow`, pano 14.5 kare 2; the
/// author sheet, pano 14.6).
@immutable
class AuthorView {
  const AuthorView({
    required this.key,
    required this.name,
    this.photo,
    this.biography = const [],
    this.groups = const [],
  });

  /// Identifies the author inside its sub-subject.
  final String key;
  final String name;

  /// The photo's path under `assets` ("/authors/a/namikkemal.png"); `null`
  /// draws the initials.
  final String? photo;

  /// The "Hakkında" text, paragraph by paragraph.
  final List<String> biography;
  final List<WorkGroup> groups;

  /// The first letters of the first two words ("Halit Ziya Uşaklıgil" is
  /// "HZ").
  String get initials => AuthorInitials.of(name);

  Iterable<WorkView> get _works => [for (final group in groups) ...group.works];

  /// How many works the author has ("8 eser"); the length of `works`.
  int get workCount => _works.length;

  /// The works whose card is missing; works with no status are not counted
  /// (T12.14: "sayaçta yalnız N eser").
  int get missingCount => _works.where((work) => work.isMissing).length;

  bool get hasWorks => groups.isNotEmpty;

  /// The work with progress id [progressId], `null` for none.
  WorkView? workOf(String progressId) {
    for (final work in _works) {
      if (work.progressId == progressId) return work;
    }
    return null;
  }

  /// The type heading of the work with progress id [progressId]; `null` for
  /// none or a type outside the table.
  String? typeOf(String progressId) {
    for (final group in groups) {
      for (final work in group.works) {
        if (work.progressId == progressId) return group.typeName;
      }
    }
    return null;
  }

  /// The progress id of the first work that can be marked learned.
  String? get firstMissingId {
    for (final work in _works) {
      if (work.isMissing) return work.progressId;
    }
    return null;
  }

  /// A copy where the work with progress id [progressId] has [card]; the
  /// same author when there is no such work.
  AuthorView withWorkCard(String progressId, ItemCardState card) {
    if (workOf(progressId) == null) return this;
    return AuthorView(
      key: key,
      name: name,
      photo: photo,
      biography: biography,
      groups: [
        for (final group in groups)
          WorkGroup(
            typeName: group.typeName,
            works: [
              for (final work in group.works)
                work.progressId == progressId ? work.withCard(card) : work,
            ],
          ),
      ],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AuthorView &&
      other.key == key &&
      other.name == name &&
      other.photo == photo &&
      listEquals(other.biography, biography) &&
      listEquals(other.groups, groups);

  @override
  int get hashCode => Object.hash(
    key,
    name,
    photo,
    Object.hashAll(biography),
    Object.hashAll(groups),
  );
}

/// Builds an [AuthorView] from the server's author item.
abstract final class AuthorViews {
  /// The generic placeholder photo of the assets; it is no portrait, so the
  /// row draws the initials instead.
  static const String _placeholderPhoto = 'author.png';

  /// [index] only keeps the key unique for an author without an id.
  static AuthorView of(LessonItem author, {int index = 0}) {
    final photo = author.imageFile;
    final hasPhoto =
        photo != null &&
        photo.trim().isNotEmpty &&
        !photo.endsWith(_placeholderPhoto);
    final order = <String?>[];
    final byType = <String?, List<WorkView>>{};
    for (final work in author.works) {
      final type = work.typeName;
      if (!byType.containsKey(type)) order.add(type);
      byType
          .putIfAbsent(type, () => [])
          .add(
            WorkView(
              title: work.title,
              progressId: work.progress?.id,
              card: TopicOutline.cardStateOf(work.progress),
            ),
          );
    }
    // The types outside the table come last, under one heading.
    final sorted = [
      ...order.whereType<String>(),
      if (order.contains(null)) null,
    ];
    return AuthorView(
      key: author.id ?? '$index:${author.name}',
      name: author.name,
      photo: hasPhoto ? photo : null,
      biography: [
        for (final paragraph in author.descriptions)
          if (paragraph.trim().isNotEmpty) paragraph.trim(),
      ],
      groups: [
        for (final type in sorted)
          WorkGroup(typeName: type, works: byType[type]!),
      ],
    );
  }
}

/// The first letters of a person's name for an avatar (pano 14.5: "NK" for
/// Namık Kemal, "Ş" for Şinasi).
abstract final class AuthorInitials {
  /// The first letter of the first two words, upper case with the Turkish
  /// rule; one word gives one letter, a blank name nothing.
  static String of(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2);
    return words
        .map((word) => TurkishText.upper(String.fromCharCode(word.runes.first)))
        .join();
  }
}
