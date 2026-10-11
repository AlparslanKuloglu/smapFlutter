import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_icons.dart';

/// The sizes of the subject glyph tile and the glyph inside it (C58 table).
enum SubjectGlyphSize {
  /// Tile 48, glyph 24: the kit.
  kit(48, 24),

  /// Tile 40, glyph 22: subject row and tile.
  row(40, 22),

  /// Tile 36, glyph 19: program row.
  program(36, 19),

  /// Tile 32, glyph 20: card preview group header.
  preview(32, 20),

  /// Tile 28, glyph 15: study card.
  card(28, 15);

  const SubjectGlyphSize(this.tile, this.glyph);

  /// Edge of the tile.
  final double tile;

  /// Edge of the glyph.
  final double glyph;
}

/// The subject glyph tile (C58 "Ders glif karosu"; pano 1.5 "Ders Renkleri",
/// 1.16 "Ders satırı"; `SmapSubjectGlyph`).
///
/// A square in the subject's tint (`SubjectTone.bg`) with its Phosphor glyph in
/// the subject accent (`SubjectTone.fg`). Radius 12 (`AppRadius.md`) from the
/// 36 pt tile up; the 28 and 32 pt tiles use 8 (the board uses 12 and a
/// non-token 10; here only radius tokens). The subject name always sits
/// beside it in `textPrimary`; a subject color never carries a right or wrong
/// meaning. A null [subject] (a lesson outside the nine) draws a neutral tile
/// (`bgSunken`, `textSecondary` book). Decoration: hidden from the screen
/// reader unless a [semanticLabel] is given.
class SubjectGlyph extends StatelessWidget {
  const SubjectGlyph({
    required this.subject,
    this.size = SubjectGlyphSize.row,
    this.semanticLabel,
    super.key,
  });

  /// The subject; null draws the neutral tile.
  final SubjectKey? subject;
  final SubjectGlyphSize size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final key = subject;
    final (fill, ink, icon) = key == null
        ? (colors.bgSunken, colors.textSecondary, subjectFallbackIcon)
        : (
            context.appSubject(key).bg,
            context.appSubject(key).fg,
            subjectIcons[key]!,
          );
    final tile = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: size.tile >= SubjectGlyphSize.program.tile
            ? AppRadius.borderMd
            : AppRadius.borderSm,
      ),
      child: SizedBox.square(
        dimension: size.tile,
        child: Center(
          child: PhosphorIcon(icon, size: size.glyph, color: ink),
        ),
      ),
    );
    if (semanticLabel case final label?) {
      return Semantics(label: label, excludeSemantics: true, child: tile);
    }
    return ExcludeSemantics(child: tile);
  }
}
