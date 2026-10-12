import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// One camera frame as the stream hands it over: a single BGRA plane.
class BgraFrame {
  const BgraFrame({
    required this.bytes,
    required this.width,
    required this.height,
    required this.bytesPerRow,
  });

  final Uint8List bytes;
  final int width;
  final int height;

  /// Row stride of [bytes]; the camera pads rows.
  final int bytesPerRow;
}

/// Makes a small JPEG of a preview frame for the form detector.
///
/// The detector (the native rectangle search of the document scanner) reads a
/// still photo the way the camera writes it: pixels in the sensor's landscape
/// order plus an EXIF orientation of 6 ("rotate right"). A portrait frame is
/// therefore turned a quarter back and tagged, so that the points the detector
/// answers are in the portrait picture the student sees, the same as for a
/// real photo. The frame is shrunk to [longEdge] first: finding a rectangle
/// needs no more, and it keeps the work light enough to run twice a second.
abstract final class CameraFrameEncoder {
  /// Longest side of the encoded frame.
  static const int longEdge = 640;

  /// JPEG quality of the encoded frame.
  static const int quality = 70;

  /// The EXIF orientation value that means "rotate 90° clockwise to display".
  static const int exifRotateRight = 6;

  /// Encodes [frame] off the main isolate; `null` when it cannot be encoded.
  static Future<Uint8List?> encode(BgraFrame frame) =>
      Isolate.run(() => encodeSync(frame));

  /// The same work on the calling isolate, for tests.
  static Uint8List? encodeSync(BgraFrame frame) {
    try {
      var image = img.Image.fromBytes(
        width: frame.width,
        height: frame.height,
        bytes: frame.bytes.buffer,
        bytesOffset: frame.bytes.offsetInBytes,
        rowStride: frame.bytesPerRow,
        numChannels: 4,
        order: img.ChannelOrder.bgra,
      );
      final longest = frame.width > frame.height ? frame.width : frame.height;
      if (longest > longEdge) {
        image = frame.width >= frame.height
            ? img.copyResize(image, width: longEdge)
            : img.copyResize(image, height: longEdge);
      }
      final portrait = image.height > image.width;
      // The detector expects sensor order (landscape) + EXIF rotate-right.
      final raw = portrait ? img.copyRotate(image, angle: 270) : image;
      raw.exif.imageIfd.orientation = exifRotateRight;
      return Uint8List.fromList(img.encodeJpg(raw, quality: quality));
    } on Object {
      return null;
    }
  }
}
