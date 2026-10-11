import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/smap_text.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/identity/avatar_initials.dart';

/// The avatar edges the design uses (C55 "Boylar ve kullanım yeri").
abstract final class AppAvatarSize {
  /// Context strip.
  static const double xs = 24;

  /// Lists, the shrunken home band.
  static const double sm = 32;

  /// Meeting row.
  static const double meeting = 36;

  /// Cards and rows, the home band.
  static const double md = 40;

  /// Student tile.
  static const double tile = 48;

  /// Account summary, role option.
  static const double lg = 56;

  /// Coach card.
  static const double coachCard = 64;

  /// Avatar sheet, empty state.
  static const double sheet = 72;

  /// Avatar choice in the kit.
  static const double xl = 96;
}

/// The person avatar (C55 "Avatar"; board 1.17 "Avatar ve ikonlar"; UI guide
/// §5 #22).
///
/// A circle that the [image] fills (the 3D caricature set; `AssetImage` or a
/// network image), on a `borderSubtle` fill while it loads. When there is
/// no image or it fails to load, the person's initials show instead: on
/// `infoBg` in `textAction`, 700 ("AK"). Sizes are in [AppAvatarSize].
///
/// [coach] adds the word badge "Koç" at the bottom right (a navy 20 pt pill
/// with a 2 pt ring in the surface color, `-14 / -6` from the corner): a
/// word, not an icon; students carry no badge. The user name and avatar show
/// only on the home screen and in the account area, not in a top bar.
///
/// Read as the person's [name] (and ", koç" for a coach: "Mehmet Özkan,
/// koç"); set [decorative] when a text beside it already says the name.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.name,
    this.image,
    this.size = AppAvatarSize.md,
    this.coach = false,
    this.decorative = false,
    this.ringColor,
    super.key,
  });

  /// The person's full name, for the initials and the accessible name.
  final String name;

  /// The picture; initials when null or when it fails.
  final ImageProvider? image;

  /// The edge of the circle.
  final double size;

  /// Shows the "Koç" badge.
  final bool coach;

  /// Leaves the avatar out of the semantics tree.
  final bool decorative;

  /// Color of the 2 pt ring around the coach badge; `bgSurface` when null.
  final Color? ringColor;

  /// The coach badge: height, side padding and ring (C55).
  static const double badgeHeight = 20;
  static const double _badgeSide = 6;
  static const double _badgeRing = 2;

  /// Where the badge sits relative to the avatar's corner (C55: -14 / -6).
  static const double _badgeRight = -14;
  static const double _badgeBottom = -6;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final initials = _Initials(
      name: name,
      size: size,
      background: colors.infoBg,
      ink: colors.textAction,
    );
    final picture = image;
    final face = ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: picture == null
            ? initials
            : ColoredBox(
                color: colors.borderSubtle,
                child: Image(
                  image: picture,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  errorBuilder: (context, error, stack) => initials,
                ),
              ),
      ),
    );

    Widget avatar = face;
    if (coach) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          face,
          Positioned(
            right: _badgeRight,
            bottom: _badgeBottom,
            child: _CoachBadge(
              label: l10n.kit_coachBadge,
              ringColor: ringColor ?? colors.bgSurface,
            ),
          ),
        ],
      );
    }
    if (decorative) return ExcludeSemantics(child: avatar);
    return Semantics(
      label: coach ? l10n.kit_a11yCoachAvatar(name) : name,
      image: true,
      excludeSemantics: true,
      child: avatar,
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({
    required this.name,
    required this.size,
    required this.background,
    required this.ink,
  });

  final String name;
  final double size;
  final Color background;
  final Color ink;

  /// The initials style that fits an avatar of [size]: 13 pt up to 32, then
  /// larger steps of the type scale so the letters keep the same share of the
  /// circle.
  static TextStyle styleFor(SmapText text, double size) {
    if (size <= 32) return text.caption;
    if (size <= 48) return text.labelLg;
    if (size <= 72) return text.titleMd;
    return text.titleLg;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background,
      child: Center(
        child: Text(
          AvatarInitials.of(name),
          style: styleFor(
            context.appText,
            size,
          ).copyWith(color: ink, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _CoachBadge extends StatelessWidget {
  const _CoachBadge({required this.label, required this.ringColor});

  final String label;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: ringColor, width: AppAvatar._badgeRing),
      ),
      child: SizedBox(
        height: AppAvatar.badgeHeight + 2 * AppAvatar._badgeRing,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppAvatar._badgeSide),
          child: Center(
            child: Text(
              label,
              style: context.appText.caption.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
