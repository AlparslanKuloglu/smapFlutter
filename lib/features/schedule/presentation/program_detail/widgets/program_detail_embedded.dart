part of '../program_detail_view.dart';

/// The slices of the Program tab of a coach's student profile (Tur 12 A,
/// pano 14.1 kare 1 and 3): the title row with "Düzenle" (or, in edit mode, the
/// large title of the program), "Gün | Hafta", the day strip, the day's topics
/// and "Günü Sıfırla", then the Hafta grid. The bar, the context strip and the
/// tabs are the profile's.
///
/// Out of edit mode the day's heading ("Cumartesi, 10 Ekim") is not drawn: the
/// board's reading frame goes from the day strip straight to the rows, as the
/// read-only frame of pano 10.4 did.
class _ProgramDetailSlivers extends StatelessWidget {
  const _ProgramDetailSlivers();

  @override
  Widget build(BuildContext context) => const SliverMainAxisGroup(
    slivers: [
      _EmbeddedHeader(),
      _EmbeddedEditHeader(),
      _DetailSegment(),
      _EmbeddedLoading(),
      _EmbeddedError(),
      _DayStrip(),
      _DayHeading(embedded: true),
      _DayList(embedded: true),
      _DayActions(embedded: true),
      _WeekSection(),
    ],
  );
}

typedef _EmbeddedHeaderData = ({
  SectionState state,
  String name,
  String? meta,
  bool editing,
  bool canEdit,
  bool canEditNow,
});

/// The program's title row (pano 14.1 kare 1): "Ekim 2. Hafta" (17/24 · 700)
/// with the bar action "Düzenle" (PencilSimple, `BarAction.inline`) at the
/// right, and under the name "Her gün biraz daha · 5–11 Ekim 2026" (13/20).
/// "Düzenle" is off without a connection (pano 14.3 kare 3) and not drawn when
/// the coach may not write (`FeatureFlags.coachProgramWriteEnabled`). In edit
/// mode the row is gone: the profile's bar holds "Bitti" and the program's
/// large title takes its place ([_EmbeddedEditHeader]).
class _EmbeddedHeader
    extends
        SelectorViewModelWidget<ProgramDetailViewModel, _EmbeddedHeaderData> {
  const _EmbeddedHeader();

  @override
  _EmbeddedHeaderData selector(ProgramDetailViewModel viewModel) {
    final detail = viewModel.detail;
    final motto = detail?.motto;
    final parts = [
      ?(motto == null || motto.isEmpty ? null : motto),
      ?detail?.span.rangeLabel,
    ];
    return (
      state: viewModel.section.state,
      name: detail?.name ?? '',
      meta: parts.isEmpty ? null : parts.join(' · '),
      editing: viewModel.editing,
      canEdit: viewModel.canEdit,
      canEditNow: viewModel.canEditNow,
    );
  }

  @override
  Widget build(BuildContext context, _EmbeddedHeaderData data) {
    if (data.state != SectionState.ready || data.editing) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final viewModel = getParentViewModel<ProgramDetailViewModel>(
      context,
      listen: false,
    );
    final student = StudentScope.studentOf(context);
    final edit = AppBarAction(
      label: l10n.schedule_edit,
      icon: PhosphorIconsRegular.pencilSimple,
      onPressed: data.canEditNow ? viewModel.startEditing : null,
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      data.name,
                      style: text.headline.copyWith(color: colors.textPrimary),
                    ),
                  ),
                  if (data.meta case final meta?)
                    Text(
                      meta,
                      style: text.caption.copyWith(color: colors.textSecondary),
                    ),
                ],
              ),
            ),
            if (data.canEdit) ...[
              const SizedBox(width: AppSpacing.s12),
              if (student != null)
                Semantics(
                  button: true,
                  enabled: data.canEditNow,
                  label: l10n.coachStudentProfile_programEditA11y(
                    TurkishSuffix.genitive(student.firstName),
                  ),
                  excludeSemantics: true,
                  onTap: data.canEditNow ? viewModel.startEditing : null,
                  child: edit,
                )
              else
                edit,
            ],
          ],
        ),
      ),
    );
  }
}

/// Edit mode of the Program tab (pano 14.1 kare 3): the program's large title,
/// its motto and its dates, as in the program screen's own edit mode. The
/// profile's header and tabs are gone and its bar holds "Bitti".
class _EmbeddedEditHeader
    extends SelectorViewModelWidget<ProgramDetailViewModel, bool> {
  const _EmbeddedEditHeader();

  @override
  bool selector(ProgramDetailViewModel viewModel) => viewModel.editing;

  @override
  Widget build(BuildContext context, bool editing) => editing
      ? const _DetailHeader()
      : const SliverToBoxAdapter(child: SizedBox.shrink());
}

/// The program as a skeleton in the tab (pano 14.3 kare 1).
class _EmbeddedLoading
    extends SelectorViewModelWidget<ProgramDetailViewModel, SectionState> {
  const _EmbeddedLoading();

  @override
  SectionState selector(ProgramDetailViewModel viewModel) =>
      viewModel.section.state;

  @override
  Widget build(BuildContext context, SectionState state) =>
      state == SectionState.loading
      ? const SliverToBoxAdapter(child: ProgramSectionSkeleton())
      : const SliverToBoxAdapter(child: SizedBox.shrink());
}

/// The program could not be loaded (pano 14.3 kare 2): the section error
/// "Programlar yüklenemedi" / "Bağlantını kontrol edip tekrar dene." with
/// "Tekrar Dene"; the bar, the strip and the tabs of the profile stay.
class _EmbeddedError
    extends SelectorViewModelWidget<ProgramDetailViewModel, SectionState> {
  const _EmbeddedError();

  @override
  SectionState selector(ProgramDetailViewModel viewModel) =>
      viewModel.section.state;

  @override
  Widget build(BuildContext context, SectionState state) {
    if (state != SectionState.error && state != SectionState.offline) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ProgramDetailViewModel>(
      context,
      listen: false,
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppErrorState.section(
          title: l10n.coachStudentProfile_programLoadErrorTitle,
          message: l10n.coachStudentProfile_programLoadErrorBody,
          onRetry: viewModel.retry,
        ),
      ),
    );
  }
}
