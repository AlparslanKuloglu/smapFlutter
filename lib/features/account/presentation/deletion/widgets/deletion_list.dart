part of '../account_deletion_view.dart';

/// The padding of the text blocks: the page's 16 at the sides.
const EdgeInsets _blockPadding = EdgeInsets.symmetric(
  horizontal: AppSpacing.gutter,
);

/// Gap between the lines of the list (pano 9.4 kare 2: "maddeler arası 12").
const double _lineGap = 12;

/// Space above the closing line (pano 9.4 kare 2: "margin-top 20").
const double _closingGap = 20;

/// "Hesabın silinemedi. Bağlantını kontrol edip tekrar dene." (pano 9.4 kare
/// 4 note), drawn as an error box under the title after a failed deletion.
/// Nothing is drawn before one.
class _DeletionFailureSliver
    extends SelectorViewModelWidget<AccountDeletionViewModel, bool> {
  const _DeletionFailureSliver();

  @override
  bool selector(AccountDeletionViewModel viewModel) => viewModel.failed;

  @override
  Widget build(BuildContext context, bool failed) {
    if (!failed) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppNoticeBox(
          message: AppLocalizations.of(context).deletion_failed,
          tone: AppNoticeTone.error,
        ),
      ),
    );
  }
}

typedef _ListData = ({int? examCount, bool hasCoach, String? coachName});

/// "Hesabını silersen:", the list and the closing line (pano 9.4 kare 2).
class _DeletionListSliver
    extends SelectorViewModelWidget<AccountDeletionViewModel, _ListData> {
  const _DeletionListSliver();

  @override
  _ListData selector(AccountDeletionViewModel viewModel) => (
    examCount: viewModel.examCount,
    hasCoach: viewModel.hasCoach,
    coachName: viewModel.coachName,
  );

  @override
  Widget build(BuildContext context, _ListData data) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final lines = DeletionConsequences.of(
      examCount: data.examCount,
      hasCoach: data.hasCoach,
      coachName: data.coachName,
    );
    return SliverPadding(
      padding: _blockPadding.copyWith(top: AppSpacing.s16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Semantics(
            header: true,
            child: Text(
              l10n.deletion_listHeading,
              style: text.titleSm.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(height: _lineGap),
          for (final (index, line) in lines.indexed) ...[
            if (index > 0) const SizedBox(height: _lineGap),
            _DeletionLine(line: line),
          ],
          const SizedBox(height: _closingGap),
          Text(
            l10n.deletion_pauseHint,
            style: text.body.copyWith(color: colors.textSecondary),
          ),
        ]),
      ),
    );
  }
}

/// One line of the list: a red X (18 pt, stroke 22 on the board; the regular
/// X here) and the sentence, 10 apart (pano 9.4 kare 2).
class _DeletionLine extends StatelessWidget {
  const _DeletionLine({required this.line});

  final DeletionConsequence line;

  /// Gap between the X and the sentence (pano 9.4: 10).
  static const double _markGap = 10;

  /// The X is 2 pt below the text's top to sit on the first line's center.
  static const double _markTop = 2;

  static const double _markSize = 18;

  String _sentence(AppLocalizations l10n) {
    final name = line.coachName;
    return switch (line.kind) {
      DeletionConsequenceKind.exams =>
        line.examCount == null
            ? l10n.deletion_lineExamsAnonymous
            : l10n.deletion_lineExams(TrFormat.sira(line.examCount!)),
      DeletionConsequenceKind.progress => l10n.deletion_lineProgress,
      DeletionConsequenceKind.coach =>
        name == null
            ? l10n.deletion_lineCoachAnonymous
            : l10n.deletion_lineCoach(name),
      DeletionConsequenceKind.irreversible => l10n.deletion_lineIrreversible,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: _markTop),
          child: ExcludeSemantics(
            child: PhosphorIcon(
              PhosphorIconsRegular.x,
              size: _markSize,
              color: colors.error,
            ),
          ),
        ),
        const SizedBox(width: _markGap),
        Expanded(
          child: Text(
            _sentence(AppLocalizations.of(context)),
            style: context.appText.bodyLg.copyWith(color: colors.textPrimary),
          ),
        ),
      ],
    );
  }
}
