import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/controls/clear_color.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';

/// The profile summary in the Hesap band (C37 "ProfileSummary"; pano 9.1 kare
/// 1 and 4; spec 2.2): a 56 pt avatar, the name (17/24 · 700, white), up to
/// two 13/20 lines under it in `textOnNavy2` ("12. Sınıf · Eşit Ağırlık",
/// "Koçun: Mehmet Özkan"; a coach's "Öğrenci koçu", "Koçluk kodun:
/// MOZK-4821") and a CaretRight 20 at the right.
///
/// The whole row is one touch target that opens the profile; it is read as
/// one button, [semanticLabel] ("Profil: Alparslan Kuloğlu, 12. Sınıf, Eşit
/// Ağırlık, koçun Mehmet Özkan"). Padding 4 / 16 / 0 with 14 between the
/// parts (the band adds the 20 under it). Pressed: a `bgNavyRaised` wash.
class ProfileSummary extends StatelessWidget {
  const ProfileSummary({
    required this.name,
    required this.lines,
    required this.semanticLabel,
    this.avatar,
    this.hint,
    this.onTap,
    super.key,
  });

  /// "Alparslan Kuloğlu".
  final String name;

  /// The lines under the name, at most two.
  final List<String> lines;

  /// What the screen reader says for the whole row.
  final String semanticLabel;

  /// The avatar picture; the initials of [name] show when it is null or fails.
  final ImageProvider? avatar;

  /// The reading hint ("Profili açar").
  final String? hint;

  /// Opens the profile; null makes the row static.
  final VoidCallback? onTap;

  /// Space between the avatar, the text and the caret (spec 2.2).
  static const double gap = 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      hint: hint,
      excludeSemantics: true,
      onTap: onTap,
      child: AppPressable(
        onTap: onTap,
        scale: 1,
        builder: (context, states) => AppFocusRing(
          focused: states.contains(WidgetState.focused),
          style: AppFocusRingStyle.inset,
          borderRadius: AppRadius.borderMd,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: states.contains(WidgetState.pressed)
                  ? colors.bgNavyRaised
                  : colors.bgNavyRaised.clear,
              borderRadius: AppRadius.borderMd,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.s4,
                AppSpacing.gutter,
                0,
              ),
              child: Row(
                children: [
                  AppAvatar(
                    name: name,
                    image: avatar,
                    size: AppAvatarSize.lg,
                    decorative: true,
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.barTitle.copyWith(
                            color: colors.textOnNavy,
                          ),
                        ),
                        for (final line in lines)
                          Text(
                            line,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.caption.copyWith(
                              color: colors.textOnNavy2,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: gap),
                    PhosphorIcon(
                      PhosphorIconsRegular.caretRight,
                      size: AppSize.iconInButton,
                      color: colors.textOnNavy2,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
