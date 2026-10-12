import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/scan/application/form_quad.dart';

void main() {
  const quad = FormQuad(
    topLeft: Offset(10, 20),
    topRight: Offset(110, 22),
    bottomRight: Offset(112, 220),
    bottomLeft: Offset(8, 218),
  );

  group('fromPoints', () {
    test('orders four unordered points clockwise from the top left', () {
      final shuffled = [
        quad.bottomRight,
        quad.topLeft,
        quad.bottomLeft,
        quad.topRight,
      ];
      expect(FormQuad.fromPoints(shuffled), quad);
    });

    test('needs exactly four distinct points', () {
      expect(FormQuad.fromPoints([quad.topLeft, quad.topRight]), isNull);
      expect(
        FormQuad.fromPoints([
          quad.topLeft,
          quad.topLeft,
          quad.bottomRight,
          quad.bottomLeft,
        ]),
        isNull,
      );
    });
  });

  group('geometry', () {
    test('a rectangle has the area of its sides and is convex', () {
      final rect = FormQuad.fromRect(const Rect.fromLTWH(0, 0, 4, 5));
      expect(rect.area, 20);
      expect(rect.isConvex, isTrue);
      expect(rect.shortestSide, 4);
    });

    test('a bowtie is not convex', () {
      const bowtie = FormQuad(
        topLeft: Offset(0, 0),
        topRight: Offset(10, 10),
        bottomRight: Offset(10, 0),
        bottomLeft: Offset(0, 10),
      );
      expect(bowtie.isConvex, isFalse);
    });

    test('a reflex corner is not convex', () {
      const dart = FormQuad(
        topLeft: Offset(0, 0),
        topRight: Offset(10, 0),
        bottomRight: Offset(4, 4),
        bottomLeft: Offset(0, 10),
      );
      expect(dart.isConvex, isFalse);
    });

    test('moves between pixels and the unit square', () {
      final unit = quad.normalizedBy(const Size(200, 400));
      expect(unit.topLeft, const Offset(0.05, 0.05));
      expect(unit.scale(200, 400).topLeft, const Offset(10, 20));
    });

    test('clamps into bounds', () {
      final clamped = quad.clampedTo(const Rect.fromLTWH(0, 0, 100, 100));
      expect(clamped.topRight, const Offset(100, 22));
      expect(clamped.bottomRight, const Offset(100, 100));
    });

    test('a corner can be replaced and read back', () {
      final moved = quad.withCorner(QuadCorner.bottomLeft, const Offset(1, 2));
      expect(moved[QuadCorner.bottomLeft], const Offset(1, 2));
      expect(moved[QuadCorner.topLeft], quad.topLeft);
      expect(QuadCorner.bottomLeft.next, QuadCorner.topLeft);
    });

    test('closeness is per corner', () {
      expect(quad.isCloseTo(quad, 0), isTrue);
      expect(
        quad.isCloseTo(
          quad.withCorner(QuadCorner.topLeft, const Offset(14, 20)),
          3,
        ),
        isFalse,
      );
      expect(
        quad.isCloseTo(
          quad.withCorner(QuadCorner.topLeft, const Offset(12, 20)),
          3,
        ),
        isTrue,
      );
    });

    test('lerps corner by corner', () {
      final half = quad.lerpTo(quad.scale(2, 2), 0.5);
      expect(half.topLeft, const Offset(15, 30));
    });
  });
}
