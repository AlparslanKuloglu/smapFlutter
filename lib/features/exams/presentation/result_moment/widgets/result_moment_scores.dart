part of '../result_moment_view.dart';

/// What the score area selects: the screen state, the moment and the chosen
/// score type.
typedef _ScoresData = (SectionState, ResultMomentModel?, AytField?);

/// The space between the counter and the score area, and between the score
/// area's parts (pano 5.1 kare 1: counter ends y=382, segment y=404, boxes
/// y=464, field net y=564).
const double _afterCounter = 22;
const double _afterSegment = AppSpacing.s12;
const double _afterBoxes = AppSpacing.s16;

/// The "Puan türü" segment, the two score boxes and the field's net (pano 5.1
/// kare 1), each only when the data has it.
///
/// - **Segment** (`.seg`, "Puan türü"): "Eşit Ağırlık" · "Sayısal" · "Sözel",
///   drawn for an AYT result that has a score type with data; it opens on the
///   student's own field. A TYT result has none (kare 2).
/// - **Boxes** (`StatBox`, 2 columns, 8 apart): "412,63" "Yerleştirme puanı"
///   and "48.215." "Sıra"; a box whose value is missing is left out, and with
///   neither the row is not drawn. A TYT result with points shows them too.
/// - **Field net**: "Eşit Ağırlık neti 40" 15/24 · 700 over "Türk Dili ve
///   Edebiyatı–Sosyal Bilimler 1 ve Matematik" 13/20 `textSecondary`, drawn
///   when the field's net is in `aytNets`.
///
/// Choosing another score type swaps only the boxes and the net. The raw
/// points are not here ("5.1 sonuç anına ham puan eklenmez", Tur 12 B).
class _MomentScoresSection
    extends SelectorViewModelWidget<ResultMomentViewModel, _ScoresData> {
  const _MomentScoresSection();

  @override
  _ScoresData selector(ResultMomentViewModel viewModel) =>
      (viewModel.screenState, viewModel.model, viewModel.selectedField);

  @override
  Widget build(BuildContext context, _ScoresData data) {
    final (state, model, selected) = data;
    if (state != SectionState.ready || model == null) return _noSliver;
    final score = model.scoreFor(selected);
    final showSegment = model.hasFieldSegment;
    final fieldNet = selected == null ? null : score.fieldNet;
    if (!showSegment && !score.hasBoxes && fieldNet == null) return _noSliver;

    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ResultMomentViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          _afterCounter,
          AppSpacing.gutter,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showSegment) ...[
              Semantics(
                container: true,
                label: l10n.resultMoment_fieldA11y,
                child: AppSegmented<AytField>(
                  segments: [
                    for (final field in AytField.values)
                      AppSegment(value: field, label: _fieldName(l10n, field)),
                  ],
                  value: selected ?? AytField.equalWeight,
                  onChanged: viewModel.selectField,
                ),
              ),
              const SizedBox(height: _afterSegment),
            ],
            if (score.hasBoxes) ...[
              _ScoreBoxes(score: score),
              const SizedBox(height: _afterBoxes),
            ],
            if (fieldNet != null) _FieldNet(field: selected!, net: fieldNet),
          ],
        ),
      ),
    );
  }
}

/// "412,63 · Yerleştirme puanı" and "48.215. · Sıra": two `StatBox`es, 8 apart;
/// a missing value leaves its column empty so the grid stays put.
class _ScoreBoxes extends StatelessWidget {
  const _ScoreBoxes({required this.score});

  final MomentScore score;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final point = score.point;
    final rank = score.rank;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppStatBox(
            label: l10n.exams_placementScore,
            value: point == null ? null : TrFormat.puan(point),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: AppStatBox(
            label: l10n.exams_rank,
            value: rank == null ? null : TrFormat.siraOrdinal(rank),
          ),
        ),
      ],
    );
  }
}

/// "Eşit Ağırlık neti 40" with the tests it is made of under it (pano 5.1
/// kare 1; Ek C).
class _FieldNet extends StatelessWidget {
  const _FieldNet({required this.field, required this.net});

  final AytField field;
  final double net;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final tests = momentFieldTests(field);
    final names = [
      for (final (index, label) in tests.indexed)
        examTestName(l10n, label, index),
    ];
    final title = l10n.resultMoment_fieldNet(
      _fieldName(l10n, field),
      TrFormat.net(net),
    );
    final composition = names.length == 2
        ? l10n.resultMoment_fieldTests(names[0], names[1])
        : names.join(', ');
    return Semantics(
      container: true,
      label: '$title, $composition',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text.bodyStrong.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            composition,
            style: text.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
