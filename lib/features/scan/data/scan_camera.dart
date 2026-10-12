import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:flutter/widgets.dart';
import 'package:smap/features/scan/application/camera_frame_encoder.dart';
import 'package:smap/features/scan/application/form_quad.dart';
import 'package:smap/features/scan/application/form_tracker.dart';
import 'package:smap/features/scan/data/scan_vision.dart';

/// The camera could not be opened (none, taken by another app, refused).
class ScanCameraException implements Exception {
  const ScanCameraException([this.cause]);

  final Object? cause;

  @override
  String toString() => 'ScanCameraException($cause)';
}

/// The camera of the scan, behind a seam so the capture ViewModel stays
/// testable (the `camera` package in the app, a fake in tests).
abstract interface class ScanCamera {
  /// Opens the back camera. Throws a [ScanCameraException] when it cannot.
  Future<ScanCameraSession> open();
}

/// An open camera: a preview, a live guess at where the form is, and the
/// shutter.
abstract interface class ScanCameraSession {
  /// The shape of the preview as the student sees it (portrait), in any
  /// unit: only its aspect is used.
  Size get previewSize;

  /// The form the camera believes it sees, in the unit square of the
  /// preview; `null` while it sees none. Platforms that cannot look for a
  /// form live keep it `null` and the photo is searched after the shutter.
  ValueListenable<FormQuad?> get liveForm;

  /// The preview, scaled to cover the box it is given.
  Widget buildPreview();

  /// Takes the photo and returns its bytes. The live search stops first.
  Future<Uint8List> takePicture();

  /// Stops the live search and the preview and frees the camera.
  Future<void> dispose();
}

/// [ScanCamera] on the `camera` package.
///
/// Portrait only; flash off; auto focus and exposure. On iOS the preview
/// stream also feeds a light form search (about twice a second): each frame
/// is shrunk to a small JPEG ([CameraFrameEncoder]) and sent to the document
/// scanner's detector ([ScanVision]); a [FormTracker] turns the answers into
/// a steady found / lost state. Android has no live search yet (its stream is
/// not BGRA) and finds the form on the photo, as the old flow did.
class CameraPackageScanCamera implements ScanCamera {
  const CameraPackageScanCamera({required ScanVision vision})
    : _vision = vision;

  final ScanVision _vision;

  @override
  Future<ScanCameraSession> open() async {
    CameraController? controller;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw const ScanCameraException('no camera');
      final back = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.iOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      await Future.wait<void>([
        controller.setFlashMode(FlashMode.off),
        controller.setFocusMode(FocusMode.auto),
        controller.setExposureMode(ExposureMode.auto),
        controller.lockCaptureOrientation(DeviceOrientation.portraitUp),
      ]).catchError((Object _) => <void>[]);
      final session = _CameraPackageSession(controller, _vision);
      session._startSearching();
      return session;
    } on ScanCameraException {
      await controller?.dispose();
      rethrow;
    } on Object catch (error) {
      await controller?.dispose();
      throw ScanCameraException(error);
    }
  }
}

class _CameraPackageSession implements ScanCameraSession {
  _CameraPackageSession(this._controller, this._vision);

  final CameraController _controller;
  final ScanVision _vision;
  final FormTracker _tracker = FormTracker();
  final ValueNotifier<FormQuad?> _liveForm = ValueNotifier<FormQuad?>(null);

  /// The gap between two searches.
  static const Duration _interval = Duration(milliseconds: 450);

  var _busy = false;
  var _disposed = false;
  var _searching = false;
  DateTime _lastSearch = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Size get previewSize {
    final size = _controller.value.previewSize ?? const Size(720, 1280);
    // The plugin reports the sensor's landscape size; the screen is portrait.
    return size.width > size.height ? Size(size.height, size.width) : size;
  }

  @override
  ValueListenable<FormQuad?> get liveForm => _liveForm;

  @override
  Widget buildPreview() {
    final size = previewSize;
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: CameraPreview(_controller),
        ),
      ),
    );
  }

  void _startSearching() {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    _searching = true;
    unawaited(
      _controller.startImageStream(_onFrame).catchError((Object _) {
        _searching = false;
      }),
    );
  }

  void _onFrame(CameraImage image) {
    if (_busy || _disposed || !_searching) return;
    final now = DateTime.now();
    if (now.difference(_lastSearch) < _interval) return;
    if (image.format.group != ImageFormatGroup.bgra8888 ||
        image.planes.length != 1) {
      return;
    }
    _busy = true;
    final plane = image.planes.first;
    final frame = BgraFrame(
      bytes: Uint8List.fromList(plane.bytes),
      width: image.width,
      height: image.height,
      bytesPerRow: plane.bytesPerRow,
    );
    unawaited(_search(frame));
  }

  Future<void> _search(BgraFrame frame) async {
    try {
      final jpeg = await CameraFrameEncoder.encode(frame);
      if (jpeg == null || _disposed || !_searching) return;
      final found = await _vision.findForm(jpeg);
      if (_disposed || !_searching) return;
      _tracker.update(found?.quad);
      _liveForm.value = _tracker.current;
    } finally {
      _lastSearch = DateTime.now();
      _busy = false;
    }
  }

  Future<void> _stopSearching() async {
    if (!_searching) return;
    _searching = false;
    try {
      if (_controller.value.isStreamingImages) {
        await _controller.stopImageStream();
      }
    } on Object {
      // The stream was already gone.
    }
  }

  @override
  Future<Uint8List> takePicture() async {
    await _stopSearching();
    final file = await _controller.takePicture();
    final bytes = await file.readAsBytes();
    try {
      await File(file.path).delete();
    } on Object {
      // The cache folder is cleaned by the system anyway.
    }
    return bytes;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _stopSearching();
    _liveForm.dispose();
    await _controller.dispose();
  }
}
