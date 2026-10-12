part of '../coach_home_view.dart';

/// "Yaklaşan görüşmeler" (pano 10.1 kare 1; C34 `MeetingRow.dateBlock`): the
/// interviews of the next seven days, the earliest first, in one card with 1 pt
/// rules between the rows. A row opens the meeting.
///
/// - empty (spec §4 10.1 [Karar]): a card "Önümüzdeki 7 günde görüşme yok." with
///   the text button "Yeni Görüşme";
/// - loading: the skeleton; failed: "Görüşmeler yüklenemedi." with "Tekrar
///   Dene".
class _MeetingsSection
    extends
        SelectorViewModelWidget<
          CoachHomeViewModel,
          AsyncSection<UpcomingMeetings>
        > {
  const _MeetingsSection();

  @override
  AsyncSection<UpcomingMeetings> selector(CoachHomeViewModel viewModel) =>
      viewModel.meetings;

  @override
  Widget build(BuildContext context, AsyncSection<UpcomingMeetings> section) {
    final l10n = AppLocalizations.of(context);
    if (section.isLoading) return const _MeetingsSkeleton();
    return Padding(
      padding: _gutter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: l10n.coachHome_meetings),
          switch (section.state) {
            SectionState.ready => _MeetingRows(meetings: section.data!.rows),
            SectionState.empty => AppEmptyState.section(
              message: l10n.coachHome_noMeetings,
              actionLabel: l10n.coachHome_newMeeting,
              onAction: () => _openNewMeeting(context),
            ),
            SectionState.loading ||
            SectionState.error ||
            SectionState.offline => AppErrorState.section(
              message: l10n.coachHome_meetingsError,
              onRetry: getParentViewModel<CoachHomeViewModel>(
                context,
                listen: false,
              ).retryMeetings,
            ),
          },
        ],
      ),
    );
  }
}

/// The card of the rows.
class _MeetingRows extends StatelessWidget {
  const _MeetingRows({required this.meetings});

  final List<HomeMeeting> meetings;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        children: [
          for (final (index, meeting) in meetings.indexed) ...[
            if (index > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: context.appColors.bgSunken,
              ),
            MeetingRow.dateBlock(
              name: meeting.studentName,
              date: meeting.date,
              type: meeting.type,
              avatar: CoachAvatars.imageOf(meeting.photo),
              onTap: () => _openMeeting(context, meeting),
            ),
          ],
        ],
      ),
    );
  }
}
