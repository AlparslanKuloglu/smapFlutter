import 'package:flutter/material.dart';
import 'package:mihr_ui/mihr_ui.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/smap_palette.dart';
import 'package:smap/core/theme/smap_text.dart';

/// The SMAP `ThemeData` for light and dark (spec §1.15; UI guide §4.6).
///
/// Built on mihr_ui's `MihrTheme` through `MihrThemeConfig` (brand navy,
/// neutral gray, Plus Jakarta Sans, flat 12 radius buttons), then
/// `materialOverrides` lays the SMAP design over it:
///
/// - `colorScheme` is `SmapColors.toColorScheme` (Tur 1 code, no seed);
/// - `scaffoldBackgroundColor` is `bgCanvas` (mihr pins it to white);
/// - `textTheme` is the mihr base merged with `SmapText.toTextTheme()` so
///   slots the design does not name keep a value (Düzeltmeler #27), and
///   colored `textPrimary`;
/// - `splashFactory` is `NoSplash` (pressed state is a tone and a 0.98
///   scale, not a ripple), `materialTapTargetSize` is `padded` (48 dp);
/// - the extensions are [SmapColors] and [SmapText].
///
/// Screen code reads tokens from `context.appColors` / `context.appText`,
/// not from this `ThemeData`. mihr buttons ignore the theme's tap target;
/// pass `tapTargetSize: MaterialTapTargetSize.padded` per instance
/// (Düzeltmeler #5). `SmapApp` (`lib/app/app.dart`) uses [light] and [dark]
/// with the system's mode (`AppThemeMode`).
abstract final class SmapTheme {
  static final ThemeData _light = _build(Brightness.light);
  static final ThemeData _dark = _build(Brightness.dark);

  /// The light theme. Built once and cached.
  static ThemeData light() => _light;

  /// The dark theme. Built once and cached.
  static ThemeData dark() => _dark;

  /// The theme for [brightness].
  static ThemeData of(Brightness brightness) =>
      brightness == Brightness.dark ? _dark : _light;

  static ThemeData _build(Brightness brightness) {
    final colors = SmapColors.of(brightness);
    final text = SmapText.standard;
    final config = MihrThemeConfig(
      brand: SmapPalette.navy,
      gray: SmapPalette.neutral,
      typography: MihrTypography.fromFontFamily(SmapText.family),
      buttonTheme: const MihrButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        shadows: MihrButtonShadows.flat,
      ),
      extraExtensions: [colors, text],
      materialOverrides: (base) => base.copyWith(
        colorScheme: colors.toColorScheme(brightness),
        scaffoldBackgroundColor: colors.bgCanvas,
        textTheme: base.textTheme
            .merge(text.toTextTheme())
            .apply(
              bodyColor: colors.textPrimary,
              displayColor: colors.textPrimary,
            ),
        splashFactory: NoSplash.splashFactory,
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
    return brightness == Brightness.dark
        ? MihrTheme.dark(config: config)
        : MihrTheme.light(config: config);
  }
}
