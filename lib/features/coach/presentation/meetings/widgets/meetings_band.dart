part of '../meetings_view.dart';

/// The root band (pano 10.5 kare 1 and 4; 1.18 kare 1): "Görüşmelerim" with
/// the Plus "Yeni görüşme" on the right. While the device is offline the strip
/// sits under the band and the corners are square.
class _MeetingsBand extends SelectorViewModelWidget<MeetingsViewModel, bool> {
  const _MeetingsBand();

  @override
  bool selector(MeetingsViewModel viewModel) => viewModel.offline;

  @override
  Widget build(BuildContext context, bool offline) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<MeetingsViewModel>(
      context,
      listen: false,
    );
    return AppRootBand(
      title: l10n.nav_tabMeetings,
      squareCorners: offline,
      action: AppIconButton(
        icon: PhosphorIconsRegular.plus,
        semanticLabel: l10n.coachMeetings_newA11y,
        variant: AppIconButtonVariant.onNavy,
        onPressed: () => unawaited(viewModel.newMeeting()),
      ),
    );
  }
}
