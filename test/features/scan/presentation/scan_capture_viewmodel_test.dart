import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/scan/application/form_quad.dart';
import 'package:smap/features/scan/data/scan_gallery_picker.dart';
import 'package:smap/features/scan/data/scan_vision.dart';
import 'package:smap/features/scan/presentation/capture/scan_capture_dialogs.dart';
import 'package:smap/features/scan/presentation/capture/scan_capture_viewmodel.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../scan_fakes.dart';

class _Dialogs implements ScanCaptureDialogs {
  final List<bool> shown = [];

  @override
  Future<void> showTutorial({required bool first}) async => shown.add(first);
}

class _Gallery implements ScanGalleryPicker {
  Uint8List? picked = Uint8List.fromList([4, 5, 6]);

  @override
  Future<Uint8List?> pick() async => picked;
}

Future<DevicePreferences> prefs([Map<String, Object> values = const {}]) async {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(values);
  return DevicePreferences.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeScanCamera camera;
  late FakeScanVision vision;
  late _Dialogs dialogs;
  late RecordingActions actions;

  Future<ScanCaptureViewModel> build({
    Map<String, Object> stored = const {},
    ScanGalleryPicker? gallery,
  }) async => ScanCaptureViewModel(
    camera: camera,
    vision: vision,
    preferences: await prefs(stored),
    dialogs: dialogs,
    actions: actions,
    gallery: gallery,
    sizer: (_) async => const Size(3024, 4032),
  );

  setUp(() {
    camera = FakeScanCamera();
    vision = FakeScanVision();
    dialogs = _Dialogs();
    actions = RecordingActions();
  });

  group('opening the camera', () {
    test('starts opening, then ready with the session', () async {
      final vm = await build();
      expect(vm.phase, CapturePhase.opening);
      await vm.init();
      expect(vm.phase, CapturePhase.ready);
      expect(vm.session, isNotNull);
      vm.dispose();
    });

    test(
      'a camera that cannot open is "Kamera açılamadı" (pano 4.10 kare 4)',
      () async {
        camera.openError = 'busy';
        final vm = await build();
        await vm.init();
        expect(vm.phase, CapturePhase.failed);
        expect(vm.session, isNull);
        vm.dispose();
      },
    );

    test('"Tekrar Dene" opens the camera again', () async {
      camera.openError = 'busy';
      final vm = await build();
      await vm.init();
      camera.openError = null;
      await vm.init();
      expect(vm.phase, CapturePhase.ready);
      expect(camera.opened, 2);
      vm.dispose();
    });

    test('retrying frees the session of the earlier try', () async {
      final vm = await build();
      await vm.init();
      final first = camera.sessions.single;
      await vm.init();
      expect(first.disposed, isTrue);
      expect(camera.sessions, hasLength(2));
      vm.dispose();
    });

    test('closing the screen frees the camera', () async {
      final vm = await build();
      await vm.init();
      final session = camera.sessions.single;
      vm.dispose();
      expect(session.disposed, isTrue);
    });
  });

  group('the how-to-shoot sheet (pano 4.2)', () {
    test(
      'opens by itself on the first opening and is remembered at once',
      () async {
        final vm = await build();
        await vm.init();
        await Future<void>.delayed(Duration.zero);
        expect(dialogs.shown, [true]);
        vm.dispose();
      },
    );

    test('does not open again once it was seen', () async {
      final vm = await build(stored: {'scan.tutorialSeen': true});
      await vm.init();
      await Future<void>.delayed(Duration.zero);
      expect(dialogs.shown, isEmpty);
      vm.dispose();
    });

    test(
      'the question mark opens it without the checkbox, whenever asked',
      () async {
        final vm = await build(stored: {'scan.tutorialSeen': true});
        await vm.init();
        await vm.showTutorial();
        await vm.showTutorial();
        expect(dialogs.shown, [false, false]);
        vm.dispose();
      },
    );
  });

  group('looking for the form (pano 4.3)', () {
    test('mirrors what the camera sees', () async {
      final vm = await build(stored: {'scan.tutorialSeen': true});
      await vm.init();
      final quad = FormQuad.fromRect(const Rect.fromLTRB(0.1, 0.2, 0.9, 0.8));
      expect(vm.liveForm.value, isNull);
      camera.sessions.single.form.value = quad;
      expect(vm.liveForm.value, quad);
      camera.sessions.single.form.value = null;
      expect(vm.liveForm.value, isNull);
      vm.dispose();
    });
  });

  group('the shutter', () {
    test('takes the photo, finds the form on it and hands both over', () async {
      final quad = FormQuad.fromRect(const Rect.fromLTRB(0.1, 0.2, 0.9, 0.8));
      vision.found = DetectedForm(
        quad: quad,
        imageSize: const Size(3024, 4032),
      );
      final vm = await build(stored: {'scan.tutorialSeen': true});
      await vm.init();
      await vm.capture();
      expect(actions.calls, ['captured']);
      expect(actions.photo!.bytes, Uint8List.fromList([1, 2, 3]));
      expect(actions.photo!.size, const Size(3024, 4032));
      expect(actions.photo!.form, quad);
      vm.dispose();
    });

    test(
      'works without a found form: the corners start on the guide',
      () async {
        final vm = await build(stored: {'scan.tutorialSeen': true});
        await vm.init();
        await vm.capture();
        expect(actions.photo!.form, isNull);
        vm.dispose();
      },
    );

    test('does nothing while the camera is not ready', () async {
      camera.openError = 'busy';
      final vm = await build();
      await vm.init();
      await vm.capture();
      expect(actions.calls, isEmpty);
      vm.dispose();
    });

    test('a photo that cannot be taken is the camera failure screen', () async {
      final vm = await build(stored: {'scan.tutorialSeen': true});
      await vm.init();
      camera.sessions.single.takeError = StateError('busy');
      await vm.capture();
      expect(vm.phase, CapturePhase.failed);
      expect(actions.calls, isEmpty);
      vm.dispose();
    });

    test('Kapat leaves the scan', () async {
      final vm = await build();
      vm.close();
      expect(actions.calls, ['close']);
      vm.dispose();
    });
  });

  group('the debug-only library pick', () {
    test('is not offered without a picker', () async {
      final vm = await build();
      expect(vm.canPickFromGallery, isFalse);
      await vm.pickFromGallery();
      expect(actions.calls, isEmpty);
      vm.dispose();
    });

    test(
      'takes a library picture through the same path as the shutter',
      () async {
        final vm = await build(gallery: _Gallery());
        expect(vm.canPickFromGallery, isTrue);
        await vm.pickFromGallery();
        expect(actions.calls, ['captured']);
        expect(actions.photo!.bytes, Uint8List.fromList([4, 5, 6]));
        vm.dispose();
      },
    );

    test('a cancelled pick changes nothing', () async {
      final picker = _Gallery()..picked = null;
      final vm = await build(gallery: picker);
      await vm.pickFromGallery();
      expect(actions.calls, isEmpty);
      vm.dispose();
    });
  });
}
