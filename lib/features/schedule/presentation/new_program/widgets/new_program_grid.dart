part of '../new_program_view.dart';

typedef _ChipsData = ({
  List<DateTime> days,
  DateTime? selected,
  String counts,
  DateTime today,
});

/// Step 2, the chosen days (pano 3.5 kare 2): 56 x 76 chips with "2 konu"
/// under the number of a day that has topics; the grid below follows the
/// selected one.
class _GridStep extends StatelessWidget {
  const _GridStep();

  @override
  Widget build(BuildContext context) {
    return const SliverMainAxisGroup(slivers: [_GridChips(), _GridSlots()]);
  }
}

class _GridChips
    extends SelectorViewModelWidget<NewProgramViewModel, _ChipsData> {
  const _GridChips();

  @override
  _ChipsData selector(NewProgramViewModel viewModel) => (
    days: viewModel.days,
    selected: viewModel.gridDay,
    counts: viewModel.days.map(viewModel.countOn).join(','),
    today: viewModel.today,
  );

  @override
  Widget build(BuildContext context, _ChipsData data) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<NewProgramViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Row(
          children: [
            for (final (i, day) in data.days.indexed) ...[
              if (i > 0) const SizedBox(width: AppSpacing.s8),
              AppDayChip(
                date: day,
                size: AppDayChipSize.large,
                today: CalendarMath.sameDay(day, data.today),
                selected:
                    data.selected != null &&
                    CalendarMath.sameDay(day, data.selected!),
                caption: viewModel.countOn(day) > 0
                    ? l10n.schedule_dayChipTopics(
                        TrFormat.sira(viewModel.countOn(day)),
                      )
                    : null,
                onTap: () => viewModel.selectGridDay(day),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The hour slots of the selected day (pano 3.5 kare 2): 06:00 to 23:00 in
/// one card; an empty hour opens the topic sheet, a filled one shows the topic
/// and its remove button.
class _GridSlots
    extends SelectorViewModelWidget<NewProgramViewModel, ProgramDay?> {
  const _GridSlots();

  @override
  ProgramDay? selector(NewProgramViewModel viewModel) {
    final day = viewModel.gridDay;
    return day == null
        ? null
        : ProgramDay(day: day, entries: viewModel.entriesOn(day));
  }

  @override
  Widget build(BuildContext context, ProgramDay? day) {
    if (day == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final viewModel = getParentViewModel<NewProgramViewModel>(
      context,
      listen: false,
    );
    final range = HourRange.of(day.entries);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        AppSpacing.s24,
      ),
      sliver: SliverToBoxAdapter(
        child: AppCard(
          padding: EdgeInsets.zero,
          clip: true,
          child: Column(
            children: [
              for (final hour in range.hours)
                HourSlot(
                  key: ValueKey<int>(hour),
                  hour: hour,
                  showRule: hour != range.last,
                  entries: [
                    for (final entry in day.entries)
                      if (entry.hour == hour) entry,
                  ],
                  onAdd: () => viewModel.placeTopic(hour),
                  onRemove: viewModel.removeEntry,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
