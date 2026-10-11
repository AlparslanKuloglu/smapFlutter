import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/lessons/application/literature_authors.dart';
import 'package:smap/features/lessons/presentation/widgets/author_row.dart';
import 'package:smap/features/lessons/presentation/widgets/eksik_tag.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// The author sheet of "Yazar ve Eserler" (pano 7.4 kare 2; spec §4.F
/// "AuthorSheet").
///
/// The head: the 56 pt avatar (the photo, or the initials in the Edebiyat
/// tones, 17 · 700), the name 20/28 · 700, the era 13/20 · 600 `textSecondary`
/// and the close button. The body (16 down, 24 at the sides): "Hakkında" 17/24
/// · 700 and the biography 16/26 (4 below it), then "Eserleri" 17/24 · 700
/// (16 below) with the works grouped by type: the type 13/20 · 700
/// `textSecondary`, the titles 16/26 joined with " · ". A heading is drawn
/// only when its text exists: no biography, no "Hakkında".
///
/// What the student knows of each work shows without a new component: the
/// titles still missing are amber and bold (read "…, eksik") and an
/// [EksikTag] "2 eksik" sits at the right of "Eserleri". The primary
/// "Öğrendim" is there only while a work is missing; it closes the sheet with
/// `true` and the ViewModel that opened it sends the works. Closing any other
/// way returns `null`.
class AuthorSheet extends StatelessWidget {
  const AuthorSheet({required this.author, super.key});

  final AuthorView author;

  /// Opens the sheet; completes with `true` when "Öğrendim" was pressed.
  static Future<bool?> show({
    required AuthorView author,
    BuildContext? context,
  }) => AppSheet.show<bool>(
    context: context,
    builder: (_) => AuthorSheet(author: author),
  );

  /// The avatar of the head (the row's is 48).
  static const double _avatar = 56;

  /// Space under the biography's heading and above the first work heading.
  static const double _headingGap = AppSpacing.s4;

  /// Gap between the "Eserleri" block and the biography.
  static const double _sectionGap = AppSpacing.s16;

  /// Gap between two work groups.
  static const double _groupGap = AppSpacing.s12;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final canLearn = author.missingProgressIds.isNotEmpty;
    return AppSheetFrame(
      semanticLabel: author.name,
      header: _Head(author: author),
      showClose: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (author.biography.isNotEmpty) ...[
            Semantics(
              header: true,
              child: Text(
                l10n.literature_about,
                style: text.headline.copyWith(color: colors.textPrimary),
              ),
            ),
            const SizedBox(height: _headingGap),
            Text(
              author.biography.join('\n\n'),
              style: text.bodyReading.copyWith(color: colors.textPrimary),
            ),
          ],
          if (author.hasWorks) ...[
            if (author.biography.isNotEmpty)
              const SizedBox(height: _sectionGap),
            _WorksHeading(missing: author.missingCount),
            const SizedBox(height: AppSpacing.s8),
            for (final (index, group) in author.groups.indexed) ...[
              if (index > 0) const SizedBox(height: _groupGap),
              _WorkGroupBlock(group: group),
            ],
          ],
        ],
      ),
      primary: canLearn
          ? AppSheetAction(
              label: l10n.literature_learned,
              onPressed: () => Navigator.of(context).pop(true),
            )
          : null,
    );
  }
}

/// Avatar, name, era and the close button (the sheet's own head).
class _Head extends StatelessWidget {
  const _Head({required this.author});

  final AuthorView author;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s12,
        AppSpacing.s12,
        0,
      ),
      child: Row(
        children: [
          AuthorAvatar(
            name: author.name,
            photo: author.photo,
            size: AuthorSheet._avatar,
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    author.name,
                    style: text.titleMd.copyWith(color: colors.textPrimary),
                  ),
                ),
                Text(
                  author.eraName,
                  style: text.caption.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: PhosphorIconsRegular.x,
            semanticLabel: l10n.common_close,
            variant: AppIconButtonVariant.close,
            focusGapColor: colors.bgRaised,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

/// "Eserleri", with the missing count beside it while a work is missing.
class _WorksHeading extends StatelessWidget {
  const _WorksHeading({required this.missing});

  final int missing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              AppLocalizations.of(context).literature_works,
              style: text.headline.copyWith(color: colors.textPrimary),
            ),
          ),
        ),
        if (missing > 0) EksikTag(count: missing),
      ],
    );
  }
}

/// One type of work: its heading and its titles in a line of text.
class _WorkGroupBlock extends StatelessWidget {
  const _WorkGroupBlock({required this.group});

  final WorkGroup group;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final body = text.bodyReading.copyWith(color: colors.textPrimary);
    final missing = body.copyWith(
      color: colors.eksik,
      fontWeight: FontWeight.w700,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.typeName ?? l10n.literature_otherType,
          style: text.caption.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text.rich(
          TextSpan(
            style: body,
            children: [
              for (final (index, work) in group.works.indexed) ...[
                if (index > 0) const TextSpan(text: ' · '),
                TextSpan(
                  text: work.title,
                  style: work.isMissing ? missing : null,
                  semanticsLabel: work.isMissing
                      ? l10n.literature_workMissingA11y(work.title)
                      : null,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
