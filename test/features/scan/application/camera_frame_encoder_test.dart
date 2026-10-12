import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:smap/features/scan/application/camera_frame_encoder.dart';

/// A BGRA frame with a padded row stride, blue in the top half and red below.
BgraFrame frame({int width = 720, int height = 1280, int pad = 64}) {
  final stride = width * 4 + pad;
  final bytes = Uint8List(stride * height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final i = y * stride + x * 4;
      final top = y < height ~/ 2;
      bytes[i] = top ? 255 : 0; // B
      bytes[i + 1] = 0; // G
      bytes[i + 2] = top ? 0 : 255; // R
      bytes[i + 3] = 255;
    }
  }
  return BgraFrame(
    bytes: bytes,
    width: width,
    height: height,
    bytesPerRow: stride,
  );
}

void main() {
  test('tags the JPEG like a camera photo: rotate right', () {
    final out = CameraFrameEncoder.encodeSync(frame())!;
    final exif = img.decodeJpgExif(out)!;
    expect(exif.imageIfd.orientation, CameraFrameEncoder.exifRotateRight);
  });

  test('a decoder that honours EXIF sees the portrait picture, 360 x 640', () {
    // `decodeJpg` applies the orientation, as the phone's image decoder does.
    final out = CameraFrameEncoder.encodeSync(frame())!;
    final shown = img.decodeJpg(out)!;
    expect(shown.width, 360);
    expect(shown.height, 640);
  });

  test('the picture the student sees is the right way up', () {
    final out = CameraFrameEncoder.encodeSync(frame())!;
    final shown = img.decodeJpg(out)!;
    final top = shown.getPixel(180, 50);
    final bottom = shown.getPixel(180, 590);
    // The top half of the frame was blue, the bottom half red.
    expect(top.b, greaterThan(top.r));
    expect(bottom.r, greaterThan(bottom.b));
  });

  test('reads a row stride wider than the row', () {
    final out = CameraFrameEncoder.encodeSync(
      frame(width: 200, height: 300, pad: 36),
    );
    expect(out, isNotNull);
  });

  test('gives null for a frame that cannot be read', () {
    final broken = BgraFrame(
      bytes: Uint8List(10),
      width: 720,
      height: 1280,
      bytesPerRow: 2880,
    );
    expect(CameraFrameEncoder.encodeSync(broken), isNull);
  });

  test('encode runs the same work in an isolate', () async {
    final out = await CameraFrameEncoder.encode(frame(width: 200, height: 300));
    expect(out, isNotNull);
  });
}
