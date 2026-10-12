import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'package:smap/shared/ui/navigation/band_math.dart';

/// The numbers of the Hesap band: the root band of the tab with the profile
/// summary inside it (pano 9.1 kare 1 and 2; C80 + C37; spec 2.2).
///
/// Open: `safeTop + 56 (title) + 4 + summary + 20`; with the summary of a
/// 56 pt avatar and three lines of text that is `62 + 56 + 4 + 64 + 20 =
/// 206`. As the page scrolls the band shrinks to `safeTop + 48 = 110`, like
/// every root band: the title goes from 24 to 17, the corners flatten and the
/// summary fades out before the band is half closed. Pure and unit-tested;
/// the widgets only draw them.
class AccountBandMetrics {
  const AccountBandMetrics({
    required this.safeTop,
    this.summaryLines = 0,
    this.hasSummary = true,
    this.textScaler = TextScaler.noScaling,
  });

  /// Title row, open.
  static const double titleRow = 56;

  /// Title row, shrunk.
  static const double collapsedRow = 48;

  /// Space above the summary row (spec 2.2: padding 4 16 0).
  static const double summaryTop = 4;

  /// Space under the band's content.
  static const double bottomPadding = 20;

  /// Avatar edge of the summary (C37).
  static const double avatar = 56;

  /// Space under the title row of a band without a summary.
  static const double plainGap = 16;

  final double safeTop;

  /// How many 13/20 lines the summary has under the name (0 to 2).
  final int summaryLines;

  /// Whether there is a summary at all (an account is known).
  final bool hasSummary;
  final TextScaler textScaler;

  /// Height of the summary row: the avatar, or the name (24) and its lines
  /// (20 each) when they are taller, at the text scale.
  double get summaryHeight => hasSummary
      ? math.max(
          avatar,
          textScaler.scale(24) + summaryLines * textScaler.scale(20),
        )
      : 0;

  double get maxExtent =>
      safeTop +
      titleRow +
      (hasSummary ? summaryTop + summaryHeight + bottomPadding : plainGap);

  double get minExtent => safeTop + collapsedRow;

  /// Progress 0..1 after [shrinkOffset] points of scroll.
  double progressAt(double shrinkOffset) => BandMath.progress(
    shrinkOffset,
    maxExtent: maxExtent,
    minExtent: minExtent,
  );

  /// Height of the title row at [progress].
  static double titleRowAt(double progress) =>
      BandMath.lerp(titleRow, collapsedRow, progress);

  /// Bottom corner radius at [progress]: 24 open, flat when shrunk.
  static double cornerAt(double progress) => BandMath.lerp(24, 0, progress);

  /// Opacity of the summary: gone before the band is half shrunk, so it never
  /// crowds the title.
  static double summaryOpacityAt(double progress) =>
      (1 - progress * 2).clamp(0.0, 1.0);
}
