part of '../exam_detail_view.dart';

/// The Genel tab (pano 5.3, 5.8 kare 1 and 2): a card of tests, each with its
/// net and stacked bar, and under it the net rule and the nets by score type.
class _GeneralTab
    extends
        SelectorViewModelWidget<
          ExamDetailViewModel,
          (SectionState, ExamGeneralModel?)
        > {
  const _GeneralTab();

  @override
  (SectionState, ExamGeneralModel?) selector(ExamDetailViewModel viewModel) =>
      (viewModel.screenState, viewModel.general);

  @override
  Widget build(BuildContext context, (SectionState, ExamGeneralModel?) data) {
    final (_, general) = data;
    final l10n = AppLocalizations.of(context);
    final Widget body;
    if (general == null) {
      body = const _CardSkeleton();
    } else if (!general.hasBreakdown) {
      body = _SectionNoteCard(
        title: l10n.examDetail_noBreakdownTitle,
        message: l10n.examDetail_noBreakdownBody,
      );
    } else {
      body = _GeneralContent(general: general);
    }
    return body;
  }
}

/// The tests card and the footnotes.
class _GeneralContent extends StatelessWidget {
  const _GeneralContent({required this.general});

  final ExamGeneralModel general;

  /// Side padding of the footnotes (pano 5.3 kare 2: left/right 20, of which
  /// 16 are the page's).
  static const double _noteInset = AppSpacing.s4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final note = context.appText.caption.copyWith(color: colors.textSecondary);
    final byType = general.scoreTypeNets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
          child: Column(
            children: [
              for (final (i, row) in general.tests.indexed) ...[
                if (i > 0) _Divider(color: colors.bgSunken),
                TestBarRow(
                  key: ValueKey(row.index),
                  name: examTestName(l10n, row.label, row.index),
                  net: row.net,
                  counts: row.counts,
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            _noteInset,
            AppSpacing.s12,
            _noteInset,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.examDetail_netRule, style: note),
              if (byType.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s4),
                Text(
                  l10n.examDetail_netsByScoreType(
                    byType
                        .map(
                          (entry) => l10n.examDetail_scoreTypeNet(
                            _fieldName(l10n, entry.field),
                            TrFormat.net(entry.net),
                          ),
                        )
                        .join(' · '),
                  ),
                  style: note,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The hairline between two rows of a card (pano 5.3: 1 pt `bgSunken`).
class _Divider extends StatelessWidget {
  const _Divider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 1, child: ColoredBox(color: color));
}
