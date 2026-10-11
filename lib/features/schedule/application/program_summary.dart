import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/schedule/application/program_span.dart';
import 'package:smap/features/schedule/data/dtos/weekly_dto.dart';

/// One program as the list draws it (C29 "ProgramRow"; pano 3.4 kare 1): the
/// name, the motto, the dates and whether it is this week's program. Immutable
/// with value equality.
@immutable
class ProgramSummary {
  const ProgramSummary({
    required this.id,
    required this.name,
    required this.motto,
    required this.isThisWeek,
    this.span,
  });

  /// The summary of [weekly] on [today]; `null` for a program the server gave
  /// no id (it cannot be opened or edited).
  static ProgramSummary? of(WeeklyDto weekly, {required DateTime today}) {
    final id = weekly.id;
    if (id == null || id.isEmpty) return null;
    final days = weekly.days;
    final span = days.isEmpty ? null : ProgramSpan.of(days, today: today);
    final thisWeek = ProgramSpan.week(today);
    final isThisWeek = days.any(thisWeek.contains);
    return ProgramSummary(
      id: id,
      name: (weekly.name ?? '').trim(),
      motto: (weekly.motto ?? '').trim(),
      isThisWeek: isThisWeek,
      span: span,
    );
  }

  final String id;

  /// "Ekim 2. Hafta".
  final String name;

  /// "Her gün biraz daha"; empty when the program has none.
  final String motto;

  /// A topic of the program falls into the current Monday-to-Sunday week:
  /// the "Bu hafta" tag.
  final bool isThisWeek;

  /// The weeks the program covers; `null` while it has no topic.
  final ProgramSpan? span;

  @override
  bool operator ==(Object other) =>
      other is ProgramSummary &&
      other.id == id &&
      other.name == name &&
      other.motto == motto &&
      other.isThisWeek == isThisWeek &&
      other.span == span;

  @override
  int get hashCode => Object.hash(id, name, motto, isThisWeek, span);
}

/// The program list as the screen holds it: the summaries in the order they
/// are drawn. Value equality, so a selector can compare it.
@immutable
class ProgramList {
  const ProgramList(this.items);

  /// Summaries of [weeklies] on [today]: this week's program first, then the
  /// newest span first; programs without topics last; the server's order
  /// breaks ties.
  factory ProgramList.of(
    Iterable<WeeklyDto> weeklies, {
    required DateTime today,
  }) {
    final indexed = <(int, ProgramSummary)>[];
    var index = 0;
    for (final weekly in weeklies) {
      final summary = ProgramSummary.of(weekly, today: today);
      if (summary != null) indexed.add((index, summary));
      index++;
    }
    indexed.sort((a, b) {
      final x = a.$2;
      final y = b.$2;
      if (x.isThisWeek != y.isThisWeek) return x.isThisWeek ? -1 : 1;
      final xs = x.span;
      final ys = y.span;
      if (xs != null && ys != null) {
        final byStart = ys.first.compareTo(xs.first);
        if (byStart != 0) return byStart;
      } else if (xs != null || ys != null) {
        return xs != null ? -1 : 1;
      }
      return a.$1.compareTo(b.$1);
    });
    return ProgramList([for (final entry in indexed) entry.$2]);
  }

  final List<ProgramSummary> items;

  bool get isEmpty => items.isEmpty;

  /// The programs whose name or motto holds [query] (Turkish case and mark
  /// folding: "I", "ı", "İ" and "i" meet; pano 3.4 kare 2). A blank query
  /// keeps everything.
  ProgramList matching(String query) {
    final needle = query.trim();
    if (needle.isEmpty) return this;
    return ProgramList([
      for (final item in items)
        if (TurkishText.contains(item.name, needle) ||
            TurkishText.contains(item.motto, needle))
          item,
    ]);
  }

  @override
  bool operator ==(Object other) =>
      other is ProgramList && listEquals(other.items, items);

  @override
  int get hashCode => Object.hashAll(items);
}
