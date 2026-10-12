part of '../meetings_view.dart';

/// The skeleton of Görüşmelerim (pano 10.5 kare 1 shape, 1.22 kare 2): the band,
/// the search field and the chips have come at once; the card holds four rows
/// of a 40 pt avatar and two lines. 15 s at most, then the error state.
class _MeetingsSkeleton extends StatelessWidget {
  const _MeetingsSkeleton();

  /// How many rows the skeleton card has.
  static const int _rows = 4;

  /// Widths of the name and the date line (pano 10.5 kare 1).
  static const double _nameWidth = 140;
  static const double _whenWidth = 190;

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
                      minHeight: AppSize.rowMinTwoLine,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                        vertical: AppSpacing.s12,
                      ),
                      child: Row(
                        children: [
                          SkeletonBox(height: AppAvatarSize.md, circle: true),
                          SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonBox(width: _nameWidth, height: 18),
                                SizedBox(height: AppSpacing.s8),
                                SkeletonBox(width: _whenWidth, height: 14),
                              ],
                            ),
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

/// No meeting at all (pano 10.5 kare 4): the clay "Hokka" 128 pt, "Henüz
/// görüşme yok", one sentence and the one action "Yeni Görüşme". The picture
/// is decoration (empty alt text).
class _MeetingsEmpty extends StatelessWidget {
  const _MeetingsEmpty();

  /// The clay picture of the board (1.25), with its own tile; not yet in the
  /// generated asset list.
  static const AssetGenImage _picture = AssetGenImage(
    'assets/illustrations/clay_inkwell.webp',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<MeetingsViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppEmptyState.screen(
        title: l10n.coachMeetings_emptyTitle,
        message: l10n.coachMeetings_emptyMessage,
        actionLabel: l10n.coachMeetings_emptyAction,
        actionIcon: PhosphorIconsRegular.plus,
        onAction: () => unawaited(viewModel.newMeeting()),
        illustration: _picture.image(
          width: AppEmptyState.illustrationSize,
          height: AppEmptyState.illustrationSize,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// The first load failed or took 15 s (or there is no connection and nothing
/// saved): "Görüşmelerin yüklenemedi" with "Tekrar Dene". Offline reads the
/// same; the shell's strip says why.
class _MeetingsError extends StatelessWidget {
  const _MeetingsError();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<MeetingsViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.coachMeetings_loadErrorTitle,
        message: l10n.coachMeetings_loadErrorMessage,
        onRetry: viewModel.retry,
      ),
    );
  }
}

/// A search or "Kiminle" choice that keeps no meeting (the controls stay): a
/// short sentence and the action that undoes it. The board draws no frame for
/// it; the card follows "Sonuç yok" of Öğrencilerim (pano 10.2 kare 3).
class _MeetingsNoMatch extends StatelessWidget {
  const _MeetingsNoMatch({required this.data});

  final MeetingListData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<MeetingsViewModel>(
      context,
      listen: false,
    );
    final searching = data.query.isNotEmpty;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppEmptyState.section(
          message: searching
              ? l10n.coachMeetings_noMatch(data.query)
              : l10n.coachMeetings_noKind,
          actionLabel: searching
              ? l10n.coachMeetings_clearSearch
              : l10n.coachMeetings_showAll,
          onAction: searching
              ? viewModel.clearSearch
              : () => viewModel.selectKind(MeetingWith.all),
        ),
      ),
    );
  }
}
