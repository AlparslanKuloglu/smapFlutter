import 'package:smap/features/scan/presentation/exam_request/sheets/exam_request_confirm_sheet.dart';

/// What the exam request shows on top of itself, behind a seam so its
/// ViewModel stays testable.
abstract interface class ScanRequestDialogs {
  /// "Talep oluşturulsun mu?": whether the student confirmed the request with
  /// [publisher] and [examName] (pano 4.9 kare 3).
  Future<bool> confirmRequest({
    required String publisher,
    required String examName,
  });
}

/// [ScanRequestDialogs] on the app's sheets.
class SheetScanRequestDialogs implements ScanRequestDialogs {
  const SheetScanRequestDialogs();

  @override
  Future<bool> confirmRequest({
    required String publisher,
    required String examName,
  }) => ExamRequestConfirmSheet.show(publisher: publisher, examName: examName);
}
