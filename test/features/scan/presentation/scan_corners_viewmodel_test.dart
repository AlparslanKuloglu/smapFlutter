import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/scan/application/corner_geometry.dart';
import 'package:smap/features/scan/application/form_quad.dart';
import 'package:smap/features/scan/application/scan_flow_state.dart';
import 'package:smap/features/scan/presentation/corners/scan_corners_viewmodel.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../scan_fakes.dart';

Future<DevicePreferences> prefs([Map<String, Object> values = const {}]) async {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(values);
  return DevicePreferences.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final photo = ScanPhoto(
    bytes: Uint8List.fromList([1, 2, 3]),
    size: const Size(3024, 4032),
  );
  late FakeScanVision vision;
  late RecordingActions actions;
  late DevicePreferences preferences;

  ScanCornersViewModel build({FormQuad? initial}) => ScanCornersViewModel(
    photo: photo,
    initial: initial ?? CornerGeometry.guideQuad,
    vision: vision,
    preferences: preferences,
    actions: actions,
  );

  setUp(() async {
    vision = FakeScanVision();
    actions = RecordingActions();
    preferences = await prefs();
  });

  group('the handles (pano 4.4)', () {
    test('start where they were given', () {
      final found = FormQuad.fromRect(const Rect.fromLTRB(0.1, 0.2, 0.9, 0.8));
      final vm = build(initial: found);
      expect(vm.quad.value, found);
      vm.dispose();
    });

    test('a drag grabs the handle where it was touched: no jump', () {
      final vm = build();
      final start = vm.quad.value.topLeft;
      vm.dragStart(QuadCorner.topLeft, start + const Offset(0.02, 0.01));
      expect(vm.active.value, QuadCorner.topLeft);
      vm.dragUpdate(start + const Offset(0.12, 0.11));
      expect(vm.quad.value.topLeft.dx, closeTo(start.dx + 0.10, 1e-9));
      expect(vm.quad.value.topLeft.dy, closeTo(start.dy + 0.10, 1e-9));
      vm.dragEnd();
      expect(vm.active.value, isNull);
      vm.dispose();
    });

    test('a handle is kept inside the photo', () {
      final vm = build();
      vm.dragStart(QuadCorner.topLeft, vm.quad.value.topLeft);
      vm.dragUpdate(const Offset(-0.4, 0.3));
      expect(vm.quad.value.topLeft, const Offset(0, 0.3));
      vm.dispose();
    });

    test(
      'a drag that would cross the sides leaves the handle where it was',
      () {
        final vm = build();
        final before = vm.quad.value;
        vm.dragStart(QuadCorner.topLeft, before.topLeft);
        vm.dragUpdate(const Offset(0.95, 0.9));
        expect(vm.quad.value, before);
        vm.dispose();
      },
    );

    test('moves only while a handle is picked up', () {
      final vm = build();
      final before = vm.quad.value;
      vm.dragUpdate(const Offset(0.5, 0.5));
      expect(vm.quad.value, before);
      vm.dispose();
    });

    test('a screen reader nudges a handle by a hundredth of the photo', () {
      final vm = build();
      final before = vm.quad.value.topRight;
      vm.nudge(QuadCorner.topRight, dx: -1);
      expect(vm.quad.value.topRight.dx, closeTo(before.dx - 0.01, 1e-9));
      vm.dispose();
    });
  });

  group('the hint card (pano 4.4 kare 1)', () {
    test('is offered until "Bir daha gösterme" hides it for good', () async {
      final vm = build();
      expect(vm.hintOffered, isTrue);
      await vm.hideHint();
      expect(vm.hintOffered, isFalse);
      expect(preferences.getBool('scan.cornersHintHidden'), isTrue);
      vm.dispose();
    });

    test('stays hidden on the next visit', () async {
      preferences = await prefs({'scan.cornersHintHidden': true});
      final vm = build();
      expect(vm.hintOffered, isFalse);
      vm.dispose();
    });
  });

  group('Devam', () {
    test(
      'straightens the photo at the handles, in pixels, and hands it on',
      () async {
        final vm = build();
        await vm.next();
        expect(
          vision.flattenedWith.single.topLeft.dx,
          closeTo(3024 * 36 / 402, 1e-6),
        );
        expect(
          vision.flattenedWith.single.bottomRight.dy,
          closeTo(4032 * 600 / 874, 1e-6),
        );
        expect(actions.calls, ['flattened']);
        expect(actions.flat, Uint8List.fromList([7, 7, 7]));
        expect(actions.quad, vm.quad.value);
        vm.dispose();
      },
    );

    test(
      'sends the whole photo when the platform cannot straighten it',
      () async {
        vision.flat = null;
        final vm = build();
        await vm.next();
        expect(actions.flat, photo.bytes);
        vm.dispose();
      },
    );

    test('is one press: the handles are locked while it works', () async {
      final vm = build();
      final done = vm.next();
      expect(vm.working, isTrue);
      vm.dragStart(QuadCorner.topLeft, vm.quad.value.topLeft);
      expect(vm.active.value, isNull);
      await done;
      vm.dispose();
    });
  });

  test('Tekrar Çek goes back to the camera and Kapat leaves', () {
    final vm = build();
    vm.retake();
    vm.close();
    expect(actions.calls, ['retake', 'close']);
    vm.dispose();
  });
}
