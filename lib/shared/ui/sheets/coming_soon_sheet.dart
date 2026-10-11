import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// The "Yakında" sheet (C73 "ComingSoonSheet"; board 1.21 kare 3).
///
/// A 64 pt `infoBg` circle with a Phosphor Hourglass, the title "Yakında",
/// "Bu bölüm henüz hazır değil. Hazır olduğunda burada göreceksin." and one
/// primary "Tamam". There is no "Haber ver" button: the request was never
/// stored (board 1.21). It lives in the kit and the gallery only; no screen
/// or menu opens it (Ek D-4).
class ComingSoonSheet extends StatelessWidget {
  const ComingSoonSheet({super.key});

  /// Opens the sheet; completes when it is closed.
  static Future<void> show({BuildContext? context}) => AppSheet.show<void>(
    context: context,
    builder: (_) => const ComingSoonSheet(),
  );

  /// Top padding above the circle (C73 "üst dolgu 28").
  static const double _topPadding = 28;

  /// The icon circle.
  static const double _circle = 64;
  static const double _icon = 32;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return AppSheetFrame(
      semanticLabel: l10n.kit2_comingSoonTitle,
      showClose: false,
      bodyPadding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        _topPadding,
        AppSpacing.s24,
        0,
      ),
      footerTopPadding: AppSpacing.s24,
      body: Column(
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
                    PhosphorIconsRegular.hourglass,
                    size: _icon,
                    color: colors.info,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Semantics(
            header: true,
            child: Text(
              l10n.kit2_comingSoonTitle,
              textAlign: TextAlign.center,
              style: text.titleMd.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            l10n.kit2_comingSoonBody,
            textAlign: TextAlign.center,
            style: text.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
      primary: AppSheetAction(
        label: l10n.common_ok,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
