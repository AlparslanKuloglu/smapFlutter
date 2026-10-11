import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/controls/app_tag.dart';
import 'package:smap/shared/ui/surfaces/app_row_shell.dart';

/// One program of the list (C29 "ProgramRow"; Tur 6; pano 3.4 kare 1 "Ekim 2.
/// Hafta · Bu hafta · Her gün biraz daha · 5–11 Ekim 2026").
///
/// A row of a card, padding 16, 12 between the parts, aligned to the top: a
/// 40 pt tile (`infoBg`, a calendar glyph 22 in `info`; radius 12), the text
/// column and CaretRight 20 (8 from the top). The text column holds the name
/// (`titleSm` 16/24 · 700) with the "Bu hafta" [AppTag] and its orange dot
/// beside it when [isThisWeek], the [motto] (15/24 `textSecondary`) and the
/// [range] (13/20 `textSecondary`). A missing motto or range is not drawn.
/// Read as one button: "Ekim 2. Hafta, Bu hafta, Her gün biraz daha, 5–11
/// Ekim 2026".
class ProgramRow extends StatelessWidget {
  const ProgramRow({
    required this.name,
    required this.onTap,
    this.motto = '',
    this.range,
    this.isThisWeek = false,
    super.key,
  });

  /// "Ekim 2. Hafta".
  final String name;

  /// "Her gün biraz daha"; empty draws no line.
  final String motto;

  /// "5–11 Ekim 2026"; null draws no line.
  final String? range;

  /// The program of the current week: the "Bu hafta" tag.
  final bool isThisWeek;
  final VoidCallback onTap;

  /// Left edge of the text: padding 16, tile 40, gap 12. The rule between two
  /// rows starts here.
  static const double textInset = 68;

  static const double _tile = 40;
  static const double _glyph = 22;
  static const double _caretTop = 8;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final reading = [
      name,
      if (isThisWeek) l10n.schedule_thisWeek,
      if (motto.isNotEmpty) motto,
      ?range,
    ].join(', ');

    return Semantics(
      button: true,
      onTap: onTap,
      label: reading,
      excludeSemantics: true,
      child: AppRowShell(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.infoBg,
                borderRadius: AppRadius.borderMd,
              ),
              child: SizedBox.square(
                dimension: _tile,
                child: Center(
                  child: PhosphorIcon(
                    PhosphorIconsRegular.calendarBlank,
                    size: _glyph,
                    color: colors.info,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        name,
                        style: text.titleSm.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isThisWeek)
                        AppTag(label: l10n.schedule_thisWeek, dot: true),
                    ],
                  ),
                  if (motto.isNotEmpty)
                    Text(
                      motto,
                      style: text.body.copyWith(color: colors.textSecondary),
                    ),
                  if (range case final dates?)
                    Text(
                      dates,
                      style: text.caption.copyWith(color: colors.textSecondary),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Padding(
              padding: const EdgeInsets.only(top: _caretTop),
              child: PhosphorIcon(
                PhosphorIconsRegular.caretRight,
                size: 20,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
