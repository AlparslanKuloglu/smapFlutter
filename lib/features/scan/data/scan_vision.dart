import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Offset, Size;

import 'package:flutter_document_scanner/flutter_document_scanner.dart'
    show Contour, FlutterDocumentScannerPlatform;
import 'package:smap/features/scan/application/form_quad.dart';

/// A form the detector found on a picture: its corners in the unit square of
/// that picture (0 to 1, the top left of the picture is 0,0) and the size of
/// the picture in pixels.
class DetectedForm {
  const DetectedForm({required this.quad, required this.imageSize});

  final FormQuad quad;
  final Size imageSize;
}

/// The two image operations of the scan, on the document scanner's native
/// code (Vision on iOS, OpenCV on Android; the vendored plugin
/// `lib/vendor/flutter_document_scanner`, whose core is not touched).
abstract interface class ScanVision {
  /// Looks for the answer area on [picture] (any image format the platform
  /// reads, with its EXIF orientation); `null` when there is none.
  ///
  /// [pictureSize] is the picture as it is shown (EXIF applied), for the
  /// platforms whose answer carries no size of its own.
  Future<DetectedForm?> findForm(Uint8List picture, {Size? pictureSize});

  /// Flattens the area [quad] (corners clockwise from the top left, in
  /// pixels of [picture]) into a straight picture; `null` when the platform
  /// cannot.
  Future<Uint8List?> flatten(Uint8List picture, FormQuad quad);
}

/// [ScanVision] on the plugin's platform channel.
class PlatformScanVision implements ScanVision {
  const PlatformScanVision();

  /// Smallest contour the Android detector accepts, in square pixels (the
  /// plugin's own default).
  static const double _minContourArea = 80000;

  FlutterDocumentScannerPlatform get _platform =>
      FlutterDocumentScannerPlatform.instance;

  @override
  Future<DetectedForm?> findForm(Uint8List picture, {Size? pictureSize}) async {
    try {
      final contour = await _platform.findContourPhoto(
        byteData: picture,
        minContourArea: _minContourArea,
      );
      return contour == null
          ? null
          : fromContour(contour, fallbackSize: pictureSize);
    } on Object {
      // A platform that cannot detect is the same as "no form found".
      return null;
    }
  }

  @override
  Future<Uint8List?> flatten(Uint8List picture, FormQuad quad) async {
    try {
      return await _platform.adjustingPerspective(
        byteData: picture,
        contour: Contour(
          points: [
            for (final corner in quad.corners)
              math.Point<double>(corner.dx, corner.dy),
          ],
        ),
      );
    } on Object {
      return null;
    }
  }

  /// A plugin contour as a [DetectedForm]: its points ordered into a
  /// [FormQuad] and divided by the picture's size (the contour's own, else
  /// [fallbackSize]). `null` for a contour without four points or without a
  /// size to divide by.
  static DetectedForm? fromContour(Contour contour, {Size? fallbackSize}) {
    final width = contour.width?.toDouble() ?? fallbackSize?.width;
    final height = contour.height?.toDouble() ?? fallbackSize?.height;
    if (width == null || height == null || width <= 0 || height <= 0) {
      return null;
    }
    final quad = FormQuad.fromPoints([
      for (final point in contour.points) Offset(point.x, point.y),
    ]);
    if (quad == null) return null;
    final size = Size(width, height);
    return DetectedForm(quad: quad.normalizedBy(size), imageSize: size);
  }
}
