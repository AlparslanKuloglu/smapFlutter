part of '../coach_home_view.dart';

/// "Dikkat gerektirenler" (pano 10.1 kare 1 and 2; C33 `AttentionRow`),
/// **drawn only when `FeatureFlags.attentionListEnabled` is open** (the body
/// does not build it otherwise).
///
/// - ready (kare 2): a card of `AttentionRow`s, one per rule that fired (a
///   student can have both); a row opens the student's profile;
/// - empty (kare 1): a card with "Şu an dikkat gerektiren öğrenci yok." and
///   the explanation of the two rules;
/// - loading: the skeleton; failed: "Dikkat listesi yüklenemedi." with
///   "Tekrar Dene".
class _AttentionSection
    extends
        SelectorViewModelWidget<
          CoachHomeViewModel,
          AsyncSection<List<AttentionItem>>
        > {
  const _AttentionSection();

  @override
  AsyncSection<List<AttentionItem>> selector(CoachHomeViewModel viewModel) =>
      viewModel.attention;

  @override
  Widget build(
    BuildContext context,
    AsyncSection<List<AttentionItem>> section,
  ) {
    final l10n = AppLocalizations.of(context);
    if (section.isLoading) return const _AttentionSkeleton();
    return Padding(
      padding: _gutter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: l10n.coachHome_attention),
          switch (section.state) {
            SectionState.ready => _AttentionRows(items: section.data!),
            SectionState.empty => const _AttentionEmptyCard(),
            SectionState.loading ||
            SectionState.error ||
            SectionState.offline => AppErrorState.section(
              message: l10n.coachHome_attentionError,
              onRetry: getParentViewModel<CoachHomeViewModel>(
                context,
                listen: false,
              ).retryAttention,
            ),
          },
        ],
      ),
    );
  }
}

/// The card of the rows, 1 pt rules between them.
class _AttentionRows extends StatelessWidget {
  const _AttentionRows({required this.items});

  final List<AttentionItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        children: [
          for (final (index, item) in items.indexed) ...[
            if (index > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: context.appColors.bgSunken,
              ),
            Builder(
              builder: (context) {
                final copy = AttentionCopy.of(l10n, item);
                return AttentionRow(
                  name: item.name,
                  sentence: copy.sentence,
                  evidence: copy.evidence,
                  rule: item.rule,
                  semanticLabel: copy.semanticLabel,
                  avatar: CoachAvatars.imageOf(item.photo),
                  onTap: () => _openStudent(
                    context,
                    id: item.studentId,
                    name: item.name,
                    photo: item.photo,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// The card of nobody needing attention (pano 10.1 kare 1: padding 16, 15/24 ·
/// 600 and the explanation 13/20 `textSecondary`).
class _AttentionEmptyCard extends StatelessWidget {
  const _AttentionEmptyCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.coachHome_attentionEmptyTitle,
            style: text.bodyStrong.copyWith(color: colors.textPrimary),
          ),
          Text(
            l10n.coachHome_attentionEmptyBody,
            style: text.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
