import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/lessons/presentation/widgets/eksik_tag.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_glyph.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/controls/app_tag.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

/// One subject card of the horizontal strip on the home screen (C21
/// "SubjectTile"; Tur 6 G3; pano 3.1 "Derslerin").
///
/// 132 wide, padding 16, radius 16, `bgSurface` (an `AppCard`), content
/// stacked and left aligned, 12 apart: the 40 pt [SubjectGlyph], the name 16/24
/// · 600 (it wraps), and 6 under it either the [EksikTag] ("60 eksik") or the
/// "Web'de" tag with ArrowSquareOut 14. A subject whose count is unknown draws
/// no tag. The strip itself (horizontal, 8 between tiles, 16 at the sides)
/// belongs to the screen; `SubjectOrdering.tileOrder` sorts it, most missing
/// first and Matematik and Geometri last. The tile opens the subject detail.
/// Read as "Tarih, 60 eksik".
class SubjectTile extends StatelessWidget {
  const SubjectTile({
    required this.name,
    required this.subject,
    this.missing,
    this.webOnly = false,
    this.onTap,
    super.key,
  });

  final String name;

  /// The subject color; null draws a neutral tile.
  final SubjectKey? subject;

  /// Missing items; null draws no tag, zero draws no tag either.
  final int? missing;

  /// The subject opens on the web: "Web'de" tag.
  final bool webOnly;
  final VoidCallback? onTap;

  /// The width of the tile.
  static const double width = 132;

  /// Gap between the name and the tag.
  static const double _tagGap = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final count = missing;
    final Widget? badge = webOnly
        ? AppTag(
            label: l10n.lessons_onWeb,
            icon: PhosphorIconsRegular.arrowSquareOut,
          )
        : (count != null && count > 0 ? EksikTag(count: count) : null);
    final reading = webOnly
        ? l10n.lessons_tileWebA11y(name)
        : (count != null && count > 0
              ? l10n.lessons_tileMissingA11y(name, TrFormat.sira(count))
              : name);
    return SizedBox(
      width: width,
      child: AppCard(
        onTap: onTap,
        semanticLabel: reading,
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubjectGlyph(subject: subject),
              const SizedBox(height: AppSpacing.s12),
              Text(
                name,
                style: context.appText.titleSm.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              if (badge != null) ...[const SizedBox(height: _tagGap), badge],
            ],
          ),
        ),
      ),
    );
  }
}
