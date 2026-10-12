part of '../meeting_detail_view.dart';

/// The name the bar and the header show: the student's, else the kind of
/// meeting ("Öğrenci görüşmesi"), nothing while there is no meeting yet.
String _meetingTitle(AppLocalizations l10n, MeetingEntry? meeting) {
  if (meeting == null) return '';
  final name = meeting.studentName;
  if (name != null) return name;
  return switch (meeting.type) {
    InterviewType.student => l10n.coachMeetings_detailKindStudent,
    InterviewType.parent => l10n.coachMeetings_detailKindParent,
    null => l10n.coachMeetings_meetingFallback,
  };
}

/// The bar (pano 10.5 kare 3): Back, and the name once the header has
/// scrolled away. No action: the meeting cannot be edited (no endpoint).
class _DetailBar
    extends SelectorViewModelWidget<MeetingDetailViewModel, MeetingEntry?> {
  const _DetailBar();

  @override
  MeetingEntry? selector(MeetingDetailViewModel viewModel) => viewModel.meeting;

  @override
  Widget build(BuildContext context, MeetingEntry? meeting) =>
      AppDetailBar(title: _meetingTitle(AppLocalizations.of(context), meeting));
}

/// What the body redraws on: the screen's state and the meeting.
typedef _BodyData = (SectionState state, MeetingEntry? meeting);

/// The body under the bar: the header and the card with the notes below, the
/// header's skeleton while a link without a hint loads, or the screen error.
class _DetailBody
    extends SelectorViewModelWidget<MeetingDetailViewModel, _BodyData> {
  const _DetailBody();

  @override
  _BodyData selector(MeetingDetailViewModel viewModel) =>
      (viewModel.screenState, viewModel.meeting);

  @override
  Widget build(BuildContext context, _BodyData data) {
    final (state, meeting) = data;
    if (state == SectionState.loading) return const _DetailSkeleton();
    if (meeting == null || state != SectionState.ready) {
      return _DetailScreenError(missing: state == SectionState.empty);
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s8,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          _DetailHeader(meeting: meeting),
          const SizedBox(height: _blockGap),
          _DetailInfoCard(meeting: meeting),
          const SizedBox(height: _sectionGap),
          const _NotesSection(),
        ]),
      ),
    );
  }
}

/// The header (pano 10.5 kare 3): the student's 56 pt avatar, the name 24/32 ·
/// 700 as the page's heading and "Öğrenci görüşmesi" under it (13/20,
/// `textSecondary`). "Veli görüşmesi" for a parent meeting (the board draws
/// only the student's).
class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.meeting});

  final MeetingEntry meeting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final title = _meetingTitle(l10n, meeting);
    final kind = switch (meeting.type) {
      InterviewType.student => l10n.coachMeetings_detailKindStudent,
      InterviewType.parent => l10n.coachMeetings_detailKindParent,
      null => null,
    };
    final asset = AvatarAsset.pathOf(meeting.photo);
    return Row(
      children: [
        AppAvatar(
          name: title,
          image: asset == null ? null : AssetImage(asset),
          size: AppAvatarSize.lg,
          decorative: true,
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleLg.copyWith(color: colors.textPrimary),
                ),
              ),
              // The kind is the title itself when the server named no student.
              if (kind != null && meeting.studentName != null)
                Text(
                  kind,
                  style: text.caption.copyWith(color: colors.textSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The card under the header (pano 10.5 kare 3): the day with the weekday and
/// the time, which cannot be tapped (56 high), and "Öğrencinin verileri ·
/// Analiz, denemeler, program" with the caret, which opens the student's data.
/// A meeting without a time draws no date row, and one without a student id no
/// link.
class _DetailInfoCard extends StatelessWidget {
  const _DetailInfoCard({required this.meeting});

  final MeetingEntry meeting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<MeetingDetailViewModel>(
      context,
      listen: false,
    );
    final moment = meeting.moment;
    final rows = [
      if (moment != null)
        AppRow(
          icon: PhosphorIconsRegular.calendarBlank,
          title: TrFormat.uzunTarihGun(moment),
          subtitle: TrFormat.saat(moment),
        ),
      if (meeting.studentId != null)
        AppRow(
          icon: PhosphorIconsRegular.chartLine,
          title: l10n.coachMeetings_studentData,
          subtitle: l10n.coachMeetings_studentDataHint,
          onTap: () => unawaited(viewModel.openStudentData()),
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return AppRowGroup(children: rows);
  }
}
