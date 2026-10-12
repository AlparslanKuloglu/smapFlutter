import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/features/scan/application/scan_job_service.dart';
import 'package:smap/features/scan/domain/scan_failure.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_actions.dart';

/// The logic of "Gönderim" (pano 4.5, 4.6; spec §4.C 4.5).
///
/// It starts a [ScanJob] for the straightened photo the moment the screen is
/// up and shows what the job reports: the three real steps and the upload's
/// real percentage (no promised time). Three ends:
///
/// - **Read.** The reader answered: the flow moves on ([ScanFlowActions.
///   readFinished]); the success haptic is not here but at the result
///   (pano 4.5 "başarı haptiği burada değil, sonuç anında").
/// - **Failed.** A connection, timeout or server failure: the screen stays,
///   "Formun gönderilemedi" with the reason, the `error` haptic, and the photo
///   kept: "Tekrar Dene" sends the same compressed photo again and "Yeni
///   Fotoğraf" goes back to the camera.
/// - **Cancelled.** "Vazgeç" stops the call and goes back to the corner
///   screen with the photo.
class ScanUploadViewModel extends BaseViewModel {
  ScanUploadViewModel({
    required Uint8List photo,
    required ScanJobService jobs,
    required ScanFlowActions actions,
  }) : _photo = photo,
       _jobs = jobs,
       _actions = actions;

  final Uint8List _photo;
  final ScanJobService _jobs;
  final ScanFlowActions _actions;

  ScanJob? _job;
  ScanFailure? _failure;
  Uint8List? _compressed;
  bool _disposed = false;

  /// Where the job is; the step list listens to it, since the percentage
  /// changes many times a second.
  final ValueNotifier<ScanJobProgress> progress = ValueNotifier(
    const ScanJobProgress(ScanJobStep.preparing),
  );

  /// The straightened photo, shown on the card.
  Uint8List get photo => _photo;

  /// Why the last run failed; `null` while it runs.
  ScanFailure? get failure => _failure;

  /// Whether the photo was compressed before the failure (the first step is
  /// then done even though the second failed).
  bool get prepared => _compressed != null;

  /// Starts (or restarts) the job. Also the body of "Tekrar Dene".
  Future<void> start() async {
    if (_job != null && _failure == null) return;
    final hadFailure = _failure != null;
    _failure = null;
    progress.value = ScanJobProgress(
      _compressed == null ? ScanJobStep.preparing : ScanJobStep.sending,
    );
    if (hadFailure) notifyListeners();
    final job = _jobs.start(_photo, compressed: _compressed);
    _job = job;
    job.progress.addListener(() {
      if (!_disposed && identical(_job, job)) {
        progress.value = job.progress.value;
      }
    });
    final result = await job.result;
    _compressed = job.compressed ?? _compressed;
    job.dispose();
    if (_disposed || !identical(_job, job)) return;
    result.fold((failure) {
      if (failure.kind == ScanFailureKind.cancelled) return;
      // With the offline queue on, "no connection" has a screen of its own.
      if (failure.isOffline && _actions.uploadOffline()) return;
      _failure = failure;
      AppHaptics.error();
      notifyListeners();
    }, _actions.readFinished);
  }

  /// "Vazgeç": stops the job and goes back to the corners with the photo.
  void cancel() {
    _job?.cancel();
    _actions.backToCorners();
  }

  /// "Yeni Fotoğraf".
  void newPhoto() => _actions.retake();

  @override
  void dispose() {
    _disposed = true;
    _job?.cancel();
    progress.dispose();
    super.dispose();
  }
}
