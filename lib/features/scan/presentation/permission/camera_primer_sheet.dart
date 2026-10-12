import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/scan/application/scan_launcher.dart';
import 'package:smap/features/scan/presentation/widgets/omr_illustrations.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// "Formunu okutmak için kamera gerekli": the sheet before the system's
/// camera dialog (pano 4.1 kare 1; flow 13.4; spec §4.C 4.1).
///
/// It opens over the screen the student tapped "Okut" on, as tall as its
/// content (the board's sheet is about half the screen): the optical form in its four navy corners (160 x 170), the
/// title (20/28), one sentence (15/24, `textSecondary`) and the primary
/// "Kameraya İzin Ver" over the quiet "Sonra". No haptic: a permission is
/// not a mistake.
///
/// It pops a [PrimerAnswer]; a dismissal (drag, scrim) is `null`, which the
/// gate treats as "Sonra" without remembering the primer as answered.
class CameraPrimerSheet extends StatelessWidget {
  const CameraPrimerSheet({super.key});

  /// Opens the sheet; completes with the answer, `null` when dismissed.
  static Future<PrimerAnswer?> show({BuildContext? context}) =>
      AppSheet.show<PrimerAnswer>(
        context: context,
        builder: (_) => const CameraPrimerSheet(),
      );

  /// Body padding of the board: 24, 24, 24, 0.
  static const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(
    AppSpacing.s24,
    AppSpacing.s24,
    AppSpacing.s24,
    0,
  );

  /// Space above the title (pano 4.1: 20) and between title and sentence.
  static const double _titleGap = 20;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    return AppSheetFrame(
      semanticLabel: l10n.scan_primerTitle,
      showClose: false,
      bodyPadding: _bodyPadding,
      body: Column(
        children: [
          const Center(child: OmrPrimerIllustration()),
          const SizedBox(height: _titleGap),
          Semantics(
            header: true,
            child: Text(
              l10n.scan_primerTitle,
              textAlign: TextAlign.center,
              style: text.titleMd.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            l10n.scan_primerBody,
            textAlign: TextAlign.center,
            style: text.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
      primary: AppSheetAction(
        label: l10n.scan_primerAllow,
        onPressed: () => Navigator.of(context).pop(PrimerAnswer.allow),
      ),
      secondary: AppSheetAction(
        label: l10n.scan_primerLater,
        variant: AppButtonVariant.quiet,
        onPressed: () => Navigator.of(context).pop(PrimerAnswer.later),
      ),
    );
  }
}
