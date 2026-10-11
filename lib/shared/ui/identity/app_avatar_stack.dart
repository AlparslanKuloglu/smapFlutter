import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';

/// A person in an [AppAvatarStack].
typedef AvatarPerson = ({String name, ImageProvider? image});

/// Overlapping avatars with a "+N" circle (C56 "AvatarStack"; board 1.17 "Üst
/// üste"; the coach's students on 10.1 and 10.2; UI guide §5 #22).
///
/// At most [maxShown] (3) avatars of 32 pt, each ringed 2 pt in
/// [ringColor] (white; `bgSurface`) and overlapping 8 pt; later avatars
/// lie over earlier ones. More people than that become a 32 pt `bgSunken`
/// circle with "+N" (13 · 700) after the last avatar. The empty-state variant
/// ([AppAvatarStack.large]) is 72 pt, overlaps 16 pt and has a 4 pt `bgCanvas`
/// ring.
///
/// Read as one phrase: "Elif Şahin, Kerem Aydın, Zeynep Kaya ve 2 öğrenci
/// daha" (the names shown, then the rest by count).
class AppAvatarStack extends StatelessWidget {
  const AppAvatarStack({
    required this.people,
    this.size = AppAvatarSize.sm,
    this.overlap = AppSpacing.s8,
    this.ringWidth = 2,
    this.ringColor,
    this.maxShown = 3,
    super.key,
  });

  /// The 72 pt empty-state variant of the coach screens (overlap 16, 4 pt
  /// ring in the canvas color).
  const AppAvatarStack.large({
    required this.people,
    this.ringColor,
    this.maxShown = 3,
    super.key,
  }) : size = AppAvatarSize.sheet,
       overlap = AppSpacing.s16,
       ringWidth = 4;

  final List<AvatarPerson> people;
  final double size;
  final double overlap;
  final double ringWidth;

  /// The ring color; `bgSurface` for the standard stack, `bgCanvas` for
  /// [AppAvatarStack.large] when null and the stack is large.
  final Color? ringColor;
  final int maxShown;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final shown = people.take(maxShown).toList(growable: false);
    final extra = people.length - shown.length;
    final ring =
        ringColor ??
        (size == AppAvatarSize.sheet ? colors.bgCanvas : colors.bgSurface);
    final outer = size + 2 * ringWidth;
    final step = outer - overlap;
    final count = shown.length + (extra > 0 ? 1 : 0);

    Widget ringed({required Widget child}) => DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: ringWidth),
        color: ring,
      ),
      child: child,
    );

    final label = extra > 0
        ? '${shown.map((p) => p.name).join(', ')} ${l10n.kit_a11yMoreStudents(extra)}'
        : shown.map((p) => p.name).join(', ');

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: SizedBox(
        width: outer + (count - 1) * step,
        height: outer,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final (i, person) in shown.indexed)
              Positioned(
                left: i * step,
                child: ringed(
                  child: AppAvatar(
                    name: person.name,
                    image: person.image,
                    size: size,
                    decorative: true,
                  ),
                ),
              ),
            if (extra > 0)
              Positioned(
                left: shown.length * step,
                child: ringed(
                  child: SizedBox.square(
                    dimension: size,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.bgSunken,
                      ),
                      child: Center(
                        child: Text(
                          '+$extra',
                          style: text.caption.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
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
    );
  }
}
