part of '../contracts_view.dart';

/// The body of Sözleşmeler: the skeleton, the card of rows, the empty or the
/// error state, by the list's state.
class _ContractsBody
    extends
        SelectorViewModelWidget<
          ContractsViewModel,
          AsyncSection<List<LegalEntry>>
        > {
  const _ContractsBody();

  @override
  AsyncSection<List<LegalEntry>> selector(ContractsViewModel viewModel) =>
      viewModel.contracts;

  @override
  Widget build(BuildContext context, AsyncSection<List<LegalEntry>> section) {
    return switch (section.state) {
      SectionState.loading => const _ContractsSkeleton(),
      SectionState.ready => _ContractsList(entries: section.data!),
      SectionState.empty => const _ContractsEmpty(),
      SectionState.error || SectionState.offline => const _ContractsError(),
    };
  }
}

/// The card of rows (pano 9.7 kare 1): the file icon, the name, the version
/// and an arrow, and the note under the card. 8 under the title (the content
/// starts at 158).
class _ContractsList extends StatelessWidget {
  const _ContractsList({required this.entries});

  final List<LegalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ContractsViewModel>(
      context,
      listen: false,
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s8,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppRowGroup(
          footer: l10n.account_contractsFooter,
          children: [
            for (final entry in entries)
              AppRow(
                key: ValueKey(entry.key),
                icon: PhosphorIconsRegular.fileText,
                title: legalEntryTitle(l10n, entry),
                subtitle: legalEntryVersion(l10n, entry),
                onTap: () => unawaited(viewModel.open(entry)),
              ),
          ],
        ),
      ),
    );
  }
}
