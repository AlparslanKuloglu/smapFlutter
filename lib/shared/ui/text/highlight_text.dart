import 'package:flutter/material.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/turkish_text.dart';

/// A run of text and whether it is part of a search match.
typedef HighlightSegment = ({String text, bool matched});

/// Splits [text] at [ranges] (offsets into [text], end exclusive, sorted and
/// not overlapping, as `TurkishText.matchRanges` returns them) into runs
/// that alternate between plain and matched. Out-of-range or empty ranges are
/// ignored, so the runs always concatenate back to [text].
List<HighlightSegment> splitByRanges(
  String text,
  List<({int start, int end})> ranges,
) {
  final segments = <HighlightSegment>[];
  var at = 0;
  for (final range in ranges) {
    final start = range.start.clamp(at, text.length);
    final end = range.end.clamp(start, text.length);
    if (end <= start) continue;
    if (start > at) {
      segments.add((text: text.substring(at, start), matched: false));
    }
    segments.add((text: text.substring(start, end), matched: true));
    at = end;
  }
  if (at < text.length) {
    segments.add((text: text.substring(at), matched: false));
  }
  return segments;
}

/// [text] with the matches of [query] marked (C10 "Eşleşme vurgusu"; board
/// 1.12 "Arama"; UI guide §5 #11): the `mark` of the design, a `warningBg`
/// background behind `textPrimary` letters, semibold.
///
/// Matching is Turkish-aware through `TurkishText.matchRanges`: case and the
/// dotted and dotless I are ignored ("ısparta" finds "Isparta", "ISPARTA"),
/// each query word marks the start of the first text word it begins, and a
/// blank query marks nothing. The 4 pt corner radius of the board `mark` is
/// not drawn: a text background cannot be rounded without breaking line
/// wrapping, so the mark is square (a documented deviation).
class HighlightText extends StatelessWidget {
  const HighlightText({
    required this.text,
    required this.query,
    this.style,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final String text;
  final String query;

  /// The base style; `body` in `textPrimary` when null.
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final base = (style ?? context.appText.body).copyWith(
      color: style?.color ?? colors.textPrimary,
    );
    final segments = splitByRanges(text, TurkishText.matchRanges(text, query));
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (final segment in segments)
            TextSpan(
              text: segment.text,
              style: segment.matched
                  ? base.copyWith(
                      backgroundColor: colors.warningBg,
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    )
                  : null,
            ),
        ],
      ),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
