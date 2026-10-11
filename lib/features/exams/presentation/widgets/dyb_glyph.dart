import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';

/// The two sizes of the D/Y/B chip.
enum DybGlyphSize {
  /// A 16 pt circle with a 10 pt glyph: small counters, question cells.
  small(16, 10),

  /// A 24 pt circle with a 14 pt glyph: large counters.
  regular(24, 14);

  const DybGlyphSize(this.circle, this.glyph);

  /// Edge of the circle.
  final double circle;

  /// Edge of the glyph inside it.
  final double glyph;
}

/// The D/Y/B chip (C40 "D/Y/B çipi"; pano 1.14 and 1.4, `DybChip` in Tur 1).
///
/// A filled circle with a glyph: Check on "Doğru", X on "Yanlış", Minus on
/// "Boş", in `dybCorrect` / `dybWrong` / `dybBlank` with the `dybOn` glyph
/// (white in light, navy in dark). The glyph is on every chip since Tur 10, so
/// the shape tells the outcome without color. It is decoration: the counter or
/// the cell that holds it gives the reading, so the chip is hidden from the
/// screen reader unless a [semanticLabel] is given.
class DybGlyph extends StatelessWidget {
  const DybGlyph({
    required this.kind,
    this.size = DybGlyphSize.small,
    this.semanticLabel,
    super.key,
  });

  final DybKind kind;
  final DybGlyphSize size;

  /// The accessible name when the chip stands alone ("Doğru").
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (fill, icon) = switch (kind) {
      DybKind.correct => (colors.dybCorrect, PhosphorIconsBold.check),
      DybKind.wrong => (colors.dybWrong, PhosphorIconsBold.x),
      DybKind.blank => (colors.dybBlank, PhosphorIconsBold.minus),
    };
    final chip = DecoratedBox(
      decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      child: SizedBox.square(
        dimension: size.circle,
        child: Center(
          child: PhosphorIcon(icon, size: size.glyph, color: colors.dybOn),
        ),
      ),
    );
    if (semanticLabel case final label?) {
      return Semantics(label: label, excludeSemantics: true, child: chip);
    }
    return ExcludeSemantics(child: chip);
  }
}
