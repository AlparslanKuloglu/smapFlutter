import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/features/scan/application/scan_job_service.dart';
import 'package:smap/features/scan/domain/scan_failure.dart';

import '../scan_fakes.dart';
import '../scan_fixtures.dart';

void main() {
  final photo = Uint8List.fromList([1, 2, 3, 4]);
  final jpeg = Uint8List.fromList([0xFF, 0xD8, 9]);
  const user = {'_id': 'u1'};

  late FakeScanRepository repository;
  late int compressions;

  ScanJobService service({Future<Uint8List> Function(Uint8List)? compress}) =>
      ScanJobService(
        repository: repository,
        user: () => user,
        compress:
            compress ??
            (_) async {
              compressions++;
              return jpeg;
            },
      );

  setUp(() {
    repository = FakeScanRepository();
    compressions = 0;
  });

  test(
    'compresses, sends the compressed photo with the user, and returns the reading',
    () async {
      repository.onRead = (bytes, progress, cancel) async =>
          Right(sampleReading());
      final job = service().start(photo);
      final result = await job.result;
      expect(result.isRight(), isTrue);
      expect(repository.read.single, jpeg);
      expect(repository.users.single, user);
      expect(compressions, 1);
      expect(job.compressed, jpeg);
    },
  );

  test(
    'walks preparing, sending with the real percentage, reading (pano 4.5)',
    () async {
      final done = Completer<void>();
      repository.onRead = (bytes, progress, cancel) async {
        progress!(10, 100);
        progress(64, 100);
        progress(100, 100);
        await done.future;
        return Right(sampleReading());
      };
      final job = service().start(photo);
      final seen = <ScanJobProgress>[];
      job.progress.addListener(() => seen.add(job.progress.value));
      expect(job.progress.value, const ScanJobProgress(ScanJobStep.preparing));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(seen, [
        const ScanJobProgress(ScanJobStep.sending),
        const ScanJobProgress(ScanJobStep.sending, percent: 10),
        const ScanJobProgress(ScanJobStep.sending, percent: 64),
        const ScanJobProgress(ScanJobStep.reading),
      ]);
      done.complete();
      await job.result;
    },
  );

  test(
    'a failed connection is a failure the screen can name, and keeps the compressed photo',
    () async {
      repository.onRead = (bytes, progress, cancel) async =>
          Left(exception(AppErrorCode.network));
      final job = service().start(photo);
      final failure = (await job.result).swap().getOrElse(
        () => throw 'no failure',
      );
      expect(failure.kind, ScanFailureKind.connection);
      expect(job.compressed, jpeg);
    },
  );

  test('a timeout, a server failure and maintenance are told apart', () async {
    for (final (code, kind) in [
      (AppErrorCode.timeout, ScanFailureKind.timeout),
      (AppErrorCode.server, ScanFailureKind.server),
      (AppErrorCode.maintenance, ScanFailureKind.maintenance),
    ]) {
      repository.onRead = (bytes, progress, cancel) async =>
          Left(exception(code));
      final failure = (await service().start(photo).result).swap().getOrElse(
        () => throw 'no failure',
      );
      expect(failure.kind, kind, reason: code.name);
    }
  });

  test('offline is a connection failure that knows it is offline', () async {
    repository.onRead = (bytes, progress, cancel) async =>
        Left(exception(AppErrorCode.offline));
    final failure = (await service().start(photo).result).swap().getOrElse(
      () => throw 'no failure',
    );
    expect(failure.kind, ScanFailureKind.connection);
    expect(failure.isOffline, isTrue);
  });

  test(
    'a retry sends the same compressed photo without compressing again',
    () async {
      repository.onRead = (bytes, progress, cancel) async =>
          Left(exception(AppErrorCode.timeout));
      final first = service().start(photo);
      await first.result;
      repository.onRead = (bytes, progress, cancel) async =>
          Right(sampleReading());
      final second = service().start(photo, compressed: first.compressed);
      expect((await second.result).isRight(), isTrue);
      expect(compressions, 1);
      expect(repository.read, [jpeg, jpeg]);
    },
  );

  test('cancel stops the call and ends with a cancelled failure', () async {
    final started = Completer<CancelToken>();
    repository.onRead = (bytes, progress, cancel) async {
      started.complete(cancel);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return Left(exception(AppErrorCode.cancelled));
    };
    final job = service().start(photo);
    final token = await started.future;
    job.cancel();
    expect(token.isCancelled, isTrue);
    final failure = (await job.result).swap().getOrElse(
      () => throw 'no failure',
    );
    expect(failure.kind, ScanFailureKind.cancelled);
  });

  test('cancelling during the compression sends nothing', () async {
    final compressing = Completer<Uint8List>();
    final job = service(compress: (_) => compressing.future).start(photo);
    job.cancel();
    compressing.complete(jpeg);
    final failure = (await job.result).swap().getOrElse(
      () => throw 'no failure',
    );
    expect(failure.kind, ScanFailureKind.cancelled);
    expect(repository.read, isEmpty);
  });

  test(
    'a photo that cannot be compressed fails as a server-side problem, not a crash',
    () async {
      final job = service(
        compress: (_) async => throw const FormatException('x'),
      ).start(photo);
      final failure = (await job.result).swap().getOrElse(
        () => throw 'no failure',
      );
      expect(failure.kind, ScanFailureKind.server);
      expect(repository.read, isEmpty);
    },
  );
}
