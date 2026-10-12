import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:smap/features/scan/data/scan_repository.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';
import 'package:smap/features/scan/domain/scan_failure.dart';

/// The three real steps of the upload screen (pano 4.5): the photo is made
/// small, it is sent, the reader reads it. No time is promised for any.
enum ScanJobStep {
  /// "Fotoğraf hazırlanıyor": compressing on the phone.
  preparing,

  /// "Gönderiliyor %64": the upload, with its real percentage.
  sending,

  /// "Cevapların okunuyor": the bytes are with the server and the answer is
  /// awaited (an indeterminate wait; the old reply deadline is 30 s).
  reading,
}

/// Where a job is: the [step] and, while sending, the [percent] (0 to 100).
@immutable
class ScanJobProgress {
  const ScanJobProgress(this.step, {this.percent = 0});

  final ScanJobStep step;
  final int percent;

  @override
  bool operator ==(Object other) =>
      other is ScanJobProgress &&
      other.step == step &&
      other.percent == percent;

  @override
  int get hashCode => Object.hash(step, percent);

  @override
  String toString() => 'ScanJobProgress(${step.name}, $percent)';
}

/// One run of "make small, send, read": its live [progress], its [result]
/// and [cancel].
class ScanJob {
  ScanJob._();

  final ValueNotifier<ScanJobProgress> _progress = ValueNotifier(
    const ScanJobProgress(ScanJobStep.preparing),
  );
  final CancelToken _cancelToken = CancelToken();

  /// The compressed photo, once it exists; a retry sends it again without
  /// compressing it twice.
  Uint8List? compressed;

  /// Where the job is; changes with the work, never on a timer.
  ValueListenable<ScanJobProgress> get progress => _progress;

  /// What the reader found, or why it failed.
  late final Future<Either<ScanFailure, OpticReading>> result;

  /// Stops the job ("Vazgeç"); [result] then fails with
  /// [ScanFailureKind.cancelled].
  void cancel() {
    if (!_cancelToken.isCancelled) _cancelToken.cancel('stopped by the user');
  }

  void dispose() => _progress.dispose();
}

/// Compress, upload, read, check (spec §8 E8 "ScanJobService"): the work
/// behind the upload screen.
///
/// The ViewModel holds no byte and no Dio: it starts a [ScanJob] with the
/// cropped photo and listens to [ScanJob.progress]. The service validates
/// the answer too: a reading without any answer cell is "Formu bulamadık"
/// ([OpticReading.foundForm]); that decision is the ViewModel's, taken from
/// the reading this service returns.
class ScanJobService {
  ScanJobService({
    required ScanRepository repository,
    required Map<String, dynamic>? Function() user,
    required Future<Uint8List> Function(Uint8List photo) compress,
  }) : _repository = repository,
       _user = user,
       _compress = compress;

  final ScanRepository _repository;
  final Map<String, dynamic>? Function() _user;
  final Future<Uint8List> Function(Uint8List photo) _compress;

  /// Starts a job for [photo] (the cropped picture, any format the
  /// compressor reads). With [compressed], the photo of an earlier run of the
  /// same job, the compression is skipped.
  ScanJob start(Uint8List photo, {Uint8List? compressed}) {
    final job = ScanJob._()..compressed = compressed;
    job.result = _run(job, photo);
    return job;
  }

  Future<Either<ScanFailure, OpticReading>> _run(
    ScanJob job,
    Uint8List photo,
  ) async {
    try {
      var jpeg = job.compressed;
      if (jpeg == null) {
        jpeg = await _compress(photo);
        job.compressed = jpeg;
      }
      if (job._cancelToken.isCancelled) {
        return const Left(ScanFailure(ScanFailureKind.cancelled));
      }
      job._progress.value = const ScanJobProgress(ScanJobStep.sending);
      final result = await _repository.readImage(
        jpeg: jpeg,
        user: _user(),
        cancelToken: job._cancelToken,
        onSendProgress: (sent, total) => _onSent(job, sent, total),
      );
      return result.fold(
        (exception) => Left(ScanFailure.of(exception)),
        Right.new,
      );
    } on Object {
      // Compression failed: the photo is not an image the phone can shrink.
      return Left(
        ScanFailure(
          job._cancelToken.isCancelled
              ? ScanFailureKind.cancelled
              : ScanFailureKind.server,
          null,
        ),
      );
    }
  }

  void _onSent(ScanJob job, int sent, int total) {
    if (total <= 0 || job._cancelToken.isCancelled) return;
    final percent = (sent * 100 ~/ total).clamp(0, 100);
    job._progress.value = sent >= total
        ? const ScanJobProgress(ScanJobStep.reading)
        : ScanJobProgress(ScanJobStep.sending, percent: percent);
  }
}
