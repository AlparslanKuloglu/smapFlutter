import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/coach/domain/attention_item.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';
import 'package:smap/shared/ui/surfaces/app_row_shell.dart';

/// A student who needs attention (C33 `AttentionRow`; Tur 9 G4; pano 10.1
/// kare 2): "Alparslan Kuloğlu" / "45 gündür deneme okutmadı" / "Son deneme 17
/// Haz. 2026 · TYT".
///
/// At least 64 high, padding 12 / 16, 12 between the parts, **top-aligned**.
/// The 40 pt avatar carries the rule badge at its bottom right (offset −4 / −4):
/// a 22 pt `warningBg` circle, a 14 pt Clock ([AttentionRule.inactive]) or
/// TrendDown ([AttentionRule.netDrop]) in `warning`, ringed 2 pt in the row's
/// surface color. Then the [name] (16/24 · 600), the [sentence] of the rule
/// (15/24, 2 under) and the [evidence] line (13/20 `textSecondary`), and a
/// CaretRight 20 at the top right. The row opens the student's profile.
///
/// The sentence and the evidence are worked out by `AttentionCopy` from the
/// server's data; a missing [evidence] is not drawn. Read as one sentence by
/// [semanticLabel] ("Alparslan Kuloğlu, 45 gündür deneme okutmadı, son deneme
/// 17 Haziran").
class AttentionRow extends StatelessWidget {
  const AttentionRow({
    required this.name,
    required this.sentence,
    required this.rule,
    required this.semanticLabel,
    this.avatar,
    this.evidence,
    this.onTap,
    super.key,
  });

  /// "Alparslan Kuloğlu".
  final String name;

  /// The rule's sentence: "45 gündür deneme okutmadı".
  final String sentence;

  /// Which rule fired; chooses the badge icon.
  final AttentionRule rule;

  /// The whole row as one sentence.
  final String semanticLabel;

  /// The student's picture; initials when null.
  final ImageProvider? avatar;

  /// The proof line: "Son deneme 17 Haz. 2026 · TYT".
  final String? evidence;

  /// Opens the student's profile.
  final VoidCallback? onTap;

  /// The row's minimum height (C33).
  static const double minHeight = 64;

  /// The badge's circle, icon and ring (C33).
  static const double _badge = 22;
  static const double _badgeIcon = 14;
  static const double _badgeRing = 2;

  /// How far the badge sticks out of the avatar's corner (C33: −4).
  static const double _badgeOffset = -4;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final evidenceLine = evidence;
    return Semantics(
      button: onTap != null,
      onTap: onTap,
      label: semanticLabel,
      excludeSemantics: true,
      child: AppRowShell(
        onTap: onTap,
        minHeight: minHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AppAvatar(
                  name: name,
                  image: avatar,
                  size: AppAvatarSize.md,
                  decorative: true,
                ),
                Positioned(
                  right: _badgeOffset,
                  bottom: _badgeOffset,
                  child: _RuleBadge(rule: rule),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: text.titleSm.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.s4 / 2),
                  Text(
                    sentence,
                    style: text.body.copyWith(color: colors.textPrimary),
                  ),
                  if (evidenceLine != null)
                    Text(
                      evidenceLine,
                      style: text.caption.copyWith(color: colors.textSecondary),
                    ),
                ],
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
    );
  }
}

/// The rule badge on the avatar's corner.
class _RuleBadge extends StatelessWidget {
  const _RuleBadge({required this.rule});

  final AttentionRule rule;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.warningBg,
        border: Border.all(
          color: colors.bgSurface,
          width: AttentionRow._badgeRing,
        ),
      ),
      child: SizedBox.square(
        dimension: AttentionRow._badge,
        child: Center(
          child: PhosphorIcon(
            switch (rule) {
              AttentionRule.inactive => PhosphorIconsRegular.clock,
              AttentionRule.netDrop => PhosphorIconsRegular.trendDown,
            },
            size: AttentionRow._badgeIcon,
            color: colors.warning,
          ),
        ),
      ),
    );
  }
}
