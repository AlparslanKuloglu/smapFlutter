import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

/// The score block of the exam detail header (C26 "ExamHeader", "Puan kartı";
/// pano 14.4 kare 1 "Eşit Ağırlık · 412,63 · 48.215." — it replaces 5.3 kare 1).
///
/// One `bgSurface` card, radius 16, padding 12 / 16. The score type of the
/// student ("Eşit Ağırlık", "Sayısal", "Sözel"; "TYT" for a TYT exam) 13/20 ·
/// 600 `textSecondary` on top. The upper row: the placement score at
/// metric-md 24/32 over "Yerleştirme puanı" 13/20, and the rank written
/// "48.215." over "Sıra", two equal columns 12 apart. A hairline follows and
/// the lower row repeats the layout for the raw points at metric-sm 17/24 over
/// "Ham puan" and "52.904." over "Sıra" (T12.11). A column whose value the
/// data does not have is not drawn; with no raw value the hairline and the
/// lower row are not drawn; with no value at all the whole card is not drawn.
///
/// Each row is read as one group, "Yerleştirme puanı 412,63, sıra 48.215" and
/// "Ham puan 398,12, sıra 52.904" (the ordinal dot is not read). The height
/// with both rows is [fullHeight] (pano 14.4 kare 4: the skeleton's 163 pt).
class ExamScoreCard extends StatelessWidget {
  const ExamScoreCard({
    required this.fieldName,
    this.score,
    this.rank,
    this.scoreHam,
    this.rankHam,
    super.key,
  });

  /// The height of the card with both rows at text scale 1 (pano 14.4 kare 4
  /// draws its skeleton this tall).
  static const double fullHeight = 163;

  static const double _verticalPadding = AppSpacing.s12;
  static const double _titleGap = 2;
  static const double _dividerGap = 10;

  /// The score type the score belongs to ("Eşit Ağırlık").
  final String fieldName;

  /// The placement score `412,63`; null when the data has none.
  final double? score;

  /// The rank `48.215`; null when the data has none.
  final int? rank;

  /// The raw points `398,12` ("Ham puan"); null draws no raw points.
  final double? scoreHam;

  /// The rank of the raw points `52.904`; null draws none.
  final int? rankHam;

  /// The screen-reader sentence of one row: "Yerleştirme puanı 412,63, sıra
  /// 48.215". A missing value is left out; the rank is read without its dot.
  /// Null when the row has neither value.
  static String? rowSpeech(
    AppLocalizations l10n, {
    required String label,
    double? points,
    int? rank,
  }) {
    if (points != null && rank != null) {
      return l10n.exams_scoreRowA11y(
        label,
        TrFormat.puan(points),
        TrFormat.sira(rank),
      );
    }
    if (points != null) {
      return l10n.exams_scoreRowPointsA11y(label, TrFormat.puan(points));
    }
    if (rank != null) {
      return l10n.exams_scoreRowRankA11y(label, TrFormat.sira(rank));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasPlacement = score != null || rank != null;
    final hasRaw = scoreHam != null || rankHam != null;
    if (!hasPlacement && !hasRaw) return const SizedBox.shrink();
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: _verticalPadding,
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
          const SizedBox(height: _titleGap),
          if (hasPlacement)
            _ScoreRow(
              points: score,
              pointsLabel: l10n.exams_placementScore,
              rank: rank,
              emphasis: _ScoreEmphasis.placement,
            ),
          if (hasPlacement && hasRaw) ...[
            const SizedBox(height: _dividerGap),
            SizedBox(height: 1, child: ColoredBox(color: colors.borderSubtle)),
            const SizedBox(height: _dividerGap),
          ],
          if (hasRaw)
            _ScoreRow(
              points: scoreHam,
              pointsLabel: l10n.examDetail_rawScore,
              rank: rankHam,
              emphasis: _ScoreEmphasis.raw,
            ),
        ],
      ),
    );
  }
}

/// Which of the two sizes a row's values are written in.
enum _ScoreEmphasis {
  /// metric-md 24/32.
  placement,

  /// metric-sm 17/24 (T12.11).
  raw,
}

/// One row of the score card: the points over their label and the rank over
/// "Sıra"; a value the data lacks leaves its column out. Read as one group.
class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.points,
    required this.pointsLabel,
    required this.rank,
    required this.emphasis,
  });

  final double? points;
  final String pointsLabel;
  final int? rank;
  final _ScoreEmphasis emphasis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = points;
    final place = rank;
    return Semantics(
      container: true,
      label: ExamScoreCard.rowSpeech(
        l10n,
        label: pointsLabel,
        points: value,
        rank: place,
      ),
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (value != null)
            Expanded(
              child: _ScoreColumn(
                value: TrFormat.puan(value),
                label: pointsLabel,
                emphasis: emphasis,
              ),
            ),
          if (value != null && place != null)
            const SizedBox(width: AppSpacing.s12),
          if (place != null)
            Expanded(
              child: _ScoreColumn(
                value: TrFormat.siraOrdinal(place),
                label: l10n.exams_rank,
                emphasis: emphasis,
              ),
            ),
        ],
      ),
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  const _ScoreColumn({
    required this.value,
    required this.label,
    required this.emphasis,
  });

  final String value;
  final String label;
  final _ScoreEmphasis emphasis;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final valueStyle = switch (emphasis) {
      _ScoreEmphasis.placement => text.metricMd,
      _ScoreEmphasis.raw => text.metricSm,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: valueStyle.copyWith(color: colors.textPrimary)),
        Text(
          label,
          style: text.caption.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
