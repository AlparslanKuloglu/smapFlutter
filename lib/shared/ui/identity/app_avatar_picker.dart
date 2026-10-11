import 'package:flutter/material.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';

/// The in-row avatar choice (C57 "AvatarPicker"; board 1.17 "Avatar seçimi";
/// sign-up 2.5, profile 9.1, 9.2; UI guide §5 #22).
///
/// All seven avatars are visible at once (never a one-by-one carousel) and
/// the choice count is written under them ("7 avatar", 13 `textSecondary`;
/// [showCount]). The selected avatar gets a 2 pt gap in [gapColor] (the page
/// color, `bgCanvas`) and a 2 pt `primary` ring outside it. Avatars are 46 pt
/// by default in a spread row (the sign-up size); the kit shows 48 pt
/// 10 apart. Each has a 48 pt touch slot, the row wraps to a second line on a
/// narrow screen. The picker sheet of 9.2 (4 columns of 72 pt, "Bu Avatarı
/// Kullan") is a sheet screen and is built by the profile task.
///
/// A tap plays `AppHaptics.selection()` and reports the index. Each reads as
/// "Avatar 3, seçili".
class AppAvatarPicker extends StatelessWidget {
  const AppAvatarPicker({
    required this.avatars,
    required this.selectedIndex,
    required this.onChanged,
    this.size = 46,
    this.showCount = true,
    this.gapColor,
    super.key,
  });

  /// The avatar pictures, in order (seven in the design).
  final List<ImageProvider> avatars;

  /// The chosen avatar; null when none is chosen yet.
  final int? selectedIndex;

  /// Null disables the picker.
  final ValueChanged<int>? onChanged;

  /// Avatar edge: 46 inline, 48 in the kit.
  final double size;
  final bool showCount;

  /// The color of the gap between an avatar and its ring.
  final Color? gapColor;

  /// Gap and ring widths of the selection (C57: 2 + 2).
  static const double selectionGap = 2;
  static const double selectionRing = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final slot = size < AppSize.touch ? AppSize.touch : size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: AppSpacing.s8,
          children: [
            for (final (i, image) in avatars.indexed)
              _AvatarOption(
                index: i,
                image: image,
                size: size,
                slot: slot,
                selected: i == selectedIndex,
                gapColor: gapColor ?? colors.bgCanvas,
                onTap: onChanged == null ? null : () => onChanged!(i),
                label: l10n.kit_a11yAvatarOption(i + 1),
                selectedLabel: l10n.kit_a11ySelected,
              ),
          ],
        ),
        if (showCount) ...[
          const SizedBox(height: AppSpacing.s8),
          Text(
            l10n.kit_avatarCount(avatars.length),
            style: context.appText.caption.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.index,
    required this.image,
    required this.size,
    required this.slot,
    required this.selected,
    required this.gapColor,
    required this.onTap,
    required this.label,
    required this.selectedLabel,
  });

  final int index;
  final ImageProvider image;
  final double size;
  final double slot;
  final bool selected;
  final Color gapColor;
  final VoidCallback? onTap;
  final String label;
  final String selectedLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final move = context.motion(AppMotion.fast, reduced: AppMotion.fast);
    const out = AppAvatarPicker.selectionGap + AppAvatarPicker.selectionRing;
    return Semantics(
      label: selected ? '$label, $selectedLabel' : label,
      button: true,
      selected: selected,
      enabled: onTap != null,
      excludeSemantics: true,
      onTap: onTap,
      child: AppPressable(
        onTap: onTap == null
            ? null
            : () {
                if (!selected) AppHaptics.selection();
                onTap!();
              },
        scale: 1,
        builder: (context, states) {
          final ring = selected || states.contains(WidgetState.focused);
          return SizedBox.square(
            dimension: slot,
            child: Center(
              child: SizedBox.square(
                dimension: size,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: AppAvatar(
                        name: '',
                        image: image,
                        size: size,
                        decorative: true,
                      ),
                    ),
                    Positioned(
                      left: -out,
                      top: -out,
                      right: -out,
                      bottom: -out,
                      child: IgnorePointer(
                        child: AnimatedContainer(
                          duration: move,
                          curve: AppMotion.standard,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ring
                                  ? colors.primary
                                  : colors.primary.withValues(alpha: 0),
                              width: AppAvatarPicker.selectionRing,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppAvatarPicker.selectionRing,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: ring
                                      ? gapColor
                                      : gapColor.withValues(alpha: 0),
                                  width: AppAvatarPicker.selectionGap,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
