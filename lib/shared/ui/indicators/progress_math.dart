/// Pure arithmetic of the progress indicators (C44, C45, C46), unit-tested.
abstract final class ProgressMath {
  /// The share of [done] in [total] as a 0 to 1 fraction, or null when there
  /// is no total to measure against (zero, negative or unknown). A null
  /// result means "draw nothing": a bar is only for a real ratio (board 1.15,
  /// "oran yoksa çizilmez").
  static double? fraction(int done, int? total) {
    if (total == null || total <= 0) return null;
    return (done / total).clamp(0.0, 1.0);
  }

  /// The whole percentage of [correct] in [total], rounded to the nearest
  /// integer (5 of 12 is 42; 41,67 rounds up), or null when [total] is not
  /// positive. Ties round away from zero. The ring draws this rounded value
  /// so the arc and the "%42" always agree.
  static int? percent(int correct, int total) {
    if (total <= 0) return null;
    final value = (correct / total * 100).round();
    return value.clamp(0, 100);
  }
}
