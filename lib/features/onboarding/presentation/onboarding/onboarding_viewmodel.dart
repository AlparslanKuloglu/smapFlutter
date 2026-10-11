import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/domain/user_role.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/onboarding/application/camera_permission.dart';
import 'package:smap/features/onboarding/application/onboarding_draft.dart';
import 'package:smap/features/onboarding/application/onboarding_flow.dart';
import 'package:smap/features/onboarding/onboarding_navigation.dart';

/// The logic of the intro flow: 3 intro pages, role, grade and track, the
/// camera primer (pano 2.1 kare 2-4, 2.2 kare 1-4; flow 13.1).
///
/// The flow itself (what follows what, what Back does) is
/// [OnboardingFlowState]; this class holds one, keeps it in the draft store
/// so a closed app opens at the same step with the same picks, and runs the
/// camera permission. It is context-free: navigation goes through
/// [OnboardingNavigator].
///
/// The onboarding-done flag is set when the flow ends, right before the
/// welcome screen opens (the guards let a signed-out route through only after
/// it).
class OnboardingViewModel extends BaseViewModel {
  OnboardingViewModel({
    required OnboardingDraftStore draft,
    required DevicePreferences preferences,
    required CameraPermission camera,
    required OnboardingNavigator navigator,
  }) : _draft = draft,
       _preferences = preferences,
       _camera = camera,
       _navigator = navigator,
       _flow = draft.read() {
    _introPage = ValueNotifier<int>(_flow.introPage);
  }

  final OnboardingDraftStore _draft;
  final DevicePreferences _preferences;
  final CameraPermission _camera;
  final OnboardingNavigator _navigator;

  OnboardingFlowState _flow;
  late final ValueNotifier<int> _introPage;
  bool _forward = true;
  bool _trackError = false;
  CameraPermissionState _cameraState = CameraPermissionState.notAsked;
  bool _cameraBusy = false;
  bool _finishing = false;

  // ── Read ──

  OnboardingStep get step => _flow.step;

  /// The last move went forward; the step switcher slides the other way on
  /// Back.
  bool get forward => _forward;

  OnboardingSelections get selections => _flow.selections;

  /// The current intro page (0-based). Changes without rebuilding the
  /// screen: the pager, the dots and the buttons listen to it.
  ValueListenable<int> get introPage => _introPage;

  /// "Alanını seç." shows under the track chips.
  bool get trackError => _trackError;

  CameraPermissionState get cameraState => _cameraState;

  /// The system dialog is open.
  bool get cameraBusy => _cameraBusy;

  // ── Start ──

  /// Called once the screen is up: a restored camera step asks the system
  /// what it already knows.
  void start() {
    if (_flow.step == OnboardingStep.camera) unawaited(_readCamera());
  }

  // ── Intro ──

  /// A swipe landed on [page].
  void setIntroPage(int page) {
    if (page == _flow.introPage || _flow.step != OnboardingStep.intro) return;
    _flow = _flow.copyWith(introPage: page);
    _introPage.value = page;
    _save();
  }

  /// "Geç".
  void skipIntro() => _move(_flow.skipIntro());

  // ── Picks ──

  void selectRole(UserRole role) {
    if (role == _flow.selections.role) return;
    _flow = _flow.copyWith(selections: _flow.selections.withRole(role));
    _save();
    notifyListeners();
  }

  void selectGrade(SchoolGrade grade) {
    if (grade == _flow.selections.grade) return;
    _flow = _flow.copyWith(selections: _flow.selections.withGrade(grade));
    _trackError = false;
    _save();
    notifyListeners();
  }

  void selectTrack(StudyTrack track) {
    final picked = _flow.selections.withTrack(track);
    if (picked == _flow.selections) return;
    _flow = _flow.copyWith(selections: picked);
    _trackError = false;
    _save();
    notifyListeners();
  }

  // ── Moves ──

  /// "Devam Et" / "Başla". On the grade step a missing track shows its error
  /// and stays; nothing is chosen for the user.
  void next() {
    if (_flow.step == OnboardingStep.grade && _flow.selections.trackMissing) {
      _trackError = true;
      notifyListeners();
      return;
    }
    final moved = _flow.next();
    if (moved == null) {
      unawaited(_finish());
    } else {
      _move(moved);
    }
  }

  /// Back on the screen, the bar or the system. `false` when the flow is at
  /// its root and there is nowhere to go.
  bool back() {
    final previous = _flow.previous();
    if (previous == null) return false;
    _move(previous, forward: false);
    return true;
  }

  void _move(OnboardingFlowState state, {bool forward = true}) {
    final stepChanged = state.step != _flow.step;
    _flow = state;
    _forward = forward;
    _trackError = false;
    _introPage.value = state.introPage;
    _save();
    if (stepChanged) {
      if (state.step == OnboardingStep.camera) unawaited(_readCamera());
      notifyListeners();
    }
  }

  // ── Camera ──

  /// "Kameraya İzin Ver" asks the system; once it was refused for good the
  /// same button is "Ayarları Aç".
  Future<void> allowCamera() async {
    if (_cameraBusy) return;
    if (_cameraState == CameraPermissionState.denied) {
      await _camera.openSettings();
      return;
    }
    _cameraBusy = true;
    notifyListeners();
    final result = await _camera.request();
    _cameraBusy = false;
    if (result == CameraPermissionState.granted) {
      await _finish();
      return;
    }
    _cameraState = result;
    notifyListeners();
  }

  /// "Sonra": on without the permission; the first scan asks again.
  Future<void> later() => _finish();

  /// The app came back to the front (from the settings): a permission given
  /// there moves the flow on.
  Future<void> onResumed() async {
    if (_flow.step != OnboardingStep.camera || _finishing) return;
    if (_cameraState != CameraPermissionState.denied) return;
    await _readCamera(moveOnWhenGranted: true);
  }

  Future<void> _readCamera({bool moveOnWhenGranted = false}) async {
    final state = await _camera.status();
    if (_finishing || _flow.step != OnboardingStep.camera) return;
    if (state == CameraPermissionState.granted && moveOnWhenGranted) {
      await _finish();
      return;
    }
    // A permission that was already given leaves the primer as it is; only a
    // refusal for good changes it.
    final next = state == CameraPermissionState.denied
        ? CameraPermissionState.denied
        : CameraPermissionState.notAsked;
    if (next == _cameraState) return;
    _cameraState = next;
    notifyListeners();
  }

  /// Sets the done flag, then opens the welcome screen.
  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    await _preferences.setBool(DevicePreferences.onboardingCompletedKey, true);
    await _draft.write(_flow);
    await _navigator.toWelcome();
  }

  void _save() => unawaited(_draft.write(_flow));

  @override
  void dispose() {
    _introPage.dispose();
    super.dispose();
  }
}
