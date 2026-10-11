import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';

/// The neutral label (C07 "Etiket"; board 1.11 "Etiket"; UI guide §5 #8).
///
/// Information only, never tappable: 24 high, 8 side padding, radius 8,
/// `bgSunken` fill, no edge, 13/20 · 600 in `textPrimary`. No category gets a
/// colored pill; color lives only in the subject dot. A tag that carries a
/// number says what it counts ("31 eksik", "Az soru", "40 soru"), never a
/// bare "31".
///
/// [icon] is a 14 pt leading Phosphor icon (`arrowSquareOut` for "Web'de");
/// [dot] is the 6 pt `accentLine` dot of "Bu hafta" (the "today" orange).
/// At text scale 1,3 the tag grows to 30 and does not truncate.
class AppTag extends StatelessWidget {
  const AppTag({required this.label, this.icon, this.dot = false, super.key});

  /// "AYT", "TYT", "SOS-2", "31 eksik", "Az soru".
  final String label;

  /// Leading Phosphor icon, 14 pt.
  final IconData? icon;

  /// Leading 6 pt accent dot ("Bu hafta").
  final bool dot;

  /// Visible height.
  static const double height = 24;

  /// Side padding.
  static const double _side = AppSpacing.s8;

  /// Gap between the icon and the text.
  static const double _iconGap = AppSpacing.s4;

  /// Edge of the accent dot and the gap after it.
  static const double _dot = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: height),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.bgSunken,
            borderRadius: AppRadius.borderSm,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _side),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (dot) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.accentLine,
                    ),
                    child: const SizedBox.square(dimension: _dot),
                  ),
                  const SizedBox(width: _dot),
                ] else if (icon case final leading?) ...[
                  PhosphorIcon(leading, size: 14, color: colors.textPrimary),
                  const SizedBox(width: _iconGap),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: context.appText.caption.copyWith(
                      color: colors.textPrimary,
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
