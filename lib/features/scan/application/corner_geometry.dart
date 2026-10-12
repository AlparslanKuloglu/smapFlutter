import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import 'package:smap/features/scan/application/form_quad.dart';

/// What moving a handle did: the new quadrilateral and whether the handle sat
/// against the edge of the photo ("Nokta bir kenara oturunca selectionClick",
/// pano 4.4).
class CornerMove {
  const CornerMove({required this.quad, required this.atEdge});

  final FormQuad quad;
  final bool atEdge;
}

/// The geometry of the corner screen and of the camera guide, as pure
/// functions (pano 4.3, 4.4; spec C67, C68).
///
/// The quadrilateral lives in the unit square of the photo (0 to 1 on both
/// axes), so it does not depend on how big the photo is drawn; the screens map
/// it to view points with [toView] and back with [toUnit].
abstract final class CornerGeometry {
  /// Where the quadrilateral starts when the detector found no form: the
  /// camera's guide frame (x 36 to 366 and y 200 to 600 on the 402 x 874
  /// board, pano 4.3), the area the student was asked to fill.
  static const FormQuad guideQuad = FormQuad(
    topLeft: Offset(36 / 402, 200 / 874),
    topRight: Offset(366 / 402, 200 / 874),
    bottomRight: Offset(366 / 402, 600 / 874),
    bottomLeft: Offset(36 / 402, 600 / 874),
  );

  /// A handle's keyboard and screen-reader step, as a share of the photo.
  static const double nudgeStep = 0.01;

  /// The distance, in view points, within which a touch picks a handle up:
  /// the 48 pt touch area (pano 4.4) and a little more for a thumb.
  static const double pickRadius = 36;

  /// The rectangle a photo of [image] occupies inside [box] when it is
  /// scaled to fit and centered (`BoxFit.contain`).
  static Rect fitContain(Size image, Size box) {
    if (image.isEmpty || box.isEmpty) return Rect.zero;
    final scale = math.min(box.width / image.width, box.height / image.height);
    final size = Size(image.width * scale, image.height * scale);
    return Rect.fromLTWH(
      (box.width - size.width) / 2,
      (box.height - size.height) / 2,
      size.width,
      size.height,
    );
  }

  /// The rectangle a picture of [content]'s shape occupies inside [box] when
  /// it is scaled to cover it and centered (`BoxFit.cover`); it reaches
  /// beyond [box] on the long axis. A camera preview is drawn this way.
  static Rect fitCover(Size content, Size box) {
    if (content.isEmpty || box.isEmpty) return Rect.zero;
    final scale = math.max(
      box.width / content.width,
      box.height / content.height,
    );
    final size = Size(content.width * scale, content.height * scale);
    return Rect.fromLTWH(
      (box.width - size.width) / 2,
      (box.height - size.height) / 2,
      size.width,
      size.height,
    );
  }

  /// A unit-square quadrilateral as view points inside [image] (the rectangle
  /// the picture occupies).
  static FormQuad toView(FormQuad unit, Rect image) => unit.map(
    (corner) => Offset(
      image.left + corner.dx * image.width,
      image.top + corner.dy * image.height,
    ),
  );

  /// A view point as a point of the unit square of [image].
  static Offset toUnit(Offset view, Rect image) => Offset(
    (view.dx - image.left) / image.width,
    (view.dy - image.top) / image.height,
  );

  /// The handle of [view] (view points) nearest to [touch], within
  /// [pickRadius]; `null` when the touch is far from all four.
  static QuadCorner? pick(FormQuad view, Offset touch) {
    QuadCorner? nearest;
    var nearestDistance = pickRadius;
    for (final corner in QuadCorner.values) {
      final distance = (view[corner] - touch).distance;
      if (distance <= nearestDistance) {
        nearest = corner;
        nearestDistance = distance;
      }
    }
    return nearest;
  }

  /// Puts [corner] of [unit] at [target] (unit square), kept inside the photo
  /// and refused when the quadrilateral would stop being convex: a bowtie
  /// cannot be flattened, so the handle stays where it was.
  static CornerMove move(FormQuad unit, QuadCorner corner, Offset target) {
    final clamped = Offset(
      target.dx.clamp(0.0, 1.0),
      target.dy.clamp(0.0, 1.0),
    );
    final atEdge =
        clamped.dx != target.dx ||
        clamped.dy != target.dy ||
        clamped.dx == 0 ||
        clamped.dx == 1 ||
        clamped.dy == 0 ||
        clamped.dy == 1;
    final moved = unit.withCorner(corner, clamped);
    if (!moved.isConvex) return CornerMove(quad: unit, atEdge: false);
    return CornerMove(quad: moved, atEdge: atEdge);
  }

  /// Moves [corner] by [step] in unit-square space in the given direction
  /// (screen-reader and keyboard adjustment).
  static CornerMove nudge(
    FormQuad unit,
    QuadCorner corner, {
    double dx = 0,
    double dy = 0,
  }) =>
      move(unit, corner, unit[corner] + Offset(dx * nudgeStep, dy * nudgeStep));

  /// Where the loupe's center goes for a handle at [handle] (view points):
  /// 70 right and 150 above it (pano 4.4 kare 2), kept [margin] inside [bounds]
  /// so it is never cut off; near the top it drops below the finger instead.
  static Offset loupeCenter({
    required Offset handle,
    required Rect bounds,
    required double diameter,
    double margin = 8,
  }) {
    final half = diameter / 2 + margin;
    var center = handle + const Offset(70, -150);
    if (center.dy - half < bounds.top) {
      center = Offset(center.dx, handle.dy + 150);
    }
    return Offset(
      center.dx.clamp(
        bounds.left + half,
        math.max(bounds.left + half, bounds.right - half),
      ),
      center.dy.clamp(
        bounds.top + half,
        math.max(bounds.top + half, bounds.bottom - half),
      ),
    );
  }

  /// A quadrilateral of the photo in pixels, for the native perspective
  /// correction.
  static FormQuad toPixels(FormQuad unit, Size image) =>
      unit.scale(image.width, image.height);
}
