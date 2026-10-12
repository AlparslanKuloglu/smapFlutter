part of '../students_view.dart';

/// The skeleton of Öğrencilerim: the band and the search field have come at
/// once; the card holds five rows of a 40 pt round avatar and two lines of 140
/// and 180 wide (the rows of pano 10.2 kare 1, in the pattern of pano 1.22).
/// 15 s at most, then the error state.
class _StudentsSkeleton extends StatelessWidget {
  const _StudentsSkeleton();

  /// How many rows the skeleton draws (the board's five students).
  static const int _rows = 5;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: AppRadius.borderLg,
          ),
          child: AppSkeleton(
            child: Column(
              children: [
                for (var i = 0; i < _rows; i++)
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: StudentRow.minHeight,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                        vertical: AppSpacing.s12,
                      ),
                      child: Row(
                        children: [
                          SkeletonBox(height: 40, circle: true),
                          SizedBox(width: AppSpacing.s12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonBox(width: 140, height: 16),
                              SizedBox(height: AppSpacing.s8),
                              SkeletonBox(width: 180, height: 13),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The coach has no student (pano 10.2 kare 4): 66 under the band, three
/// avatars of 72 that overlap by 16 (the board's av-1, av-4 and av-3, a
/// picture of the design, not of the coach's students), "Henüz öğrencin yok"
/// 20/28 · 700 (24 under them), the sentence 15/24 `textSecondary` (8 under
/// it) and, 24 under that, the primary "Öğrenci Ekle" and, 12 under it, the
/// outlined "Kodunu Paylaş". The share button is there only for a coach who
/// has a coaching code.
class _StudentsEmpty extends StatelessWidget {
  const _StudentsEmpty();

  /// The space under the band (pano 10.2 kare 4: content from 200, band 134).
  static const double _top = 66;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<StudentsViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          _top,
          AppSpacing.s24,
          0,
        ),
        child: Semantics(
          container: true,
          liveRegion: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ExcludeSemantics(
                  child: AppAvatarStack.large(
                    people: [
                      for (final index in StudentAvatars.emptyStateIndices)
                        (
                          name: '',
                          image: AssetImage(StudentAvatars.assetOf(index)!),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              Semantics(
                header: true,
                child: Text(
                  l10n.students_emptyTitle,
                  textAlign: TextAlign.center,
                  style: text.titleMd.copyWith(color: colors.textPrimary),
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                l10n.students_emptyMessage,
                textAlign: TextAlign.center,
                style: text.body.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s24),
              AppButton(
                label: l10n.students_emptyAdd,
                icon: PhosphorIconsRegular.plus,
                expand: true,
                onPressed: viewModel.addStudent,
              ),
              if (viewModel.canShareCode) ...[
                const SizedBox(height: AppSpacing.s12),
                Builder(
                  builder: (buttonContext) => AppButton(
                    label: l10n.students_emptyShare,
                    icon: PhosphorIconsRegular.shareNetwork,
                    variant: AppButtonVariant.outline,
                    expand: true,
                    onPressed: () => viewModel.shareCode(
                      l10n,
                      origin: _originOf(buttonContext),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// The button's rectangle on screen, for the iPad share popover.
  static Rect? _originOf(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}

/// The student list did not load (or the first load took 15 s): the
/// full-screen error state, "Öğrenciler yüklenemedi" with "Tekrar Dene" (back
/// to the skeleton). Offline with nothing saved reads the same; the shell's
/// strip says why.
class _StudentsError extends StatelessWidget {
  const _StudentsError();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<StudentsViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.students_loadErrorTitle,
        message: l10n.students_loadErrorMessage,
        onRetry: viewModel.retry,
      ),
    );
  }
}
