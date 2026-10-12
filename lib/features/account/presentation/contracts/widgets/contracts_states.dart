part of '../contracts_view.dart';

/// The skeleton of the list (pano 1.22 kare 2 pattern): the card with three
/// rows of an icon square and two lines, in the real rows' size. 15 s at
/// most, then the error state.
class _ContractsSkeleton extends StatelessWidget {
  const _ContractsSkeleton();

  /// The widths of the title lines of the three rows.
  static const List<double> _titleWidths = [140, 180, 150];

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
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: AppRadius.borderLg,
          ),
          child: AppSkeleton(
            child: Column(
              children: [
                for (final width in _titleWidths)
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: AppSize.rowMinTwoLine,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                        vertical: AppSpacing.s16,
                      ),
                      child: Row(
                        children: [
                          const SkeletonBox(width: 24, height: 24),
                          const SizedBox(width: AppSpacing.s12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonBox(width: width, height: 18),
                              const SizedBox(height: AppSpacing.s8),
                              const SkeletonBox(width: 96, height: 14),
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

/// The server sent no document.
class _ContractsEmpty extends StatelessWidget {
  const _ContractsEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SliverToBoxAdapter(
      child: AppEmptyState.screen(
        title: l10n.account_contractsEmptyTitle,
        message: l10n.account_contractsEmptyMessage,
      ),
    );
  }
}

/// The list did not load (or took 15 s): "Tekrar Dene" goes back to the
/// skeleton. Offline with nothing saved reads the same; the shell's strip says
/// why.
class _ContractsError extends StatelessWidget {
  const _ContractsError();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ContractsViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.account_contractsErrorTitle,
        message: l10n.account_loadErrorMessage,
        onRetry: () => unawaited(viewModel.retry()),
      ),
    );
  }
}
