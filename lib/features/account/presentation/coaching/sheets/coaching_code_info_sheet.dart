import 'package:flutter/material.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// Whose words the sheet speaks: the student asks what the code is that the
/// coach gave; the coach asks what the code does for their students.
enum CodeInfoAudience {
  /// "Koçluk kodu nedir?" (pano 9.5 kare 4), on the student's Koçluk screen.
  student,

  /// "Koçluk kodu ne işe yarar?" (Tur 12 G, 14.11 kare 2), on the coach's
  /// Hesap. The coach's screen belongs to E14a; this variant only holds the
  /// words.
  coach,
}

/// The small explanation sheet of the coaching code (pano 9.5 kare 4
/// "Koçluk Kodu Nedir?"; Tur 12 G).
///
/// No close button and no icon; the title, two paragraphs (16/26) and the
/// primary "Tamam" (the handle and the scrim also close it). Opens in the
/// root navigator, so it covers the bottom bar.
class CoachingCodeInfoSheet extends StatelessWidget {
  const CoachingCodeInfoSheet({required this.audience, super.key});

  final CodeInfoAudience audience;

  /// Opens the sheet; completes when it is closed.
  static Future<void> show({
    required CodeInfoAudience audience,
    BuildContext? context,
  }) => AppSheet.show<void>(
    context: context,
    builder: (_) => CoachingCodeInfoSheet(audience: audience),
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
    final student = audience == CodeInfoAudience.student;
    final title = student
        ? l10n.coachingInfo_title
        : l10n.coachingInfo_coachTitle;
    final paragraphs = student
        ? [l10n.coachingInfo_body1, l10n.coachingInfo_body2]
        : [l10n.coachingInfo_coachBody1, l10n.coachingInfo_coachBody2];
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
