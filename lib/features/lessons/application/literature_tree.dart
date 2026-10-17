import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/features/lessons/domain/lesson_content.dart';

/// An era ("dönem") of Yazar ve Eserler (pano 14.5 kare 1; one row of the
/// list): `yazarEserMainSubjects` → `_id`, `name`, `order`, `itemDataCount`.
@immutable
class LiteratureEra {
  const LiteratureEra({
    required this.id,
    required this.name,
    this.order,
    this.missing,
  });

  final String id;

  /// "Tanzimat Dönemi".
  final String name;

  /// The server's number of the era; the list keeps the server's order.
  final int? order;

  /// Missing works under the era (`itemDataCount`); `null` when the server
  /// sent none (no tag, no counter).
  final int? missing;

  LiteratureEra withMissing(int? missing) =>
      LiteratureEra(id: id, name: name, order: order, missing: missing);

  @override
  bool operator ==(Object other) =>
      other is LiteratureEra &&
      other.id == id &&
      other.name == name &&
      other.order == order &&
      other.missing == missing;

  @override
  int get hashCode => Object.hash(id, name, order, missing);
}

/// A sub-subject ("alt başlık") of an era: one accordion of the era detail
/// (pano 14.5 kare 2 "Birinci Dönem Sanatçıları").
@immutable
class LiteratureSub {
  const LiteratureSub({
    required this.id,
    required this.name,
    this.missing,
    this.items = const [],
  });

  final String id;
  final String name;

  /// Missing works under the sub-subject (`itemDataCount`); `null` when the
  /// server sent none.
  final int? missing;

  /// What `getItems` listed under it: the authors themselves, or the groups
  /// whose authors `getSubjectAuthors` lists when the accordion opens.
  final List<LessonItem> items;

  LiteratureSub withMissing(int? missing) =>
      LiteratureSub(id: id, name: name, missing: missing, items: items);

  @override
  bool operator ==(Object other) =>
      other is LiteratureSub &&
      other.id == id &&
      other.name == name &&
      other.missing == missing &&
      listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(id, name, missing, Object.hashAll(items));
}

/// Sums the missing counts the server gave: `null` when none gave one.
int? sumMissing(Iterable<int?> counts) {
  int? total;
  for (final count in counts) {
    if (count != null) total = (total ?? 0) + count;
  }
  return total;
}
