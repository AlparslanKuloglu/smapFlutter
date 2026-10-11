import 'dart:math' as math;

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/features/lessons/domain/lesson_content.dart';
import 'package:smap/features/lessons/domain/main_subjects.dart';

/// One work of an author with what the student knows of it (pano 7.4 kare 2
/// "Eserleri").
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
  final ItemCardState card;

  bool get isMissing => card == ItemCardState.missing;

  WorkView learned() => WorkView(
    title: title,
    progressId: progressId,
    card: ItemCardState.learned,
  );

  @override
  bool operator ==(Object other) =>
      other is WorkView &&
      other.title == title &&
      other.progressId == progressId &&
      other.card == card;

  @override
  int get hashCode => Object.hash(title, progressId, card);
}

/// The works of one type under their heading ("Roman": İntibah · Cezmi).
@immutable
class WorkGroup {
  const WorkGroup({required this.typeName, required this.works});

  /// "Roman", "Tiyatro"; `null` for the types outside the table, which the
  /// view heads "Diğer".
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

/// An author of the Yazar ve Eserler list (C28 `AuthorRow`, pano 7.4).
@immutable
class AuthorView {
  const AuthorView({
    required this.key,
    required this.name,
    required this.eraName,
    this.photo,
    this.biography = const [],
    this.groups = const [],
  });

  /// Identifies the author in the list.
  final String key;
  final String name;

  /// The era ("dönem") the row shows under the name: "Tanzimat".
  final String eraName;

  /// The photo's path under `assets` ("/authors/a/namikkemal.png"); `null`
  /// draws the initials.
  final String? photo;

  /// The "Hakkında" text, paragraph by paragraph.
  final List<String> biography;
  final List<WorkGroup> groups;

  /// The first letters of the first two words ("Halit Ziya Uşaklıgil" is
  /// "HZ").
  String get initials => AuthorInitials.of(name);

  /// The works whose card is missing.
  int get missingCount => [
    for (final group in groups)
      for (final work in group.works)
        if (work.isMissing) work,
  ].length;

  /// The progress ids of the missing works that can be sent.
  List<String> get missingProgressIds => [
    for (final group in groups)
      for (final work in group.works)
        if (work.isMissing && (work.progressId ?? '').isNotEmpty)
          work.progressId!,
  ];

  bool get hasWorks => groups.isNotEmpty;

  /// A copy where the works with the given progress ids are learned.
  AuthorView withLearned(Set<String> progressIds) => AuthorView(
    key: key,
    name: name,
    eraName: eraName,
    photo: photo,
    biography: biography,
    groups: [
      for (final group in groups)
        WorkGroup(
          typeName: group.typeName,
          works: [
            for (final work in group.works)
              progressIds.contains(work.progressId) && work.isMissing
                  ? work.learned()
                  : work,
          ],
        ),
    ],
  );

  @override
  bool operator ==(Object other) =>
      other is AuthorView &&
      other.key == key &&
      other.name == name &&
      other.eraName == eraName &&
      other.photo == photo &&
      listEquals(other.biography, biography) &&
      listEquals(other.groups, groups);

  @override
  int get hashCode => Object.hash(
    key,
    name,
    eraName,
    photo,
    Object.hashAll(biography),
    Object.hashAll(groups),
  );
}

/// The author list of the Edebiyat lesson (pano 7.4 kare 1).
@immutable
class LiteratureAuthors {
  const LiteratureAuthors(this.authors);

  /// Builds the list from the authors of each era, in era order.
  factory LiteratureAuthors.of(List<EraAuthors> eras) => LiteratureAuthors([
    for (final era in eras)
      for (final (index, author) in era.authors.indexed)
        _authorView(era.name, index, author),
  ]);

  final List<AuthorView> authors;

  bool get isEmpty => authors.isEmpty;

  AuthorView? authorOf(String key) {
    for (final author in authors) {
      if (author.key == key) return author;
    }
    return null;
  }

  /// A copy where [author] replaces the author with the same key.
  LiteratureAuthors withAuthor(AuthorView author) => LiteratureAuthors([
    for (final existing in authors)
      existing.key == author.key ? author : existing,
  ]);

  /// A copy where the works of [authorKey] with [progressIds] are learned.
  LiteratureAuthors withLearned(String authorKey, Set<String> progressIds) =>
      LiteratureAuthors([
        for (final author in authors)
          author.key == authorKey ? author.withLearned(progressIds) : author,
      ]);

  @override
  bool operator ==(Object other) =>
      other is LiteratureAuthors && listEquals(other.authors, authors);

  @override
  int get hashCode => Object.hashAll(authors);

  /// The generic placeholder photo of the assets; it is no portrait, so the
  /// row draws the initials instead.
  static const String _placeholderPhoto = 'author.png';

  static AuthorView _authorView(String eraName, int index, LessonItem author) {
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
      key: author.id ?? '$eraName:$index:${author.name}',
      name: author.name,
      eraName: eraName,
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

/// An era ("dönem") and its authors, as `getSubjectAuthors` answers.
@immutable
class EraAuthors {
  const EraAuthors({required this.name, required this.authors, this.id});

  final String? id;
  final String name;
  final List<LessonItem> authors;
}

/// Reads the authors of the Edebiyat lesson (spec §4.F 7.4): the main subjects
/// of Yazar ve Eserler, the sub-subjects and eras under them and the authors
/// of each era.
///
/// The old screen walked this tree by hand, one level at a time; the new one
/// shows the authors in one list with their era under the name, so the eras'
/// authors are read together, [batch] requests at a time. An item of a
/// sub-subject that is an author itself (`yazarCategory`, `itsYazar`) joins
/// the list under its sub-subject's name. If any request fails the whole load
/// fails: a list with an era missing would pass for the whole list.
class LiteratureLoader {
  const LiteratureLoader(this._repository, {this.batch = 6});

  final LessonContentRepository _repository;

  /// Requests for the authors of eras that run at the same time.
  final int batch;

  Future<AppResult<List<EraAuthors>>> load({String? studentId}) async {
    final mains = await _repository.getAuthorMainSubjects(studentId: studentId);
    final mainFailure = mains.leftOrNull;
    if (mainFailure != null) return Left(mainFailure);

    // Stage 1: the sub-subjects of every main subject, in order.
    final contents = await Future.wait([
      for (final main in mains.rightOrNull ?? const <MainSubject>[])
        _repository.getSubjectContent(
          mainSubjectId: main.id,
          authorMode: true,
          studentId: studentId,
        ),
    ]);
    final slots = <_Slot>[];
    for (final content in contents) {
      final failure = content.leftOrNull;
      if (failure != null) return Left(failure);
      for (final sub in content.rightOrNull ?? const <SubSubject>[]) {
        for (final item in sub.items) {
          final isAuthor = item.isAuthor || item.authorCategoryId != null;
          if (isAuthor) {
            slots.add(_Slot.direct(sub.name, item));
          } else if ((item.id ?? '').isNotEmpty) {
            slots.add(_Slot.era(item));
          }
        }
      }
    }

    // Stage 2: the authors of the eras, a few at a time.
    final eraSlots = [
      for (final slot in slots)
        if (slot.era != null) slot,
    ];
    for (var start = 0; start < eraSlots.length; start += batch) {
      final chunk = eraSlots.sublist(
        start,
        math.min(start + batch, eraSlots.length),
      );
      final answers = await Future.wait([
        for (final slot in chunk)
          _repository.getSubjectAuthors(
            itemId: slot.era!.id!,
            studentId: studentId,
          ),
      ]);
      for (final (index, answer) in answers.indexed) {
        final failure = answer.leftOrNull;
        if (failure != null) return Left(failure);
        chunk[index].authors = answer.rightOrNull ?? const [];
      }
    }

    final eras = <EraAuthors>[];
    for (final slot in slots) {
      final era = slot.era;
      if (era != null) {
        if (slot.authors.isNotEmpty) {
          eras.add(
            EraAuthors(id: era.id, name: era.name, authors: slot.authors),
          );
        }
      } else {
        eras.add(EraAuthors(name: slot.eraName, authors: [slot.author!]));
      }
    }
    return Right(_merge(eras));
  }

  /// Direct authors of one sub-subject sit together under its name.
  static List<EraAuthors> _merge(List<EraAuthors> eras) {
    final merged = <EraAuthors>[];
    for (final era in eras) {
      final last = merged.isEmpty ? null : merged.last;
      if (era.id == null &&
          last != null &&
          last.id == null &&
          last.name == era.name) {
        merged[merged.length - 1] = EraAuthors(
          name: last.name,
          authors: [...last.authors, ...era.authors],
        );
      } else {
        merged.add(era);
      }
    }
    return merged;
  }
}

class _Slot {
  _Slot.era(LessonItem item) : era = item, author = null, eraName = item.name;

  _Slot.direct(this.eraName, LessonItem item) : author = item, era = null;

  final LessonItem? era;
  final LessonItem? author;
  final String eraName;
  List<LessonItem> authors = const [];
}

/// The first letters of a person's name for an avatar (pano 7.4: "NK" for
/// Namık Kemal, "HZ" for Halit Ziya Uşaklıgil, "Ş" for Şinasi).
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
