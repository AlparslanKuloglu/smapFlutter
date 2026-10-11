import 'package:smap/features/exams/application/dyb_counts.dart';

/// The rules of the topic result list (C23 `TopicResultRow`; pano 1.15,
/// 5.5), pure and unit-tested.
abstract final class TopicRanking {
  /// A topic with this many questions or fewer wears the "Az soru" tag:
  /// one question makes a percentage meaningless.
  static const int fewQuestionsMax = 2;

  /// The success percentage, `(d * 100 / n).round()` with `n = D + Y + B`,
  /// or null when the topic has no question at all ("Soru yok", no ring).
  /// Ties round away from zero: 5 of 12 is 42.
  static int? percent(DybCounts counts) {
    final n = counts.total;
    if (n <= 0) return null;
    return (counts.correct * 100 / n).round();
  }

  /// Whether the "Az soru" tag shows: one or two questions. A topic without
  /// questions says "Soru yok" in its ring instead.
  static bool isFewQuestions(DybCounts counts) =>
      counts.total >= 1 && counts.total <= fewQuestionsMax;

  /// [items] ordered weakest first: percentage ascending, and for equal
  /// percentages the topic with more questions first. A topic with no
  /// question goes last. Topics that still tie keep their given order (the
  /// sort is stable). Returns a new list.
  static List<T> sort<T>(
    Iterable<T> items, {
    required DybCounts Function(T item) countsOf,
  }) {
    final indexed = [for (final (i, item) in items.indexed) (i, item)];
    indexed.sort((a, b) {
      final countsA = countsOf(a.$2);
      final countsB = countsOf(b.$2);
      final percentA = percent(countsA);
      final percentB = percent(countsB);
      if (percentA == null || percentB == null) {
        if (percentA == percentB) return a.$1.compareTo(b.$1);
        return percentA == null ? 1 : -1;
      }
      final byPercent = percentA.compareTo(percentB);
      if (byPercent != 0) return byPercent;
      final byTotal = countsB.total.compareTo(countsA.total);
      if (byTotal != 0) return byTotal;
      return a.$1.compareTo(b.$1);
    });
    return [for (final entry in indexed) entry.$2];
  }
}
