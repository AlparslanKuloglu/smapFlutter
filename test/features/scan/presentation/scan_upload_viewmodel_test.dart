import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/features/scan/application/scan_job_service.dart';
import 'package:smap/features/scan/domain/scan_failure.dart';
import 'package:smap/features/scan/presentation/upload/scan_upload_viewmodel.dart';

import '../scan_fakes.dart';
import '../scan_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final photo = Uint8List.fromList([1, 2, 3]);
  final jpeg = Uint8List.fromList([0xFF, 0xD8]);
  late FakeScanRepository repository;
  late RecordingActions actions;
  late int compressions;

  ScanUploadViewModel build() {
    final jobs = ScanJobService(
      repository: repository,
      user: () => const {'_id': 'u1'},
      compress: (_) async {
        compressions++;
        return jpeg;
      },
    );
    return ScanUploadViewModel(photo: photo, jobs: jobs, actions: actions);
  }

  setUp(() {
    repository = FakeScanRepository();
    actions = RecordingActions();
    compressions = 0;
  });

  test('a successful read moves the flow on with the reading', () async {
    repository.onRead = (bytes, progress, cancel) async =>
        Right(sampleReading());
    final vm = build();
    await vm.start();
    expect(actions.calls, ['readFinished']);
    expect(actions.reading!.grid!.totalCells, 160);
    expect(vm.failure, isNull);
    vm.dispose();
  });

  test('follows the job: preparing, sending %64, reading (pano 4.5)', () async {
    final release = Completer<void>();
    repository.onRead = (bytes, progress, cancel) async {
      progress!(64, 100);
      await Future<void>.delayed(Duration.zero);
      progress(100, 100);
      await release.future;
      return Right(sampleReading());
    };
    final vm = build();
    final seen = <ScanJobProgress>[];
    vm.progress.addListener(() => seen.add(vm.progress.value));
    final run = vm.start();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(
      seen,
      contains(const ScanJobProgress(ScanJobStep.sending, percent: 64)),
    );
    expect(seen.last, const ScanJobProgress(ScanJobStep.reading));
    release.complete();
    await run;
    vm.dispose();
  });

  group('a failure (pano 4.5 kare 4)', () {
    test('stays on the screen with the reason and keeps the photo', () async {
      repository.onRead = (bytes, progress, cancel) async =>
          Left(exception(AppErrorCode.network));
      final vm = build();
      await vm.start();
      expect(vm.failure!.kind, ScanFailureKind.connection);
      expect(vm.prepared, isTrue);
      expect(actions.calls, isEmpty);
      expect(vm.photo, photo);
      vm.dispose();
    });

    test('"Tekrar Dene" sends the same compressed photo again', () async {
      repository.onRead = (bytes, progress, cancel) async =>
          Left(exception(AppErrorCode.timeout));
      final vm = build();
      await vm.start();
      expect(vm.failure!.kind, ScanFailureKind.timeout);
      repository.onRead = (bytes, progress, cancel) async =>
          Right(sampleReading());
      await vm.start();
      expect(vm.failure, isNull);
      expect(actions.calls, ['readFinished']);
      expect(compressions, 1);
      expect(repository.read, [jpeg, jpeg]);
      vm.dispose();
    });

    test('"Yeni Fotoğraf" goes back to the camera', () async {
      repository.onRead = (bytes, progress, cancel) async =>
          Left(exception(AppErrorCode.network));
      final vm = build();
      await vm.start();
      vm.newPhoto();
      expect(actions.calls, ['retake']);
      vm.dispose();
    });

    test(
      'without a connection and with the queue on, the flow takes it',
      () async {
        actions.offlineAccepted = true;
        repository.onRead = (bytes, progress, cancel) async =>
            Left(exception(AppErrorCode.offline));
        final vm = build();
        await vm.start();
        expect(actions.calls, ['uploadOffline']);
        expect(vm.failure, isNull);
        vm.dispose();
      },
    );

    test('without a connection and no queue, the failure stays here', () async {
      repository.onRead = (bytes, progress, cancel) async =>
          Left(exception(AppErrorCode.offline));
      final vm = build();
      await vm.start();
      expect(actions.calls, ['uploadOffline']);
      expect(vm.failure!.isOffline, isTrue);
      vm.dispose();
    });
  });

  test('Vazgeç stops the call and goes back to the corners', () async {
    final started = Completer<void>();
    repository.onRead = (bytes, progress, cancel) async {
      started.complete();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      return Left(exception(AppErrorCode.cancelled));
    };
    final vm = build();
    final run = vm.start();
    await started.future;
    vm.cancel();
    await run;
    expect(actions.calls, ['backToCorners']);
    expect(vm.failure, isNull);
    vm.dispose();
  });

  test('a second start while it runs does nothing', () async {
    final release = Completer<void>();
    repository.onRead = (bytes, progress, cancel) async {
      await release.future;
      return Right(sampleReading());
    };
    final vm = build();
    final first = vm.start();
    await vm.start();
    release.complete();
    await first;
    expect(repository.read, hasLength(1));
    vm.dispose();
  });
}
