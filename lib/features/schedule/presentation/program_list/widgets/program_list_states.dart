part of '../program_list_view.dart';

/// The list as a skeleton (pano 3.7 kare 2): one card, a 40 x 40 tile (radius
/// 12) and three lines of 140 x 18, 170 x 14 and 100 x 14. The title and the
/// search field are already there; at 15 s without an answer the screen turns
/// to the error.
class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      sliver: SliverToBoxAdapter(
        child: AppSkeleton(
          child: AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 40, height: 40, radius: AppRadius.md),
                SizedBox(width: AppSpacing.s12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 140, height: 18),
                    SizedBox(height: AppSpacing.s8),
                    SkeletonBox(width: 170, height: 14),
                    SizedBox(height: AppSpacing.s8),
                    SkeletonBox(width: 100, height: 14),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// No program yet (pano 3.7 kare 1): the clay bulb, "Henüz programın yok", the
/// sentence and "Haftalık Programını Kur". The bar has no "Yeni Program" and
/// there is no search field. A coach sees the student's name instead (Tur 12
/// A, brief 14.1 kare 4): "Alparslan'ın programı yok", "Onun için bir hafta
/// kurabilirsin; …" and "Program Kur".
class _ListEmpty extends StatelessWidget {
  const _ListEmpty({
    required this.onSetUp,
    required this.canCreate,
    this.studentFirstName,
  });

  final VoidCallback? onSetUp;

  /// A screen that only reads has no action to offer.
  final bool canCreate;

  /// The student's first name in a coach's view; null for the user's own.
  final String? studentFirstName;

  /// The clay "Ampul" picture of board 1.25 (a crop of the board, like the
  /// welcome screen's map); nothing is drawn while the file is missing.
  static const String _bulbAsset = 'assets/illustrations/clay_bulb.webp';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = studentFirstName;
    return SliverToBoxAdapter(
      child: AppEmptyState.screen(
        title: name == null
            ? l10n.schedule_emptyTitle
            : l10n.coachStudentProfile_programEmptyTitle(
                TurkishSuffix.genitive(name),
              ),
        message: name == null
            ? l10n.schedule_emptyBody
            : l10n.coachStudentProfile_programEmptyBody(name),
        actionLabel: canCreate
            ? (name == null
                  ? l10n.schedule_emptyAction
                  : l10n.coachStudentProfile_programSetUp)
            : null,
        onAction: onSetUp,
        topPadding: AppSpacing.s64,
        illustration: Image.asset(
          _bulbAsset,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// The programs could not be loaded and none is saved (pano 3.7 kare 3): the
/// full-screen error, "Programların yüklenemedi", "Bağlantını kontrol edip
/// tekrar dene.", "Tekrar Dene" (back to the skeleton). No title is drawn.
class _ListError extends StatelessWidget {
  const _ListError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.schedule_loadError,
        message: l10n.schedule_loadErrorBody,
        onRetry: onRetry,
      ),
    );
  }
}
