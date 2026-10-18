import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/text/metric_text.dart';

/// The coach's share code (C35 `CodeCard`; Tur 9 G6; pano 10.1 kare 3, 10.3
/// kare 1 and 2): "Koçluk kodun", the code "MOZK-4821", the line "Öğrencin bu
/// kodu Hesap › Koçluk'a girince sana bağlanır." and two equal outlined
/// buttons, "Kopyala" and "Paylaş".
///
/// Padding 16, `bgSurface`, radius 16 with an inner 1 pt `borderSubtle` edge:
/// the one card with an edge (C35). The code is `metricMd` (24/32 · 700) with
/// 1 pt letter spacing, 2 under the label; the help line 4 under it; the
/// buttons 12 under that, 8 apart, the 40 pt (`md`) size with Copy and
/// ShareNetwork icons (the board draws 44; decision Ç-25 puts them on the
/// kit's `md`). The code is read as "Koçluk kodun MOZK-4821".
///
/// The card draws only for a code that exists; whoever places it checks that
/// first. [onShare] gets the share button's rectangle so an iPad can anchor
/// its popover.
class CodeCard extends StatelessWidget {
  const CodeCard({
    required this.code,
    required this.onCopy,
    required this.onShare,
    super.key,
  });

  /// The code as the server holds it, shown as `MOZK-4821`.
  final String code;

  /// "Kopyala": copies [code] and shows the toast.
  final VoidCallback onCopy;

  /// "Paylaş": opens the share sheet, anchored at the given rectangle.
  final ValueChanged<Rect?> onShare;

  /// The letter spacing of the code (C35: 1).
  static const double codeSpacing = 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.coachWidgets_codeTitle,
              style: text.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s4 / 2),
            Semantics(
              label: l10n.coachWidgets_codeA11y(code),
              excludeSemantics: true,
              child: Text(
                code,
                style: MetricSize.md
                    .styleOf(text)
                    .copyWith(
                      letterSpacing: codeSpacing,
                      color: colors.textPrimary,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              l10n.coachWidgets_codeHint,
              style: text.caption.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l10n.coachWidgets_codeCopy,
                    onPressed: onCopy,
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.md40,
                    icon: PhosphorIconsRegular.copy,
                    expand: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Builder(
                    builder: (buttonContext) => AppButton(
                      label: l10n.coachWidgets_codeShare,
                      onPressed: () => onShare(originOf(buttonContext)),
                      variant: AppButtonVariant.outline,
                      size: AppButtonSize.md40,
                      icon: PhosphorIconsRegular.shareNetwork,
                      expand: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The button's rectangle on screen, for the iPad share popover.
  static Rect? originOf(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}
