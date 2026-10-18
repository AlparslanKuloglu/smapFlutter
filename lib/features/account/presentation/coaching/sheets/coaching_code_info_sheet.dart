import 'package:flutter/material.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// The small explanation sheet of the student's coaching code (pano 9.5 kare 4
/// "Koçluk Kodu Nedir?"). The coach's code has its own sheet (pano 14.11,
/// `CoachCodeSheet`).
///
/// No close button and no icon; the title, two paragraphs (16/26) and the
/// primary "Tamam" (the handle and the scrim also close it). Opens in the
/// root navigator, so it covers the bottom bar.
class CoachingCodeInfoSheet extends StatelessWidget {
  const CoachingCodeInfoSheet({super.key});

  /// Opens the sheet; completes when it is closed.
  static Future<void> show({BuildContext? context}) => AppSheet.show<void>(
    context: context,
    builder: (_) => const CoachingCodeInfoSheet(),
  );

  /// Body top padding (pano 9.5 kare 4: "dolgu 20 24 0").
  static const double _topPadding = 20;

  /// Space above the paragraphs (pano 9.5 kare 4: "margin-top 10").
  static const double _paragraphGap = 10;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final title = l10n.coachingInfo_title;
    final paragraphs = [l10n.coachingInfo_body1, l10n.coachingInfo_body2];
    return AppSheetFrame(
      semanticLabel: title,
      showClose: false,
      bodyPadding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        _topPadding,
        AppSpacing.s24,
        0,
      ),
      footerTopPadding: AppSpacing.s24,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: text.titleMd.copyWith(color: colors.textPrimary),
            ),
          ),
          for (final paragraph in paragraphs) ...[
            const SizedBox(height: _paragraphGap),
            Text(
              paragraph,
              style: text.bodyReading.copyWith(color: colors.textPrimary),
            ),
          ],
        ],
      ),
      primary: AppSheetAction(
        label: l10n.common_ok,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
