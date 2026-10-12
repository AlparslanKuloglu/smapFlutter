part of '../account_view.dart';

/// The groups of Hesap (pano 9.1 kare 1, 2 and 4), 20 apart: "Hesap",
/// "Koçluk", "Bildirimler", "Yasal", "Destek" and the red "Çıkış Yap" in a
/// group of its own.
///
/// One selector over [AccountMenuData]: the groups are mostly static, so they
/// rebuild only when the role, the coach line or what the router offers
/// changes. A row whose screen is not in the router is not drawn (see
/// `AccountNavigator.canOpen`), and with it its group when it was the only
/// row.
class _AccountGroups
    extends SelectorViewModelWidget<AccountViewModel, AccountMenuData> {
  const _AccountGroups();

  @override
  AccountMenuData selector(AccountViewModel viewModel) => viewModel.menu;

  @override
  Widget build(BuildContext context, AccountMenuData data) {
    final groups = <Widget>[
      _ProfileGroup(data: data),
      if (data.isCoach)
        const _CoachCodeGroup()
      else if (data.canOpenCoaching)
        _CoachingGroup(link: data.link, coachName: data.coachName),
      if (data.canOpenNotifications) const _NotificationsGroup(),
      const _LegalGroup(),
      if (data.hasSupport) const _SupportGroup(),
      const _LogoutGroup(),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, group) in groups.indexed) ...[
          if (i > 0) const SizedBox(height: _groupGap),
          group,
        ],
      ],
    );
  }
}

/// "Hesap": Profil and Şifre.
class _ProfileGroup extends StatelessWidget {
  const _ProfileGroup({required this.data});

  final AccountMenuData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AccountViewModel>(
      context,
      listen: false,
    );
    return AppRowGroup(
      title: l10n.account_groupAccount,
      children: [
        AppRow(
          icon: PhosphorIconsRegular.userCircle,
          title: l10n.account_rowProfile,
          subtitle: data.isCoach
              ? l10n.account_rowProfileCoachSub
              : l10n.account_rowProfileStudentSub,
          onTap: viewModel.openProfile,
        ),
        if (data.canOpenPassword)
          AppRow(
            icon: PhosphorIconsRegular.lock,
            title: l10n.account_rowPassword,
            onTap: viewModel.openPassword,
          ),
      ],
    );
  }
}

/// "Koçluk" of a student: the coach's name, or "Koçunla bağlan".
class _CoachingGroup extends StatelessWidget {
  const _CoachingGroup({required this.link, required this.coachName});

  final CoachLinkState link;
  final String? coachName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AccountViewModel>(
      context,
      listen: false,
    );
    return AppRowGroup(
      title: l10n.account_groupCoaching,
      children: [
        AppRow(
          icon: PhosphorIconsRegular.users,
          title: l10n.account_rowCoaching,
          subtitle: switch (link) {
            CoachLinkState.linked => coachName,
            CoachLinkState.none => l10n.account_rowCoachingNone,
            CoachLinkState.unknown => null,
          },
          onTap: viewModel.openCoaching,
        ),
      ],
    );
  }
}

/// "Bildirimler".
class _NotificationsGroup extends StatelessWidget {
  const _NotificationsGroup();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AccountViewModel>(
      context,
      listen: false,
    );
    return AppRowGroup(
      title: l10n.account_groupNotifications,
      children: [
        AppRow(
          icon: PhosphorIconsRegular.bell,
          title: l10n.account_rowNotifications,
          subtitle: l10n.account_rowNotificationsSub,
          onTap: viewModel.openNotifications,
        ),
      ],
    );
  }
}

/// "Yasal": Sözleşmeler.
class _LegalGroup extends StatelessWidget {
  const _LegalGroup();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AccountViewModel>(
      context,
      listen: false,
    );
    return AppRowGroup(
      title: l10n.account_groupLegal,
      children: [
        AppRow(
          icon: PhosphorIconsRegular.fileText,
          title: l10n.account_rowContracts,
          subtitle: l10n.account_rowContractsSub,
          onTap: viewModel.openContracts,
        ),
      ],
    );
  }
}

/// "Destek": "Bize Yaz" opens a mail draft (ArrowSquareOut: it leaves the
/// app).
class _SupportGroup extends StatelessWidget {
  const _SupportGroup();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AccountViewModel>(
      context,
      listen: false,
    );
    return AppRowGroup(
      title: l10n.account_groupSupport,
      children: [
        AppRow(
          icon: PhosphorIconsRegular.envelope,
          title: l10n.account_rowSupport,
          subtitle: l10n.account_rowSupportSub,
          external: true,
          onTap: () => unawaited(viewModel.writeSupport(l10n)),
        ),
      ],
    );
  }
}

/// "Çıkış Yap": red, no arrow, in a group of its own; it asks first.
class _LogoutGroup extends StatelessWidget {
  const _LogoutGroup();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AccountViewModel>(
      context,
      listen: false,
    );
    return AppRowGroup(
      children: [
        AppRow(
          icon: PhosphorIconsRegular.signOut,
          title: l10n.account_rowLogout,
          danger: true,
          onTap: () => unawaited(viewModel.logout()),
        ),
      ],
    );
  }
}
