import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:smap/features/scan/application/image_compressor.dart';

Uint8List photo(int width, int height) {
  final image = img.Image(width: width, height: height);
  for (var y = 0; y < height; y += 8) {
    for (var x = 0; x < width; x += 8) {
      img.fillRect(
        image,
        x1: x,
        y1: y,
        x2: x + 7,
        y2: y + 7,
        color: img.ColorRgb8(x % 255, y % 255, (x + y) % 255),
      );
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  test('the long edge is 2400 px and the quality 85', () {
    expect(ImageCompressor.longEdge, 2400);
    expect(ImageCompressor.quality, 85);
  });

  test(
    'shrinks a wide photo to 2400 px on its long edge, keeping the shape',
    () {
      final out = ImageCompressor.compressSync(photo(3200, 2400));
      final decoded = img.decodeJpg(out)!;
      expect(decoded.width, 2400);
      expect(decoded.height, 1800);
    },
  );

  test('shrinks a tall photo by its height', () {
    final out = ImageCompressor.compressSync(photo(2400, 3200));
    final decoded = img.decodeJpg(out)!;
    expect(decoded.height, 2400);
    expect(decoded.width, 1800);
  });

  test('leaves a small photo at its size and makes it a JPEG', () {
    final out = ImageCompressor.compressSync(photo(800, 600));
    final decoded = img.decodeJpg(out)!;
    expect(decoded.width, 800);
    expect(decoded.height, 600);
    // JPEG starts with FFD8.
    expect(out[0], 0xFF);
    expect(out[1], 0xD8);
  });

  test('turns the photo upright by its EXIF orientation', () {
    final image = img.Image(width: 400, height: 200);
    image.exif.imageIfd.orientation = 6;
    final jpeg = Uint8List.fromList(img.encodeJpg(image));
    final out = ImageCompressor.compressSync(jpeg);
    final decoded = img.decodeJpg(out)!;
    expect(decoded.width, 200);
    expect(decoded.height, 400);
  });

  test('refuses what is not an image', () {
    expect(
      () => ImageCompressor.compressSync(Uint8List.fromList([1, 2, 3])),
      throwsFormatException,
    );
  });

  test('compress does the same off the main isolate', () async {
    final out = await ImageCompressor.compress(photo(3000, 1000));
    final decoded = img.decodeJpg(out)!;
    expect(decoded.width, 2400);
    expect(decoded.height, 800);
  });
}
