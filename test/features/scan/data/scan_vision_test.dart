import 'dart:math';
import 'dart:ui';

import 'package:flutter_document_scanner/flutter_document_scanner.dart'
    show Contour;
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/scan/data/scan_vision.dart';

void main() {
  test(
    'a contour becomes a quadrilateral in the unit square of its picture',
    () {
      final form = PlatformScanVision.fromContour(
        const Contour(
          width: 1000,
          height: 2000,
          points: [
            Point(100, 400),
            Point(900, 400),
            Point(900, 1600),
            Point(100, 1600),
          ],
        ),
      )!;
      expect(form.imageSize, const Size(1000, 2000));
      expect(form.quad.topLeft, const Offset(0.1, 0.2));
      expect(form.quad.bottomRight, const Offset(0.9, 0.8));
    },
  );

  test('unordered points (Android) are put in order first', () {
    final form = PlatformScanVision.fromContour(
      const Contour(
        width: 100,
        height: 100,
        points: [Point(90, 90), Point(10, 10), Point(10, 90), Point(90, 10)],
      ),
    )!;
    expect(form.quad.topLeft, const Offset(0.1, 0.1));
    expect(form.quad.topRight, const Offset(0.9, 0.1));
    expect(form.quad.bottomRight, const Offset(0.9, 0.9));
    expect(form.quad.bottomLeft, const Offset(0.1, 0.9));
  });

  test('a contour without a size takes the picture\'s', () {
    final form = PlatformScanVision.fromContour(
      const Contour(
        points: [Point(0, 0), Point(50, 0), Point(50, 50), Point(0, 50)],
      ),
      fallbackSize: const Size(100, 100),
    )!;
    expect(form.quad.bottomRight, const Offset(0.5, 0.5));
  });

  test(
    'a contour with no size to divide by, or without four points, is nothing',
    () {
      expect(
        PlatformScanVision.fromContour(
          const Contour(
            points: [Point(0, 0), Point(1, 0), Point(1, 1), Point(0, 1)],
          ),
        ),
        isNull,
      );
      expect(
        PlatformScanVision.fromContour(
          const Contour(
            width: 10,
            height: 10,
            points: [Point(0, 0), Point(1, 1)],
          ),
        ),
        isNull,
      );
    },
  );
}
