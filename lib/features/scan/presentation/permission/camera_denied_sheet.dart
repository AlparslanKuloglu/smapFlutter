import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// "Kamera izni kapalı": the sheet that takes the camera's place once the
/// permission was refused (pano 4.1 kare 2; spec §4.C 4.1).
///
/// A 40 pt `errorBg` circle with a CameraSlash in `error`, the title, the
/// explanation, and the primary "Ayarları Aç" over the quiet "Vazgeç". It
/// pops `true` for "Ayarları Aç" and `false` (or `null` when dismissed) for
/// the rest; opening the settings and checking the permission when the app
/// comes back is the gate's job.
class CameraDeniedSheet extends StatelessWidget {
  const CameraDeniedSheet({super.key});

  /// Opens the sheet; completes `true` when the student asked for the
  /// settings.
  static Future<bool> show({BuildContext? context}) async {
    final answer = await AppSheet.show<bool>(
      context: context,
      builder: (_) => const CameraDeniedSheet(),
    );
    return answer ?? false;
  }

  /// The icon circle and its glyph (pano 4.1 kare 2: 40 and 22).
  static const double _circle = 40;
  static const double _icon = 22;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    return AppSheetFrame(
      semanticLabel: l10n.scan_deniedTitle,
      showClose: false,
      bodyPadding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s16,
        AppSpacing.s24,
        0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.errorBg,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: _circle,
                    child: Center(
                      child: PhosphorIcon(
                        PhosphorIconsRegular.cameraSlash,
                        size: _icon,
                        color: colors.error,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.scan_deniedTitle,
                    style: text.titleMd.copyWith(color: colors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            l10n.scan_deniedBody,
            style: text.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
      primary: AppSheetAction(
        label: l10n.scan_openSettings,
        onPressed: () => Navigator.of(context).pop(true),
      ),
      secondary: AppSheetAction(
        label: l10n.common_cancel,
        variant: AppButtonVariant.quiet,
        onPressed: () => Navigator.of(context).pop(false),
      ),
    );
  }
}
