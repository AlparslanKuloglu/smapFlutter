part of '../lessons_view.dart';

/// The navy band of Derslerim with its TYT / AYT segment (pano 7.1 kare 1;
/// 1.18 kare 2). The band is 178 high and does not shrink; the choice is
/// remembered by the ViewModel.
class _LessonsBand
    extends SelectorViewModelWidget<LessonsViewModel, LessonsExamType> {
  const _LessonsBand();

  @override
  LessonsExamType selector(LessonsViewModel viewModel) => viewModel.examType;

  @override
  Widget build(BuildContext context, LessonsExamType data) {
    final viewModel = getParentViewModel<LessonsViewModel>(
      context,
      listen: false,
    );
    return AppRootBand(
      title: AppLocalizations.of(context).nav_tabLessons,
      bottom: AppRootBandBottom.segment(
        child: AppSegmented<LessonsExamType>(
          onNavy: true,
          value: data,
          onChanged: viewModel.selectExamType,
          segments: const [
            AppSegment(
              value: LessonsExamType.tyt,
              label: LessonSegments.tytLabel,
            ),
            AppSegment(
              value: LessonsExamType.ayt,
              label: LessonSegments.aytLabel,
            ),
          ],
        ),
      ),
    );
  }
}
