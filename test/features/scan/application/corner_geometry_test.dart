import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/scan/application/corner_geometry.dart';
import 'package:smap/features/scan/application/form_quad.dart';

void main() {
  group('the guide (pano 4.3)', () {
    test(
      'is the 330 x 400 frame of the 402 x 874 board in the unit square',
      () {
        const guide = CornerGeometry.guideQuad;
        expect(guide.topLeft.dx * 402, closeTo(36, 1e-9));
        expect(guide.topLeft.dy * 874, closeTo(200, 1e-9));
        expect(guide.bottomRight.dx * 402, closeTo(366, 1e-9));
        expect(guide.bottomRight.dy * 874, closeTo(600, 1e-9));
        expect(guide.isConvex, isTrue);
      },
    );
  });

  group('fitting', () {
    test('contain centers a tall photo in a wide room', () {
      final rect = CornerGeometry.fitContain(
        const Size(300, 600),
        const Size(400, 400),
      );
      expect(rect.height, 400);
      expect(rect.width, 200);
      expect(rect.left, 100);
      expect(rect.top, 0);
    });

    test('cover fills the room and reaches past it on the long axis', () {
      final rect = CornerGeometry.fitCover(
        const Size(720, 1280),
        const Size(402, 600),
      );
      expect(rect.width, closeTo(402, 1e-9));
      expect(rect.height, greaterThan(600));
      expect(rect.top, lessThan(0));
    });

    test('empty sizes give an empty rectangle', () {
      expect(CornerGeometry.fitContain(Size.zero, const Size(1, 1)), Rect.zero);
      expect(CornerGeometry.fitCover(const Size(1, 1), Size.zero), Rect.zero);
    });

    test('view points and the unit square map back and forth', () {
      const image = Rect.fromLTWH(10, 20, 200, 400);
      final view = CornerGeometry.toView(
        const FormQuad(
          topLeft: Offset(0.1, 0.1),
          topRight: Offset(0.9, 0.1),
          bottomRight: Offset(0.9, 0.9),
          bottomLeft: Offset(0.1, 0.9),
        ),
        image,
      );
      expect(view.topLeft, const Offset(30, 60));
      expect(
        CornerGeometry.toUnit(view.bottomRight, image),
        const Offset(0.9, 0.9),
      );
    });
  });

  group('picking a handle', () {
    final view = CornerGeometry.guideQuad.scale(400, 800);

    test('takes the nearest handle within reach', () {
      final topLeft = view.topLeft;
      expect(
        CornerGeometry.pick(view, topLeft + const Offset(20, -10)),
        QuadCorner.topLeft,
      );
      expect(
        CornerGeometry.pick(view, view.bottomRight),
        QuadCorner.bottomRight,
      );
    });

    test('takes nothing far from every handle', () {
      expect(CornerGeometry.pick(view, const Offset(200, 400)), isNull);
    });
  });

  group('moving a handle', () {
    const quad = CornerGeometry.guideQuad;

    test('puts it where it is dragged', () {
      final move = CornerGeometry.move(
        quad,
        QuadCorner.topLeft,
        const Offset(0.2, 0.3),
      );
      expect(move.quad.topLeft, const Offset(0.2, 0.3));
      expect(move.atEdge, isFalse);
    });

    test('keeps it inside the photo and says it sits against the edge', () {
      final move = CornerGeometry.move(
        quad,
        QuadCorner.topLeft,
        const Offset(-0.5, 0.3),
      );
      expect(move.quad.topLeft, const Offset(0, 0.3));
      expect(move.atEdge, isTrue);
    });

    test('refuses a move that would cross the sides', () {
      final move = CornerGeometry.move(
        quad,
        QuadCorner.topLeft,
        const Offset(0.95, 0.9),
      );
      expect(move.quad, quad);
      expect(move.atEdge, isFalse);
    });

    test('nudges by a hundredth of the photo', () {
      final move = CornerGeometry.nudge(
        quad,
        QuadCorner.bottomRight,
        dx: 1,
        dy: -1,
      );
      expect(
        move.quad.bottomRight.dx,
        closeTo(quad.bottomRight.dx + 0.01, 1e-12),
      );
      expect(
        move.quad.bottomRight.dy,
        closeTo(quad.bottomRight.dy - 0.01, 1e-12),
      );
    });
  });

  group('the loupe (pano 4.4 kare 2)', () {
    const bounds = Rect.fromLTWH(0, 0, 402, 700);

    test('sits 70 right and 150 above the handle', () {
      final center = CornerGeometry.loupeCenter(
        handle: const Offset(100, 500),
        bounds: bounds,
        diameter: 116,
      );
      expect(center, const Offset(170, 350));
    });

    test('is kept inside the room on the right', () {
      final center = CornerGeometry.loupeCenter(
        handle: const Offset(390, 500),
        bounds: bounds,
        diameter: 116,
      );
      expect(center.dx, 402 - 58 - 8);
    });

    test('drops below the finger near the top', () {
      final center = CornerGeometry.loupeCenter(
        handle: const Offset(200, 60),
        bounds: bounds,
        diameter: 116,
      );
      expect(center.dy, 210);
    });
  });

  test('pixels are the unit square times the photo', () {
    final pixels = CornerGeometry.toPixels(
      CornerGeometry.guideQuad,
      const Size(804, 1748),
    );
    expect(pixels.topLeft.dx, closeTo(72, 1e-9));
    expect(pixels.bottomRight.dy, closeTo(1200, 1e-9));
  });
}
