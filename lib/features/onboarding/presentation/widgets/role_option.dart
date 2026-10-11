import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/controls/app_radio.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';

/// One choice of the role screen (C38 "RoleOption"; pano 2.2 kare 1 "Rol",
/// 11.13): a full-width card with a 56 pt avatar, the title "Öğrenciyim" or
/// "Öğrenci Koçuyum" and one sentence ("Denemelerini okut, eksiklerini
/// kapat."), and the radio mark at the right.
///
/// Padding 16 and radius 16 on `bgSurface`; a 1 pt `borderSubtle` edge, 2 pt
/// `primary` when [selected] (the edge is drawn over the card, so nothing
/// moves). Title 17/24 · 700, sentence 15/24 `textSecondary` 2 below. The
/// whole card is the target (56 + 32 high); it is one option of a radio group
/// and reads as "Öğrenciyim, Denemelerini okut, eksiklerini kapat., seçili".
class RoleOption extends StatelessWidget {
  const RoleOption({
    required this.title,
    required this.description,
    required this.avatar,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;

  /// The caricature of the role.
  final ImageProvider avatar;
  final bool selected;
  final VoidCallback onTap;

  /// Edge widths of the card: rest and selected.
  static const double _restEdge = 1;
  static const double _selectedEdge = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final move = context.motion(AppMotion.fast, reduced: AppMotion.fast);
    return Semantics(
      label: '$title, $description',
      inMutuallyExclusiveGroup: true,
      checked: selected,
      excludeSemantics: true,
      onTap: onTap,
      child: AppPressable(
        onTap: onTap,
        haptic: true,
        builder: (context, states) => AppFocusRing(
          focused: states.contains(WidgetState.focused),
          borderRadius: AppRadius.borderLg,
          child: AnimatedContainer(
            duration: move,
            curve: AppMotion.standard,
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: colors.bgSurface,
              borderRadius: AppRadius.borderLg,
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: selected ? colors.primary : colors.borderSubtle,
                width: selected ? _selectedEdge : _restEdge,
              ),
            ),
            child: Row(
              children: [
                AppAvatar(
                  name: title,
                  image: avatar,
                  size: AppAvatarSize.lg,
                  decorative: true,
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: text.headline.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: text.body.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
                // The mark is 24; the radio's own 48 target overflows the box
                // and takes no taps: the card is the target.
                SizedBox(
                  width: AppRadio.mark,
                  height: AppRadio.mark,
                  child: OverflowBox(
                    maxWidth: AppSize.touch,
                    maxHeight: AppSize.touch,
                    child: ExcludeSemantics(
                      child: IgnorePointer(
                        child: AppRadio<bool>(
                          value: true,
                          groupValue: selected,
                          onChanged: (_) {},
                          semanticLabel: title,
                        ),
                      ),
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
