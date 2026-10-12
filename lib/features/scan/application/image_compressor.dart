import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Makes the photo small enough to send: the long edge at most 2400 px, JPEG
/// at quality 85 (pano 4.5 kare 1 "Fotoğraf telefonda küçültülüp sıkıştırılır";
/// spec decision T2.5).
///
/// The work is CPU heavy (decode, resize, encode a 12 MP photo), so
/// [compress] runs it in a separate isolate and the screen keeps spinning.
abstract final class ImageCompressor {
  /// Longest side of the result, in pixels.
  static const int longEdge = 2400;

  /// JPEG quality.
  static const int quality = 85;

  /// Compresses [photo] (any format the `image` package decodes) off the main
  /// isolate. Throws a [FormatException] when it is not an image.
  static Future<Uint8List> compress(Uint8List photo) =>
      Isolate.run(() => compressSync(photo));

  /// The same work on the calling isolate, for tests.
  static Uint8List compressSync(Uint8List photo) {
    final img.Image? decoded;
    try {
      decoded = img.decodeImage(photo);
    } on Object {
      // The decoders throw on a stream that merely resembles a header.
      throw const FormatException('The photo is not an image.');
    }
    if (decoded == null) {
      throw const FormatException('The photo is not an image.');
    }
    var image = img.bakeOrientation(decoded);
    final longest = image.width > image.height ? image.width : image.height;
    if (longest > longEdge) {
      image = image.width >= image.height
          ? img.copyResize(
              image,
              width: longEdge,
              interpolation: img.Interpolation.average,
            )
          : img.copyResize(
              image,
              height: longEdge,
              interpolation: img.Interpolation.average,
            );
    }
    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }
}
