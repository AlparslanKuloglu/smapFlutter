part of '../meeting_detail_view.dart';

/// The skeleton of a link that has no meeting yet (pano 1.22 kare 2 shape of
/// pano 10.5 kare 3): the bar has come; the header's avatar and two lines, the
/// two-row card and the notes' title with one card.
class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s8,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppSkeleton(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  SkeletonBox(height: AppAvatarSize.lg, circle: true),
                  SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 180, height: 24),
                        SizedBox(height: AppSpacing.s8),
                        SkeletonBox(width: 110, height: 14),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _blockGap),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.bgSurface,
                  borderRadius: AppRadius.borderLg,
                ),
                child: const SizedBox(
                  height: AppSize.rowMinTwoLine * 2,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: _sectionGap),
              const SkeletonBox(width: 90, height: 24),
              const SizedBox(height: AppSpacing.s12),
              const _NotesSkeletonCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The notes' skeleton: one card of two lines of text.
class _NotesSkeleton extends StatelessWidget {
  const _NotesSkeleton();

  @override
  Widget build(BuildContext context) =>
      const AppSkeleton(child: _NotesSkeletonCard());
}

class _NotesSkeletonCard extends StatelessWidget {
  const _NotesSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 16),
          SizedBox(height: AppSpacing.s8),
          SkeletonBox(width: 160, height: 16),
        ],
      ),
    );
  }
}

/// The notes failed to load (or the request timed out): "Notlar yüklenemedi."
/// with "Tekrar Dene" in the card, the rest of the screen working.
class _NotesError extends StatelessWidget {
  const _NotesError();

  @override
  Widget build(BuildContext context) {
    final viewModel = getParentViewModel<MeetingDetailViewModel>(
      context,
      listen: false,
    );
    return AppErrorState.section(
      message: AppLocalizations.of(context).coachMeetings_notesLoadFailed,
      onRetry: viewModel.retry,
    );
  }
}

/// The meeting did not load or is not in the list any more: the whole screen
/// is the error state with "Tekrar Dene".
class _DetailScreenError extends StatelessWidget {
  const _DetailScreenError({required this.missing});

  /// The server answered, but the meeting is not in its list.
  final bool missing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<MeetingDetailViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: missing
            ? l10n.coachMeetings_detailMissingTitle
            : l10n.coachMeetings_detailErrorTitle,
        message: missing
            ? l10n.coachMeetings_detailMissingMessage
            : l10n.coachMeetings_loadErrorMessage,
        onRetry: viewModel.retry,
      ),
    );
  }
}
