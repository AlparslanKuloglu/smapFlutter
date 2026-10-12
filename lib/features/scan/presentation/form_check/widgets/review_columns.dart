part of '../scan_review_view.dart';

typedef _ColumnsData = ({FormCheckModel model, int column});

/// The column segment and the caption under it (pano 4.7): "1. kolon" to "4.
/// kolon", each with "N boş" or "boş yok" under it (the counters of
/// `AppSegmented`; columns are named by their number because the exam is not
/// known yet), and "3. kolon · 40 soru · düzeltmek için soruya dokun" (13/20 ·
/// 600, `textSecondary`).
class _ReviewColumns
    extends SelectorViewModelWidget<ScanReviewViewModel, _ColumnsData> {
  const _ReviewColumns();

  @override
  _ColumnsData selector(ScanReviewViewModel viewModel) =>
      (model: viewModel.model, column: viewModel.column);

  @override
  Widget build(BuildContext context, _ColumnsData data) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final vm = getParentViewModel<ScanReviewViewModel>(context, listen: false);
    final model = data.model;
    final columns = model.grid.columnCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (columns >= 2)
            AppSegmented<int>(
              segments: [
                for (var c = 1; c <= columns; c++)
                  AppSegment<int>(
                    value: c,
                    label: l10n.scan_columnN(TrFormat.sira(c)),
                    counter: model.blanksIn(c) == 0
                        ? l10n.scan_noBlank
                        : l10n.scan_blankCount(
                            TrFormat.sira(model.blanksIn(c)),
                          ),
                  ),
              ],
              value: data.column,
              onChanged: vm.selectColumn,
            ),
          const SizedBox(height: AppSpacing.s16),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.s4),
            child: Text(
              l10n.scan_columnCaption(
                TrFormat.sira(data.column),
                TrFormat.sira(model.grid.questionCount(data.column)),
              ),
              style: text.caption.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
        ],
      ),
    );
  }
}
