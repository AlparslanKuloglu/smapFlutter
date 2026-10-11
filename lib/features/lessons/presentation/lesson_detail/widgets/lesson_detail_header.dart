part of '../lesson_detail_view.dart';

/// The bar of Ders Detayı: Back, and the lesson's name once the title under
/// it has scrolled away (pano 7.2; C82).
class _LessonBar
    extends SelectorViewModelWidget<LessonDetailViewModel, LessonHeaderData> {
  const _LessonBar();

  @override
  LessonHeaderData selector(LessonDetailViewModel viewModel) =>
      viewModel.header;

  @override
  Widget build(BuildContext context, LessonHeaderData data) =>
      AppDetailBar(title: _lessonTitle(context, data));
}

/// The title block: the 40 pt glyph tile and the name 24/32 · 700, 12 apart
/// (pano 7.2 y=102; 7.4). It is the page's heading for screen readers.
class _LessonTitle
    extends SelectorViewModelWidget<LessonDetailViewModel, LessonHeaderData> {
  const _LessonTitle();

  @override
  LessonHeaderData selector(LessonDetailViewModel viewModel) =>
      viewModel.header;

  @override
  Widget build(BuildContext context, LessonHeaderData data) {
    final title = _lessonTitle(context, data);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Semantics(
          header: true,
          child: Row(
            children: [
              SubjectGlyph(subject: data.subject),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.titleLg.copyWith(
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Edebiyat section segment, "Konular" and "Yazar ve Eserler" (pano 7.4
/// y=158); nothing for any other lesson.
class _LessonSectionBar
    extends SelectorViewModelWidget<LessonDetailViewModel, LessonSectionData> {
  const _LessonSectionBar();

  @override
  LessonSectionData selector(LessonDetailViewModel viewModel) =>
      viewModel.sectionData;

  @override
  Widget build(BuildContext context, LessonSectionData data) {
    final section = data.section;
    if (section == null) return _noSliver;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<LessonDetailViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s12,
          AppSpacing.gutter,
          0,
        ),
        child: AppSegmented<LiteratureSection>(
          value: section,
          onChanged: viewModel.selectSection,
          segments: [
            AppSegment(
              value: LiteratureSection.topics,
              label: l10n.lessonDetail_sectionTopics,
            ),
            AppSegment(
              value: LiteratureSection.authors,
              label: l10n.lessonDetail_sectionAuthors,
            ),
          ],
        ),
      ),
    );
  }
}
