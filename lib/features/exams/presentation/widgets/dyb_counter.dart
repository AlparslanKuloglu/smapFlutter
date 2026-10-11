import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/presentation/widgets/dyb_glyph.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The two sizes of the counter.
enum DybCounterSize {
  /// Three columns, chip 24 over the value 24/32 · 700: exam detail, result
  /// moment (always with the words "Doğru", "Yanlış", "Boş").
  large,

  /// One inline row of chip 16 + value 15/20 · 700 + letter or word.
  small,
}

/// What follows the value of a small counter.
enum DybCounterLabels {
  /// "D", "Y", "B": accordion header, exam row.
  letter,

  /// "doğru", "yanlış", "boş": where there is room, such as a topic row or
  /// the home screen's last exam.
  word,
}

/// The D/Y/B counter (C41 "DybLarge / DybSmall"; pano 1.14 "Büyük ve küçük
/// üçlü sayaç"; screens 5.1, 5.3, 3.1, 5.5; `DybCounter` in Tur 1).
///
/// The order is always Doğru, Yanlış, Boş, and Boş is shown even when it is
/// zero ("veri var, değeri sıfır"). The numbers are written in `textPrimary`;
/// the color lives only on the chip, and a letter or a word is always beside
/// it, so the counter reads in grayscale. The whole counter is read as one
/// sentence: "86 doğru, 74 yanlış, 0 boş".
///
/// [labels] only matters for [DybCounterSize.small]; the large counter always
/// writes the words.
class DybCounter extends StatelessWidget {
  const DybCounter({
    required this.counts,
    this.size = DybCounterSize.small,
    this.labels = DybCounterLabels.letter,
    super.key,
  });

  final DybCounts counts;
  final DybCounterSize size;
  final DybCounterLabels labels;

  /// Gap between the items of a small counter with letters (vertical 4 when
  /// it wraps).
  static const double _letterGap = 14;

  /// Gap between the items of a small counter with words.
  static const double _wordGap = 10;

  /// Gap between the three columns of the large counter.
  static const double _columnGap = AppSpacing.s12;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: l10n.exams_dybA11y(counts.correct, counts.wrong, counts.blank),
      excludeSemantics: true,
      child: switch (size) {
        DybCounterSize.large => _LargeCounter(counts: counts),
        DybCounterSize.small => _SmallCounter(counts: counts, labels: labels),
      },
    );
  }
}

class _LargeCounter extends StatelessWidget {
  const _LargeCounter({required this.counts});

  final DybCounts counts;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    String wordOf(DybKind kind) => switch (kind) {
      DybKind.correct => l10n.exams_dybCorrect,
      DybKind.wrong => l10n.exams_dybWrong,
      DybKind.blank => l10n.exams_dybBlank,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, kind) in DybKind.ordered.indexed) ...[
          if (i > 0) const SizedBox(width: DybCounter._columnGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DybGlyph(kind: kind, size: DybGlyphSize.regular),
                    const SizedBox(width: AppSpacing.s8),
                    Flexible(
                      child: Text(
                        wordOf(kind),
                        style: text.bodyStrong.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  TrFormat.sira(counts.of(kind)),
                  style: text.metricMd.copyWith(color: colors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SmallCounter extends StatelessWidget {
  const _SmallCounter({required this.counts, required this.labels});

  final DybCounts counts;
  final DybCounterLabels labels;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final word = labels == DybCounterLabels.word;
    String suffixOf(DybKind kind) => switch ((kind, word)) {
      (DybKind.correct, false) => l10n.exams_dybLetterCorrect,
      (DybKind.wrong, false) => l10n.exams_dybLetterWrong,
      (DybKind.blank, false) => l10n.exams_dybLetterBlank,
      (DybKind.correct, true) => l10n.exams_dybWordCorrect,
      (DybKind.wrong, true) => l10n.exams_dybWordWrong,
      (DybKind.blank, true) => l10n.exams_dybWordBlank,
    };
    final value = text.bodyStrong.copyWith(
      color: colors.textPrimary,
      fontWeight: FontWeight.w700,
      height: 20 / 15,
    );
    final suffix = text.caption.copyWith(color: colors.textSecondary);
    return Wrap(
      spacing: word ? DybCounter._wordGap : DybCounter._letterGap,
      runSpacing: AppSpacing.s4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final kind in DybKind.ordered)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DybGlyph(kind: kind),
              const SizedBox(width: AppSpacing.s4),
              Text(TrFormat.sira(counts.of(kind)), style: value),
              const SizedBox(width: AppSpacing.s4),
              Text(suffixOf(kind), style: suffix),
            ],
          ),
      ],
    );
  }
}
