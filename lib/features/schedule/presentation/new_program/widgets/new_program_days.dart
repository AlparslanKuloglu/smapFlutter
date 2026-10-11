part of '../new_program_view.dart';

typedef _DaysData = ({List<DateTime> days, DateTime today});

/// Step 1 (pano 3.5 kare 1): the calendar, past days closed, several days
/// picked one by one, and the legend "Bugün" under it. Each pick plays the
/// selection haptic (the calendar's own).
class _DaysStep
    extends SelectorViewModelWidget<NewProgramViewModel, _DaysData> {
  const _DaysStep();

  @override
  _DaysData selector(NewProgramViewModel viewModel) =>
      (days: viewModel.days, today: viewModel.today);

  @override
  Widget build(BuildContext context, _DaysData data) {
    final viewModel = getParentViewModel<NewProgramViewModel>(
      context,
      listen: false,
    );
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCalendar(
              selected: data.days.toSet(),
              today: data.today,
              onToggle: viewModel.toggleDay,
            ),
            const SizedBox(height: AppSpacing.s16),
            const Padding(
              padding: EdgeInsets.only(left: AppSpacing.s4),
              child: AppCalendarLegend(),
            ),
            const SizedBox(height: AppSpacing.s24),
          ],
        ),
      ),
    );
  }
}
