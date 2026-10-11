import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The missing-items tag (C08 "EksikTag"; Tur 5 G3; screens 3.1 subject tiles,
/// 7.2 topic rows, 7.3 sub-topic, item and card sheet, 8.1 card).
///
/// A flag icon and the word "eksik" in amber: 24 high, 8 side padding, radius
/// 8, 4 between the icon and the text, `eksik` on `eksikBg`. The text is
/// 13/20 · 600 (the note says 600, the screen CSS 700; 600 is used). Amber is
/// "eksik" only; red stays for a wrong answer.
///
/// [count] is the number of missing items: "31 eksik". With a null [count] the
/// tag says "Eksik" (an item or a card, not a count). A count of zero draws
/// nothing: "0 eksik" is never written. A count above zero is read "3 eksik"
/// (the flag is decoration). At text scale 1,3 the tag grows and does not cut
/// its text.
class EksikTag extends StatelessWidget {
  const EksikTag({this.count, super.key});

  /// How many items are missing; null is the item-level tag "Eksik", zero
  /// draws nothing.
  final int? count;

  /// Visible height.
  static const double height = 24;

  /// Edge of the flag icon.
  static const double _iconSize = 14;

  @override
  Widget build(BuildContext context) {
    final amount = count;
    if (amount != null && amount <= 0) return const SizedBox.shrink();
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final label = amount == null
        ? l10n.lessons_missingItem
        : l10n.lessons_missingCount(TrFormat.sira(amount));
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: height),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.eksikBg,
            borderRadius: AppRadius.borderSm,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(
                  PhosphorIconsRegular.flag,
                  size: _iconSize,
                  color: colors.eksik,
                ),
                const SizedBox(width: AppSpacing.s4),
                Flexible(
                  child: Text(
                    label,
                    style: context.appText.caption.copyWith(
                      color: colors.eksik,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
