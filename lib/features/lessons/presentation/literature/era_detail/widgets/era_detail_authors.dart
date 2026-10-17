part of '../era_detail_view.dart';

/// The inside of an accordion (pano 14.5 kare 2 and 3, 14.7 kare 2): a rule
/// under the header, then the skeleton, the author rows (C28), the sentence
/// "Bu bölümde yazar yok." or the error. Only this accordion is affected by a
/// failure.
class _SubAuthors
    extends SelectorViewModelWidget<EraDetailViewModel, SubAuthorsData> {
  const _SubAuthors({required this.subId});

  final String subId;

  @override
  SubAuthorsData selector(EraDetailViewModel viewModel) =>
      viewModel.subAuthors(subId);

  @override
  Widget build(BuildContext context, SubAuthorsData data) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, thickness: 1, color: colors.bgSunken),
        switch (data.state) {
          SectionState.loading => const _AuthorsSkeleton(),
          SectionState.ready => _AuthorRows(subId: subId, rows: data.rows),
          SectionState.empty => const _NoAuthors(),
          SectionState.error ||
          SectionState.offline => _AuthorsError(subId: subId),
        },
      ],
    );
  }
}

/// The author rows with a rule between two of them.
class _AuthorRows extends StatelessWidget {
  const _AuthorRows({required this.subId, required this.rows});

  final String subId;
  final List<AuthorRowData> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final viewModel = getParentViewModel<EraDetailViewModel>(
      context,
      listen: false,
    );
    if (rows.isEmpty) return const _NoAuthors();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, row) in rows.indexed) ...[
          if (index > 0)
            Divider(height: 1, thickness: 1, color: colors.bgSunken),
          AuthorRow(
            key: ValueKey(row.key),
            name: row.name,
            workCount: row.workCount,
            missing: row.missing,
            photo: row.photo,
            onTap: () => viewModel.openAuthor(subId, row.key),
          ),
        ],
      ],
    );
  }
}

/// Three skeleton rows while the authors load: a 48 pt round photo and two
/// lines (pano 14.5 kare 3); 15 s at most, then the error.
class _AuthorsSkeleton extends StatelessWidget {
  const _AuthorsSkeleton();

  /// The widths of the name lines.
  static const List<double> _nameWidths = [140, 190, 110];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: AppSkeleton(
        child: Column(
          children: [
            for (final width in _nameWidths)
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppSize.rowMinTwoLine,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s12,
                  ),
                  child: Row(
                    children: [
                      const SkeletonBox(width: 48, height: 48, circle: true),
                      const SizedBox(width: AppSpacing.s12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: width, height: 16),
                          const SizedBox(height: AppSpacing.s8),
                          const SkeletonBox(width: 56, height: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A sub-subject with no author: one sentence inside the accordion.
class _NoAuthors extends StatelessWidget {
  const _NoAuthors();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Text(
        AppLocalizations.of(context).literature_noAuthors,
        style: context.appText.body.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
    );
  }
}

/// The authors did not load (pano 14.7 kare 2): the warning icon, "Yazarlar
/// yüklenemedi." 15/24 · 600, "Bağlantını kontrol edip tekrar dene." 13/20
/// `textSecondary` and the text button "Tekrar Dene", inside the accordion.
class _AuthorsError extends StatelessWidget {
  const _AuthorsError({required this.subId});

  final String subId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<EraDetailViewModel>(
      context,
      listen: false,
    );
    return Semantics(
      container: true,
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s16,
          AppSpacing.s16,
          AppSpacing.s8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: PhosphorIcon(
                PhosphorIconsRegular.warningCircle,
                size: AppSize.iconInButton,
                color: colors.error,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.literature_authorsErrorTitle,
                    style: text.bodyStrong.copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    l10n.literature_authorsErrorBody,
                    style: text.caption.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Transform.translate(
                    offset: const Offset(-AppSpacing.s12, 0),
                    child: AppButton(
                      label: l10n.common_retry,
                      variant: AppButtonVariant.text,
                      size: AppButtonSize.md40,
                      onPressed: () => viewModel.retryAuthors(subId),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
