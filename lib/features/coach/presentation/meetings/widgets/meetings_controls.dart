part of '../meetings_view.dart';

/// What the controls redraw on: the first load's state (they are not drawn in
/// the empty state, kare 4) and the "Kiminle" choice.
typedef _ControlsData = ({SectionState state, MeetingWith kind});

/// The search field and the "Kiminle" chips (pano 10.5 kare 1): "Görüşme ara"
/// 16 under the band, then the pills "Tümü · Öğrenci · Veli" (40 high, one
/// choice) 8 under it. Not drawn in the empty state (kare 4) and the error
/// states, where there is nothing to search.
class _MeetingsControls
    extends SelectorViewModelWidget<MeetingsViewModel, _ControlsData> {
  const _MeetingsControls({required this.search});

  /// The page's controller, so "Aramayı Temizle" can empty the field.
  final TextEditingController search;

  @override
  _ControlsData selector(MeetingsViewModel viewModel) =>
      (state: viewModel.state, kind: viewModel.kind);

  @override
  Widget build(BuildContext context, _ControlsData data) {
    final shown =
        data.state == SectionState.loading || data.state == SectionState.ready;
    if (!shown) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<MeetingsViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s16,
          AppSpacing.gutter,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSearchField(
              controller: search,
              semanticLabel: l10n.coachMeetings_searchHint,
              hintText: l10n.coachMeetings_searchHint,
              onQueryChanged: viewModel.setQuery,
            ),
            const SizedBox(height: AppSpacing.s8),
            Semantics(
              container: true,
              label: l10n.coachMeetings_withLabel,
              child: AppChipGroup<MeetingWith>(
                size: AppChipSize.md40,
                selected: {data.kind},
                onChanged: viewModel.selectKind,
                items: [
                  AppChipItem(
                    value: MeetingWith.all,
                    label: l10n.coachMeetings_withAll,
                  ),
                  AppChipItem(
                    value: MeetingWith.student,
                    label: l10n.coachMeetings_kindStudent,
                  ),
                  AppChipItem(
                    value: MeetingWith.parent,
                    label: l10n.coachMeetings_kindParent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
