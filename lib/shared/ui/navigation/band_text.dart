import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Text height measuring shared by the bands (a [TextPainter] at the width
/// the text gets; the same numbers the widgets lay out).
abstract final class BandText {
  /// Height of [text] in [style] at [width], capped at [maxLines] lines
  /// (rounded up to a whole logical pixel so a sum never falls short).
  static double height({
    required String text,
    required TextStyle style,
    required double width,
    required TextScaler textScaler,
    required TextDirection textDirection,
    int? maxLines,
  }) => size(
    text: text,
    style: style,
    width: width,
    textScaler: textScaler,
    textDirection: textDirection,
    maxLines: maxLines,
  ).height;

  /// Laid-out size of [text] (width is the longest line's) at most [width]
  /// wide; both sides rounded up.
  static Size size({
    required String text,
    required TextStyle style,
    required double width,
    required TextScaler textScaler,
    required TextDirection textDirection,
    int? maxLines,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: maxLines,
    )..layout(maxWidth: math.max(0, width));
    final result = Size(
      painter.width.ceilToDouble(),
      painter.height.ceilToDouble(),
    );
    painter.dispose();
    return result;
  }
}
