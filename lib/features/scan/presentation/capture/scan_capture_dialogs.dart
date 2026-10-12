import 'package:smap/features/scan/presentation/tutorial/omr_tutorial_sheet.dart';

/// What the camera screen shows on top of itself, behind a seam so its
/// ViewModel stays testable.
abstract interface class ScanCaptureDialogs {
  /// The how-to-shoot sheet (pano 4.2). [first] is the automatic opening
  /// (with the "Bir daha gösterme" checkbox); the "?" button opens it without.
  Future<void> showTutorial({required bool first});
}

/// [ScanCaptureDialogs] on the app's sheets.
///
/// The tutorial is shown on the first opening only (the view model remembers
/// it the moment it is shown, `DevicePreferences.cameraTutorialSeenKey`), so
/// the checkbox's answer changes nothing more: the board offers it, the
/// design's rule "yalnız ilk sefer" already holds.
class SheetScanCaptureDialogs implements ScanCaptureDialogs {
  const SheetScanCaptureDialogs();

  @override
  Future<void> showTutorial({required bool first}) async {
    await OmrTutorialSheet.show(offerDontShowAgain: first);
  }
}
