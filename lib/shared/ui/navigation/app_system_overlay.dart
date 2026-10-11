import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/shared/ui/controls/clear_color.dart';

/// Which surface sits under the status bar (spec C80, C82; Düzeltmeler (b)
/// "Koyu tema eksikleri"; board 1.18 "Durum çubuğu").
enum AppSystemOverlayKind {
  /// The navy root or home band: light icons in both themes (the band is
  /// `bgNavy` also in dark).
  band,

  /// The detail bar on the canvas: dark icons in the light theme, light
  /// icons in the dark theme.
  bar,

  /// The camera flow: always dark, so light icons in both themes.
  camera,
}

/// The `SystemUiOverlayStyle` of each shell surface (C80 "Durum çubuğu açık
/// içerik", C82 "koyu içerik", camera "her temada koyu").
///
/// The status bar itself is transparent (the band or bar draws behind it).
/// `statusBarBrightness` is the iOS name for the background brightness and is
/// the opposite of the icon brightness. The Android navigation bar is
/// transparent too, with no contrast scrim, and follows the same icon rule.
abstract final class AppSystemOverlay {
  /// The style of [kind] under a theme of [theme] brightness.
  static SystemUiOverlayStyle of(AppSystemOverlayKind kind, Brightness theme) {
    final lightIcons = switch (kind) {
      AppSystemOverlayKind.band || AppSystemOverlayKind.camera => true,
      AppSystemOverlayKind.bar => theme == Brightness.dark,
    };
    // The bottom edge follows the page theme, except in the camera flow.
    final lightNavIcons = kind == AppSystemOverlayKind.camera
        ? true
        : theme == Brightness.dark;
    final clear = SmapColors.of(theme).bgCanvas.clear;
    return SystemUiOverlayStyle(
      statusBarColor: clear,
      statusBarIconBrightness: lightIcons ? Brightness.light : Brightness.dark,
      statusBarBrightness: lightIcons ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: clear,
      systemNavigationBarDividerColor: clear,
      systemNavigationBarIconBrightness: lightNavIcons
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );
  }
}

/// Sets the system overlay style while its child is on screen: wrap the band,
/// the bar or the camera page in it (`AnnotatedRegion` under the status bar
/// decides; the topmost region at the top edge wins).
class AppSystemOverlayRegion extends StatelessWidget {
  const AppSystemOverlayRegion({
    required this.kind,
    required this.child,
    super.key,
  });

  final AppSystemOverlayKind kind;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemOverlay.of(kind, Theme.brightnessOf(context)),
      child: child,
    );
  }
}
