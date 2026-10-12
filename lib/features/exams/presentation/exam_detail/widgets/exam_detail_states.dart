part of '../exam_detail_view.dart';

/// The screen error (pano 5.8 kare 3): "Deneme yüklenemedi", "Bağlantını
/// kontrol edip tekrar dene." and "Tekrar Dene", which returns to the
/// skeleton. The bar and its Back button stay; no haptic on the error itself.
class _ExamScreenError
    extends SelectorViewModelWidget<ExamDetailViewModel, SectionState> {
  const _ExamScreenError();

  @override
  SectionState selector(ExamDetailViewModel viewModel) => viewModel.screenState;

  @override
  Widget build(BuildContext context, SectionState data) {
    if (data != SectionState.error && data != SectionState.offline) {
      return _noSliver;
    }
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ExamDetailViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.examDetail_errorTitle,
        message: l10n.examDetail_errorMessage,
        onRetry: viewModel.retry,
      ),
    );
  }
}

/// The skeleton of a tab (pano 5.8 kare 1): a card with three repeats of a
/// 16 high line (220, 150, 120 wide) over a 12 high pill.
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  /// Widths of the three lines.
  static const List<double> _widths = [220, 150, 120];

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(AppSpacing.s16),
    child: AppSkeleton(
      semanticLabel: AppLocalizations.of(context).kit_loading,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, width) in _widths.indexed) ...[
              if (i > 0) const SizedBox(height: 14),
              SkeletonBox(width: width),
              const SizedBox(height: AppSpacing.s8),
              const SizedBox(
                width: double.infinity,
                child: SkeletonBox(height: 12, radius: AppRadius.full),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// A section's empty card with a title and a sentence (pano 5.8 kare 2
/// "Ders kırılımı yok"): centered, 16 padding.
class _SectionNoteCard extends StatelessWidget {
  const _SectionNoteCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return AppCard(
      child: Semantics(
        container: true,
        liveRegion: true,
        child: Column(
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: text.titleSm.copyWith(color: colors.textPrimary),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.caption.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// A section's one-sentence empty card inside a tab (pano 5.8 "Boş
/// metinleri").
class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => AppEmptyState.section(message: message);
}

/// A section's error card inside a tab: the sentence and "Tekrar Dene", which
/// returns that section to its skeleton.
class _SectionError extends StatelessWidget {
  const _SectionError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) =>
      AppErrorState.section(message: message, onRetry: onRetry);
}
