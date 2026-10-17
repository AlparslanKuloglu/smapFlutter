part of '../topic_picker_sheet.dart';

/// Rows of the list while it loads (the radio mark, a title bar).
class _TopicListSkeleton extends StatelessWidget {
  const _TopicListSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s16,
        AppSpacing.s24,
        0,
      ),
      child: AppSkeleton(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 96, height: 14),
            SizedBox(height: AppSpacing.s16),
            _SkeletonRow(),
            _SkeletonRow(),
            _SkeletonRow(),
          ],
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s16),
      child: Row(
        children: [
          SkeletonBox(height: 24, circle: true),
          SizedBox(width: AppSpacing.s24),
          Expanded(child: SkeletonBox(height: 18)),
        ],
      ),
    );
  }
}

/// The lessons failed to load (not in the board; "Tekrar Dene").
class _TopicListError extends StatelessWidget {
  const _TopicListError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s16,
        AppSpacing.s24,
        0,
      ),
      child: AppErrorState.section(
        message: AppLocalizations.of(context).schedule_topicsLoadError,
        onRetry: onRetry,
      ),
    );
  }
}

/// An empty bag (not in the board; one sentence). A coach's sheet names the
/// student ([name]).
class _TopicListEmpty extends StatelessWidget {
  const _TopicListEmpty({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s24,
        AppSpacing.s24,
        0,
      ),
      child: Text(
        name == null
            ? AppLocalizations.of(context).schedule_bagEmpty
            : AppLocalizations.of(
                context,
              ).coachStudentProfile_bagEmpty(TurkishSuffix.genitive(name!)),
        style: context.appText.body.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
    );
  }
}
