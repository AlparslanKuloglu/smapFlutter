import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// "Optik okuma şu an kapalı": the information sheet shown instead of the
/// camera while the reading service is in maintenance (pano 4.10 kare 2; spec
/// §4.C 4.10; flag `FeatureFlags.omrEnabled`).
///
/// A 40 pt `infoBg` circle with a Wrench in `info`, the title and "Kısa bir
/// bakım yapıyoruz. Birazdan tekrar dene.", and the one primary "Tamam". An
/// estimated time is added only when the server gives one; none is invented.
/// It is nobody's fault, so there is no haptic.
class OmrClosedSheet extends StatelessWidget {
  const OmrClosedSheet({super.key});

  /// Opens the sheet; completes when it is closed.
  static Future<void> show({BuildContext? context}) => AppSheet.show<void>(
    context: context,
    builder: (_) => const OmrClosedSheet(),
  );

  static const double _circle = 40;
  static const double _icon = 22;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    return AppSheetFrame(
      semanticLabel: l10n.scan_omrClosedTitle,
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
                    color: colors.infoBg,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: _circle,
                    child: Center(
                      child: PhosphorIcon(
                        PhosphorIconsRegular.wrench,
                        size: _icon,
                        color: colors.info,
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
                    l10n.scan_omrClosedTitle,
                    style: text.titleMd.copyWith(color: colors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            l10n.scan_omrClosedBody,
            style: text.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
      primary: AppSheetAction(
        label: l10n.scan_ok,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
