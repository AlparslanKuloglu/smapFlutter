import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_glyph.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// The "Web'de" sheet of a web-only lesson (pano 7.1 kare 3; spec §4.F
/// "WebOnlySheet"; Ek D-5).
///
/// A small sheet: the lesson's glyph tile 40 and "Kavram haritan web'de" 20/28
/// · 700 (6 down from the tile's top), under them 12 below "Matematik ve
/// Geometri kavram haritan şimdilik smaptr.com'da." 15/24 `textSecondary`, then
/// the primary "Web'de Aç" with ArrowSquareOut and the quiet "Tamam". There is
/// no "Haber ver": the request was never stored.
///
/// It returns `true` for "Web'de Aç" and `false` (or nothing) otherwise; the
/// ViewModel that opened it opens the browser.
class WebOnlySheet extends StatelessWidget {
  const WebOnlySheet({required this.subject, required this.host, super.key});

  /// The lesson's subject color; `null` draws a neutral tile.
  final SubjectKey? subject;

  /// The site's address as written in the sentence ("smaptr.com").
  final String host;

  /// Opens the sheet and completes with whether "Web'de Aç" was pressed.
  static Future<bool> show({
    required SubjectKey? subject,
    required String host,
    BuildContext? context,
  }) async {
    final open = await AppSheet.show<bool>(
      context: context,
      builder: (_) => WebOnlySheet(subject: subject, host: host),
    );
    return open ?? false;
  }

  /// The title sits 6 below the top of the tile (board: padding-top 6).
  static const double _titleTop = 6;

  /// Body padding above the title block (C71 "dolgu 24/24/0").
  static const double _topPadding = AppSpacing.s24;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return AppSheetFrame(
      semanticLabel: l10n.lessons_webSheetTitle,
      showClose: false,
      bodyPadding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        _topPadding,
        AppSpacing.s24,
        0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubjectGlyph(subject: subject),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: _titleTop),
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.lessons_webSheetTitle,
                      style: text.titleMd.copyWith(color: colors.textPrimary),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            l10n.lessons_webSheetBody(host),
            style: text.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
      primary: AppSheetAction(
        label: l10n.lessons_webSheetOpen,
        icon: PhosphorIconsRegular.arrowSquareOut,
        onPressed: () => Navigator.of(context).pop(true),
      ),
      secondary: AppSheetAction(
        label: l10n.common_ok,
        variant: AppButtonVariant.quiet,
        onPressed: () => Navigator.of(context).pop(false),
      ),
    );
  }
}
