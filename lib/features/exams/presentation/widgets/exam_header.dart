import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/presentation/widgets/dyb_counter.dart';
import 'package:smap/features/exams/presentation/widgets/exam_cover.dart';
import 'package:smap/features/exams/presentation/widgets/exam_score_card.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/controls/app_tag.dart';
import 'package:smap/shared/ui/text/delta_text.dart';

/// The two looks of the exam header.
enum ExamHeaderVariant {
  /// The top of "Deneme Detay" (screen 5.3).
  detail,

  /// The result moment right after a read (screen 5.1).
  moment,
}

/// The exam header (C26 "ExamHeader"; pano 5.3 "Deneme Detay · Genel" and 5.1
/// "Sonuç Anı").
///
/// **[ExamHeader.detail]** (5.3): the 48 x 64 [ExamCover]; the publisher 13 ·
/// 600 `textSecondary`; the exam name 20/28 · 700; under it, 4 apart, the type
/// tag and the long date 13 ("5 Ekim 2026"); then the net 40/48 · 800 · −1
/// with "net" 17/24 · 600 `textSecondary` (8 apart); the large D/Y/B counter;
/// and, when the data has them, the [ExamScoreCard]. Fields without data
/// (publisher, score, rank) are not drawn.
///
/// **[ExamHeader.moment]** (5.1): the 56 x 76 cover with radius 8; the
/// publisher; the name 17/24 · 700; the tag and date 6 below; the net at
/// metric-xl 56/64 · 800 · −1,5 with "net" 17/24 · 600; the change in the
/// result size (15/24 · 700 `delta` with ArrowUp 18, "önceki AYT denemene
/// göre") when there is a previous exam of the type; the large counter. The
/// content rises 8 pt while fading in over 250 ms (a plain fade under
/// "Reduce motion"); the success haptic is played once by the screen, not
/// here. The whole moment is read as one sentence (a heading): "Türkiye Geneli Deneme 6,
/// 67,5 net, 86 doğru, 74 yanlış, 0 boş, önceki sınava göre +8,25".
///
/// The collapse of the large title into the short bar when the page scrolls
/// belongs to the detail bar, not to this widget.
class ExamHeader extends StatelessWidget {
  const ExamHeader.detail({
    required this.name,
    required this.typeLabel,
    this.net,
    this.counts,
    this.date,
    this.publisher,
    this.coverUrl,
    this.scoreFieldName,
    this.score,
    this.rank,
    this.scoreHam,
    this.rankHam,
    super.key,
  }) : variant = ExamHeaderVariant.detail,
       delta = null,
       animateIn = false;

  const ExamHeader.moment({
    required this.name,
    required double this.net,
    required DybCounts this.counts,
    required DateTime this.date,
    required this.typeLabel,
    this.publisher,
    this.coverUrl,
    this.delta,
    this.animateIn = true,
    super.key,
  }) : variant = ExamHeaderVariant.moment,
       scoreFieldName = null,
       score = null,
       rank = null,
       scoreHam = null,
       rankHam = null;

  final ExamHeaderVariant variant;
  final String name;

  /// The net from the server; null (detail only) draws no net.
  final double? net;

  /// Null (detail only) draws no counter.
  final DybCounts? counts;

  /// Null (detail only) draws no date.
  final DateTime? date;

  /// "TYT" or "AYT".
  final String typeLabel;
  final String? publisher;
  final String? coverUrl;

  /// Detail: the field the score belongs to ("Eşit Ağırlık").
  final String? scoreFieldName;

  /// Detail: the placement score; null draws no score column.
  final double? score;

  /// Detail: the rank; null draws no rank column.
  final int? rank;

  /// Detail: the raw points ("Ham puan", Tur 12 B); null draws no raw row.
  final double? scoreHam;

  /// Detail: the rank of the raw points.
  final int? rankHam;

  /// Moment: the net change against the previous exam of the type.
  final double? delta;

  /// Moment: rise and fade in on first show.
  final bool animateIn;

  bool get _isMoment => variant == ExamHeaderVariant.moment;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final netValue = net;
    final netText = netValue == null ? null : TrFormat.net(netValue);
    final countValues = counts;
    final day = date;
    final publisherName = publisher;
    final fieldName = scoreFieldName;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isMoment
                ? ExamCover.moment(url: coverUrl)
                : ExamCover.header(url: coverUrl),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (publisherName != null)
                    Text(
                      publisherName,
                      style: text.caption.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  // The screen's title: its own heading node for the detail
                  // header (the moment is one sentence, a heading itself).
                  Semantics(
                    header: !_isMoment,
                    container: !_isMoment,
                    child: Text(
                      name,
                      style: (_isMoment ? text.headline : text.titleMd)
                          .copyWith(color: colors.textPrimary),
                    ),
                  ),
                  SizedBox(height: _isMoment ? 6 : AppSpacing.s4),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (typeLabel.isNotEmpty) AppTag(label: typeLabel),
                      if (day != null)
                        Text(
                          TrFormat.uzunTarih(day),
                          style: text.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (netText != null) ...[
          SizedBox(height: _isMoment ? AppSpacing.s24 : AppSpacing.s12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                netText,
                style: (_isMoment ? text.metricXl : text.metricLg).copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                l10n.exams_netUnit,
                style: text.metricSm.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
        if (_isMoment && delta != null) ...[
          const SizedBox(height: AppSpacing.s4),
          DeltaText(
            value: delta,
            size: DeltaTextSize.result,
            suffix: l10n.exams_deltaVsPreviousMoment(typeLabel),
          ),
        ],
        if (countValues != null) ...[
          SizedBox(height: _isMoment ? AppSpacing.s24 : AppSpacing.s16),
          DybCounter(counts: countValues, size: DybCounterSize.large),
        ],
        if (!_isMoment &&
            fieldName != null &&
            (score != null ||
                rank != null ||
                scoreHam != null ||
                rankHam != null))
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s16),
            child: ExamScoreCard(
              fieldName: fieldName,
              score: score,
              rank: rank,
              scoreHam: scoreHam,
              rankHam: rankHam,
            ),
          ),
      ],
    );

    if (!_isMoment) return body;
    final change = delta;
    final summary = countValues!;
    return Semantics(
      container: true,
      header: true,
      label: change == null
          ? l10n.exams_momentA11y(
              name,
              netText!,
              summary.correct,
              summary.wrong,
              summary.blank,
            )
          : l10n.exams_momentWithDeltaA11y(
              name,
              netText!,
              summary.correct,
              summary.wrong,
              summary.blank,
              TrFormat.delta(change),
            ),
      excludeSemantics: true,
      child: animateIn ? _RiseIn(child: body) : body,
    );
  }
}

/// Rises 8 pt while fading in over 250 ms (a plain fade under "Reduce
/// motion"): the entrance of the result moment.
class _RiseIn extends StatelessWidget {
  const _RiseIn({required this.child});

  final Widget child;

  /// How far the content travels.
  static const double _rise = AppSpacing.s8;

  @override
  Widget build(BuildContext context) {
    final reduce = context.reduceMotion;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: context.motion(AppMotion.base, reduced: AppMotion.reducedFade),
      curve: AppMotion.enter,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, reduce ? 0 : (1 - t) * _rise),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
