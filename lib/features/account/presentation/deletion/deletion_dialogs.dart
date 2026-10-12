import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/sheets/app_confirm_sheet.dart';

/// The one dialog of "Hesabını sil": the dangerous confirmation (pano 9.4
/// kare 3). A ViewModel asks this and gets a plain answer; tests give it one.
abstract interface class AccountDeletionDialogs {
  /// "Hesabın silinsin mi?" for the account of [userName]; `true` when the
  /// user pressed "Hesabımı Sil".
  Future<bool> confirmDeletion({String? userName});
}

/// [AccountDeletionDialogs] as the app's confirm sheet (UI guide §6 rule 15).
///
/// A ViewModel has no `BuildContext`, so the sheet opens on the root
/// navigator (`AppSheet.navigatorKey`); [l10n] gives the texts (the app is
/// Turkish only, so the localizations do not depend on a widget).
class SheetAccountDeletionDialogs implements AccountDeletionDialogs {
  const SheetAccountDeletionDialogs({required this.l10n});

  final AppLocalizations l10n;

  /// The tone of the sheet is the dangerous one: red primary, "Vazgeç" under
  /// it with the focus on it. No typed word and no new sign-in (D-28).
  @override
  Future<bool> confirmDeletion({String? userName}) async {
    final name = userName?.trim();
    final result = await AppConfirmSheet.show(
      title: l10n.deletion_confirmTitle,
      message: name == null || name.isEmpty
          ? l10n.deletion_confirmBodyAnonymous
          : l10n.deletion_confirmBody(name),
      confirmLabel: l10n.deletion_confirmAction,
      cancelLabel: l10n.common_cancel,
      danger: true,
    );
    return result.confirmed;
  }
}
