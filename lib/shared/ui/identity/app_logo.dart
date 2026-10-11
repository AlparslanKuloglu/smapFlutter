import 'package:flutter/material.dart';
import 'package:smap/gen/assets.gen.dart';
import 'package:smap/l10n/app_localizations.dart';

/// Which colors the S-route mark is drawn in (board 1.26 "Renkler"; spec §4.1
/// "Üretilecek dosyalar").
enum AppLogoTone {
  /// Navy top hook, orange bottom hook: on a light surface
  /// (`smap_mark.svg`).
  onLight,

  /// White top hook, orange bottom hook: on the navy surface
  /// (`smap_mark_on_navy.svg`).
  onNavy,

  /// One navy color; the weave gap still separates the hooks
  /// (`smap_mark_mono_navy.svg`).
  monoNavy,

  /// One white color (`smap_mark_mono_white.svg`).
  monoWhite,
}

/// The S-route mark (C59 `SmapLogoMark`; board 1.26 "Logo çalışması · S-rota",
/// proposal A; UI guide §5 #23).
///
/// Two hooks of the same shape, turned 180 degrees around the center, woven:
/// navy over orange on the left, orange over navy on the right, with a gap
/// where they cross. The SVG assets in `assets/brand/` carry the geometry
/// (viewBox 600 x 794); the widget fixes only [height] and keeps the aspect
/// (width = 0,756 of the height).
///
/// Rules (board 1.26): inside the app the smallest size is 20 pt (16 px and
/// below only the one-color silhouette); the clear space is one line width on
/// every side; no gradient, glow, shadow, outline or rotation; orange never
/// stands alone. The logo appears in the app only on the splash and sign-in
/// screens, never in the root bands. Read as "SMAP" unless [decorative].
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({
    required this.height,
    this.tone = AppLogoTone.onLight,
    this.decorative = false,
    super.key,
  }) : assert(height >= minHeight, 'The mark is never smaller than 20 pt');

  /// The height; the width follows.
  final double height;
  final AppLogoTone tone;
  final bool decorative;

  /// Smallest size in the app.
  static const double minHeight = 20;

  /// Width over height of the mark (600 / 794).
  static const double aspect = 600 / 794;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final svg = switch (tone) {
      AppLogoTone.onLight => Assets.brand.smapMark,
      AppLogoTone.onNavy => Assets.brand.smapMarkOnNavy,
      AppLogoTone.monoNavy => Assets.brand.smapMarkMonoNavy,
      AppLogoTone.monoWhite => Assets.brand.smapMarkMonoWhite,
    };
    final picture = svg.svg(
      height: height,
      width: height * aspect,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
    if (decorative) return ExcludeSemantics(child: picture);
    return Semantics(
      label: l10n.kit_logoLabel,
      image: true,
      excludeSemantics: true,
      child: picture,
    );
  }
}

/// How the wordmark sits next to the mark.
enum AppLockupLayout {
  /// Mark left, "SMAP" right: the sign-in screen (2.3).
  horizontal,

  /// Mark above, "SMAP" below: the splash (2.1).
  vertical,
}

/// The mark with the "SMAP" wordmark (C59 `SmapLockup`; board 1.26 "Kilit
/// yapılar"; screens 2.1, 2.2, 2.3; UI guide §5 #23).
///
/// The wordmark is Plus Jakarta Sans ExtraBold, tracking -2 %, converted to
/// outlines in the SVG, so it needs no font. Proportions are fixed by the
/// assets: horizontal is 36 pt of mark, 12 gap, "SMAP" 24 pt (108 x 36 in all);
/// vertical is 104 pt of mark, 20 gap, "SMAP" 40 pt (115 x 154 in all).
/// [height] scales the whole lockup; the default is the design size. Use
/// [onNavy] on the navy splash (the top hook and the word turn white).
/// Read as "SMAP".
class AppLockup extends StatelessWidget {
  const AppLockup({
    this.layout = AppLockupLayout.horizontal,
    this.onNavy = false,
    this.height,
    this.decorative = false,
    super.key,
  });

  final AppLockupLayout layout;

  /// White top hook and wordmark, for the navy surface.
  final bool onNavy;

  /// Overall height; the design size when null (36 or 154).
  final double? height;
  final bool decorative;

  /// Design heights of the two layouts.
  static const double horizontalHeight = 36;
  static const double verticalHeight = 153.8;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vertical = layout == AppLockupLayout.vertical;
    final svg = switch ((vertical, onNavy)) {
      (false, false) => Assets.brand.smapLockupHorizontal,
      (false, true) => Assets.brand.smapLockupHorizontalOnNavy,
      (true, false) => Assets.brand.smapLockupVertical,
      (true, true) => Assets.brand.smapLockupVerticalOnNavy,
    };
    final designHeight = vertical ? verticalHeight : horizontalHeight;
    final picture = svg.svg(
      height: height ?? designHeight,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
    if (decorative) return ExcludeSemantics(child: picture);
    return Semantics(
      label: l10n.kit_logoLabel,
      image: true,
      excludeSemantics: true,
      child: picture,
    );
  }
}
