part of '../meetings_view.dart';

/// The list under the controls: by the first load's state the skeleton, the
/// empty state, the error or the groups of meetings (pano 10.5 kare 1 and 4).
class _MeetingsListSection
    extends SelectorViewModelWidget<MeetingsViewModel, MeetingListData> {
  const _MeetingsListSection();

  @override
  MeetingListData selector(MeetingsViewModel viewModel) => viewModel.list;

  @override
  Widget build(BuildContext context, MeetingListData data) {
    return switch (data.state) {
      SectionState.loading => const _MeetingsSkeleton(),
      SectionState.empty => const _MeetingsEmpty(),
      SectionState.error || SectionState.offline => const _MeetingsError(),
      SectionState.ready =>
        data.sections.isEmpty && !data.hasMore
            ? _MeetingsNoMatch(data: data)
            : _MeetingGroups(data: data),
    };
  }
}

/// The groups of meetings and the footer under them (pano 10.5 kare 1): the
/// group title "Yaklaşan · 2" sits 16 under the chips, the past meetings have
/// their own title, 24 apart. A search or choice that keeps nothing of the
/// loaded pages while more follow shows the footer's spinner, not the "no
/// result" card, until the walk ends.
class _MeetingGroups extends StatelessWidget {
  const _MeetingGroups({required this.data});

  final MeetingListData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = data.sections;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (sections.upcoming.isNotEmpty)
              _MeetingGroup(
                title: l10n.coachMeetings_upcoming(
                  TrFormat.sira(sections.upcoming.length),
                ),
                meetings: sections.upcoming,
              ),
            if (sections.upcoming.isNotEmpty && sections.past.isNotEmpty)
              const SizedBox(height: AppSpacing.s24),
            if (sections.past.isNotEmpty)
              _MeetingGroup(
                title: l10n.coachMeetings_past(
                  TrFormat.sira(sections.past.length),
                ),
                meetings: sections.past,
              ),
            _MeetingsFooter(data: data),
          ],
        ),
      ),
    );
  }
}

/// One titled card of meeting rows (C18 "ListGroup" with the title of pano
/// 10.5 kare 1).
class _MeetingGroup extends StatelessWidget {
  const _MeetingGroup({required this.title, required this.meetings});

  final String title;
  final List<MeetingEntry> meetings;

  @override
  Widget build(BuildContext context) {
    final viewModel = getParentViewModel<MeetingsViewModel>(
      context,
      listen: false,
    );
    return AppRowGroup(
      title: title,
      children: [
        for (final meeting in meetings)
          _MeetingRow(
            key: ValueKey(meeting.id),
            meeting: meeting,
            onTap: () => unawaited(viewModel.openMeeting(meeting)),
          ),
      ],
    );
  }
}

/// One meeting (pano 10.5 kare 1; 1.16 row; G5 `MeetingRow`): the student's
/// 40 pt avatar, the name, "12 Ekim 2026 Pazartesi · 16:00", the tag
/// "Öğrenci" or "Veli" and the caret. A meeting the server gave no student
/// name for is named by its kind, and a missing time is left out. Read as
/// "Alparslan Kuloğlu, 12 Ekim 2026 Pazartesi, 16:00, öğrenci görüşmesi,
/// düğme".
class _MeetingRow extends StatelessWidget {
  const _MeetingRow({required this.meeting, required this.onTap, super.key});

  final MeetingEntry meeting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final type = meeting.type;
    final moment = meeting.moment;
    final title =
        meeting.studentName ??
        switch (type) {
          InterviewType.student => l10n.coachMeetings_detailKindStudent,
          InterviewType.parent => l10n.coachMeetings_detailKindParent,
          null => l10n.coachMeetings_meetingFallback,
        };
    final tag = switch (type) {
      InterviewType.student => l10n.coachMeetings_kindStudent,
      InterviewType.parent => l10n.coachMeetings_kindParent,
      null => null,
    };
    final when = moment == null
        ? null
        : l10n.coachMeetings_rowWhen(
            TrFormat.uzunTarihGun(moment),
            TrFormat.saat(moment),
          );
    final spoken = [
      title,
      if (moment != null) TrFormat.uzunTarihGun(moment),
      if (moment != null) TrFormat.saat(moment),
      if (type == InterviewType.student) l10n.coachMeetings_a11yKindStudent,
      if (type == InterviewType.parent) l10n.coachMeetings_a11yKindParent,
    ].join(', ');
    final asset = AvatarAsset.pathOf(meeting.photo);
    return Semantics(
      container: true,
      button: true,
      label: spoken,
      excludeSemantics: true,
      onTap: onTap,
      child: AppRow(
        leading: AppAvatar(
          name: title,
          image: asset == null ? null : AssetImage(asset),
          size: AppAvatarSize.md,
          decorative: true,
        ),
        title: title,
        subtitle: when,
        tag: tag,
        onTap: onTap,
      ),
    );
  }
}

/// Under the groups: the spinner while the next page loads, or the section
/// error "Tekrar Dene" when it failed (a page of a list never replaces it).
class _MeetingsFooter extends StatelessWidget {
  const _MeetingsFooter({required this.data});

  final MeetingListData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (data.moreFailed) {
      final viewModel = getParentViewModel<MeetingsViewModel>(
        context,
        listen: false,
      );
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s16),
        child: AppErrorState.section(
          message: l10n.coachMeetings_moreFailed,
          onRetry: () => unawaited(viewModel.retryMore()),
        ),
      );
    }
    if (data.loadingMore || data.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s24),
        child: Center(
          child: AppSpinner(semanticLabel: l10n.coachMeetings_loadingMore),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
