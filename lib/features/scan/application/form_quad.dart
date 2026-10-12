import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import 'package:flutter/foundation.dart';

/// The four handles of the answer-area quadrilateral (pano 4.4, spec C68).
enum QuadCorner {
  topLeft,
  topRight,
  bottomRight,
  bottomLeft;

  /// The next corner clockwise.
  QuadCorner get next => values[(index + 1) % values.length];
}

/// The answer area as four corners, clockwise from the top left: the
/// "bulunan kenar" of the camera (pano 4.3 kare 2) and the handles of the
/// corner screen (pano 4.4).
///
/// The same type serves three coordinate spaces: image pixels (what the
/// native perspective correction takes), the unit square of the photo or
/// preview (0 to 1, what the detector reports and the screens map from), and
/// view points (what the handles are drawn at). [scale] and [map] move it
/// between them.
@immutable
class FormQuad {
  const FormQuad({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
  });

  /// Orders four unordered corner points (the Android detector does not
  /// order them): the smallest `x + y` is the top left, the largest the
  /// bottom right; of the two others the smaller `y - x` is the top right.
  /// `null` unless there are exactly four points.
  static FormQuad? fromPoints(Iterable<Offset> points) {
    final list = points.toList();
    if (list.length != 4) return null;
    Offset pick(double Function(Offset) key, {required bool largest}) {
      var best = list.first;
      for (final point in list) {
        final better = largest
            ? key(point) > key(best)
            : key(point) < key(best);
        if (better) best = point;
      }
      return best;
    }

    final topLeft = pick((p) => p.dx + p.dy, largest: false);
    final bottomRight = pick((p) => p.dx + p.dy, largest: true);
    final topRight = pick((p) => p.dy - p.dx, largest: false);
    final bottomLeft = pick((p) => p.dy - p.dx, largest: true);
    final distinct = {topLeft, topRight, bottomRight, bottomLeft};
    if (distinct.length != 4) return null;
    return FormQuad(
      topLeft: topLeft,
      topRight: topRight,
      bottomRight: bottomRight,
      bottomLeft: bottomLeft,
    );
  }

  /// A rectangle as a quadrilateral.
  factory FormQuad.fromRect(Rect rect) => FormQuad(
    topLeft: rect.topLeft,
    topRight: rect.topRight,
    bottomRight: rect.bottomRight,
    bottomLeft: rect.bottomLeft,
  );

  final Offset topLeft;
  final Offset topRight;
  final Offset bottomRight;
  final Offset bottomLeft;

  /// The corners clockwise from the top left; the order the native
  /// perspective correction takes.
  List<Offset> get corners => [topLeft, topRight, bottomRight, bottomLeft];

  /// The corner [corner].
  Offset operator [](QuadCorner corner) => switch (corner) {
    QuadCorner.topLeft => topLeft,
    QuadCorner.topRight => topRight,
    QuadCorner.bottomRight => bottomRight,
    QuadCorner.bottomLeft => bottomLeft,
  };

  /// This quadrilateral with [corner] moved to [point].
  FormQuad withCorner(QuadCorner corner, Offset point) => FormQuad(
    topLeft: corner == QuadCorner.topLeft ? point : topLeft,
    topRight: corner == QuadCorner.topRight ? point : topRight,
    bottomRight: corner == QuadCorner.bottomRight ? point : bottomRight,
    bottomLeft: corner == QuadCorner.bottomLeft ? point : bottomLeft,
  );

  /// Every corner through [transform].
  FormQuad map(Offset Function(Offset corner) transform) => FormQuad(
    topLeft: transform(topLeft),
    topRight: transform(topRight),
    bottomRight: transform(bottomRight),
    bottomLeft: transform(bottomLeft),
  );

  /// Every corner scaled by [sx] and [sy] (unit square to pixels and back).
  FormQuad scale(double sx, double sy) =>
      map((corner) => Offset(corner.dx * sx, corner.dy * sy));

  /// This quadrilateral in the unit square of an image of [size].
  FormQuad normalizedBy(Size size) => scale(1 / size.width, 1 / size.height);

  /// Every corner moved to the nearest point of [bounds].
  FormQuad clampedTo(Rect bounds) => map(
    (corner) => Offset(
      corner.dx.clamp(bounds.left, bounds.right),
      corner.dy.clamp(bounds.top, bounds.bottom),
    ),
  );

  /// The area by the shoelace formula, in the unit of the space squared.
  double get area {
    final points = corners;
    var twice = 0.0;
    for (var i = 0; i < points.length; i++) {
      final a = points[i];
      final b = points[(i + 1) % points.length];
      twice += a.dx * b.dy - b.dx * a.dy;
    }
    return twice.abs() / 2;
  }

  /// Whether the corners form a convex quadrilateral (no crossed sides, no
  /// reflex corner): the only shape the perspective correction can flatten.
  bool get isConvex {
    final points = corners;
    double? sign;
    for (var i = 0; i < points.length; i++) {
      final a = points[i];
      final b = points[(i + 1) % points.length];
      final c = points[(i + 2) % points.length];
      final cross =
          (b.dx - a.dx) * (c.dy - b.dy) - (b.dy - a.dy) * (c.dx - b.dx);
      if (cross == 0) return false;
      sign ??= cross.sign;
      if (cross.sign != sign) return false;
    }
    return true;
  }

  /// Whether every corner of [other] is within [tolerance] of the same
  /// corner of this one (the detector's frame-to-frame jitter).
  bool isCloseTo(FormQuad other, double tolerance) {
    for (var i = 0; i < 4; i++) {
      if ((corners[i] - other.corners[i]).distance > tolerance) return false;
    }
    return true;
  }

  /// The corner-wise blend of this and [other]; [t] 0 is this, 1 is [other].
  FormQuad lerpTo(FormQuad other, double t) => FormQuad(
    topLeft: Offset.lerp(topLeft, other.topLeft, t)!,
    topRight: Offset.lerp(topRight, other.topRight, t)!,
    bottomRight: Offset.lerp(bottomRight, other.bottomRight, t)!,
    bottomLeft: Offset.lerp(bottomLeft, other.bottomLeft, t)!,
  );

  /// The shortest side, to tell a sliver from a real area.
  double get shortestSide {
    final points = corners;
    var shortest = double.infinity;
    for (var i = 0; i < points.length; i++) {
      shortest = math.min(
        shortest,
        (points[(i + 1) % points.length] - points[i]).distance,
      );
    }
    return shortest;
  }

  @override
  bool operator ==(Object other) =>
      other is FormQuad &&
      other.topLeft == topLeft &&
      other.topRight == topRight &&
      other.bottomRight == bottomRight &&
      other.bottomLeft == bottomLeft;

  @override
  int get hashCode => Object.hash(topLeft, topRight, bottomRight, bottomLeft);

  @override
  String toString() =>
      'FormQuad($topLeft, $topRight, $bottomRight, $bottomLeft)';
}
