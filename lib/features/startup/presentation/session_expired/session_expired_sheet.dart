import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// "Oturumun sona erdi" (pano 2.7 kare 2; spec §3.4, C71).
///
/// A small sheet above any screen: a 40 pt `infoBg` circle with a clock, the
/// title, "Güvenliğin için yeniden giriş yapman gerekiyor. Okuttuğun
/// denemeler hesabında duruyor." and one primary "Giriş Yap". The scrim, the
/// drag and the Android back button do not close it; the button is the only
/// way out and completes [show] with `true`.
class SessionExpiredSheet extends StatelessWidget {
  const SessionExpiredSheet({super.key});

  /// Opens the sheet on the root navigator (no [BuildContext]: the session
  /// manager's flow has none). Completes with `true` when "Giriş Yap" was
  /// pressed and `false` when no navigator was there to show it.
  static Future<bool> show({BuildContext? context}) async {
    final result = await AppSheet.show<bool>(
      context: context,
      dismissible: false,
      builder: (_) => const SessionExpiredSheet(),
    );
    return result ?? false;
  }

  /// The icon circle and the clock inside it.
  static const double _circle = 40;
  static const double _icon = 22;

  /// Body top padding (spec "dolgu 20/24/0").
  static const double _topPadding = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return AppSheetFrame(
      semanticLabel: l10n.startup_sessionExpiredTitle,
      showClose: false,
      // Back and the close gesture ask first; the answer is "no".
      onCloseAttempt: () {},
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
                        PhosphorIconsRegular.clock,
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
                    l10n.startup_sessionExpiredTitle,
                    style: text.titleMd.copyWith(color: colors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.startup_sessionExpiredBody,
              style: text.body.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
      primary: AppSheetAction(
        label: l10n.startup_sessionExpiredAction,
        autofocus: true,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
