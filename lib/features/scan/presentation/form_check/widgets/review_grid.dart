part of '../scan_review_view.dart';

/// The answer grid of the selected column (pano 4.7): five columns, 8 apart,
/// 20 from the sides, one `QuestionCell.formCheck` per question numbered from
/// 1 (a blank reading is dashed amber, a corrected one navy with a pencil).
/// A tap opens the fix sheet at that question.
class _ReviewGridSliver
    extends SelectorViewModelWidget<ScanReviewViewModel, _ColumnsData> {
  const _ReviewGridSliver();

  @override
  _ColumnsData selector(ScanReviewViewModel viewModel) =>
      (model: viewModel.model, column: viewModel.column);

  /// The gutter and the gap between cells (pano 4.7: left 20, gap 8).
  static const double _gutter = 20;
  static const double _gap = AppSpacing.s8;

  @override
  Widget build(BuildContext context, _ColumnsData data) {
    final vm = getParentViewModel<ScanReviewViewModel>(context, listen: false);
    final model = data.model;
    final column = data.column;
    final count = model.grid.questionCount(column);
    final height = QuestionCell.formCheckHeightFor(
      MediaQuery.textScalerOf(context),
    );
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: _gutter),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: QuestionCell.columns,
          mainAxisSpacing: _gap,
          crossAxisSpacing: _gap,
          mainAxisExtent: height,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final question = index + 1;
          return QuestionCell.formCheck(
            number: question,
            status: model.statusOf(column, question),
            marked: model.markOf(column, question),
            onTap: () => unawaited(vm.fixCell(question)),
          );
        }, childCount: count),
      ),
    );
  }
}
