import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/presentation/widgets/dyb_counter.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';
import 'package:smap/shared/ui/text/delta_text.dart';

/// The "Son denemen" card of the home screen (C25 "ExamCard", summary
/// variant; pano 3.1 kare 1 and 2 "Son denemen"; the list form of the same
/// card is [ExamRow]).
///
/// Card padding 16. Top to bottom:
///
/// - the exam name 16/24 · 700 and the meta line 13 `textSecondary`
///   ("Örnek Yayınları · AYT · 5 Eki. 2026"; the publisher is left out when
///   the data has none, the name never carries "(Test)");
/// - 12 below, the net 40/48 · 800 · −1 with "net" 15/24 · 600
///   `textSecondary`, and beside it the change: ArrowUp 14 and "+8,25" 13/20 ·
///   700 in `delta`, then "önceki AYT'ye göre" in `textSecondary`. No change
///   is drawn without a previous exam of the same type;
/// - 8 below, the word counter "86 doğru · 74 yanlış · 0 boş";
/// - a 1 pt rule (16 above, 12 below), "En çok kaçırdığın konu" 13 · 700
///   `textSecondary` and the sentence from the server ("Kurtuluş Savaşı
///   Hazırlık Dönemi'nde 13 sorudan 9'unu kaçırdın.") 15/24; both are left
///   out when the data has no weakest topic;
/// - 16 below, the one primary button "Analizi Gör", full width.
///
/// [ExamSummaryCard.empty] is the card of a student with no exam: "Henüz deneme
/// okutmadın.", one sentence and the primary "İlk Denemeni Okut" with the
/// camera icon. If data is missing a field is not drawn; nothing is faked.
class ExamSummaryCard extends StatelessWidget {
  /// The card of the last exam.
  const ExamSummaryCard({
    required String name,
    required double net,
    required DybCounts counts,
    required DateTime date,
    required String typeLabel,
    VoidCallback? onAnalyze,
    this.publisher,
    this.delta,
    this.weakestTopicSentence,
    super.key,
  }) : _name = name,
       _net = net,
       _counts = counts,
       _date = date,
       _typeLabel = typeLabel,
       onPrimary = onAnalyze,
       isEmpty = false;

  /// The card for a student who has read no exam yet; [onScan] opens the
  /// camera.
  const ExamSummaryCard.empty({required VoidCallback onScan, super.key})
    : _name = null,
      _net = null,
      _counts = null,
      _date = null,
      _typeLabel = null,
      publisher = null,
      delta = null,
      weakestTopicSentence = null,
      onPrimary = onScan,
      isEmpty = true;

  final String? _name;
  final double? _net;
  final DybCounts? _counts;
  final DateTime? _date;
  final String? _typeLabel;

  /// "Örnek Yayınları"; null when the data has none.
  final String? publisher;

  /// The net change against the previous exam of the same type, `+8,25`;
  /// null when there is none.
  final double? delta;

  /// The complete sentence about the weakest topic.
  final String? weakestTopicSentence;

  /// "Analizi Gör" (card) or "İlk Denemeni Okut" (empty card).
  final VoidCallback? onPrimary;

  /// Whether this is the empty card.
  final bool isEmpty;

  /// The separator of the meta line.
  static const String metaSeparator = ' · ';

  /// Gap above the rule, and below it.
  static const double _ruleAbove = AppSpacing.s16;
  static const double _ruleBelow = AppSpacing.s12;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    if (isEmpty) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.exams_summaryEmptyTitle,
              style: text.titleSm.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              l10n.exams_summaryEmptyBody,
              style: text.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s16),
            AppButton(
              label: l10n.exams_summaryScan,
              icon: PhosphorIconsRegular.camera,
              expand: true,
              onPressed: onPrimary,
            ),
          ],
        ),
      );
    }

    final meta = [
      ?publisher,
      _typeLabel!,
      TrFormat.kisaTarih(_date!, withYear: true),
    ].join(metaSeparator);
    final sentence = weakestTopicSentence;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _name!,
            style: text.titleSm.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(meta, style: text.caption.copyWith(color: colors.textSecondary)),
          const SizedBox(height: AppSpacing.s12),
          Wrap(
            spacing: AppSpacing.s12,
            runSpacing: AppSpacing.s4,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    TrFormat.net(_net!),
                    style: text.metricLg.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    l10n.exams_netUnit,
                    style: text.bodyStrong.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (delta != null)
                DeltaText(
                  value: delta,
                  size: DeltaTextSize.badge,
                  suffix: l10n.exams_deltaVsPrevious(_typeLabel),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          DybCounter(counts: _counts!, labels: DybCounterLabels.word),
          if (sentence != null) ...[
            const SizedBox(height: _ruleAbove),
            Divider(height: 1, thickness: 1, color: colors.bgSunken),
            const SizedBox(height: _ruleBelow),
            Text(
              l10n.exams_summaryWeakestTopic,
              style: text.caption.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              sentence,
              style: text.body.copyWith(color: colors.textPrimary),
            ),
          ],
          const SizedBox(height: AppSpacing.s16),
          AppButton(
            label: l10n.exams_summaryAnalyze,
            expand: true,
            onPressed: onPrimary,
          ),
        ],
      ),
    );
  }
}
