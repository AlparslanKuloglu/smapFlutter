import 'package:smap/features/scan/domain/answer_correction.dart';
import 'package:smap/features/scan/domain/answer_grid.dart';
import 'package:smap/features/scan/presentation/form_check/sheets/answer_fix_sheet.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/sheets/app_confirm_sheet.dart';

/// What the answer check shows on top of itself, behind a seam so its
/// ViewModel stays testable (UI guide §6 rule 16).
abstract interface class ScanReviewDialogs {
  /// The fix sheet (pano 4.7 kare 2 and 3). Completes with the corrections as
  /// the student left them; `null` never (closing the sheet keeps what was
  /// added).
  Future<AnswerCorrections> fixAnswers({
    required AnswerGrid grid,
    required AnswerCorrections corrections,
    required AnswerCell start,
  });

  /// "Okutmadan çıkılsın mı?": whether the student really wants to leave with
  /// the corrections they made.
  Future<bool> confirmExit();
}

/// [ScanReviewDialogs] on the app's sheets.
class SheetScanReviewDialogs implements ScanReviewDialogs {
  const SheetScanReviewDialogs({required this.l10n});

  final AppLocalizations l10n;

  @override
  Future<AnswerCorrections> fixAnswers({
    required AnswerGrid grid,
    required AnswerCorrections corrections,
    required AnswerCell start,
  }) async =>
      await AnswerFixSheet.show(
        grid: grid,
        corrections: corrections,
        start: start,
      ) ??
      corrections;

  @override
  Future<bool> confirmExit() async {
    final result = await AppConfirmSheet.show(
      title: l10n.scan_exitTitle,
      message: l10n.scan_exitBody,
      confirmLabel: l10n.scan_exitConfirm,
    );
    return result.confirmed;
  }
}
