import 'package:flutter/foundation.dart' show immutable;
import 'package:smap/features/exams/application/dyb_counts.dart';

/// One drawn part of a stacked D/Y/B bar.
@immutable
class BarSegment {
  const BarSegment({
    required this.kind,
    required this.left,
    required this.width,
  });

  final DybKind kind;

  /// Distance of the part's left edge from the bar's left edge.
  final double left;

  /// Width of the part.
  final double width;

  /// The right edge.
  double get right => left + width;

  @override
  bool operator ==(Object other) =>
      other is BarSegment &&
      other.kind == kind &&
      other.left == left &&
      other.width == width;

  @override
  int get hashCode => Object.hash(kind, left, width);

  @override
  String toString() => 'BarSegment($kind, left: $left, width: $width)';
}

/// The geometry of the stacked bar (C42 `DybStackedBar`; pano 1.14), pure and
/// unit-tested.
///
/// Parts are as wide as their count (flex). A part whose count is zero is not
/// drawn (its counter still is). A 2 pt gap separates neighbours so the
/// border is visible without color vision; the gap is taken out of the
/// width, so parts and gaps fill the bar exactly.
abstract final class StackedBarMath {
  /// The gap between two parts.
  static const double gap = 2;

  /// The parts of [counts] in a bar [width] wide, in D, Y, B order. Empty
  /// when there are no questions or the width is not positive.
  static List<BarSegment> segments(
    DybCounts counts,
    double width, {
    double gap = StackedBarMath.gap,
  }) {
    final total = counts.total;
    if (total <= 0 || width <= 0) return const [];
    final kinds = [
      for (final kind in DybKind.ordered)
        if (counts.of(kind) > 0) kind,
    ];
    final gaps = (kinds.length - 1) * gap;
    final usable = width - gaps;
    if (usable <= 0) return const [];
    final out = <BarSegment>[];
    var left = 0.0;
    for (final kind in kinds) {
      final part = usable * counts.of(kind) / total;
      out.add(BarSegment(kind: kind, left: left, width: part));
      left += part + gap;
    }
    return out;
  }
}
