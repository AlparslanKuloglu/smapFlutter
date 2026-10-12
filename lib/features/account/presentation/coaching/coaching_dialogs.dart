import 'package:smap/features/account/application/coaching_logic.dart';
import 'package:smap/features/account/domain/coach_code.dart';
import 'package:smap/features/account/presentation/coaching/sheets/change_coach_sheet.dart';
import 'package:smap/features/account/presentation/coaching/sheets/coaching_code_info_sheet.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/sheets/app_confirm_sheet.dart';

/// The sheets of "Koçluk" (pano 9.5 kare 2 and 4; Tur 12 F). A ViewModel asks
/// these and gets plain answers; tests give them answers.
abstract interface class CoachingDialogs {
  /// "Koç bağlantısı kaldırılsın mı?" about [coachName]; `true` when the user
  /// pressed "Bağlantıyı Kaldır".
  Future<bool> confirmUnlink({required String coachName});

  /// "Koçluk kodu nedir?" (kare 4).
  Future<void> showCodeInfo();

  /// "Koçunu değiştir": asks for the new code and tries it with [submit]
  /// while the sheet is busy. Completes with the new coach, or `null` when
  /// the sheet was closed without a link.
  Future<CoachLink?> changeCoach({
    required CoachLink current,
    required Future<CoachLinkResult> Function(CoachCode code) submit,
  });
}

/// [CoachingDialogs] as the app's sheets (UI guide §6 rule 15). A ViewModel
/// has no `BuildContext`, so they open on the root navigator
/// (`AppSheet.navigatorKey`); [l10n] gives the texts of the confirm sheet.
class SheetCoachingDialogs implements CoachingDialogs {
  const SheetCoachingDialogs({required this.l10n});

  final AppLocalizations l10n;

  @override
  Future<bool> confirmUnlink({required String coachName}) async {
    final result = await AppConfirmSheet.show(
      title: l10n.coaching_unlinkTitle,
      message: l10n.coaching_unlinkBody(coachName),
      confirmLabel: l10n.coaching_unlinkAction,
      cancelLabel: l10n.common_cancel,
      danger: true,
    );
    return result.confirmed;
  }

  @override
  Future<void> showCodeInfo() =>
      CoachingCodeInfoSheet.show(audience: CodeInfoAudience.student);

  @override
  Future<CoachLink?> changeCoach({
    required CoachLink current,
    required Future<CoachLinkResult> Function(CoachCode code) submit,
  }) => ChangeCoachSheet.show(current: current, submit: submit);
}
