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
import 'package:smap/shared/ui/indicators/app_linear_progress.dart';
import 'package:smap/shared/ui/surfaces/app_row_shell.dart';

/// One subject in the list of "Derslerim" (C20 "SubjectRow"; pano 1.16 "Ders
/// satırı", 7.1 "Derslerim · TYT / AYT"; Tur 5 G1).
///
/// At least 72 high, padding 12 / 16, 12 between the parts. Left: the 40 pt
/// [SubjectGlyph]. Middle: the name 16/24 · 600 (no "TYT" prefix; at text
/// scale 1,3 it wraps and the tag drops under it), an optional test line 13
/// `textSecondary` ("Sosyal Bilimler 2 testi") and, only for a subject with
/// card data, an 8 pt progress bar in the subject color with "41 / 64 kart
/// biliniyor" 13 under it (8 below the name). Right: one tag and the arrow.
///
/// The tag is exactly one of: [webOnly] "Web'de" with ArrowSquareOut 14 (and
/// the arrow becomes ArrowSquareOut 20); an [EksikTag] "31 eksik" for a
/// [missing] above zero; a neutral "eksik yok" for a [missing] of zero; the
/// neutral [tag] text ("SOS-2") when no count is known. With none of them no
/// tag is drawn. Read as "Matematik, web'de açılır" or "Tarih, 60 eksik".
class SubjectRow extends StatelessWidget {
  const SubjectRow({
    required this.name,
    required this.subject,
    this.testName,
    this.missing,
    this.tag,
    this.webOnly = false,
    this.cardsKnown,
    this.cardsTotal,
    this.onTap,
    super.key,
  });

  /// "Türkçe", "Tarih-2".
  final String name;

  /// The subject color; null draws a neutral tile.
  final SubjectKey? subject;

  /// "Sosyal Bilimler 2 testi".
  final String? testName;

  /// Missing items; null is unknown, zero is "eksik yok".
  final int? missing;

  /// A neutral tag for a subject whose missing count is unknown ("SOS-2").
  final String? tag;

  /// The subject opens on the web: "Web'de" tag, no card progress.
  final bool webOnly;

  /// Known cards; the bar is drawn only with a positive [cardsTotal].
  final int? cardsKnown;
  final int? cardsTotal;

  /// Opens the subject detail (or the "Web'de Aç" sheet).
  final VoidCallback? onTap;

  bool get _hasProgress =>
      !webOnly && cardsKnown != null && (cardsTotal ?? 0) > 0;

  /// Text scale from which the tag drops under the name.
  static const double _stackScale = 1.25;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final stacked = MediaQuery.textScalerOf(context).scale(1) >= _stackScale;
    final Widget? badge = _badge(l10n);
    final title = Text(
      name,
      style: text.titleSm.copyWith(color: colors.textPrimary),
    );

    final reading = <String>[
      name,
      if (webOnly)
        l10n.lessons_opensOnWeb
      else if (missing != null && missing! > 0)
        l10n.lessons_missingCount(TrFormat.sira(missing!))
      else if (missing == 0)
        l10n.lessons_noMissing
      else
        ?tag,
      ?testName,
      if (_hasProgress) l10n.lessons_cardsKnown(cardsKnown!, cardsTotal!),
    ];

    return MergeSemantics(
      child: Semantics(
        button: onTap != null,
        onTap: onTap,
        label: reading.join(', '),
        child: ExcludeSemantics(
          child: AppRowShell(
            onTap: onTap,
            minHeight: AppSize.rowMinTwoLine,
            child: Row(
              children: [
                SubjectGlyph(subject: subject),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (stacked || badge == null)
                        title
                      else
                        Row(
                          children: [
                            Expanded(child: title),
                            const SizedBox(width: AppSpacing.s8),
                            badge,
                          ],
                        ),
                      if (stacked && badge != null) ...[
                        const SizedBox(height: AppSpacing.s4),
                        badge,
                      ],
                      if (testName case final line?)
                        Text(
                          line,
                          style: text.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      if (_hasProgress) ...[
                        const SizedBox(height: AppSpacing.s8),
                        AppLinearProgress(
                          value: cardsKnown!,
                          total: cardsTotal,
                          style: AppProgressStyle.subject,
                          color: subject == null
                              ? colors.textSecondary
                              : context.appSubject(subject!).fg,
                          label: l10n.lessons_cardsKnown(
                            cardsKnown!,
                            cardsTotal!,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                PhosphorIcon(
                  webOnly
                      ? PhosphorIconsRegular.arrowSquareOut
                      : PhosphorIconsRegular.caretRight,
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

  Widget? _badge(AppLocalizations l10n) {
    if (webOnly) {
      return AppTag(
        label: l10n.lessons_onWeb,
        icon: PhosphorIconsRegular.arrowSquareOut,
      );
    }
    final count = missing;
    if (count != null) {
      return count > 0
          ? EksikTag(count: count)
          : AppTag(label: l10n.lessons_noMissing);
    }
    if (tag case final label?) return AppTag(label: label);
    return null;
  }
}
