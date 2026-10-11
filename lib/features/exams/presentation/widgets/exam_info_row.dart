import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

/// The info row card of the result moment (C26 "ExamHeader", "Bilgi satırı
/// kartı"; pano 5.1 "Bu denemeden 23 bilgi kartı eklendi").
///
/// A card at least 64 high, padding 12 / 16, 12 between the parts: a 40 pt
/// circle in `infoBg` with a 22 pt Cards icon in `info`, the sentence 15/24 ·
/// 600 and a CaretRight 20. The whole card opens the cards tab of the exam.
/// The sentence comes from the caller.
class ExamInfoRow extends StatelessWidget {
  const ExamInfoRow({required this.text, required this.onTap, super.key});

  /// "Bu denemeden 23 bilgi kartı eklendi".
  final String text;
  final VoidCallback? onTap;

  /// Minimum height of the card.
  static const double minHeight = 64;

  /// Edge of the icon circle.
  static const double _circle = 40;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = context.appText;
    return AppCard(
      onTap: onTap,
      semanticLabel: text,
      padding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.infoBg,
                  borderRadius: AppRadius.borderFull,
                ),
                child: SizedBox.square(
                  dimension: _circle,
                  child: Center(
                    child: PhosphorIcon(
                      PhosphorIconsRegular.cards,
                      size: 22,
                      color: colors.info,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Text(
                  text,
                  style: style.bodyStrong.copyWith(color: colors.textPrimary),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              PhosphorIcon(
                PhosphorIconsRegular.caretRight,
                size: AppSize.iconInButton,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
