part of '../notifications_view.dart';

typedef _QuietData = ({bool enabled, int start, int end, bool locked});

/// The group "Sessiz saatler" (pano 9.6 kare 1 and 3): the row with a Clock,
/// "Bu saatlerde bildirim gelmez" and a switch, and while it is on the rows
/// "Başlangıç" and "Bitiş" with the time and a caret; a row opens the time
/// wheel. Under the group, "Değişiklikler anında kaydedilir." The switch is
/// inactive while the system permission is off; the two rows stay normal
/// (kare 2).
class _QuietSliver
    extends SelectorViewModelWidget<NotificationsViewModel, _QuietData> {
  const _QuietSliver();

  @override
  _QuietData selector(NotificationsViewModel viewModel) {
    final preferences = viewModel.preferences;
    return (
      enabled: preferences.quietEnabled,
      start: preferences.quietStart,
      end: preferences.quietEnd,
      locked: viewModel.permissionOff,
    );
  }

  /// The rows without an icon keep the text of the first row's alignment (the
  /// board hides an icon to leave the gap): an empty 24 pt box.
  static const Widget _iconGap = SizedBox(width: AppSize.icon);

  static String _time(int minutes) =>
      TrFormat.saatParcali(minutes ~/ 60, minutes % 60);

  @override
  Widget build(BuildContext context, _QuietData data) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<NotificationsViewModel>(
      context,
      listen: false,
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        _sectionGap,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppRowGroup(
          title: l10n.notifications_quietHeading,
          footer: l10n.notifications_savedNote,
          children: [
            AppRow(
              icon: PhosphorIconsRegular.clock,
              title: l10n.notifications_quietTitle,
              subtitle: l10n.notifications_quietBody,
              onTap: data.locked
                  ? null
                  : () => viewModel.setQuietEnabled(on: !data.enabled),
              trailing: AppSwitch(
                value: data.enabled,
                onChanged: data.locked
                    ? null
                    : (on) => viewModel.setQuietEnabled(on: on),
              ),
            ),
            if (data.enabled) ...[
              AppRow(
                leading: _iconGap,
                title: l10n.notifications_quietStart,
                value: _time(data.start),
                onTap: () => viewModel.pickQuietTime(QuietBound.start),
              ),
              AppRow(
                leading: _iconGap,
                title: l10n.notifications_quietEnd,
                value: _time(data.end),
                onTap: () => viewModel.pickQuietTime(QuietBound.end),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
