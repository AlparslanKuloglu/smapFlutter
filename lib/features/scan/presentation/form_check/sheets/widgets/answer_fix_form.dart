part of '../answer_fix_sheet.dart';

/// The form of the fix sheet (pano 4.7 kare 2): column, question, option and
/// the primary "Düzeltmeyi Ekle", 16 apart.
class _FixForm extends StatelessWidget {
  const _FixForm({required this.viewModel});

  final AnswerFixSheetViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = viewModel.draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(l10n.scan_fieldColumn),
        const SizedBox(height: AppSpacing.s8),
        AppSegmented<int>(
          segments: [
            for (var c = 1; c <= draft.grid.columnCount; c++)
              AppSegment<int>(
                value: c,
                label: l10n.scan_columnN(TrFormat.sira(c)),
              ),
          ],
          value: draft.column,
          onChanged: viewModel.selectColumn,
        ),
        const SizedBox(height: AppSpacing.s16),
        _FieldLabel(l10n.scan_fieldQuestion),
        const SizedBox(height: AppSpacing.s8),
        _QuestionStepper(viewModel: viewModel),
        const SizedBox(height: AppSpacing.s16),
        _FieldLabel(l10n.scan_yourMark),
        const SizedBox(height: AppSpacing.s8),
        _ChoiceChips(viewModel: viewModel),
        const SizedBox(height: AppSpacing.s16),
        AppButton(
          label: l10n.scan_addCorrection,
          expand: true,
          focusGapColor: context.appColors.bgRaised,
          onPressed: draft.canAdd ? viewModel.add : null,
        ),
      ],
    );
  }
}

/// A field's name above it (14/20 · 600).
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: context.appText.labelMd.copyWith(
      color: context.appColors.textPrimary,
    ),
  );
}

/// The question stepper (pano 4.7 kare 2): a quiet 48 minus ("Önceki soru"),
/// an 88 pt box with the number (700, centered; read as a spin button:
/// "Soru numarası"), a quiet 48 plus ("Sonraki soru"), and at the right "Okunan"
/// (13/20) over the value the reader found: a grey disc with a dash and "Boş",
/// or the letter.
class _QuestionStepper extends StatelessWidget {
  const _QuestionStepper({required this.viewModel});

  final AnswerFixSheetViewModel viewModel;

  static const double _box = 88;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final draft = viewModel.draft;
    return Row(
      children: [
        _StepButton(
          icon: PhosphorIconsRegular.minus,
          label: l10n.scan_previousQuestionA11y,
          onPressed: draft.hasPrevious ? () => viewModel.step(-1) : null,
        ),
        const SizedBox(width: AppSpacing.s8),
        Semantics(
          label: l10n.scan_questionNumberA11y,
          value: '${draft.question}',
          increasedValue: draft.hasNext ? '${draft.question + 1}' : null,
          decreasedValue: draft.hasPrevious ? '${draft.question - 1}' : null,
          onIncrease: draft.hasNext ? () => viewModel.step(1) : null,
          onDecrease: draft.hasPrevious ? () => viewModel.step(-1) : null,
          excludeSemantics: true,
          child: SizedBox(
            width: _box,
            height: AppSize.input,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.bgSurface,
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: colors.borderControl),
              ),
              child: Center(
                child: Text(
                  TrFormat.sira(draft.question),
                  style: text.titleSm.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        _StepButton(
          icon: PhosphorIconsRegular.plus,
          label: l10n.scan_nextQuestionA11y,
          onPressed: draft.hasNext ? () => viewModel.step(1) : null,
        ),
        const SizedBox(width: AppSpacing.s16),
        Expanded(child: _ReadValue(read: draft.read)),
      ],
    );
  }
}

/// The 48 x 48 quiet button of the stepper: `bgSunken`, radius 12.
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: AppPressable(
        onTap: onPressed,
        builder: (context, states) => AppFocusRing(
          focused: states.contains(WidgetState.focused),
          gapColor: colors.bgRaised,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.bgSunken,
              borderRadius: AppRadius.borderMd,
            ),
            child: SizedBox.square(
              dimension: AppSize.touch,
              child: Center(
                child: PhosphorIcon(
                  icon,
                  size: AppSize.icon - 4,
                  color: onPressed == null
                      ? colors.textDisabled
                      : colors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Okunan" and what the reader found in the cell (pano 4.7 kare 2).
class _ReadValue extends StatelessWidget {
  const _ReadValue({required this.read});

  final AnswerChoice read;

  static const double _disc = 20;
  static const double _glyph = 12;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.scan_readValue,
          style: text.caption.copyWith(color: colors.textSecondary),
        ),
        Row(
          children: [
            if (read == AnswerChoice.blank) ...[
              ExcludeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.dybBlank,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: _disc,
                    child: Center(
                      child: PhosphorIcon(
                        PhosphorIconsBold.minus,
                        size: _glyph,
                        color: colors.dybOn,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
            ],
            Flexible(
              child: Text(
                read == AnswerChoice.blank ? l10n.scan_blank : read.legacyValue,
                style: text.bodyStrong.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The option chips (pano 4.7 kare 2): A to E as 48 x 48 squares and "Boş" 64
/// wide; the picked one is navy. Picking plays `selectionClick` (the chip
/// does).
class _ChoiceChips extends StatelessWidget {
  const _ChoiceChips({required this.viewModel});

  final AnswerFixSheetViewModel viewModel;

  /// The "Boş" chip's width.
  static const double _blankWidth = 64;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final picked = viewModel.draft.choice;
    final gap = context.appColors.bgRaised;
    return Wrap(
      spacing: AppSpacing.s8,
      runSpacing: AppSpacing.s8,
      children: [
        for (final choice in AnswerChoice.letters)
          AppChip.square(
            label: choice.legacyValue,
            selected: picked == choice,
            focusGapColor: gap,
            onTap: () => viewModel.pick(choice),
          ),
        AppChip.square(
          label: l10n.scan_blank,
          width: _blankWidth,
          selected: picked == AnswerChoice.blank,
          focusGapColor: gap,
          onTap: () => viewModel.pick(AnswerChoice.blank),
        ),
      ],
    );
  }
}
