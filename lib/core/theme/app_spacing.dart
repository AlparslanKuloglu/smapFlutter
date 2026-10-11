/// The 4 pt spacing grid (handoff 11.12 "Şekil, gölge, boşluk" `space-4` …
/// `space-64`, spec §1.12).
///
/// Used instead of numeric literals: `SizedBox(height: AppSpacing.s16)`.
/// Page edge is [gutter] (16); the sign-in and sign-up screens (2.x) use
/// [gutterAuth] (24). Sections sit 24 to 32 apart; a touch target is 48.
abstract final class AppSpacing {
  /// `space-4`: icon to label, number to unit.
  static const double s4 = 4;

  /// `space-8`: between chips, inline items, icon to label in a button.
  static const double s8 = 8;

  /// `space-12`: row vertical padding, title to content.
  static const double s12 = 12;

  /// `space-16`: page edge, card padding.
  static const double s16 = 16;

  /// `space-24`: groups inside a section, sheet horizontal padding, form
  /// field gap.
  static const double s24 = 24;

  /// `space-32`: between sections.
  static const double s32 = 32;

  /// `space-48`: touch target, around an empty state.
  static const double s48 = 48;

  /// `space-64`: above a screen-level empty state.
  static const double s64 = 64;

  /// Page edge on screens 3.x to 10.x.
  static const double gutter = s16;

  /// Page edge on the sign-in / sign-up screens (2.x).
  static const double gutterAuth = s24;

  /// Minimum touch target, 48 x 48.
  static const double touch = s48;
}

/// Fixed measures of the design (spec §1.12 "Sabit ölçüler"; board 1.7).
///
/// Only values that are the same on every screen live here. A measure that
/// belongs to one component stays in that component as a named constant.
abstract final class AppSize {
  /// Minimum touch target edge.
  static const double touch = AppSpacing.touch;

  /// Visible size of a control whose touch target is padded to 48 (a 4 pt
  /// invisible margin each side; `MaterialTapTargetSize.padded`).
  static const double touchVisible = 40;

  /// List row, one line, minimum height.
  static const double rowMin = 56;

  /// List row, two lines, minimum height.
  static const double rowMinTwoLine = 72;

  /// Root band height with the safe area, expanded (no segment or tab).
  static const double bandExpanded = 134;

  /// Root band height when it carries a segment or a tab row (spec: 174 to
  /// 178; Tur 1 and the UI guide use 178).
  static const double bandWithTabs = 178;

  /// Root band height collapsed (the band shrinks over 56 pt of scroll).
  static const double bandCollapsed = 110;

  /// Detail top bar, with the safe area, collapsed (spec: 102 to 110).
  static const double detailBar = 110;

  /// Bottom bar height without the bottom safe area.
  static const double bottomBar = 68;

  /// Camera button edge (radius `AppRadius.lg`, sits 16 pt above the bar).
  static const double cameraButton = 56;

  /// Camera button lift above the bottom bar.
  static const double cameraButtonLift = 16;

  /// Sheet handle width.
  static const double sheetHandleWidth = 36;

  /// Sheet handle height.
  static const double sheetHandleHeight = 4;

  /// Sheet handle offset from the sheet top.
  static const double sheetHandleTop = 8;

  /// Input height.
  static const double input = 48;

  /// Chip, visible heights (`sm` / `md` / `lg`); the touch target is 48.
  static const double chipSm = 36;
  static const double chipMd = 40;
  static const double chipLg = 48;

  /// Icon size inside a button.
  static const double iconInButton = 20;

  /// Icon size standing alone.
  static const double icon = 24;

  /// Gap between an icon and its label in a button (chips and bar buttons
  /// use 6).
  static const double iconGap = AppSpacing.s8;

  /// Reference frame the boards were drawn at (iPhone 16 Pro), logical
  /// points. Layout is never fixed to it; this is for tests and galleries.
  static const double referenceWidth = 402;
  static const double referenceHeight = 874;

  /// Reference safe area, top and bottom.
  static const double referenceSafeTop = 62;
  static const double referenceSafeBottom = 34;
}
