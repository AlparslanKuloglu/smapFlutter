part of '../topic_picker_sheet.dart';

typedef _ListData = ({
  TopicSource source,
  AsyncSection<List<TopicGroup>> section,
});

/// The list under the segment: skeleton, error, empty bag or the groups
/// (pano 3.5 kare 3).
class _TopicListSection
    extends SelectorViewModelWidget<TopicPickerViewModel, _ListData> {
  const _TopicListSection();

  @override
  _ListData selector(TopicPickerViewModel viewModel) =>
      (source: viewModel.source, section: viewModel.shown);

  @override
  Widget build(BuildContext context, _ListData data) {
    final viewModel = getParentViewModel<TopicPickerViewModel>(
      context,
      listen: false,
    );
    final section = data.section;
    return switch (section.state) {
      SectionState.loading => const _TopicListSkeleton(),
      SectionState.error ||
      SectionState.offline => _TopicListError(onRetry: viewModel.retry),
      SectionState.empty => const _TopicListEmpty(),
      SectionState.ready => _TopicGroups(
        groups: section.data ?? const [],
        // The bag has no "eksik" field for a coach's student (Tur 12 A).
        bag: data.source == TopicSource.bag && !viewModel.isCoachView,
      ),
    };
  }
}

/// The groups: a lesson heading over its radio rows.
class _TopicGroups extends StatelessWidget {
  const _TopicGroups({required this.groups, required this.bag});

  final List<TopicGroup> groups;
  final bool bag;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in groups) ...[
          _GroupHeading(name: group.lessonName),
          for (final choice in group.choices)
            _TopicRow(
              key: ValueKey<String>(choice.key),
              choice: choice,
              showEksik: bag,
            ),
        ],
      ],
    );
  }
}

/// A lesson heading: 13/20 · 700 `textSecondary`, padding 12 / 24 / 0 (pano
/// 3.5 kare 3).
class _GroupHeading extends StatelessWidget {
  const _GroupHeading({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s12,
        AppSpacing.s24,
        0,
      ),
      child: Semantics(
        header: true,
        child: Text(
          name,
          style: context.appText.caption.copyWith(
            color: context.appColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// One radio row (pano 3.5 kare 3): the radio, the topic with "Programda: Pzt
/// 10:00" under it, and the "Eksik" tag of a bag topic. At least 56 high,
/// padding 8 / 24, 12 between the parts; the whole row is the target.
class _TopicRow extends SelectorViewModelWidget<TopicPickerViewModel, bool> {
  const _TopicRow({required this.choice, required this.showEksik, super.key});

  final TopicChoice choice;
  final bool showEksik;

  /// The radio's 48 pt box starts 12 in so its 24 pt mark is 24 from the
  /// edge, as in the board.
  static const double _boxInset = 12;

  @override
  bool selector(TopicPickerViewModel viewModel) =>
      viewModel.isSelected(choice.key);

  @override
  Widget build(BuildContext context, bool selected) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<TopicPickerViewModel>(
      context,
      listen: false,
    );
    final placed = viewModel.placedAt(choice);
    void pick() => viewModel.select(choice);
    final placedLine = placed == null
        ? null
        : l10n.schedule_inProgramAt(
            TrFormat.gunKisa(placed.day),
            placed.timeLabel,
          );
    final reading = [
      l10n.schedule_topicRowA11y(choice.title, choice.lessonName),
      ?placedLine,
      // The tag is part of this reading (the row hides its own nodes).
      if (showEksik) l10n.lessons_missingItem,
    ].join(', ');

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: reading,
      excludeSemantics: true,
      onTap: pick,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: pick,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSize.rowMin),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              _boxInset,
              AppSpacing.s8,
              AppSpacing.s24,
              AppSpacing.s8,
            ),
            child: Row(
              children: [
                AppRadio<bool>(
                  value: true,
                  groupValue: selected ? true : null,
                  onChanged: (_) => pick(),
                  semanticLabel: choice.title,
                  focusGapColor: colors.bgRaised,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        choice.title,
                        style: text.bodyStrong.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      if (placedLine case final line?)
                        Text(
                          line,
                          style: text.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (showEksik) ...[
                  const SizedBox(width: AppSpacing.s12),
                  const EksikTag(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
