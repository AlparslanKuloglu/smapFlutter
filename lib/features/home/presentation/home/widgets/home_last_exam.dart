part of '../home_view.dart';

/// "Son denemen" (pano 3.1 kare 1 to 3, 3.2 kare 1 and 2; C25 `ExamCard`
/// summary): the newest exam with its net, the change against the previous
/// exam of the same type, the small D/Y/B counter, the weakest topic and the
/// one primary button "Analizi Gör".
///
/// A student with no exam sees "Henüz deneme okutmadın." and "İlk Denemeni
/// Okut" (kare 3). Loading shows the skeleton; a failure shows the section
/// error card, and the other sections keep working. Each field the data
/// lacks (publisher, change, weakest topic) is simply not drawn.
class _LastExamSection
    extends
        SelectorViewModelWidget<HomeViewModel, AsyncSection<LastExamSummary>> {
  const _LastExamSection();

  @override
  AsyncSection<LastExamSummary> selector(HomeViewModel viewModel) =>
      viewModel.lastExam;

  @override
  Widget build(BuildContext context, AsyncSection<LastExamSummary> section) {
    if (section.isLoading) return const _LastExamSkeleton();
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<HomeViewModel>(context, listen: false);
    final Widget content;
    switch (section.state) {
      case SectionState.empty:
        content = ExamSummaryCard.empty(onScan: viewModel.openScan);
      case SectionState.ready:
        content = _LastExamCard(exam: section.data!);
      case SectionState.loading:
      case SectionState.error:
      case SectionState.offline:
        content = AppErrorState.section(
          message: l10n.home_lastExamError,
          onRetry: viewModel.retryLastExam,
        );
    }
    return Padding(
      padding: _gutter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: l10n.home_lastExam),
          content,
        ],
      ),
    );
  }
}

/// The card of the last exam: the data of [LastExamSummary] on the kit's
/// `ExamSummaryCard`.
class _LastExamCard extends StatelessWidget {
  const _LastExamCard({required this.exam});

  final LastExamSummary exam;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final weakest = exam.weakestTopic;
    return ExamSummaryCard(
      name: exam.name ?? l10n.home_examNameFallback(exam.kind.label),
      publisher: exam.publisher,
      typeLabel: exam.kind.label,
      date: exam.date,
      net: exam.net,
      counts: exam.counts,
      delta: exam.delta,
      weakestTopicSentence: weakest == null
          ? null
          : l10n.home_mostMissedSentence(
              weakest.nameLocative,
              weakest.totalText,
              weakest.wrongAccusative,
            ),
      onAnalyze: () => _openExam(context, exam.examId),
    );
  }
}
