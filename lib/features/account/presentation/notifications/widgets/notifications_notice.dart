part of '../notifications_view.dart';

/// The box under the title: the info box "Bildirimler planlı: ..." while the
/// backend does not send notifications (kare 1), the warning "Bildirim izni
/// kapalı. ..." with "Ayarları Aç" while the system forbids them (kare 2),
/// nothing otherwise.
class _NoticeSliver
    extends
        SelectorViewModelWidget<NotificationsViewModel, NotificationsNotice> {
  const _NoticeSliver();

  @override
  NotificationsNotice selector(NotificationsViewModel viewModel) =>
      viewModel.notice;

  @override
  Widget build(BuildContext context, NotificationsNotice notice) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<NotificationsViewModel>(
      context,
      listen: false,
    );
    final box = switch (notice) {
      NotificationsNotice.none => null,
      NotificationsNotice.planned => AppNoticeBox(
        message: l10n.notifications_plannedNotice,
      ),
      NotificationsNotice.permissionOff => AppNoticeBox(
        message: l10n.notifications_permissionOff,
        tone: AppNoticeTone.warning,
        actionLabel: l10n.notifications_openSettings,
        onAction: viewModel.openSettings,
      ),
    };
    if (box == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(child: box),
    );
  }
}
