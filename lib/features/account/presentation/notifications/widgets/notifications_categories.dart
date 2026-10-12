part of '../notifications_view.dart';

typedef _CategoriesData = ({
  NotificationPreferences preferences,
  bool locked,
  bool isCoach,
  String? coachName,
});

/// The group "Kategoriler" (pano 9.6 kare 1): four rows with a title, a line
/// under it and a switch; no leading icon. With the system permission off the
/// switches are inactive and keep their value (kare 2). A coach has no
/// categories (not designed).
class _CategoriesSliver
    extends SelectorViewModelWidget<NotificationsViewModel, _CategoriesData> {
  const _CategoriesSliver();

  @override
  _CategoriesData selector(NotificationsViewModel viewModel) => (
    preferences: viewModel.preferences,
    locked: viewModel.permissionOff,
    isCoach: viewModel.isCoach,
    coachName: viewModel.coachName,
  );

  @override
  Widget build(BuildContext context, _CategoriesData data) {
    if (data.isCoach) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<NotificationsViewModel>(
      context,
      listen: false,
    );
    final name = data.coachName;
    final rows = <(NotificationCategory, String, String)>[
      (
        NotificationCategory.examReady,
        l10n.notifications_examReadyTitle,
        l10n.notifications_examReadyBody,
      ),
      (
        NotificationCategory.coachAssigned,
        l10n.notifications_coachAssignedTitle,
        name == null
            ? l10n.notifications_coachAssignedBodyAnonymous
            : l10n.notifications_coachAssignedBody(name),
      ),
      (
        NotificationCategory.meetingPlanned,
        l10n.notifications_meetingPlannedTitle,
        l10n.notifications_meetingPlannedBody,
      ),
      (
        NotificationCategory.studyReminder,
        l10n.notifications_studyReminderTitle,
        l10n.notifications_studyReminderBody,
      ),
    ];
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        _sectionGap,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppRowGroup(
          title: l10n.notifications_categoriesHeading,
          children: [
            for (final (category, title, body) in rows)
              _CategoryRow(
                title: title,
                subtitle: body,
                on: data.preferences.isOn(category),
                locked: data.locked,
                onChanged: (on) => viewModel.setCategory(category, on: on),
              ),
          ],
        ),
      ),
    );
  }
}

/// One category: the row toggles with its switch (pano 9.6: "Anahtar 52 × 32").
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.title,
    required this.subtitle,
    required this.on,
    required this.locked,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool on;
  final bool locked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => AppRow(
    title: title,
    subtitle: subtitle,
    onTap: locked ? null : () => onChanged(!on),
    trailing: AppSwitch(value: on, onChanged: locked ? null : onChanged),
  );
}
