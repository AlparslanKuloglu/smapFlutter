/// The order of the subject tiles on the home screen (C21 `SubjectTile`;
/// pano 3.1 "Derslerin"): the subject with the most missing items first;
/// subjects that open on the web (Matematik, Geometri) come last. Pure and
/// unit-tested.
abstract final class SubjectOrdering {
  /// [items] ordered for the tile strip. Sorted by missing count descending;
  /// an unknown count (null) counts as zero; web-only subjects go after all
  /// the others. Subjects that tie keep their given order (stable). Returns
  /// a new list.
  static List<T> tileOrder<T>(
    Iterable<T> items, {
    required int? Function(T item) missingOf,
    required bool Function(T item) isWebOnly,
  }) {
    final indexed = [for (final (i, item) in items.indexed) (i, item)];
    indexed.sort((a, b) {
      final webA = isWebOnly(a.$2);
      final webB = isWebOnly(b.$2);
      if (webA != webB) return webA ? 1 : -1;
      final missingA = missingOf(a.$2) ?? 0;
      final missingB = missingOf(b.$2) ?? 0;
      final byMissing = missingB.compareTo(missingA);
      if (byMissing != 0) return byMissing;
      return a.$1.compareTo(b.$1);
    });
    return [for (final entry in indexed) entry.$2];
  }
}
