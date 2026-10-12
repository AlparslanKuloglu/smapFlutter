import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/navigation/app_home_band.dart';
import 'package:smap/shared/ui/navigation/band_math.dart';
import 'package:smap/shared/ui/navigation/band_text.dart';

/// What the home band measures with the real text before it knows its
/// height (C81): the open greeting, the coach sub line and the counter row,
/// each at the width the layout gives it.
typedef HomeBandMeasures = ({
  double greeting,
  double? subtitle,
  double? counter,
});

/// Measuring half of [AppHomeBand]: the same strings, styles and widths the
/// widgets lay out, so the band is exactly as tall as its content at any
/// text scale (pano 3.1; FIN14E: "Merhaba, Alparslan" at 1,35).
extension HomeBandMeasure on AppHomeBand {
  HomeBandMeasures measure(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final content = MediaQuery.sizeOf(context).width - 2 * AppSpacing.gutter;
    final textWidth = content - HomeBandMetrics.avatarOpen - AppSpacing.s12;

    final greeting = BandText.height(
      text: AppHomeBand.greetingText(l10n, name),
      style: text.titleMd,
      width: textWidth,
      textScaler: scaler,
      textDirection: direction,
      maxLines: HomeBandMetrics.openGreetingLines,
    );

    double? subtitle;
    if (role == AppHomeBandRole.coach) {
      final line = AppHomeBand.coachLine(l10n, studentCount, upcomingMeetings);
      if (line != null) {
        subtitle = BandText.height(
          text: line,
          style: text.caption,
          width: textWidth,
          textScaler: scaler,
          textDirection: direction,
          maxLines: 2,
        );
      }
    }

    double? counterHeight;
    final counter = this.counter;
    if (role == AppHomeBandRole.student && counter != null) {
      final days = TrFormat.sira(counter.daysLeft);
      final figure = BandText.size(
        text: days,
        style: text.metricLg,
        width: content,
        textScaler: scaler,
        textDirection: direction,
        maxLines: 1,
      );
      final sideWidth = content - figure.width - AppSpacing.s12;
      final unit = BandText.height(
        text: l10n.nav_homeCounterUnit,
        style: text.bodyStrong.copyWith(fontWeight: FontWeight.w700),
        width: sideWidth,
        textScaler: scaler,
        textDirection: direction,
      );
      final exam = BandText.height(
        text: l10n.nav_homeCounterExam(TrFormat.uzunTarihGun(counter.examDate)),
        style: text.caption,
        width: sideWidth,
        textScaler: scaler,
        textDirection: direction,
      );
      counterHeight = figure.height > unit + exam + AppSpacing.s4
          ? figure.height
          : unit + exam + AppSpacing.s4;
    }
    return (greeting: greeting, subtitle: subtitle, counter: counterHeight);
  }
}
