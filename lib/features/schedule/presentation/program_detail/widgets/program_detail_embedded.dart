part of '../program_detail_view.dart';

/// The slices of the Program tab of a coach's student profile (Tur 12 A,
/// brief 14.1 kare 1): the title row, "Gün | Hafta", the day strip, the day's
/// topics and "Günü Sıfırla", then the Hafta grid. The bar, the context strip
/// and the large title of [ProgramDetailView] are the profile's.
class _ProgramDetailSlivers extends StatelessWidget {
  const _ProgramDetailSlivers();

  @override
  Widget build(BuildContext context) => const SliverMainAxisGroup(
    slivers: [
      _EmbeddedHeader(),
      _DetailSegment(),
      _DetailLoading(),
      _EmbeddedError(),
      _DayStrip(),
      _DayHeading(),
      _DayList(),
      _DayActions(),
      _WeekSection(),
    ],
  );
}

typedef _EmbeddedHeaderData = ({
  SectionState state,
  String name,
  String? meta,
  bool editing,
  bool canEditNow,
});

/// The program's title row (brief 14.1 kare 1): "Ekim 2. Hafta" (17/24 ·
/// 700) with the inline "Düzenle" at the right, which becomes "Bitti" in edit
/// mode (every change is saved at once; "Bitti" only closes the mode), and
/// under it "Her gün biraz daha · 5–11 Ekim 2026". Off without a connection.
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
      canEditNow: viewModel.canEditNow,
    );
  }

  @override
  Widget build(BuildContext context, _EmbeddedHeaderData data) {
    if (data.state != SectionState.ready) {
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
    final action = data.editing
        ? AppButton(
            label: l10n.schedule_done,
            icon: PhosphorIconsRegular.check,
            variant: AppButtonVariant.text,
            size: AppButtonSize.md40,
            onPressed: viewModel.finishEditing,
          )
        : AppButton(
            label: l10n.schedule_edit,
            icon: PhosphorIconsRegular.pencilSimple,
            variant: AppButtonVariant.text,
            size: AppButtonSize.md40,
            onPressed: data.canEditNow ? viewModel.startEditing : null,
          );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter - AppSpacing.s12,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      data.name,
                      style: text.headline.copyWith(color: colors.textPrimary),
                    ),
                  ),
                ),
                if (student != null && !data.editing)
                  Semantics(
                    button: true,
                    enabled: data.canEditNow,
                    label: l10n.coachStudentProfile_programEditA11y(
                      TurkishSuffix.genitive(student.firstName),
                    ),
                    excludeSemantics: true,
                    onTap: data.canEditNow ? viewModel.startEditing : null,
                    child: action,
                  )
                else
                  action,
              ],
            ),
            if (data.meta case final meta?)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s12),
                child: Text(
                  meta,
                  style: text.caption.copyWith(color: colors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The program could not be loaded (brief 14.3 kare 2): a section error
/// "Programlar yüklenemedi. Bağlantını kontrol edip tekrar dene." with "Tekrar
/// Dene"; the bar, the strip and the tabs of the profile stay.
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
          message: AppLocalizations.of(
            context,
          ).coachStudentProfile_programLoadError,
          onRetry: viewModel.retry,
        ),
      ),
    );
  }
}
