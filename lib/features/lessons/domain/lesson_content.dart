import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/features/lessons/application/lesson_catalog.dart';

/// Whether the student has learned an item, and for each of its cards
/// (`itemData` of an item: `status`, `statusArray`, `itsIndependent`).
///
/// An item holds one card per `prompts` entry; `statusArray[i]` is the status
/// of card `i` (1 learned, 0 missing).
@immutable
class ItemProgress {
  const ItemProgress({
    this.id,
    this.status,
    this.statusArray = const [],
    this.isIndependent = false,
    this.subjectId,
  });

  /// Id of the progress record (`itemData._id`): what `learnedItem` takes.
  final String? id;

  /// `1` learned, `0` missing; `null` when the server sent none.
  final int? status;

  /// Status per card (1 learned, 0 missing).
  final List<int> statusArray;

  /// `itsIndependent == 1`: a stand-alone question whose single status is
  /// [status].
  final bool isIndependent;

  /// The main subject the record belongs to (`subject`).
  final String? subjectId;

  /// The item or one of its cards is missing (the legacy "alert" rule:
  /// `status == 0` or a 0 in `statusArray`); drives the red card icon.
  bool get hasMissing => status == 0 || statusArray.contains(0);

  /// The item is learned: `status == 1` and no card is missing.
  bool get isLearned => status == 1 && !statusArray.contains(0);

  /// How many cards are missing (the legacy count): the zeros of
  /// [statusArray]; with no card list, 1 for a stand-alone item whose status
  /// is 0; otherwise 0.
  int get missingCount {
    if (statusArray.isNotEmpty) return statusArray.where((s) => s == 0).length;
    return isIndependent && status == 0 ? 1 : 0;
  }

  @override
  bool operator ==(Object other) =>
      other is ItemProgress &&
      other.id == id &&
      other.status == status &&
      other.isIndependent == isIndependent &&
      other.subjectId == subjectId &&
      listEquals(other.statusArray, statusArray);

  @override
  int get hashCode => Object.hash(
    id,
    status,
    isIndependent,
    subjectId,
    Object.hashAll(statusArray),
  );
}

/// One card of an item (`itemData.prompts[]`): a title and a text.
@immutable
class ItemPrompt {
  const ItemPrompt({this.title, this.content, this.isFavorite = false});

  final String? title;

  /// The card text (`content`, or `text` when that is what the server sent).
  final String? content;

  final bool isFavorite;

  @override
  bool operator ==(Object other) =>
      other is ItemPrompt &&
      other.title == title &&
      other.content == content &&
      other.isFavorite == isFavorite;

  @override
  int get hashCode => Object.hash(title, content, isFavorite);
}

/// One work of an author (`works[]`): its title, its type and the student's
/// progress ("Öğrendim" box).
@immutable
class AuthorWork {
  const AuthorWork({required this.title, this.typeId, this.progress});

  /// The work's title (`eser`).
  final String title;

  /// Id of the work type (`type`); see [typeName].
  final String? typeId;

  /// The student's progress; `null` when the work has no record to learn.
  final ItemProgress? progress;

  /// The work type's name ("Roman"); `null` for an id outside
  /// [AuthorWorkTypes] (the screen groups those under "Diğer").
  String? get typeName => AuthorWorkTypes.nameOf(typeId);

  @override
  bool operator ==(Object other) =>
      other is AuthorWork &&
      other.title == title &&
      other.typeId == typeId &&
      other.progress == progress;

  @override
  int get hashCode => Object.hash(title, typeId, progress);
}

/// An entry of a lesson's content tree: a topic item with cards, an era
/// ("dönem") or an author of the "Yazar & Eserler" tab.
@immutable
class LessonItem {
  const LessonItem({
    required this.name,
    this.id,
    this.descriptions = const [],
    this.imageFile,
    this.progress,
    this.prompts = const [],
    this.isAuthor = false,
    this.authorCategoryId,
    this.works = const [],
    this.progressRecords = const [],
    this.isFavorite = false,
  });

  /// Id of the item (`_id`): what `getSubjectAuthors` takes for an era.
  final String? id;

  final String name;

  /// The item's text, paragraph by paragraph (`desc`).
  final List<String> descriptions;

  /// Image file the server names (authors' photos live in the app's assets:
  /// `assets<file>`).
  final String? imageFile;

  /// The item's own progress (`itemData`), for a topic item.
  final ItemProgress? progress;

  /// The item's cards (`itemData.prompts`).
  final List<ItemPrompt> prompts;

  /// `itsYazar == 1`: an author (it has [works]); otherwise a topic item or
  /// an era.
  final bool isAuthor;

  /// The era the author belongs to (`yazarCategory`).
  final String? authorCategoryId;

  /// An author's works.
  final List<AuthorWork> works;

  /// Progress records grouped under an era (the sub-subject's `itemDatas`
  /// whose author belongs to this era).
  final List<ItemProgress> progressRecords;

  final bool isFavorite;

  /// The biography or text as one block, paragraphs separated by a blank
  /// line.
  String get text => descriptions.join('\n\n');

  /// Missing cards or works under this entry (the legacy count): an author
  /// counts each work that is missing once; any other entry adds up its own
  /// progress and its era's records.
  int get missingCount {
    if (isAuthor) {
      return works.where((work) => work.progress?.hasMissing ?? false).length;
    }
    return (progress?.missingCount ?? 0) +
        progressRecords.fold(0, (sum, record) => sum + record.missingCount);
  }

  /// Something under this entry is missing: the red state of its icon.
  bool get hasMissing => missingCount > 0 || (progress?.hasMissing ?? false);

  @override
  bool operator ==(Object other) =>
      other is LessonItem &&
      other.id == id &&
      other.name == name &&
      other.imageFile == imageFile &&
      other.progress == progress &&
      other.isAuthor == isAuthor &&
      other.authorCategoryId == authorCategoryId &&
      other.isFavorite == isFavorite &&
      listEquals(other.descriptions, descriptions) &&
      listEquals(other.prompts, prompts) &&
      listEquals(other.works, works) &&
      listEquals(other.progressRecords, progressRecords);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    imageFile,
    progress,
    isAuthor,
    authorCategoryId,
    isFavorite,
    Object.hashAll(descriptions),
    Object.hashAll(prompts),
    Object.hashAll(works),
    Object.hashAll(progressRecords),
  );
}

/// A sub-subject ("alt konu"): an expandable block of a main subject with its
/// items.
@immutable
class SubSubject {
  const SubSubject({
    required this.id,
    required this.name,
    this.missingCount,
    this.items = const [],
  });

  final String id;
  final String name;

  /// Missing items the answer counts itself (`itemDataCount`, Yazar &
  /// Eserler); `null` otherwise, then use [computedMissing].
  final int? missingCount;

  /// The block's items; empty until `getItems` has answered.
  final List<LessonItem> items;

  /// Missing cards or works over [items].
  int get computedMissing =>
      items.fold(0, (sum, item) => sum + item.missingCount);

  /// The missing count to show: the server's when it sent one, else
  /// [computedMissing].
  int get missing => missingCount ?? computedMissing;

  /// A copy holding [items].
  SubSubject withItems(List<LessonItem> items) =>
      SubSubject(id: id, name: name, missingCount: missingCount, items: items);

  @override
  bool operator ==(Object other) =>
      other is SubSubject &&
      other.id == id &&
      other.name == name &&
      other.missingCount == missingCount &&
      listEquals(other.items, items);

  @override
  int get hashCode =>
      Object.hash(id, name, missingCount, Object.hashAll(items));
}
