import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/topic_ranking.dart';
import 'package:smap/features/exams/presentation/widgets/dyb_counter.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/controls/app_tag.dart';
import 'package:smap/shared/ui/indicators/app_success_ring.dart';
import 'package:smap/shared/ui/surfaces/app_row_shell.dart';

/// One topic of an exam with its success ring (C23 "TopicResultRow"; pano
/// 1.15 "Konu satırında", screens 5.5 and 5.10 "Deneme Detay · Konular").
///
/// 72 pt minimum, padding 12 / 16, 12 between the parts. Left: the topic name
/// 16/24 · 600 (it wraps, it is never cut: "İslamiyet Etkisindeki Türk
/// Edebiyatı (Divan-Halk Edebiyatı)"), and 6 under it the small word counter
/// ("5 doğru · 7 yanlış · 0 boş") with the "Az soru" tag when the topic has
/// one or two questions. Right: an [AppSuccessRing] of 48 pt, a single color,
/// "%42", or "Soru yok" without a ring when the topic has no question.
///
/// The percentage is `(D * 100 / n).round()` with `n = D + Y + B`; the list
/// is ordered weakest first by `TopicRanking.sort`. The whole row opens the
/// topic detail.
class TopicResultRow extends StatelessWidget {
  const TopicResultRow({
    required this.name,
    required this.counts,
    this.onTap,
    super.key,
  });

  final String name;
  final DybCounts counts;

  /// Opens the topic detail; null makes the row static.
  final VoidCallback? onTap;

  /// Gap between the counter and the "Az soru" tag.
  static const double _metaGap = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return MergeSemantics(
      child: Semantics(
        button: onTap != null,
        child: AppRowShell(
          onTap: onTap,
          minHeight: AppSize.rowMinTwoLine,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: text.titleSm.copyWith(color: colors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: _metaGap,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        DybCounter(
                          counts: counts,
                          labels: DybCounterLabels.word,
                        ),
                        if (TopicRanking.isFewQuestions(counts))
                          AppTag(label: l10n.exams_fewQuestions),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              AppSuccessRing(correct: counts.correct, total: counts.total),
            ],
          ),
        ),
      ),
    );
  }
}
