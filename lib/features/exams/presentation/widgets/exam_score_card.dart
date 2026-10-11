import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

/// The score block of the exam detail header (C26 "ExamHeader", "Puan kartı";
/// pano 5.3 kare 1 "Eşit Ağırlık · 412,63 · 48.215.").
///
/// A `bgSurface` card, radius 16, padding 12 / 16. The field name ("Eşit
/// Ağırlık") 13 · 600 `textSecondary` on top; under it up to two columns, 12
/// apart: the placement score 24/32 · 700 · −0,4 over "Yerleştirme puanı"
/// 13 · 600, and the rank written "48.215." over "Sıra". A column whose value
/// the data does not have is not drawn, and with neither value the whole card
/// is not drawn.
class ExamScoreCard extends StatelessWidget {
  const ExamScoreCard({
    required this.fieldName,
    this.score,
    this.rank,
    super.key,
  });

  /// The field the score belongs to ("Eşit Ağırlık").
  final String fieldName;

  /// The placement score `412,63`; null when the data has none.
  final double? score;

  /// The rank `48.215`; null when the data has none.
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final points = score;
    final place = rank;
    if (points == null && place == null) return const SizedBox.shrink();
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldName,
            style: text.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (points != null)
                Expanded(
                  child: _ScoreColumn(
                    value: TrFormat.puan(points),
                    label: l10n.exams_placementScore,
                  ),
                ),
              if (points != null && place != null)
                const SizedBox(width: AppSpacing.s12),
              if (place != null)
                Expanded(
                  child: _ScoreColumn(
                    value: TrFormat.siraOrdinal(place),
                    label: l10n.exams_rank,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  const _ScoreColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return Semantics(
      label: AppLocalizations.of(context).exams_scoreColumnA11y(label, value),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: text.metricMd.copyWith(color: colors.textPrimary)),
          Text(
            label,
            style: text.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
