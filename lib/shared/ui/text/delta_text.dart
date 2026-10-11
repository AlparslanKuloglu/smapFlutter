import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/smap_text.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The direction a [DeltaText] points.
enum DeltaDirection {
  up,
  down,
  flat;

  /// The direction of [value] as it will be written: a value that rounds to
  /// zero in `TrFormat.delta` is [flat], so "0" never carries an arrow and
  /// "+0,001" cannot show an up arrow beside the text "0".
  static DeltaDirection of(num value) {
    if (TrFormat.delta(value) == '0') return flat;
    return value > 0 ? up : down;
  }
}

/// The three sizes of the change text (C49 "Metrik ve delta metni").
enum DeltaTextSize {
  /// 13/20 · 700, arrow 14: the home screen's net change.
  badge,

  /// 13/20 · 600, arrow 14: inside an `AppStatBox`.
  stat,

  /// 15/24 · 700, arrow 18: the result moment.
  result;

  /// The text style of the size, colorless.
  TextStyle styleOf(SmapText text) => switch (this) {
    badge => text.caption.copyWith(fontWeight: FontWeight.w700),
    stat => text.caption.copyWith(fontWeight: FontWeight.w600),
    result => text.bodyStrong.copyWith(fontWeight: FontWeight.w700),
  };

  /// The arrow edge.
  double get arrow => this == result ? 18 : 14;
}

/// A signed change with an arrow, such as "+8,25" (C49 `SmapDeltaText`; board
/// 1.16 "İstatistik kutusu"; UI guide §5 #20).
///
/// The sign is always written (`TrFormat.delta`: "+8,25", "−1,5" with the
/// real minus sign, "0" for none) and an ArrowUp or ArrowDown stands beside
/// it, 4 pt away. Both are in the `delta` color (navy-600 / navy-300). Green is
/// reserved for "Doğru" and red for a wrong answer, so a rise is not green; the
/// sign and the arrow carry the meaning, never the color. For a rank a
/// falling number is good and reads through the arrow. [suffix] is the
/// explanation in `textSecondary` ("son denemede"). Nothing is drawn for a
/// null [value] (no two exams, no delta).
///
/// Read as "artış +8,25 son denemede" / "düşüş −1,5".
class DeltaText extends StatelessWidget {
  const DeltaText({
    required this.value,
    this.suffix,
    this.size = DeltaTextSize.stat,
    super.key,
  });

  final num? value;

  /// "son denemede".
  final String? suffix;
  final DeltaTextSize size;

  @override
  Widget build(BuildContext context) {
    final change = value;
    if (change == null) return const SizedBox.shrink();
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final style = size.styleOf(context.appText);
    final direction = DeltaDirection.of(change);
    final written = TrFormat.delta(change);
    final word = switch (direction) {
      DeltaDirection.up => l10n.kit_a11yDeltaUp,
      DeltaDirection.down => l10n.kit_a11yDeltaDown,
      DeltaDirection.flat => l10n.kit_a11yDeltaFlat,
    };

    return Semantics(
      label: [word, written, ?suffix].join(' '),
      excludeSemantics: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.s4,
        children: [
          if (direction != DeltaDirection.flat)
            PhosphorIcon(
              direction == DeltaDirection.up
                  ? PhosphorIconsBold.arrowUp
                  : PhosphorIconsBold.arrowDown,
              size: size.arrow,
              color: colors.delta,
            ),
          Text(written, style: style.copyWith(color: colors.delta)),
          if (suffix case final note?)
            Text(
              note,
              style: style.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
