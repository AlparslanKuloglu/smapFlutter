part of '../answer_fix_sheet.dart';

/// The corrections list (pano 4.7 kare 2 and 3): a hairline, "Düzeltmeler"
/// (17/24 · 700) and either "Henüz düzeltme yok. Okunan cevap formundakinden
/// farklıysa yukarıdan ekle." (15/24, `textSecondary`) or one row per
/// correction, newest first. A new row slides in from the top in 250 ms (a
/// fade under "reduce motion").
class _FixCorrections extends StatelessWidget {
  const _FixCorrections({required this.viewModel});

  final AnswerFixSheetViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final items = viewModel.corrections.items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(
          color: colors.borderSubtle,
          child: const SizedBox(height: 1),
        ),
        const SizedBox(height: AppSpacing.s16),
        Semantics(
          header: true,
          child: Text(
            l10n.scan_corrections,
            style: text.headline.copyWith(color: colors.textPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s16),
            child: Text(
              l10n.scan_correctionsEmpty,
              style: text.body.copyWith(color: colors.textSecondary),
            ),
          )
        else
          for (final item in items)
            _CorrectionRow(
              key: ValueKey(item.cell),
              correction: item,
              onRemove: () => viewModel.remove(item.cell),
            ),
      ],
    );
  }
}

/// One correction: "3. kolon · 12. soru" (15/24 · 600), "Boş → C" (15/24) and
/// the 48 pt X ("Düzeltmeyi kaldır: 3. kolon, 12. soru"); 56 high, a hairline
/// above.
class _CorrectionRow extends StatelessWidget {
  const _CorrectionRow({
    required this.correction,
    required this.onRemove,
    super.key,
  });

  final AnswerCorrection correction;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final col = TrFormat.sira(correction.cell.column);
    final q = TrFormat.sira(correction.cell.question);
    final from = _name(l10n, correction.from);
    final to = _name(l10n, correction.to);
    final row = DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSize.rowMin),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.scan_correctionRow(col, q),
                style: text.bodyStrong.copyWith(color: colors.textPrimary),
              ),
            ),
            Text(
              l10n.scan_correctionChange(from, to),
              style: text.body.copyWith(color: colors.textPrimary),
            ),
            AppIconButton(
              icon: PhosphorIconsRegular.x,
              iconSize: 20,
              semanticLabel: l10n.scan_removeCorrectionA11y(col, q),
              focusGapColor: colors.bgRaised,
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
    return _SlideIn(child: row);
  }

  static String _name(AppLocalizations l10n, AnswerChoice choice) =>
      choice == AnswerChoice.blank ? l10n.scan_blank : choice.legacyValue;
}

/// Grows its child in from the top over 250 ms when it first appears.
class _SlideIn extends StatelessWidget {
  const _SlideIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = context.motion(AppMotion.base, reduced: AppMotion.fast);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: AppMotion.enter,
      builder: (context, t, child) => ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: context.reduceMotion ? 1 : t,
          child: Opacity(opacity: t, child: child),
        ),
      ),
      child: child,
    );
  }
}
