import 'package:auto_route/auto_route.dart';
import 'package:smap/features/legacy/legacy_links_e8.dart';

/// Where the scan leads out of itself (spec §3.6 "Çekim … onay → mexamFound
/// ise /scan/result/:id, değilse /scan/exam-not-found"; pano 4.9 kare 4): the
/// ViewModel of the flow holds this instead of a router, so a test can record
/// the calls.
abstract interface class ScanNavigator {
  /// Closes the scan: back to the screen it was opened from.
  void close();

  /// The exam [examId] was recognised: the result moment replaces the scan
  /// (pano 5.1), and the scan leaves the stack.
  void showResult(String examId);

  /// Anasayfa, with the scan gone.
  void goHome();
}

/// [ScanNavigator] on auto_route; [_router] is the stack router of the scan's
/// own route on the root stack (`context.router`).
class RouterScanNavigator implements ScanNavigator {
  const RouterScanNavigator(this._router);

  final StackRouter _router;

  @override
  void close() => _router.maybePop();

  @override
  void showResult(String examId) => openScanResult(_router, examId);

  @override
  void goHome() => goHomeAfterScan(_router);
}
