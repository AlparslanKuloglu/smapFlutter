import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/lessons/application/literature_authors.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/surfaces/app_row_shell.dart';

/// One author of "Yazar ve Eserler" (C28 "AuthorRow"; pano 7.4 kare 1).
///
/// At least 72 high, padding 12 / 16, 12 between the parts. Left: the 48 pt
/// round photo; an author without a photo (or one whose file is not in the
/// app) shows the initials in the Edebiyat tones (`bgSurface` tint and
/// accent, 15 · 700). Middle: the name 16/24 · 600 and the era 13/20
/// `textSecondary` under it. Right: CaretRight 20. The row opens the author
/// sheet.
///
/// Read as "Namık Kemal, Tanzimat".
class AuthorRow extends StatelessWidget {
  const AuthorRow({
    required this.name,
    required this.era,
    this.photo,
    this.onTap,
    super.key,
  });

  /// "Namık Kemal".
  final String name;

  /// "Tanzimat".
  final String era;

  /// The photo's path under `assets` ("/authors/a/namikkemal.png"); `null`
  /// draws the initials.
  final String? photo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return MergeSemantics(
      child: Semantics(
        button: onTap != null,
        onTap: onTap,
        label: l10n.literature_authorA11y(name, era),
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
                      Text(
                        era,
                        style: text.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
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
