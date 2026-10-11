part of '../new_program_view.dart';

/// Step 3 (pano 3.5 kare 4): "Program adı" and "Motto (isteğe bağlı)" with
/// "Program listesinde adın altında görünür." under it, then the summary
/// card. The page owns the text controllers (the ViewModel holds none); the
/// name starts as the suggestion ("Ekim 3. Hafta").
class _NameStep extends StatefulWidget {
  const _NameStep();

  @override
  State<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<_NameStep> {
  late final TextEditingController _name;
  late final TextEditingController _motto;

  @override
  void initState() {
    super.initState();
    final viewModel = getParentViewModel<NewProgramViewModel>(
      context,
      listen: false,
    );
    _name = TextEditingController(text: viewModel.name);
    _motto = TextEditingController(text: viewModel.motto);
  }

  @override
  void dispose() {
    _name.dispose();
    _motto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        AppSpacing.s24,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NameFields(name: _name, motto: _motto),
            const SizedBox(height: AppSpacing.s24),
            const _SummaryCard(),
          ],
        ),
      ),
    );
  }
}

/// The two fields; the name shows "Programına bir ad ver." after a save with
/// no name.
class _NameFields extends SelectorViewModelWidget<NewProgramViewModel, bool> {
  const _NameFields({required this.name, required this.motto});

  final TextEditingController name;
  final TextEditingController motto;

  /// The motto label sits 20 below the name field (pano 3.5 kare 4).
  static const double _gap = 20;

  @override
  bool selector(NewProgramViewModel viewModel) => viewModel.nameError;

  @override
  Widget build(BuildContext context, bool nameError) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<NewProgramViewModel>(
      context,
      listen: false,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: l10n.schedule_fieldName,
          controller: name,
          errorText: nameError ? l10n.schedule_nameRequired : null,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.sentences,
          onChanged: viewModel.setName,
        ),
        const SizedBox(height: _gap),
        AppTextField(
          label: l10n.schedule_fieldMotto,
          optional: true,
          controller: motto,
          helperText: l10n.schedule_mottoHelp,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          onChanged: viewModel.setMotto,
        ),
      ],
    );
  }
}

/// The summary card (pano 3.5 kare 4): "Günler · 12–17 Ekim 2026 · 6 gün" and
/// "Çalışmalar · 3 çalışma, hepsi Pazartesi" with "Salı–Cumartesi henüz boş;
/// kaydettikten sonra ekleyebilirsin." under it. Built from what the student
/// chose, never from a sample.
class _SummaryCard
    extends SelectorViewModelWidget<NewProgramViewModel, NewProgramSummary> {
  const _SummaryCard();

  @override
  NewProgramSummary selector(NewProgramViewModel viewModel) =>
      viewModel.summary;

  @override
  Widget build(BuildContext context, NewProgramSummary summary) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final count = TrFormat.sira(summary.studyCount);
    final only = summary.onlyDay;
    final usedDays = summary.dayCount - summary.emptyDays.length;
    final studies = only != null
        ? l10n.schedule_summaryStudiesOneDay(count, TrFormat.gunAdi(only))
        : l10n.schedule_summaryStudiesSpread(count, TrFormat.sira(usedDays));

    Widget row(String label, String value, {String? note}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.caption.copyWith(color: colors.textSecondary)),
        Text(value, style: text.bodyStrong.copyWith(color: colors.textPrimary)),
        if (note != null) ...[
          const SizedBox(height: AppSpacing.s4),
          Text(note, style: text.caption.copyWith(color: colors.textSecondary)),
        ],
      ],
    );

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            l10n.schedule_summaryDays,
            l10n.schedule_summaryDaysValue(
              summary.range,
              TrFormat.sira(summary.dayCount),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
            child: Divider(height: 1, thickness: 1, color: colors.bgSunken),
          ),
          row(
            l10n.schedule_summaryStudies,
            studies,
            note: summary.emptyDays.isEmpty
                ? null
                : l10n.schedule_summaryEmptyDays(
                    DayRunsLabel.of(summary.emptyDays),
                  ),
          ),
        ],
      ),
    );
  }
}
