part of '../lesson_detail_view.dart';

/// The row under the title: the "Eksiklerim (31)" chip at the left and the
/// "Kartlarım" text button at the right (pano 7.2 y=158; Tarih: "Kartlarım ·
/// 41/64"). The chip is a toggle, navy when on. It is drawn only with a real
/// count; the button shows the deck's progress only with real card counts.
class _LessonFilterBar
    extends
        SelectorViewModelWidget<LessonDetailViewModel, LessonFilterBarData> {
  const _LessonFilterBar();

  /// The text button pulls its 12 pt side padding out of the gutter, so its
  /// label ends at the page edge (pano 7.2: margin-right −12).
  static const double _buttonPull = 12;

  @override
  LessonFilterBarData selector(LessonDetailViewModel viewModel) =>
      viewModel.filterBar;

  @override
  Widget build(BuildContext context, LessonFilterBarData data) {
    if (!data.visible) return _noSliver;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<LessonDetailViewModel>(
      context,
      listen: false,
    );
    final known = data.cardsKnown;
    final total = data.cardsTotal;
    final missing = data.missingTotal;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s12,
          AppSpacing.gutter,
          0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (missing != null)
              Flexible(
                child: AppChip(
                  label: l10n.lessonDetail_missingFilter(
                    TrFormat.sira(missing),
                  ),
                  size: AppChipSize.md40,
                  icon: PhosphorIconsRegular.flag,
                  selected: data.onlyMissing,
                  onTap: viewModel.toggleOnlyMissing,
                ),
              )
            else
              const SizedBox.shrink(),
            Transform.translate(
              offset: const Offset(_buttonPull, 0),
              child: AppButton(
                label: known != null && total != null
                    ? l10n.lessonDetail_cardsProgress(
                        TrFormat.sira(known),
                        TrFormat.sira(total),
                      )
                    : l10n.lessonDetail_cards,
                icon: PhosphorIconsRegular.cards,
                variant: AppButtonVariant.text,
                size: AppButtonSize.md40,
                onPressed: viewModel.openCards,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The category segment with its counters (pano 7.2 y=214): "Tümü · TYT · AYT"
/// or "TYT · AYT · SOS-2". A counter is drawn where the server counted
/// ("28 eksik", "eksik yok"); an option nobody counted has none.
class _LessonSegmentBar
    extends
        SelectorViewModelWidget<LessonDetailViewModel, LessonSegmentBarData> {
  const _LessonSegmentBar();

  @override
  LessonSegmentBarData selector(LessonDetailViewModel viewModel) =>
      viewModel.segmentBar;

  @override
  Widget build(BuildContext context, LessonSegmentBarData data) {
    if (!data.visible) return _noSliver;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<LessonDetailViewModel>(
      context,
      listen: false,
    );
    String? counter(int? missing) => switch (missing) {
      null => null,
      0 => l10n.lessons_noMissing,
      final count => l10n.lessons_missingCount(TrFormat.sira(count)),
    };
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s12,
          AppSpacing.gutter,
          0,
        ),
        child: AppSegmented<int>(
          value: data.selected!,
          onChanged: viewModel.selectSegment,
          segments: [
            for (final segment in data.segments)
              AppSegment(
                value: segment.value,
                label: segment.label ?? l10n.lessonDetail_segmentAll,
                counter: counter(segment.missing),
              ),
          ],
        ),
      ),
    );
  }
}
