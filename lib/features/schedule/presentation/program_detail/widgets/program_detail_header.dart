part of '../program_detail_view.dart';

typedef _BarData = ({
  SectionState state,
  String name,
  ProgramViewMode mode,
  bool editing,
  bool canEdit,
  bool canEditNow,
});

/// The bar (pano 3.4 kare 3 and 4, 3.6 kare 1): back and "Düzenle"; in edit
/// mode no back and "Bitti" (a plain mode switch: everything is saved); in
/// the Hafta view the program's name is in the bar from the start.
class _DetailBar
    extends SelectorViewModelWidget<ProgramDetailViewModel, _BarData> {
  const _DetailBar();

  @override
  _BarData selector(ProgramDetailViewModel viewModel) => (
    state: viewModel.section.state,
    name: viewModel.detail?.name ?? '',
    mode: viewModel.mode,
    editing: viewModel.editing,
    canEdit: viewModel.canEdit,
    canEditNow: viewModel.canEditNow,
  );

  @override
  Widget build(BuildContext context, _BarData data) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ProgramDetailViewModel>(
      context,
      listen: false,
    );
    final ready = data.state == SectionState.ready;
    Widget? action;
    if (ready && data.canEdit) {
      action = data.editing
          ? AppBarAction(
              label: l10n.schedule_done,
              onPressed: viewModel.finishEditing,
            )
          : AppBarAction(
              label: l10n.schedule_edit,
              onPressed: data.canEditNow ? viewModel.startEditing : null,
            );
    }
    return AppDetailBar(
      title: ready && data.name.isNotEmpty ? data.name : l10n.schedule_title,
      compactAlways: ready && data.mode == ProgramViewMode.week,
      leading: data.editing
          ? AppDetailBarLeading.none
          : AppDetailBarLeading.back,
      action: action,
    );
  }
}

typedef _HeaderData = ({
  SectionState state,
  ProgramViewMode mode,
  String name,
  String motto,
  String? range,
});

/// The large title, the motto and the date range (pano 3.4 kare 3: "Ekim 2.
/// Hafta · Her gün biraz daha · 5–11 Ekim 2026"); the Hafta view has none.
class _DetailHeader
    extends SelectorViewModelWidget<ProgramDetailViewModel, _HeaderData> {
  const _DetailHeader();

  @override
  _HeaderData selector(ProgramDetailViewModel viewModel) => (
    state: viewModel.section.state,
    mode: viewModel.mode,
    name: viewModel.detail?.name ?? '',
    motto: viewModel.detail?.motto ?? '',
    range: viewModel.detail?.span.rangeLabel,
  );

  @override
  Widget build(BuildContext context, _HeaderData data) {
    if (data.state != SectionState.ready || data.mode == ProgramViewMode.week) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final colors = context.appColors;
    final text = context.appText;
    return SliverMainAxisGroup(
      slivers: [
        if (data.name.isNotEmpty) LargeTitleSliver(title: data.name),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.s4,
            AppSpacing.gutter,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.motto.isNotEmpty)
                  Text(
                    data.motto,
                    style: text.body.copyWith(color: colors.textSecondary),
                  ),
                if (data.range case final dates?) ...[
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    dates,
                    style: text.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// "Gün | Hafta" (pano 3.4 kare 3 and 4), under the header; in the Hafta view
/// right under the bar.
class _DetailSegment
    extends SelectorViewModelWidget<ProgramDetailViewModel, _ModeData> {
  const _DetailSegment();

  @override
  _ModeData selector(ProgramDetailViewModel viewModel) =>
      (state: viewModel.section.state, mode: viewModel.mode);

  @override
  Widget build(BuildContext context, _ModeData data) {
    if (data.state != SectionState.ready) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ProgramDetailViewModel>(
      context,
      listen: false,
    );
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        data.mode == ProgramViewMode.week ? AppSpacing.s8 : AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: Semantics(
          container: true,
          label: l10n.schedule_viewLabel,
          child: AppSegmented<ProgramViewMode>(
            segments: [
              AppSegment(
                value: ProgramViewMode.day,
                label: l10n.schedule_viewDay,
              ),
              AppSegment(
                value: ProgramViewMode.week,
                label: l10n.schedule_viewWeek,
              ),
            ],
            value: data.mode,
            onChanged: viewModel.setMode,
          ),
        ),
      ),
    );
  }
}

typedef _StripData = ({
  SectionState state,
  ProgramViewMode mode,
  ProgramSpan? span,
  DateTime selected,
  DateTime today,
});

/// The day strip (pano 3.4 kare 3): 48 x 64 chips, seven spread edge to edge;
/// a program of more weeks scrolls sideways. Today has the orange dot, the
/// chosen day is navy.
class _DayStrip
    extends SelectorViewModelWidget<ProgramDetailViewModel, _StripData> {
  const _DayStrip();

  @override
  _StripData selector(ProgramDetailViewModel viewModel) => (
    state: viewModel.section.state,
    mode: viewModel.mode,
    span: viewModel.detail?.span,
    selected: viewModel.selectedDay,
    today: viewModel.today,
  );

  @override
  Widget build(BuildContext context, _StripData data) {
    final span = data.span;
    if (data.state != SectionState.ready ||
        data.mode != ProgramViewMode.day ||
        span == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final viewModel = getParentViewModel<ProgramDetailViewModel>(
      context,
      listen: false,
    );
    final days = span.days;
    Widget chip(DateTime day) => AppDayChip(
      date: day,
      today: CalendarMath.sameDay(day, data.today),
      selected: CalendarMath.sameDay(day, data.selected),
      onTap: () => viewModel.selectDay(day),
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: days.length <= 7
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [for (final day in days) chip(day)],
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final (i, day) in days.indexed) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.s8),
                      chip(day),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
