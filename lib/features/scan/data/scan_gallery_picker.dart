import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Takes a picture from the photo library, **for debugging only**: a
/// simulator has no camera, so the corner screen and what follows are looked
/// at with a library picture. The product has no gallery (spec D-15 "Flaş ve
/// galeri yok"); nothing builds a picker unless [ScanDebug.galleryEnabled].
abstract interface class ScanGalleryPicker {
  /// The picked picture's bytes; `null` when nothing was picked.
  Future<Uint8List?> pick();
}

/// [ScanGalleryPicker] on `image_picker`.
class ImagePickerGalleryPicker implements ScanGalleryPicker {
  const ImagePickerGalleryPicker();

  @override
  Future<Uint8List?> pick() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    return file?.readAsBytes();
  }
}

/// The debug switch of the gallery pick: a debug build run with
/// `--dart-define=SCAN_GALLERY=true`. Always `false` in release.
abstract final class ScanDebug {
  static const bool _define = bool.fromEnvironment('SCAN_GALLERY');

  static const bool galleryEnabled = kDebugMode && _define;
}
