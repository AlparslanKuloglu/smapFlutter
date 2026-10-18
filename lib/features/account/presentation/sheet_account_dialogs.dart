import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/account/presentation/account/sheets/coach_code_sheet.dart';
import 'package:smap/features/account/presentation/account_dialogs.dart';
import 'package:smap/features/account/presentation/profile/sheets/avatar_sheet.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/sheets/app_confirm_sheet.dart';

/// [AccountDialogs] as the app's sheets (UI guide §6 rule 15).
///
/// A ViewModel has no `BuildContext`, so the sheets open on the root
/// navigator (`AppSheet.navigatorKey`); [l10n] gives the texts of the confirm
/// sheets (the app is Turkish only, so the localizations do not depend on a
/// widget).
class SheetAccountDialogs implements AccountDialogs {
  const SheetAccountDialogs({required this.l10n});

  final AppLocalizations l10n;

  @override
  Future<bool> confirmLogout({int pendingForms = 0}) async {
    final result = await AppConfirmSheet.show(
      title: l10n.account_logoutTitle,
      message: pendingForms > 0
          ? l10n.account_logoutMessagePending(TrFormat.sira(pendingForms))
          : l10n.account_logoutMessage,
      confirmLabel: l10n.account_logoutConfirm,
      cancelLabel: l10n.common_cancel,
    );
    return result.confirmed;
  }

  @override
  Future<bool> confirmDiscardEdits() async {
    final result = await AppConfirmSheet.show(
      title: l10n.account_discardTitle,
      message: l10n.account_discardBody,
      confirmLabel: l10n.account_discardConfirm,
      cancelLabel: l10n.common_cancel,
    );
    return result.confirmed;
  }

  @override
  Future<int?> pickAvatar({int? selectedIndex}) =>
      AvatarSheet.show(selectedIndex: selectedIndex);

  @override
  Future<void> showCoachCode() => CoachCodeSheet.show();
}
