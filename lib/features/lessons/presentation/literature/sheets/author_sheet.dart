import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/lessons/application/literature_authors.dart';
import 'package:smap/features/lessons/application/literature_service.dart';
import 'package:smap/features/lessons/presentation/literature/sheets/author_sheet_viewmodel.dart';
import 'package:smap/features/lessons/presentation/widgets/author_row.dart';
import 'package:smap/features/lessons/presentation/widgets/work_row.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// The author sheet of Yazar ve Eserler (pano 14.6 kare 1 to 3, 14.7 kare 3
/// and 4; replaces 7.4 kare 2; spec §4.F "AuthorSheet").
///
/// A full-size sheet (1.20). The head: the 56 pt avatar (the photo, or the
/// initials in the Edebiyat tones), the name 20/28 · 700, the era 13/20 · 600
/// `textSecondary` and the close button. The body (16 down, 24 at the sides):
/// "Hakkında" 17/24 · 700 and the biography 16/26, then "Eserleri" with the
/// counter "8 eser · 2 eksik" at its right, and the works in groups by type:
/// the heading 13/20 · 700 `textSecondary` ("Roman · 2") and a [WorkRow] per
/// work. A missing work has "Eksik" and "Öğrendim"; a known one has the check
/// and "Biliyorsun"; a work with no status has only its name and is not
/// counted as missing. An author without works gets the sentence "Bu yazarın
/// eser listesi henüz yok.". There is no author-level "Öğrendim" and no action
/// band.
///
/// The sheet reads the author from [LiteratureService] by its keys, so
/// "Öğrendim" changes the row, the counter and every count behind the sheet
/// together; the toast with "Geri Al" comes from the service. While the device
/// is offline the strip shows above the sheet, the buttons are off and the
/// first missing work says why. Closing returns nothing.
class AuthorSheet extends StatelessWidget {
  const AuthorSheet({
    required this.service,
    required this.eraId,
    required this.subId,
    required this.authorKey,
    super.key,
  });

  final LiteratureService service;
  final String eraId;
  final String subId;
  final String authorKey;

  /// Opens the sheet on the root navigator, with the offline strip above it
  /// while [online] is false.
  static Future<void> show({
    required LiteratureService service,
    required String eraId,
    required String subId,
    required String authorKey,
    ValueListenable<bool>? online,
    BuildContext? context,
  }) => AppSheet.show<void>(
    context: context,
    size: AppSheetSize.full,
    online: online ?? service.online,
    builder: (_) => AuthorSheet(
      service: service,
      eraId: eraId,
      subId: subId,
      authorKey: authorKey,
    ),
  );

  /// The avatar of the head (the row's is 48).
  static const double _avatar = 56;

  /// Space between the biography and the "Eserleri" block.
  static const double _sectionGap = AppSpacing.s24;

  /// Space between two work groups.
  static const double _groupGap = AppSpacing.s16;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthorSheetViewModel>.reactive(
      viewModelBuilder: () => AuthorSheetViewModel(
        service: service,
        eraId: eraId,
        subId: subId,
        authorKey: authorKey,
      ),
      builder: (context, viewModel, _) {
        final author = viewModel.author;
        if (author == null) return const SizedBox.shrink();
        return AppSheetFrame(
          semanticLabel: AppLocalizations.of(
            context,
          ).literature_sheetA11y(author.name, viewModel.eraName),
          header: _Head(author: author, eraName: viewModel.eraName),
          showClose: false,
          body: _Body(author: author, viewModel: viewModel),
        );
      },
    );
  }
}

/// Avatar, name, era and the close button (the sheet's own head).
class _Head extends StatelessWidget {
  const _Head({required this.author, required this.eraName});

  final AuthorView author;
  final String eraName;

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
                if (eraName.isNotEmpty)
                  Text(
                    eraName,
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

/// "Hakkında" and "Eserleri" with the groups of works.
class _Body extends StatelessWidget {
  const _Body({required this.author, required this.viewModel});

  final AuthorView author;
  final AuthorSheetViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return Column(
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
          const SizedBox(height: AppSpacing.s4),
          for (final (index, paragraph) in author.biography.indexed) ...[
            if (index > 0) const SizedBox(height: AppSpacing.s8),
            Text(
              paragraph,
              style: text.bodyReading.copyWith(color: colors.textPrimary),
            ),
          ],
          const SizedBox(height: AuthorSheet._sectionGap),
        ],
        _WorksHeading(author: author),
        const SizedBox(height: AppSpacing.s8),
        if (!author.hasWorks)
          Text(
            l10n.literature_noWorks,
            style: text.bodyReading.copyWith(color: colors.textSecondary),
          )
        else
          for (final (index, group) in author.groups.indexed) ...[
            if (index > 0) const SizedBox(height: AuthorSheet._groupGap),
            _WorkGroupBlock(group: group, viewModel: viewModel),
          ],
      ],
    );
  }
}

/// "Eserleri" and, at the right, "8 eser · 2 eksik" ("8 eser" when nothing is
/// missing; nothing for an author without works).
class _WorksHeading extends StatelessWidget {
  const _WorksHeading({required this.author});

  final AuthorView author;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final count = author.workCount;
    final missing = author.missingCount;
    final counter = count == 0
        ? null
        : missing > 0
        ? l10n.literature_worksCounter(
            TrFormat.sira(count),
            TrFormat.sira(missing),
          )
        : l10n.literature_workCount(TrFormat.sira(count));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              l10n.literature_works,
              style: text.headline.copyWith(color: colors.textPrimary),
            ),
          ),
        ),
        if (counter != null)
          Semantics(
            liveRegion: true,
            child: Text(
              counter,
              style: text.caption.copyWith(color: colors.textSecondary),
            ),
          ),
      ],
    );
  }
}

/// One type of work: its heading "Roman · 2" and a row per work.
class _WorkGroupBlock extends StatelessWidget {
  const _WorkGroupBlock({required this.group, required this.viewModel});

  final WorkGroup group;
  final AuthorSheetViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final noteFor = viewModel.offlineNoteFor;
    final online = viewModel.isOnline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.literature_typeHeading(
              group.typeName ?? l10n.literature_otherType,
              TrFormat.sira(group.works.length),
            ),
            style: text.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (final (index, work) in group.works.indexed) ...[
          if (index > 0)
            Divider(height: 1, thickness: 1, color: colors.borderSubtle),
          WorkRow(
            key: ValueKey('${work.progressId}:${work.title}'),
            title: work.title,
            state: work.card,
            typeName: group.typeName,
            offlineNote: noteFor != null && work.progressId == noteFor,
            onLearn: online && work.canLearn
                ? () => viewModel.learn(work.progressId!)
                : null,
          ),
        ],
      ],
    );
  }
}
