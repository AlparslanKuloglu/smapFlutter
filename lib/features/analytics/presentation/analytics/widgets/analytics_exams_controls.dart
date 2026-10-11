part of '../analytics_view.dart';

typedef _ControlsData = ({
  bool visible,
  ExamTypeFilter type,
  ExamDatePreset date,
  ExamCounts counts,
});

/// The type segment and the summary line (pano 6.2 kare 1). Shown once the
/// list has answered, and kept while a later load runs; hidden when there is
/// no exam at all, and on a failed unfiltered list.
class _ExamsControls
    extends SelectorViewModelWidget<AnalyticsViewModel, _ControlsData> {
  const _ExamsControls();

  @override
  _ControlsData selector(AnalyticsViewModel viewModel) {
    final state = viewModel.examList.state;
    final initial = viewModel.query.isInitial;
    final visible =
        viewModel.examsSettled &&
        switch (state) {
          SectionState.loading || SectionState.ready => true,
          SectionState.empty ||
          SectionState.error ||
          SectionState.offline => !initial,
        };
    return (
      visible: visible,
      type: viewModel.query.type,
      date: viewModel.query.date,
      counts: viewModel.counts,
    );
  }

  @override
  Widget build(BuildContext context, _ControlsData data) {
    if (!data.visible) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        _sectionGap,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ExamTypeSegment(type: data.type, counts: data.counts),
            const SizedBox(height: AppSpacing.s8),
            _ExamSummaryRow(date: data.date),
          ],
        ),
      ),
    );
  }
}

/// "Tümü / 10 deneme · TYT / 6 deneme · AYT / 4 deneme" (pano 6.2 "Sayaçlı
/// segment"). An option the server gave no count for has no counter line.
class _ExamTypeSegment extends StatelessWidget {
  const _ExamTypeSegment({required this.type, required this.counts});

  final ExamTypeFilter type;
  final ExamCounts counts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AnalyticsViewModel>(
      context,
      listen: false,
    );
    String? counter(int? count) =>
        count == null || count <= 0 ? null : l10n.analytics_examCount(count);
    return Semantics(
      container: true,
      label: l10n.analytics_typeA11y,
      child: AppSegmented<ExamTypeFilter>(
        value: type,
        onChanged: viewModel.selectType,
        segments: [
          AppSegment(
            value: ExamTypeFilter.all,
            label: l10n.analytics_typeAll,
            counter: counter(counts.all),
          ),
          AppSegment(
            value: ExamTypeFilter.tyt,
            label: NetExamType.tyt.label,
            counter: counter(counts.tyt),
          ),
          AppSegment(
            value: ExamTypeFilter.ayt,
            label: NetExamType.ayt.label,
            counter: counter(counts.ayt),
          ),
        ],
      ),
    );
  }
}

/// "Tüm tarihler · En yeni önce" and the text button "Süz ve Sırala" (pano
/// 6.2 kare 1; the button's label meets the page margin, margin-right -12).
/// The list always comes newest first: the backend has no sort parameter yet,
/// so the sheet has the date ranges only.
class _ExamSummaryRow extends StatelessWidget {
  const _ExamSummaryRow({required this.date});

  final ExamDatePreset date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.analytics_summaryLine(examDateLabel(l10n, date)),
            style: context.appText.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(SectionHeader.actionBleed, 0),
          child: AppButton(
            label: l10n.analytics_sortAction,
            variant: AppButtonVariant.text,
            size: AppButtonSize.md40,
            icon: PhosphorIconsRegular.sliders,
            onPressed: () => _openSheet(context),
          ),
        ),
      ],
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final viewModel = getParentViewModel<AnalyticsViewModel>(
      context,
      listen: false,
    );
    final chosen = await ExamFilterSheet.show(context, initial: date);
    if (chosen == null || chosen == viewModel.query.date) return;
    AppHaptics.selection();
    viewModel.applyDate(chosen);
  }
}
