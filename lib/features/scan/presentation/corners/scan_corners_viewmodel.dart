import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/scan/application/corner_geometry.dart';
import 'package:smap/features/scan/application/form_quad.dart';
import 'package:smap/features/scan/application/scan_flow_state.dart';
import 'package:smap/features/scan/application/scan_preference_keys.dart';
import 'package:smap/features/scan/data/scan_vision.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_actions.dart';

/// The logic of "Köşeleri Ayarla" (pano 4.4; spec §4.C 4.4).
///
/// - The four handles start where the detector found the form, else on the
///   guide frame ([ScanPhoto.startQuad]); when the student comes back from the
///   upload they are where they left them.
/// - A drag grabs the handle where the finger touched it (no jump), keeps it
///   inside the photo and refuses a move that would make the quadrilateral
///   cross itself. `AppHaptics.selection` plays when a handle settles against
///   the photo's edge.
/// - The hint card ("Noktaları cevap alanının köşelerine getir.") shows until
///   "Bir daha gösterme" hides it for good; it is out of the way while a handle
///   is dragged.
/// - "Devam" straightens the photo at the handles (the platform's perspective
///   correction; the photo itself, not the preview) and hands the result to
///   the upload; there is no second editing step (spec 4.4). If the platform
///   cannot straighten it, the whole photo goes on.
///
/// The handles change sixty times a second while dragged, so they live in
/// [ValueNotifier]s and only the layers that draw them rebuild.
class ScanCornersViewModel extends BaseViewModel {
  ScanCornersViewModel({
    required ScanPhoto photo,
    required FormQuad initial,
    required ScanVision vision,
    required DevicePreferences preferences,
    required ScanFlowActions actions,
  }) : _photo = photo,
       _vision = vision,
       _preferences = preferences,
       _actions = actions,
       quad = ValueNotifier<FormQuad>(initial),
       _hintHidden =
           preferences.getBool(ScanPreferenceKeys.cornersHintHidden) ?? false;

  final ScanPhoto _photo;
  final ScanVision _vision;
  final DevicePreferences _preferences;
  final ScanFlowActions _actions;

  /// The handles, in the unit square of the photo.
  final ValueNotifier<FormQuad> quad;

  /// The handle being dragged; `null` between drags.
  final ValueNotifier<QuadCorner?> active = ValueNotifier<QuadCorner?>(null);

  bool _hintHidden;
  bool _working = false;
  bool _atEdge = false;
  bool _disposed = false;
  Offset _grab = Offset.zero;

  /// The photo being adjusted.
  ScanPhoto get photo => _photo;

  /// Whether "Devam" is running.
  bool get working => _working;

  /// Whether the hint card is offered (the student did not hide it).
  bool get hintOffered => !_hintHidden;

  /// "Bir daha gösterme" on the hint card.
  Future<void> hideHint() async {
    _hintHidden = true;
    notifyListeners();
    await _preferences.setBool(ScanPreferenceKeys.cornersHintHidden, true);
  }

  /// A finger touched [corner] at [touch] (unit square).
  void dragStart(QuadCorner corner, Offset touch) {
    if (_working) return;
    _grab = quad.value[corner] - touch;
    _atEdge = false;
    active.value = corner;
  }

  /// The finger moved to [touch] (unit square).
  void dragUpdate(Offset touch) {
    final corner = active.value;
    if (corner == null || _working) return;
    final result = CornerGeometry.move(quad.value, corner, touch + _grab);
    quad.value = result.quad;
    if (result.atEdge && !_atEdge) AppHaptics.selection();
    _atEdge = result.atEdge;
  }

  /// The finger lifted.
  void dragEnd() {
    active.value = null;
    _atEdge = false;
  }

  /// Screen-reader and keyboard step of [corner] by [dx] and [dy] (each -1, 0
  /// or 1; [CornerGeometry.nudgeStep] of the photo).
  void nudge(QuadCorner corner, {double dx = 0, double dy = 0}) {
    if (_working) return;
    quad.value = CornerGeometry.nudge(quad.value, corner, dx: dx, dy: dy).quad;
  }

  /// "Devam".
  Future<void> next() async {
    if (_working) return;
    _working = true;
    notifyListeners();
    final corners = quad.value;
    final flat = await _vision.flatten(
      _photo.bytes,
      CornerGeometry.toPixels(corners, _photo.size),
    );
    if (_disposed) return;
    _actions.flattened(flat ?? _photo.bytes, corners);
  }

  /// "Tekrar Çek": back to the camera ("öğretici yeniden açılmaz").
  void retake() => _actions.retake();

  /// Kapat.
  void close() => _actions.close();

  @override
  void dispose() {
    _disposed = true;
    quad.dispose();
    active.dispose();
    super.dispose();
  }
}
