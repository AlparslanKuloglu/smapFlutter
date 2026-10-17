import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/lessons/presentation/widgets/eksik_tag.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/surfaces/app_row_shell.dart';

/// One topic of a subject (C22 "TopicRow"; pano 1.16 "Konu satırı · Türkçe,
/// 1'den n'ye", screen 7.2 "Ders Detayı"; Tur 5).
///
/// At least 64 high, padding 12 / 16, 12 between the parts. Left: the number
/// in a 28 pt circle (`bgSunken`, 13/28 · 700, centered). Middle: the topic
/// name 16/24 · 600, wrapping to two lines or more, never cut ("İkinci Dünya
/// Savaşı Sürecinde Türkiye ve Dünya"). Right: the [EksikTag] when [missing] is
/// above zero (nothing is written for none, "0 eksik" never) and CaretRight
/// 20. From text scale 1,25 the tag sits under the name instead, and the
/// number circle grows with the text.
///
/// [number] is made on the device, 1 to n without a gap, and a filtered list
/// keeps the numbers of the full list (`TopicNumbering`). Read as "9. Fiilde
/// Çatı, 3 eksik"; the row opens the topic detail.
///
/// [missingWorks] makes it the era row of Yazar ve Eserler (pano 14.5 kare 1):
/// the tag says "2 eksik eser" and the row is read "1, Tanzimat Dönemi, 2
/// eksik eser".
class TopicRow extends StatelessWidget {
  const TopicRow({
    required this.number,
    required this.name,
    this.missing,
    this.missingWorks = false,
    this.onTap,
    super.key,
  });

  /// The number in the full list, 1-based.
  final int number;
  final String name;

  /// Missing items of the topic; null or zero draws no tag.
  final int? missing;

  /// The missing count is of works ("2 eksik eser"), as on an era row.
  final bool missingWorks;
  final VoidCallback? onTap;

  /// Edge of the number circle.
  static const double _badge = 28;

  /// Minimum height of the row.
  static const double minHeight = 64;

  /// Text scale from which the tag drops under the name (as in `SubjectRow`),
  /// so a long name keeps the row's width.
  static const double _stackScale = 1.25;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final count = missing;
    final tagged = count != null && count > 0;
    final stacked =
        tagged && MediaQuery.textScalerOf(context).scale(1) >= _stackScale;
    final badge = MediaQuery.textScalerOf(context).scale(_badge);
    return MergeSemantics(
      child: Semantics(
        button: onTap != null,
        onTap: onTap,
        label: tagged && missingWorks
            ? l10n.literature_eraRowA11y(number, name, TrFormat.sira(count))
            : [
                l10n.lessons_topicRowA11y(number, name),
                if (tagged) l10n.lessons_missingCount(TrFormat.sira(count)),
              ].join(', '),
        child: ExcludeSemantics(
          child: AppRowShell(
            onTap: onTap,
            minHeight: minHeight,
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.bgSunken,
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: SizedBox.square(
                    dimension: badge,
                    child: Center(
                      child: Text(
                        '$number',
                        style: text.caption.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                          height: _badge / 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: text.titleSm.copyWith(color: colors.textPrimary),
                      ),
                      if (stacked) ...[
                        const SizedBox(height: AppSpacing.s4),
                        EksikTag(count: count, works: missingWorks),
                      ],
                    ],
                  ),
                ),
                if (tagged && !stacked) ...[
                  const SizedBox(width: AppSpacing.s12),
                  EksikTag(count: count, works: missingWorks),
                ],
                const SizedBox(width: AppSpacing.s8),
                PhosphorIcon(
                  PhosphorIconsRegular.caretRight,
                  size: AppSize.iconInButton,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
