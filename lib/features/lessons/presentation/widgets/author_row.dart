import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/lessons/application/literature_authors.dart';
import 'package:smap/features/lessons/presentation/widgets/eksik_tag.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/surfaces/app_row_shell.dart';

/// One author of an era's sub-subject (C28 "AuthorRow"; pano 14.5 kare 2,
/// replaces 7.4 kare 1).
///
/// At least 72 high, padding 12 / 16, 12 between the parts. Left: the 48 pt
/// round photo; an author without a photo (or one whose file is not in the
/// app) shows the initials in the Edebiyat tones (`bgSurface` tint and
/// accent, 15 · 700). Middle: the name 16/24 · 600 and the work count "8 eser"
/// 13/20 `textSecondary` under it (the count is `works.length`; nothing is
/// written for an author without works). Right: the [EksikTag] "2 eksik" while
/// works are missing and CaretRight 20. From text scale 1,25 the tag sits
/// under the count instead, as on `TopicRow`. The row opens the author sheet.
///
/// Read as "Namık Kemal, 8 eser, 2 eksik".
class AuthorRow extends StatelessWidget {
  const AuthorRow({
    required this.name,
    required this.workCount,
    this.missing = 0,
    this.photo,
    this.onTap,
    super.key,
  });

  /// "Namık Kemal".
  final String name;

  /// The number of works, "8 eser"; zero draws no count.
  final int workCount;

  /// Works the student is missing; zero draws no tag ("0 eksik" is never
  /// written).
  final int missing;

  /// The photo's path under `assets` ("/authors/a/namikkemal.png"); `null`
  /// draws the initials.
  final String? photo;
  final VoidCallback? onTap;

  /// Text scale from which the tag drops under the count.
  static const double _stackScale = 1.25;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final tagged = missing > 0;
    final stacked =
        tagged && MediaQuery.textScalerOf(context).scale(1) >= _stackScale;
    final works = workCount > 0
        ? l10n.literature_workCount(TrFormat.sira(workCount))
        : null;
    final reading = tagged
        ? l10n.literature_authorRowMissingA11y(
            name,
            works ?? '',
            TrFormat.sira(missing),
          )
        : works == null
        ? name
        : l10n.literature_authorRowA11y(name, works);
    return MergeSemantics(
      child: Semantics(
        button: onTap != null,
        onTap: onTap,
        label: reading,
        child: ExcludeSemantics(
          child: AppRowShell(
            onTap: onTap,
            minHeight: AppSize.rowMinTwoLine,
            child: Row(
              children: [
                AuthorAvatar(name: name, photo: photo),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: text.titleSm.copyWith(color: colors.textPrimary),
                      ),
                      if (works != null)
                        Text(
                          works,
                          style: text.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      if (stacked) ...[
                        const SizedBox(height: AppSpacing.s4),
                        EksikTag(count: missing),
                      ],
                    ],
                  ),
                ),
                if (tagged && !stacked) ...[
                  const SizedBox(width: AppSpacing.s8),
                  EksikTag(count: missing),
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

/// The round portrait of an author: the photo, or the initials in the
/// Edebiyat tones (C28; pano 7.4 "fotoğraf yoksa baş harf"). Decoration.
class AuthorAvatar extends StatelessWidget {
  const AuthorAvatar({
    required this.name,
    this.photo,
    this.size = defaultSize,
    super.key,
  });

  final String name;

  /// The photo's path under `assets`; `null` draws the initials.
  final String? photo;
  final double size;

  /// Edge of the avatar in the row (the author sheet draws 56).
  static const double defaultSize = 48;

  /// Decoded width of a photo, so a large file is not kept whole.
  static const int _decodeWidth = 160;

  @override
  Widget build(BuildContext context) {
    final tone = context.appSubject(SubjectKey.edebiyat);
    final text = context.appText;
    final initials = Text(
      AuthorInitials.of(name),
      style: (size > defaultSize ? text.headline : text.bodyStrong).copyWith(
        color: tone.fg,
        fontWeight: FontWeight.w700,
      ),
    );
    final path = photo;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: ClipOval(
          child: ColoredBox(
            color: tone.bg,
            child: path == null
                ? Center(child: initials)
                : Image.asset(
                    'assets$path',
                    fit: BoxFit.cover,
                    cacheWidth: _decodeWidth,
                    errorBuilder: (context, error, stackTrace) =>
                        Center(child: initials),
                  ),
          ),
        ),
      ),
    );
  }
}
