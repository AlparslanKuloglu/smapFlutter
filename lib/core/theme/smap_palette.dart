import 'package:flutter/painting.dart';
import 'package:mihr_ui/mihr_ui.dart' show ColorScale;

/// The three raw color scales of the SMAP design (board 1.1, "Renk
/// skalaları"): navy, orange and neutral.
///
/// Only the theme layer reads these. Screen code uses the roles on
/// `SmapColors` (`context.appColors`), never a scale step, so that a theme
/// change swaps the value behind a role (handoff 11.12, "Ekran kodu yalnız
/// rol adlarını kullanır").
///
/// mihr_ui's [ColorScale] has a 25 step that the SMAP design does not
/// define. Assumption: navy-25 and orange-25 are a tint just under the 50
/// step, and neutral-25 is neutral-0 (`#FFFFFF`), as the UI guide §4.8
/// suggests. No role uses a 25 step.
abstract final class SmapPalette {
  // -- Navy (brand: navy-900 `#0F294A`) -----------------------------------
  static const Color navy25 = Color(0xFFF8FAFD);
  static const Color navy50 = Color(0xFFF1F5FA);
  static const Color navy100 = Color(0xFFE2EAF4);
  static const Color navy200 = Color(0xFFC5D4E8);
  static const Color navy300 = Color(0xFF9BB3D3);
  static const Color navy400 = Color(0xFF6C8BB6);
  static const Color navy500 = Color(0xFF4A6A97);
  static const Color navy600 = Color(0xFF36537C);
  static const Color navy700 = Color(0xFF264066);
  static const Color navy800 = Color(0xFF1A3357);
  static const Color navy900 = Color(0xFF0F294A);
  static const Color navy950 = Color(0xFF091A31);

  // -- Orange (brand: orange-500 `#FF6600`) -------------------------------
  static const Color orange25 = Color(0xFFFFFAF6);
  static const Color orange50 = Color(0xFFFFF4EC);
  static const Color orange100 = Color(0xFFFFE6D4);
  static const Color orange200 = Color(0xFFFFCBA6);
  static const Color orange300 = Color(0xFFFFA76B);
  static const Color orange400 = Color(0xFFFF8533);
  static const Color orange500 = Color(0xFFFF6600);
  static const Color orange600 = Color(0xFFE05500);
  static const Color orange700 = Color(0xFFB34400);
  static const Color orange800 = Color(0xFF8A3500);
  static const Color orange900 = Color(0xFF662800);
  static const Color orange950 = Color(0xFF3D1800);

  // -- Neutral (navy-tinted gray, hue 215) --------------------------------
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF2F4F7);
  static const Color neutral100 = Color(0xFFE8ECF1);
  static const Color neutral200 = Color(0xFFDCE2E9);
  static const Color neutral300 = Color(0xFFC3CBD6);
  static const Color neutral400 = Color(0xFF9AA5B4);
  static const Color neutral500 = Color(0xFF697586);
  static const Color neutral600 = Color(0xFF556173);
  static const Color neutral700 = Color(0xFF3E4858);
  static const Color neutral800 = Color(0xFF2A3241);
  static const Color neutral900 = Color(0xFF1B2232);
  static const Color neutral950 = Color(0xFF0F1420);

  /// Navy scale, in mihr_ui's shape for `MihrThemeConfig.brand`.
  static const ColorScale navy = ColorScale(
    shade25: navy25,
    shade50: navy50,
    shade100: navy100,
    shade200: navy200,
    shade300: navy300,
    shade400: navy400,
    shade500: navy500,
    shade600: navy600,
    shade700: navy700,
    shade800: navy800,
    shade900: navy900,
    shade950: navy950,
  );

  /// Orange scale.
  static const ColorScale orange = ColorScale(
    shade25: orange25,
    shade50: orange50,
    shade100: orange100,
    shade200: orange200,
    shade300: orange300,
    shade400: orange400,
    shade500: orange500,
    shade600: orange600,
    shade700: orange700,
    shade800: orange800,
    shade900: orange900,
    shade950: orange950,
  );

  /// Neutral scale, in mihr_ui's shape for `MihrThemeConfig.gray`.
  static const ColorScale neutral = ColorScale(
    shade25: neutral0,
    shade50: neutral50,
    shade100: neutral100,
    shade200: neutral200,
    shade300: neutral300,
    shade400: neutral400,
    shade500: neutral500,
    shade600: neutral600,
    shade700: neutral700,
    shade800: neutral800,
    shade900: neutral900,
    shade950: neutral950,
  );
}
