import 'package:stacked/stacked.dart';

import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/features/scan/application/scan_flow_state.dart';
import 'package:smap/features/scan/presentation/capture/scan_capture_dialogs.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_actions.dart';

/// The logic of the full-screen errors of the scan (pano 4.10 kare 1 and 3;
/// spec §4.C 4.10).
///
/// - **Form bulunamadı.** The reader could not choose an answer area. The
///   `error` haptic plays once when the screen appears; "Yeni Fotoğraf" goes
///   back to the camera and "Nasıl Çekilir?" opens the how-to-shoot sheet (the
///   screen stays).
/// - **Bağlantı yok (planlı).** Only while the offline queue exists: "Tamam"
///   leaves, "Şimdi Tekrar Dene" sends again. No haptic: it is nobody's
///   mistake.
///
/// Kapat leaves the scan in both.
class ScanErrorViewModel extends BaseViewModel {
  ScanErrorViewModel({
    required this.kind,
    required ScanCaptureDialogs dialogs,
    required ScanFlowActions actions,
  }) : _dialogs = dialogs,
       _actions = actions;

  final ScanErrorKind kind;
  final ScanCaptureDialogs _dialogs;
  final ScanFlowActions _actions;

  /// The haptic of the screen's arrival.
  void init() {
    if (kind == ScanErrorKind.formNotFound) AppHaptics.error();
  }

  /// "Yeni Fotoğraf".
  void newPhoto() => _actions.retake();

  /// "Nasıl Çekilir?".
  Future<void> showTutorial() => _dialogs.showTutorial(first: false);

  /// "Tamam" and Kapat.
  void close() => _actions.close();

  /// "Şimdi Tekrar Dene".
  void retryNow() => _actions.retryUpload();
}
