part of '../program_detail_view.dart';

typedef _DayHeadData = ({
  SectionState state,
  ProgramViewMode mode,
  DateTime day,
  int count,
  bool editing,
});

/// "Cumartesi, 10 Ekim" (17/24 · 700) and "3 çalışma" (13/20) beside it (pano
/// 3.4 kare 3). An empty day has no count (pano 3.6 kare 3). In the coach's
/// Program tab ([embedded]) only edit mode draws it (pano 14.1 kare 1 and 3).
class _DayHeading
    extends SelectorViewModelWidget<ProgramDetailViewModel, _DayHeadData> {
  const _DayHeading({this.embedded = false});

  final bool embedded;

  @override
  _DayHeadData selector(ProgramDetailViewModel viewModel) => (
    state: viewModel.section.state,
    mode: viewModel.mode,
    day: viewModel.selectedDay,
    count: viewModel.detail?.countOn(viewModel.selectedDay) ?? 0,
    editing: viewModel.editing,
  );

  @override
  Widget build(BuildContext context, _DayHeadData data) {
    if (data.state != SectionState.ready ||
        data.mode != ProgramViewMode.day ||
        (embedded && !data.editing)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final title = l10n.schedule_dayTitle(
      TrFormat.gunAdi(data.day),
      '${data.day.day}',
      TrFormat.months[data.day.month - 1],
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s24,
        AppSpacing.gutter,
        AppSpacing.s12,
      ),
      sliver: SliverToBoxAdapter(
        child: Semantics(
          header: true,
          child: Wrap(
            spacing: AppSpacing.s8,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(
                title,
                style: text.headline.copyWith(color: colors.textPrimary),
              ),
              if (data.count > 0)
                Text(
                  l10n.schedule_studyCount(TrFormat.sira(data.count)),
                  style: text.caption.copyWith(color: colors.textSecondary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef _DayListData = ({
  SectionState state,
  ProgramViewMode mode,
  ProgramDay? day,
  bool editing,
  bool canEditNow,
});

/// The day's topics in one card (pano 3.4 kare 3, 3.6 kare 1): a row per topic
/// with its time, glyph, lesson and name. In edit mode the times and the X
/// are actions and "Konu Ekle" sits under the card; an empty day is one
/// sentence and, in edit mode, "Konu Ekle" (pano 3.6 kare 3).
///
/// In the coach's Program tab ([embedded]) the day has no heading out of edit
/// mode, so the card keeps 12 pt from the day strip (pano 14.1 kare 1).
class _DayList
    extends SelectorViewModelWidget<ProgramDetailViewModel, _DayListData> {
  const _DayList({this.embedded = false});

  final bool embedded;

  @override
  _DayListData selector(ProgramDetailViewModel viewModel) => (
    state: viewModel.section.state,
    mode: viewModel.mode,
    day: viewModel.detail?.dayOf(viewModel.selectedDay),
    editing: viewModel.editing,
    canEditNow: viewModel.canEditNow,
  );

  @override
  Widget build(BuildContext context, _DayListData data) {
    final day = data.day;
    if (data.state != SectionState.ready ||
        data.mode != ProgramViewMode.day ||
        day == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final viewModel = getParentViewModel<ProgramDetailViewModel>(
      context,
      listen: false,
    );
    final l10n = AppLocalizations.of(context);
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        embedded && !data.editing ? AppSpacing.s12 : 0,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (day.isEmpty)
              _EmptyDay(
                editing: data.editing,
                onAdd: data.canEditNow ? viewModel.addTopic : null,
              )
            else
              _EntryRows(
                entries: day.entries,
                editing: data.editing,
                // A coach's topics do not open: there are no lessons for a
                // coach to go to.
                onOpen: viewModel.isCoachView
                    ? null
                    : (entry) => _openTopic(context, entry),
                onTime: viewModel.changeTime,
                onRemove: viewModel.removeEntry,
              ),
            if (data.editing && !day.isEmpty) ...[
              const SizedBox(height: AppSpacing.s16),
              AppButton(
                label: l10n.schedule_addTopic,
                icon: PhosphorIconsRegular.plus,
                variant: AppButtonVariant.outline,
                expand: true,
                onPressed: data.canEditNow ? viewModel.addTopic : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The rows of the card, 1 pt rules between them.
class _EntryRows extends StatelessWidget {
  const _EntryRows({
    required this.entries,
    required this.editing,
    required this.onOpen,
    required this.onTime,
    required this.onRemove,
  });

  final List<ProgramEntry> entries;
  final bool editing;
  final ValueChanged<ProgramEntry>? onOpen;
  final ValueChanged<ProgramEntry> onTime;
  final ValueChanged<ProgramEntry> onRemove;

  @override
  Widget build(BuildContext context) {
    final rule = context.appColors.bgSunken;
    return AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        children: [
          for (final (i, entry) in entries.indexed) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.s16),
                child: Divider(height: 1, thickness: 1, color: rule),
              ),
            ProgramItemRow(
              key: ValueKey<String>(entry.id),
              hour: entry.hour,
              minute: entry.minute,
              subjectName: entry.lessonName,
              topic: entry.title,
              subject: entry.subject,
              mode: editing ? ProgramItemMode.edit : ProgramItemMode.view,
              onTap: entry.canOpenTopic && onOpen != null
                  ? () => onOpen!(entry)
                  : null,
              onTimeTap: () => onTime(entry),
              onRemove: () => onRemove(entry),
            ),
          ],
        ],
      ),
    );
  }
}

/// A day with no topic (pano 3.6 kare 3): "Bu gün için çalışma yok." in a
/// card, padding 20 / 16 / 8, centered, and in edit mode the text button
/// "Konu Ekle" with a Plus.
class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.editing, required this.onAdd});

  final bool editing;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        20,
        AppSpacing.s16,
        AppSpacing.s8,
      ),
      child: Semantics(
        container: true,
        liveRegion: true,
        child: Column(
          children: [
            Text(
              l10n.schedule_emptyDay,
              textAlign: TextAlign.center,
              style: context.appText.body.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
            if (editing)
              AppButton(
                label: l10n.schedule_addTopic,
                icon: PhosphorIconsRegular.plus,
                variant: AppButtonVariant.text,
                size: AppButtonSize.md40,
                onPressed: onAdd,
              ),
          ],
        ),
      ),
    );
  }
}
