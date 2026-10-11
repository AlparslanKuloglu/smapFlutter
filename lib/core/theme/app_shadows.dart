import 'package:flutter/material.dart';

/// The two elevation shadows (handoff 11.12; spec §1.12): 57 shadows in the
/// old app became these.
///
/// A surface has an edge or a shadow, never both; cards have neither.
/// `raised` is for the dragged card, the camera button and the magnifier;
/// `overlay` is for the toast, tooltips and chart balloons. A sheet is
/// separated by its scrim, not a shadow; in dark theme elevation is shown by
/// a lighter surface, so the dark shadows are only a faint depth cue.
///
/// Shadows depend on the theme but are not colors of a role, so they are not
/// fields of `SmapColors`.
abstract final class AppShadows {
  /// `shadow-raised`, light: 0 2 8, `#0F294A` at 8%.
  static const List<BoxShadow> raisedLight = [
    BoxShadow(offset: Offset(0, 2), blurRadius: 8, color: Color(0x140F294A)),
  ];

  /// `shadow-raised`, dark: 0 2 8, black at 40%.
  static const List<BoxShadow> raisedDark = [
    BoxShadow(offset: Offset(0, 2), blurRadius: 8, color: Color(0x66000000)),
  ];

  /// `shadow-overlay`, light: 0 8 24, `#0F294A` at 16%.
  static const List<BoxShadow> overlayLight = [
    BoxShadow(offset: Offset(0, 8), blurRadius: 24, color: Color(0x290F294A)),
  ];

  /// `shadow-overlay`, dark: 0 8 24, black at 56%.
  static const List<BoxShadow> overlayDark = [
    BoxShadow(offset: Offset(0, 8), blurRadius: 24, color: Color(0x8F000000)),
  ];

  /// `shadow-raised` for [brightness].
  static List<BoxShadow> raised(Brightness brightness) =>
      brightness == Brightness.dark ? raisedDark : raisedLight;

  /// `shadow-overlay` for [brightness].
  static List<BoxShadow> overlay(Brightness brightness) =>
      brightness == Brightness.dark ? overlayDark : overlayLight;

  /// `shadow-raised` for the theme in [context].
  static List<BoxShadow> raisedOf(BuildContext context) =>
      raised(Theme.brightnessOf(context));

  /// `shadow-overlay` for the theme in [context].
  static List<BoxShadow> overlayOf(BuildContext context) =>
      overlay(Theme.brightnessOf(context));
}

/// Backdrop blur, in sigma (spec §1.12, Ç-51). The board CSS `blur(20px)`
/// is a standard deviation, so sigma is the CSS value as is. mihr_ui's
/// `BackdropBlurStyle.blurPx` is twice the sigma; pass `2 * sigma` there.
///
/// `BackdropFilter` exists only in the bottom bar and the sheet scrim.
abstract final class AppBlur {
  /// Bottom bar, behind `SmapColors.bgBar`.
  static const double bar = 20;

  /// Sheet scrim, behind `SmapColors.scrim`.
  static const double scrim = 8;
}
