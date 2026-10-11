part of '../analytics_view.dart';

/// How the filter row shows: the pill with its count, the pill alone
/// (reloading), or nothing (first load, whose skeleton draws the pill itself;
/// an error; no exam at all).
enum _FilterRowMode { counted, bare, hidden }

typedef _FilterRowData = ({
  _FilterRowMode mode,
  AnalyticsFilter filter,
  int? count,
});

/// The Genel tab's filter row (pano 6.1 "Süzgeç satırı, iki uçta"): the pill
/// "TYT · Genel" with a caret, and "6 deneme" at the other end. The pill
/// opens the filter sheet (kare 3).
class _GeneralFilterRow
    extends SelectorViewModelWidget<AnalyticsViewModel, _FilterRowData> {
  const _GeneralFilterRow();

  @override
  _FilterRowData selector(AnalyticsViewModel viewModel) {
    final general = viewModel.general;
    final mode = switch (general.state) {
      SectionState.loading =>
        viewModel.generalSettled ? _FilterRowMode.bare : _FilterRowMode.hidden,
      SectionState.ready => _FilterRowMode.counted,
      SectionState.empty =>
        viewModel.noExamsAtAll || !viewModel.countsSettled
            ? _FilterRowMode.hidden
            : _FilterRowMode.bare,
      SectionState.error || SectionState.offline => _FilterRowMode.hidden,
    };
    return (
      mode: mode,
      filter: viewModel.filter,
      count: general.data?.examCount,
    );
  }

  @override
  Widget build(BuildContext context, _FilterRowData data) {
    if (data.mode == _FilterRowMode.hidden) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        _sectionGap,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: _FilterRow(filter: data.filter, count: data.count),
      ),
    );
  }
}

/// The pill and the count.
class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.filter, required this.count});

  final AnalyticsFilter filter;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final lesson = filter.lesson;
    final label = l10n.analytics_filterLabel(
      filter.exam.label,
      lesson == null
          ? l10n.analytics_filterGeneral
          : AnalyticsLessons.shortName(lesson),
    );
    final total = count;
    return Row(
      children: [
        Semantics(
          button: true,
          label: l10n.analytics_filterA11y(label),
          excludeSemantics: true,
          onTap: () => _openFilter(context),
          child: AppChip(
            label: label,
            size: AppChipSize.md40,
            trailingIcon: PhosphorIconsRegular.caretDown,
            onTap: () => _openFilter(context),
          ),
        ),
        if (total != null) ...[
          const Spacer(),
          Text(
            l10n.analytics_examCount(total),
            style: context.appText.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  /// Opens the sheet; a changed choice is applied with the selection haptic
  /// (pano 6.1 "Süzgeç değişince grafik 350 ms'de yeniden çizilir").
  Future<void> _openFilter(BuildContext context) async {
    final viewModel = getParentViewModel<AnalyticsViewModel>(
      context,
      listen: false,
    );
    final chosen = await AnalyticsFilterSheet.show(
      context,
      initial: viewModel.filter,
      userField: viewModel.userField,
    );
    if (chosen == null || chosen == viewModel.filter) return;
    AppHaptics.selection();
    viewModel.applyFilter(chosen);
  }
}
