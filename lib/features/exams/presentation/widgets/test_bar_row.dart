import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/presentation/widgets/dyb_counter.dart';
import 'package:smap/features/exams/presentation/widgets/dyb_stacked_bar.dart';
import 'package:smap/l10n/app_localizations.dart';

/// One test of an exam with its net and its stacked bar (C42 `SmapTestBarRow`;
/// pano 1.14, screen 5.3 "Genel").
///
/// Top line, aligned on the baseline: the full test name 16/24 · 600 (it
/// wraps, it is never cut: "Türk Dili ve Edebiyatı–Sosyal Bilimler 1"), the
/// net 17/24 · 700 and "net" 13 · 500 `textSecondary`, 16 apart. Under it, 10
/// below, the [DybStackedBar]; 8 below that the small lettered counter and,
/// at the right, "40 soru". Padding is 14 above and below; the rule between
/// two rows is drawn by the card or group that holds them (1 pt `bgSunken`).
///
/// [net] comes from the server. The row is read as one sentence: "Matematik,
/// 21,25 net, 40 sorudan 25 doğru, 15 yanlış, 0 boş".
class TestBarRow extends StatelessWidget {
  const TestBarRow({
    required this.name,
    required this.net,
    required this.counts,
    this.animate = true,
    super.key,
  });

  /// The full test name.
  final String name;
  final double net;
  final DybCounts counts;

  /// Whether the bar fills on first show.
  final bool animate;

  /// Vertical padding of the row.
  static const double _verticalPadding = 14;

  /// Gap between the name line and the bar.
  static const double _barGap = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final netText = TrFormat.net(net);
    return Semantics(
      container: true,
      label: l10n.exams_testRowA11y(
        name,
        netText,
        counts.total,
        counts.correct,
        counts.wrong,
        counts.blank,
      ),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: text.titleSm.copyWith(color: colors.textPrimary),
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
                Text(
                  netText,
                  style: text.metricSm.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(width: AppSpacing.s4),
                Text(
                  l10n.exams_netUnit,
                  style: text.caption.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: _barGap),
            DybStackedBar(counts: counts, animate: animate),
            const SizedBox(height: AppSpacing.s8),
            Row(
              children: [
                Expanded(child: DybCounter(counts: counts)),
                const SizedBox(width: AppSpacing.s8),
                Text(
                  l10n.exams_questionCount(counts.total),
                  style: text.caption.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
