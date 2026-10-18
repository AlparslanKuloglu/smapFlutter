part of '../account_view.dart';

/// "Koçluk" of a coach (pano 14.11 kare 1; replaces pano 9.1 kare 4): one group
/// with the value row "Koçluk kodun" and the code "MOZK-4821" at the right,
/// then the arrow (the value variant of `AppRow`, C17). The row is the one
/// touch target; it opens the code sheet where "Kopyala" and "Paylaş" now
/// live (T12.25). Read as "Koçluk kodun, MOZK-4821, aç". A coach whose code is
/// not on the device yet still gets the row, without a value: the sheet asks
/// for it (pano 14.11 kare 4 and 5), nothing is invented.
class _CoachCodeGroup
    extends SelectorViewModelWidget<AccountViewModel, String?> {
  const _CoachCodeGroup();

  @override
  String? selector(AccountViewModel viewModel) => viewModel.menu.coachCode;

  @override
  Widget build(BuildContext context, String? code) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AccountViewModel>(
      context,
      listen: false,
    );
    return AppRowGroup(
      title: l10n.account_groupCoaching,
      children: [
        Semantics(
          hint: l10n.account_coachCodeRowHint,
          child: AppRow(
            icon: PhosphorIconsRegular.users,
            title: l10n.account_coachCodeTitle,
            value: code,
            onTap: () => unawaited(viewModel.openCoachCode()),
          ),
        ),
      ],
    );
  }
}
