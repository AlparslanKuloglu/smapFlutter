part of '../exam_detail_view.dart';

/// What the Konular tab selects: the section, the exam's type (it decides
/// which lesson a topic opens) and whether a coach is looking.
typedef _TopicsData = (AsyncSection<ExamTopicsModel>, NetExamType?, bool);

/// The Konular tab (pano 5.5, 5.10; flow 13.6): "neyi çalışmalıyım?". The card
/// of the most missed topic with "Bu Konuyu Çalış", then each lesson with its
/// topics weakest first. It loads when first shown and has its own skeleton,
/// "Konu analizi henüz hazır değil." and error with "Tekrar Dene".
class _TopicsTab
    extends SelectorViewModelWidget<ExamDetailViewModel, _TopicsData> {
  const _TopicsTab();

  @override
  _TopicsData selector(ExamDetailViewModel viewModel) =>
      (viewModel.topics, viewModel.exam?.kind, viewModel.isCoachView);

  @override
  Widget build(BuildContext context, _TopicsData data) {
    final (section, _, _) = data;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ExamDetailViewModel>(
      context,
      listen: false,
    );
    return switch (section.state) {
      SectionState.loading => const _CardSkeleton(),
      SectionState.empty => _SectionEmpty(message: l10n.examDetail_topicsEmpty),
      SectionState.error || SectionState.offline => _SectionError(
        message: l10n.examDetail_topicsError,
        onRetry: viewModel.retryTopics,
      ),
      SectionState.ready => _TopicsContent(model: section.data!),
    };
  }
}

/// The most missed card and the lesson groups.
class _TopicsContent extends StatelessWidget {
  const _TopicsContent({required this.model});

  final ExamTopicsModel model;

  /// Gap between two lesson groups.
  static const double _groupGap = AppSpacing.s24;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (model.mostMissed case final missed?) ...[
          _MostMissedCard(missed: missed),
          const SizedBox(height: _sectionGap),
        ],
        for (final (i, group) in model.groups.indexed) ...[
          if (i > 0) const SizedBox(height: _groupGap),
          _TopicGroupSection(group: group),
        ],
      ],
    );
  }
}

/// "En çok kaçırdığın konu" (pano 5.5, 5.10): the caption 13 · 600, the
/// topic's name 17/24 · 700, "12 sorudan 7'sini kaçırdın." and the primary
/// "Bu Konuyu Çalış" (not for a coach, not for a lesson with no topic
/// screen).
class _MostMissedCard extends StatelessWidget {
  const _MostMissedCard({required this.missed});

  final MostMissedTopic missed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final viewModel = getParentViewModel<ExamDetailViewModel>(
      context,
      listen: false,
    );
    final canStudy = viewModel.canStudyLesson(missed.lessonName);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.examDetail_mostMissedLabel,
            style: text.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            missed.topic.name,
            style: text.headline.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.examDetail_mostMissedSentence(
              TrFormat.sira(missed.total),
              TurkishSuffix.possessiveAccusative(TrFormat.sira(missed.wrong)),
            ),
            style: text.body.copyWith(color: colors.textPrimary),
          ),
          if (canStudy) ...[
            const SizedBox(height: AppSpacing.s12),
            AppButton(
              label: l10n.examDetail_studyTopic,
              expand: true,
              onPressed: () => viewModel.openTopic(
                lessonName: missed.lessonName,
                topicName: missed.topic.name,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One lesson (pano 5.5): its name 17/24 · 700 with "zayıftan güçlüye" at the
/// far end, the lettered counter with "24 soru" under it, and a card of
/// [TopicResultRow]s.
class _TopicGroupSection extends StatelessWidget {
  const _TopicGroupSection({required this.group});

  final TopicGroup group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final viewModel = getParentViewModel<ExamDetailViewModel>(
      context,
      listen: false,
    );
    final canStudy = viewModel.canStudyLesson(group.lessonName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          container: true,
          label: l10n.examDetail_lessonGroupA11y(
            group.lessonName,
            TrFormat.sira(group.counts.total),
          ),
          excludeSemantics: true,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        group.lessonName,
                        style: text.headline.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      l10n.examDetail_weakToStrong,
                      style: text.caption.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s4),
                Wrap(
                  spacing: AppSpacing.s12,
                  runSpacing: AppSpacing.s4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DybCounter(counts: group.counts),
                    Text(
                      l10n.exams_questionCount(group.counts.total),
                      style: text.caption.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          clip: true,
          child: Column(
            children: [
              for (final (i, topic) in group.topics.indexed) ...[
                if (i > 0) _Divider(color: colors.bgSunken),
                TopicResultRow(
                  key: ValueKey('${group.lessonName}/${topic.name}'),
                  name: topic.name,
                  counts: topic.counts,
                  onTap: canStudy
                      ? () => viewModel.openTopic(
                          lessonName: group.lessonName,
                          topicName: topic.name,
                        )
                      : null,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
