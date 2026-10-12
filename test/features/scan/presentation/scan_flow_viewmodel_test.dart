import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/scan/application/form_quad.dart';
import 'package:smap/features/scan/application/scan_flow_state.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_viewmodel.dart';

import '../scan_fakes.dart';
import '../scan_fixtures.dart';

void main() {
  late RecordingNavigator navigator;
  final photo = ScanPhoto(
    bytes: Uint8List.fromList([1]),
    size: const Size(10, 20),
  );
  final quad = FormQuad.fromRect(const Rect.fromLTRB(0.1, 0.2, 0.9, 0.8));
  final flat = Uint8List.fromList([2]);

  ScanFlowViewModel build({bool queue = false}) =>
      ScanFlowViewModel(navigator: navigator, offlineQueueEnabled: queue);

  setUp(() => navigator = RecordingNavigator());

  test('walks the whole way to an unknown exam (flow 13.4 and 13.5)', () {
    final vm = build();
    var stages = <ScanStage>[vm.state.stage];
    vm.addListener(() => stages.add(vm.state.stage));
    vm.captured(photo);
    vm.flattened(flat, quad);
    vm.readFinished(sampleReading());
    vm.examUnknown(AnswerReply.fromJson(sampleAnswerJson(found: false)));
    expect(stages, [
      ScanStage.capture,
      ScanStage.corners,
      ScanStage.upload,
      ScanStage.review,
      ScanStage.request,
    ]);
    vm.dispose();
  });

  test('a recognised exam leaves for the result through the navigator', () {
    final vm = build()..examRecognised('abc');
    expect(navigator.calls, ['result:abc']);
    vm.dispose();
  });

  test('"Tekrar Çek" builds a fresh camera: the generation moves on', () {
    final vm = build()..captured(photo);
    final before = vm.generation;
    vm.retake();
    expect(vm.state.stage, ScanStage.capture);
    expect(vm.generation, before + 1);
    vm.dispose();
  });

  test('Vazgeç on the upload returns to the corners with the photo', () {
    final vm = build()
      ..captured(photo)
      ..flattened(flat, quad)
      ..backToCorners();
    expect(vm.state.stage, ScanStage.corners);
    expect(vm.state.photo, photo);
    vm.dispose();
  });

  test('a form the reader cannot find is the error stage', () {
    final vm = build()
      ..captured(photo)
      ..flattened(flat, quad)
      ..readFinished(
        OpticReading.fromJson(const {'answersArray': <Object?>[]}),
      );
    expect(vm.state.stage, ScanStage.error);
    expect(vm.state.errorKind, ScanErrorKind.formNotFound);
    vm.dispose();
  });

  group('the planned offline screen', () {
    test('is taken only while the queue flag is on', () {
      final off = build()
        ..captured(photo)
        ..flattened(flat, quad);
      expect(off.uploadOffline(), isFalse);
      expect(off.state.stage, ScanStage.upload);
      off.dispose();

      final on = build(queue: true)
        ..captured(photo)
        ..flattened(flat, quad);
      expect(on.uploadOffline(), isTrue);
      expect(on.state.errorKind, ScanErrorKind.offline);
      on.retryUpload();
      expect(on.state.stage, ScanStage.upload);
      on.dispose();
    });

    test('is not taken outside the upload', () {
      final vm = build(queue: true);
      expect(vm.uploadOffline(), isFalse);
      vm.dispose();
    });
  });

  test('leaving goes through the navigator', () {
    final vm = build()
      ..close()
      ..goHome();
    expect(navigator.calls, ['close', 'home']);
    vm.dispose();
  });

  test('notifies only when the state changes', () {
    final vm = build();
    var notified = 0;
    vm.addListener(() => notified++);
    vm.backToCorners();
    expect(notified, 0);
    vm.captured(photo);
    expect(notified, 1);
    vm.dispose();
  });
}
