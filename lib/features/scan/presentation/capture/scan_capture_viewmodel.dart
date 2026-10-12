import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:stacked/stacked.dart';

import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/scan/application/form_quad.dart';
import 'package:smap/features/scan/application/scan_flow_state.dart';
import 'package:smap/features/scan/data/scan_camera.dart';
import 'package:smap/features/scan/data/scan_gallery_picker.dart';
import 'package:smap/features/scan/data/scan_vision.dart';
import 'package:smap/features/scan/presentation/capture/scan_capture_dialogs.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_actions.dart';

/// Reads the size an encoded picture is shown at (EXIF applied).
typedef PictureSizer = Future<ui.Size> Function(Uint8List bytes);

/// The default [PictureSizer]: decodes the picture once and measures it.
Future<ui.Size> sizeOfEncodedPicture(Uint8List bytes) async {
  final image = await decodeImageFromList(bytes);
  final size = ui.Size(image.width.toDouble(), image.height.toDouble());
  image.dispose();
  return size;
}

/// Where the camera screen is.
enum CapturePhase {
  /// The camera is starting (a spinner on the dark page).
  opening,

  /// The preview runs; the shutter works.
  ready,

  /// The shutter was pressed; the photo is being taken and read.
  capturing,

  /// The camera could not be opened or the photo could not be taken:
  /// "Kamera açılamadı" (pano 4.10 kare 4).
  failed,
}

/// The logic of "Çekim" (pano 4.3, 4.10 kare 4; spec §4.C 4.3).
///
/// - **Opening.** The back camera opens; if it cannot, the screen becomes
///   "Kamera açılamadı" with the `error` haptic and "Tekrar Dene". Once the
///   preview runs for the first time the how-to-shoot sheet comes up (350 ms),
///   once: it is remembered as seen the moment it is shown, and "?" opens it
///   again whenever asked (without the "Bir daha gösterme" box).
/// - **Looking.** The camera tells [liveForm] where it believes the form is;
///   the hint pill and the orange quadrilateral follow it. The shutter works
///   whether or not a form is found: detection is a suggestion (spec 4.3).
/// - **Shutter.** `AppHaptics.medium`, the photo is taken, the form is
///   searched on it, and the corner screen opens with the photo and what was
///   found.
///
/// The ViewModel owns the camera session and releases it when it is
/// disposed, which is when the flow moves on or closes.
class ScanCaptureViewModel extends BaseViewModel {
  ScanCaptureViewModel({
    required ScanCamera camera,
    required ScanVision vision,
    required DevicePreferences preferences,
    required ScanCaptureDialogs dialogs,
    required ScanFlowActions actions,
    ScanGalleryPicker? gallery,
    PictureSizer sizer = sizeOfEncodedPicture,
  }) : _camera = camera,
       _gallery = gallery,
       _vision = vision,
       _preferences = preferences,
       _dialogs = dialogs,
       _actions = actions,
       _sizer = sizer;

  final ScanCamera _camera;
  final ScanVision _vision;
  final DevicePreferences _preferences;
  final ScanCaptureDialogs _dialogs;
  final ScanFlowActions _actions;
  final PictureSizer _sizer;
  final ScanGalleryPicker? _gallery;

  CapturePhase _phase = CapturePhase.opening;
  ScanCameraSession? _session;
  bool _disposed = false;
  bool _tutorialOpen = false;

  /// Mirrors the session's live form so the view can listen to one stable
  /// notifier from the first frame on.
  final ValueNotifier<FormQuad?> _liveForm = ValueNotifier<FormQuad?>(null);

  CapturePhase get phase => _phase;

  /// The open camera, once there is one.
  ScanCameraSession? get session => _session;

  /// The form the camera believes it sees (unit square of the preview).
  ValueListenable<FormQuad?> get liveForm => _liveForm;

  /// Opens the camera. Also the body of "Tekrar Dene".
  Future<void> init() async {
    final previous = _session;
    if (previous != null) {
      _session = null;
      previous.liveForm.removeListener(_mirrorForm);
      _liveForm.value = null;
      await previous.dispose();
    }
    _setPhase(CapturePhase.opening);
    try {
      final session = await _camera.open();
      if (_disposed) {
        unawaited(session.dispose());
        return;
      }
      _session = session;
      session.liveForm.addListener(_mirrorForm);
      _setPhase(CapturePhase.ready);
      unawaited(_showFirstTutorial());
    } on ScanCameraException {
      if (_disposed) return;
      AppHaptics.error();
      _setPhase(CapturePhase.failed);
    }
  }

  void _mirrorForm() => _liveForm.value = _session?.liveForm.value;

  Future<void> _showFirstTutorial() async {
    if (_preferences.getBool(DevicePreferences.cameraTutorialSeenKey) ??
        false) {
      return;
    }
    // Remembered the moment it is shown: "yalnız ilk sefer".
    await _preferences.setBool(DevicePreferences.cameraTutorialSeenKey, true);
    if (_disposed) return;
    await _openTutorial(first: true);
  }

  /// The "?" button: the how-to-shoot sheet, without the checkbox.
  Future<void> showTutorial() => _openTutorial(first: false);

  Future<void> _openTutorial({required bool first}) async {
    if (_tutorialOpen) return;
    _tutorialOpen = true;
    try {
      await _dialogs.showTutorial(first: first);
    } finally {
      _tutorialOpen = false;
    }
  }

  /// The shutter.
  Future<void> capture() async {
    final session = _session;
    if (_phase != CapturePhase.ready || session == null) return;
    AppHaptics.medium();
    _setPhase(CapturePhase.capturing);
    try {
      await _process(await session.takePicture());
    } on Object {
      if (_disposed) return;
      AppHaptics.error();
      _setPhase(CapturePhase.failed);
    }
  }

  Future<void> _process(Uint8List bytes) async {
    final size = await _sizer(bytes);
    final found = await _vision.findForm(bytes, pictureSize: size);
    if (_disposed) return;
    _actions.captured(ScanPhoto(bytes: bytes, size: size, form: found?.quad));
  }

  /// Whether the debug-only gallery pick is offered on the camera failure
  /// screen (simulators have no camera; see `ScanDebug`).
  bool get canPickFromGallery => _gallery != null;

  /// Debug only: takes the photo from the photo library instead of the camera,
  /// so the corner screen and the screens after it can be seen on a
  /// simulator. The product has no gallery (spec D-15).
  Future<void> pickFromGallery() async {
    final picker = _gallery;
    if (picker == null || _phase == CapturePhase.capturing) return;
    final bytes = await picker.pick();
    if (bytes == null || _disposed) return;
    await _process(bytes);
  }

  /// Kapat.
  void close() => _actions.close();

  void _setPhase(CapturePhase phase) {
    if (_phase == phase) return;
    _phase = phase;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _session?.liveForm.removeListener(_mirrorForm);
    unawaited(_session?.dispose());
    _liveForm.dispose();
    super.dispose();
  }
}
