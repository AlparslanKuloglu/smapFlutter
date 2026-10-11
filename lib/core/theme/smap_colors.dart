import 'package:flutter/material.dart';
import 'package:smap/core/theme/smap_palette.dart';
import 'package:smap/core/theme/subject_tone.dart';

/// Every color of the SMAP design as roles (handoff 11.12 "Token Tablosu").
///
/// Field names are the camelCase form of the 11.12 "Rol" column
/// (`bg-canvas` -> [bgCanvas]); the doc comment of each field names the
/// 11.12 "Flutter" column (a `ColorScheme` slot, or `ext.<name>` for the
/// name the handoff gave the extension field). Light and dark expose the
/// same field set, so screen code never branches on the theme.
///
/// Read it with `context.appColors`. Screen code uses only roles, never a
/// palette step (`SmapPalette`) or `Theme.of(context).colorScheme`.
///
/// Name decisions (Düzeltmeler #24): the handoff "Flutter" column gives
/// extension names (`navyBand`, `onNavyBand`, `contextStrip`, `bar`,
/// `dybEmpty`); the coordinator chose the role-name form instead
/// ([bgNavy], [textOnNavy], [bgContext], [bgBar], [dybBlank]).
@immutable
class SmapColors extends ThemeExtension<SmapColors> {
  const SmapColors({
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgRaised,
    required this.bgSunken,
    required this.bgNavy,
    required this.bgNavyRaised,
    required this.bgContext,
    required this.bgBar,
    required this.scrim,
    required this.borderSubtle,
    required this.borderStrong,
    required this.borderControl,
    required this.textPrimary,
    required this.textSecondary,
    required this.textPlaceholder,
    required this.textDisabled,
    required this.textOnNavy,
    required this.textOnNavy2,
    required this.textAction,
    required this.textAccent,
    required this.primary,
    required this.onPrimary,
    required this.primaryPressed,
    required this.accent,
    required this.onAccent,
    required this.accentLine,
    required this.focusRing,
    required this.dybCorrect,
    required this.dybWrong,
    required this.dybBlank,
    required this.dybOn,
    required this.dybCorrectBg,
    required this.dybWrongBg,
    required this.dybBlankBg,
    required this.delta,
    required this.eksik,
    required this.eksikBg,
    required this.error,
    required this.onError,
    required this.errorBg,
    required this.success,
    required this.successBg,
    required this.warning,
    required this.warningBg,
    required this.info,
    required this.infoBg,
    required this.chartLine,
    required this.chartArea,
    required this.chartHighlight,
    required this.chartGrid,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inverseInfo,
    required this.inverseSuccess,
    required this.inverseError,
    required this.chartSeries,
    required this.subjects,
  });

  /// `bg-canvas` · Flutter: `ColorScheme.surface`. Page background, behind cards.
  final Color bgCanvas;

  /// `bg-surface` · Flutter: `ColorScheme.surfaceContainerLowest`. Card, list group, input fill.
  final Color bgSurface;

  /// `bg-raised` · Flutter: `ColorScheme.surfaceContainerLow`. Sheet; one step lighter than the surface in dark.
  final Color bgRaised;

  /// `bg-sunken` · Flutter: `ColorScheme.surfaceContainerHighest`. Segment and progress track, skeleton, quiet button.
  final Color bgSunken;

  /// `bg-navy` · Flutter: `ext.navyBand`. Root tab band; the toast in light theme.
  final Color bgNavy;

  /// `bg-navy-raised` · Flutter: `ext.navyBandRaised`. Segment track inside the navy band.
  final Color bgNavyRaised;

  /// `bg-context` · Flutter: `ext.contextStrip`. Coach context strip (Tur 9).
  final Color bgContext;

  /// `bg-bar` · Flutter: `ext.bar`. Bottom bar, drawn over a 20 pt blur (`AppBlur.bar`). 92% opaque.
  final Color bgBar;

  /// `scrim` · Flutter: `ColorScheme.scrim`. Sheet scrim, drawn over an 8 pt blur (`AppBlur.scrim`). 48% light, 64% dark.
  final Color scrim;

  /// `border-subtle` · Flutter: `ColorScheme.outlineVariant`. Divider, cell and card edge (decorative).
  final Color borderSubtle;

  /// `border-strong` · Flutter: `ext.borderStrong`. Disabled control edge, sheet handle (exempt from contrast).
  final Color borderStrong;

  /// `border-control` · Flutter: `ColorScheme.outline`. Input, chip, checkbox, off-switch edge (3:1).
  final Color borderControl;

  /// `text-primary` · Flutter: `ColorScheme.onSurface`. Title, body, value; primary icon.
  final Color textPrimary;

  /// `text-secondary` · Flutter: `ColorScheme.onSurfaceVariant`. Sub text, label, axis, inactive tab; secondary icon.
  final Color textSecondary;

  /// `text-placeholder` · Flutter: `ext.textPlaceholder`. Only the "Örn: …" hint inside an input on a surface fill.
  final Color textPlaceholder;

  /// `text-disabled` · Flutter: `ext.textDisabled`. Disabled control text (exempt from contrast).
  final Color textDisabled;

  /// `text-on-navy` · Flutter: `ext.onNavyBand`. Band title and action on [bgNavy].
  final Color textOnNavy;

  /// `text-on-navy-2` · Flutter: `ext.onNavyBandVariant`. Band sub text, inactive band segment label.
  final Color textOnNavy2;

  /// `text-action` · Flutter: `ext.textAction`. Text button, inline link (underlined); input focus edge.
  final Color textAction;

  /// `text-accent` · Flutter: `ext.textAccent`. Orange text when needed; never orange-500 in light.
  final Color textAccent;

  /// `primary` · Flutter: `ColorScheme.primary`. Primary button, selected segment and chip, on-switch.
  final Color primary;

  /// `on-primary` · Flutter: `ColorScheme.onPrimary`. Text and icon on [primary].
  final Color onPrimary;

  /// `primary-pressed` · Flutter: `ext.primaryPressed`. Pressed primary.
  final Color primaryPressed;

  /// `accent` · Flutter: `ColorScheme.secondary`. Camera button fill only (and the shutter). No white text on it.
  final Color accent;

  /// `on-accent` · Flutter: `ColorScheme.onSecondary`. Camera icon (navy, not white).
  final Color onAccent;

  /// `accent-line` · Flutter: `ext.accentLine`. Position indicator, progress fill, "today", selected chart point.
  final Color accentLine;

  /// `focus-ring` · Flutter: `ext.focusRing`. Focus ring: 2 pt line plus 2 pt gap.
  final Color focusRing;

  /// `dyb-correct` · Flutter: `ext.dybCorrect`. Correct ("Doğru"): chip, bar, the right option text in a wrong cell.
  final Color dybCorrect;

  /// `dyb-wrong` · Flutter: `ext.dybWrong`. Wrong ("Yanlış"): chip and bar. Never text.
  final Color dybWrong;

  /// `dyb-blank` · Flutter: `ext.dybBlank`. Blank ("Boş"): chip and bar. Never text. (Tur 1 called it dybEmpty.)
  final Color dybBlank;

  /// `dyb-on` · Flutter: `ext.dybOn`. Glyph (check, x, minus) on a D/Y/B chip. Tur 1 / 1.4 only.
  final Color dybOn;

  /// `dyb-correct-bg` · Flutter: `ext.dybCorrectBg`. Correct question cell tint. Tur 1 / 1.4 only; dark stays 1.4's value.
  final Color dybCorrectBg;

  /// `dyb-wrong-bg` · Flutter: `ext.dybWrongBg`. Wrong question cell.
  final Color dybWrongBg;

  /// `dyb-blank-bg` · Flutter: `ext.dybBlankBg`. Blank question cell.
  final Color dybBlankBg;

  /// `delta` · Flutter: `ext.delta`. Change value and arrow ("+8,25"). Green is reserved for "Doğru" (Tur 10).
  final Color delta;

  /// `eksik` · Flutter: `ext.eksik`. EksikTag flag and "3 eksik" (Tur 5). Same value as [warning].
  final Color eksik;

  /// `eksik-bg` · Flutter: `ext.eksikBg`. EksikTag background.
  final Color eksikBg;

  /// `error` · Flutter: `ColorScheme.error`. Error icon and short emphasis, danger button, destructive confirm.
  final Color error;

  /// `on-error` · Flutter: `ColorScheme.onError`. Text on the danger button. Tur 1 code and 1.23/1.24.
  final Color onError;

  /// `error-bg` · Flutter: `ext.errorBg`. Error notice box.
  final Color errorBg;

  /// `success` · Flutter: `ext.success`. Success icon (password updated, account deleted).
  final Color success;

  /// `success-bg` · Flutter: `ext.successBg`. Success background.
  final Color successBg;

  /// `warning` · Flutter: `ext.warning`. Warning box, attention badge. Never orange.
  final Color warning;

  /// `warning-bg` · Flutter: `ext.warningBg`. Warning background.
  final Color warningBg;

  /// `info` · Flutter: `ext.info`. Info box, icon circles.
  final Color info;

  /// `info-bg` · Flutter: `ext.infoBg`. Info background.
  final Color infoBg;

  /// `chart-line` · Flutter: `ext.chartLine`. Net line, 2.5 pt, straight segments.
  final Color chartLine;

  /// `chart-area` · Flutter: `ext.chartArea`. Area under the line: chartLine at 10% (dark 14%). Tur 1 only.
  final Color chartArea;

  /// `chart-highlight` · Flutter: `ext.chartHighlight`. Last or selected point.
  final Color chartHighlight;

  /// `chart-grid` · Flutter: `ext.chartGrid`. Horizontal grid, 1 pt.
  final Color chartGrid;

  /// `inverse-surface` · Flutter: `ColorScheme.inverseSurface`. Inverse surface: the toast and offline strip (navy in light, `#E8ECF1` in dark). Not a 11.12 role; added per Düzeltmeler #24 and the "ters yüzey" note.
  final Color inverseSurface;

  /// `on-inverse-surface` · Flutter: `ColorScheme.onInverseSurface`. Text on [inverseSurface].
  final Color onInverseSurface;

  /// `inverse-info` · Flutter: `ext.inverseInfo`. Info icon on [inverseSurface]: the other theme's info color.
  final Color inverseInfo;

  /// `inverse-success` · Flutter: `ext.inverseSuccess`. Success icon on [inverseSurface].
  final Color inverseSuccess;

  /// `inverse-error` · Flutter: `ext.inverseError`. Error icon on [inverseSurface].
  final Color inverseError;

  /// Comparison series for multi-line charts: four colors, in order. The
  /// light set is Tur 1's; the dark set is a decision (the design leaves it
  /// open): the matching dark chart roles plus the dark `dybBlank`.
  final List<Color> chartSeries;

  /// Per-subject tile and accent colors (handoff 11.12 `subject`). Use
  /// `context.appSubject(key)`.
  final Map<SubjectKey, SubjectTone> subjects;

  /// The light set.
  static const SmapColors light = SmapColors(
    bgCanvas: SmapPalette.neutral50,
    bgSurface: SmapPalette.neutral0,
    bgRaised: SmapPalette.neutral0,
    bgSunken: SmapPalette.neutral100,
    bgNavy: SmapPalette.navy900,
    bgNavyRaised: SmapPalette.navy800,
    bgContext: SmapPalette.navy50,
    bgBar: Color(0xEBFFFFFF),
    scrim: Color(0x7A091A31),
    borderSubtle: SmapPalette.neutral200,
    borderStrong: SmapPalette.neutral300,
    borderControl: SmapPalette.neutral500,
    textPrimary: SmapPalette.neutral900,
    textSecondary: SmapPalette.neutral600,
    textPlaceholder: SmapPalette.neutral500,
    textDisabled: SmapPalette.neutral400,
    textOnNavy: SmapPalette.neutral0,
    textOnNavy2: SmapPalette.navy200,
    textAction: SmapPalette.navy800,
    textAccent: SmapPalette.orange700,
    primary: SmapPalette.navy900,
    onPrimary: SmapPalette.neutral0,
    primaryPressed: SmapPalette.navy950,
    accent: SmapPalette.orange500,
    onAccent: SmapPalette.navy900,
    accentLine: SmapPalette.orange600,
    focusRing: SmapPalette.navy600,
    dybCorrect: Color(0xFF0B6E3E),
    dybWrong: Color(0xFFD8333A),
    dybBlank: Color(0xFF7E8A9B),
    dybOn: Color(0xFFFFFFFF),
    dybCorrectBg: Color(0xFFE4F4EA),
    dybWrongBg: Color(0xFFFCEAEA),
    dybBlankBg: SmapPalette.neutral100,
    delta: SmapPalette.navy600,
    eksik: Color(0xFF8A5A00),
    eksikBg: Color(0xFFFCF1D9),
    error: Color(0xFFC42D35),
    onError: Color(0xFFFFFFFF),
    errorBg: Color(0xFFFCEAEA),
    success: Color(0xFF0B6E3E),
    successBg: Color(0xFFE4F4EA),
    warning: Color(0xFF8A5A00),
    warningBg: Color(0xFFFCF1D9),
    info: SmapPalette.navy600,
    infoBg: SmapPalette.navy100,
    chartLine: SmapPalette.navy700,
    chartArea: Color(0x1A264066),
    chartHighlight: SmapPalette.orange600,
    chartGrid: SmapPalette.neutral200,
    inverseSurface: SmapPalette.navy900,
    onInverseSurface: SmapPalette.neutral0,
    inverseInfo: SmapPalette.navy200,
    inverseSuccess: Color(0xFF52CC8E),
    inverseError: Color(0xFFFF8F8F),
    chartSeries: [
      SmapPalette.navy700,
      SmapPalette.orange600,
      SmapPalette.navy400,
      Color(0xFF7E8A9B),
    ],
    subjects: SubjectTone.light,
  );

  /// The dark set. Not the light set inverted: surfaces are navy-tinted and
  /// lighten as they rise (board 1.2).
  static const SmapColors dark = SmapColors(
    bgCanvas: Color(0xFF0A1424),
    bgSurface: Color(0xFF121D31),
    bgRaised: Color(0xFF18263D),
    bgSunken: Color(0xFF213049),
    bgNavy: SmapPalette.navy900,
    bgNavyRaised: SmapPalette.navy800,
    bgContext: Color(0xFF1A2B45),
    bgBar: Color(0xEB121D31),
    scrim: Color(0xA302060E),
    borderSubtle: Color(0xFF26354D),
    borderStrong: Color(0xFF34445F),
    borderControl: Color(0xFF6B7D97),
    textPrimary: Color(0xFFEDF1F6),
    textSecondary: Color(0xFFA9B5C6),
    textPlaceholder: Color(0xFF8B9AAF),
    textDisabled: Color(0xFF56657C),
    textOnNavy: SmapPalette.neutral0,
    textOnNavy2: SmapPalette.navy200,
    textAction: SmapPalette.navy300,
    textAccent: Color(0xFFFF9A57),
    primary: SmapPalette.navy200,
    onPrimary: SmapPalette.navy950,
    primaryPressed: SmapPalette.navy300,
    accent: SmapPalette.orange500,
    onAccent: SmapPalette.navy900,
    accentLine: SmapPalette.orange400,
    focusRing: SmapPalette.navy300,
    dybCorrect: Color(0xFF52CC8E),
    dybWrong: Color(0xFFF07575),
    dybBlank: Color(0xFF6E7C92),
    dybOn: Color(0xFF0A1424),
    dybCorrectBg: Color(0xFF133325),
    dybWrongBg: Color(0xFF3B1D22),
    dybBlankBg: Color(0xFF213049),
    delta: SmapPalette.navy300,
    eksik: Color(0xFFF2C46D),
    eksikBg: Color(0xFF33270F),
    error: Color(0xFFFF8F8F),
    onError: Color(0xFF3B0A10),
    errorBg: Color(0xFF3B1D22),
    success: Color(0xFF52CC8E),
    successBg: Color(0xFF15301F),
    warning: Color(0xFFF2C46D),
    warningBg: Color(0xFF33270F),
    info: SmapPalette.navy300,
    infoBg: Color(0xFF1A2B45),
    chartLine: SmapPalette.navy300,
    chartArea: Color(0x249BB3D3),
    chartHighlight: SmapPalette.orange400,
    chartGrid: Color(0xFF26354D),
    inverseSurface: SmapPalette.neutral100,
    onInverseSurface: SmapPalette.neutral900,
    inverseInfo: SmapPalette.navy600,
    inverseSuccess: Color(0xFF0B6E3E),
    inverseError: Color(0xFFC42D35),
    chartSeries: [
      SmapPalette.navy300,
      SmapPalette.orange400,
      SmapPalette.navy400,
      Color(0xFF6E7C92),
    ],
    subjects: SubjectTone.dark,
  );

  /// The set for [brightness].
  static SmapColors of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// Every color field, in declaration order. Used by tests and by [lerp].
  List<Color> get colors => [
    bgCanvas,
    bgSurface,
    bgRaised,
    bgSunken,
    bgNavy,
    bgNavyRaised,
    bgContext,
    bgBar,
    scrim,
    borderSubtle,
    borderStrong,
    borderControl,
    textPrimary,
    textSecondary,
    textPlaceholder,
    textDisabled,
    textOnNavy,
    textOnNavy2,
    textAction,
    textAccent,
    primary,
    onPrimary,
    primaryPressed,
    accent,
    onAccent,
    accentLine,
    focusRing,
    dybCorrect,
    dybWrong,
    dybBlank,
    dybOn,
    dybCorrectBg,
    dybWrongBg,
    dybBlankBg,
    delta,
    eksik,
    eksikBg,
    error,
    onError,
    errorBg,
    success,
    successBg,
    warning,
    warningBg,
    info,
    infoBg,
    chartLine,
    chartArea,
    chartHighlight,
    chartGrid,
    inverseSurface,
    onInverseSurface,
    inverseInfo,
    inverseSuccess,
    inverseError,
  ];

  /// The `ColorScheme` for stock Material widgets, built from these roles
  /// exactly as the Tur 1 note (11.1, "ColorScheme") writes it: no seed.
  ///
  /// Slots the design leaves open: `surfaceTint` is transparent (no M3 tonal
  /// tint), `surfaceContainer` and `surfaceContainerHigh` are [bgSunken],
  /// `inverseSurface` / `onInverseSurface` are the inverse roles, the rest
  /// keep Material's derived defaults. Screen code never reads the scheme.
  ColorScheme toColorScheme(Brightness brightness) => ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: onPrimary,
    secondary: accent,
    onSecondary: onAccent,
    error: error,
    onError: onError,
    surface: bgCanvas,
    onSurface: textPrimary,
    onSurfaceVariant: textSecondary,
    outline: borderControl,
    outlineVariant: borderSubtle,
    surfaceContainerLowest: bgSurface,
    surfaceContainerLow: bgRaised,
    surfaceContainer: bgSunken,
    surfaceContainerHigh: bgSunken,
    surfaceContainerHighest: bgSunken,
    inverseSurface: inverseSurface,
    onInverseSurface: onInverseSurface,
    surfaceTint: const Color(0x00000000),
    scrim: scrim,
  );

  @override
  SmapColors copyWith({
    Color? bgCanvas,
    Color? bgSurface,
    Color? bgRaised,
    Color? bgSunken,
    Color? bgNavy,
    Color? bgNavyRaised,
    Color? bgContext,
    Color? bgBar,
    Color? scrim,
    Color? borderSubtle,
    Color? borderStrong,
    Color? borderControl,
    Color? textPrimary,
    Color? textSecondary,
    Color? textPlaceholder,
    Color? textDisabled,
    Color? textOnNavy,
    Color? textOnNavy2,
    Color? textAction,
    Color? textAccent,
    Color? primary,
    Color? onPrimary,
    Color? primaryPressed,
    Color? accent,
    Color? onAccent,
    Color? accentLine,
    Color? focusRing,
    Color? dybCorrect,
    Color? dybWrong,
    Color? dybBlank,
    Color? dybOn,
    Color? dybCorrectBg,
    Color? dybWrongBg,
    Color? dybBlankBg,
    Color? delta,
    Color? eksik,
    Color? eksikBg,
    Color? error,
    Color? onError,
    Color? errorBg,
    Color? success,
    Color? successBg,
    Color? warning,
    Color? warningBg,
    Color? info,
    Color? infoBg,
    Color? chartLine,
    Color? chartArea,
    Color? chartHighlight,
    Color? chartGrid,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? inverseInfo,
    Color? inverseSuccess,
    Color? inverseError,
    List<Color>? chartSeries,
    Map<SubjectKey, SubjectTone>? subjects,
  }) => SmapColors(
    bgCanvas: bgCanvas ?? this.bgCanvas,
    bgSurface: bgSurface ?? this.bgSurface,
    bgRaised: bgRaised ?? this.bgRaised,
    bgSunken: bgSunken ?? this.bgSunken,
    bgNavy: bgNavy ?? this.bgNavy,
    bgNavyRaised: bgNavyRaised ?? this.bgNavyRaised,
    bgContext: bgContext ?? this.bgContext,
    bgBar: bgBar ?? this.bgBar,
    scrim: scrim ?? this.scrim,
    borderSubtle: borderSubtle ?? this.borderSubtle,
    borderStrong: borderStrong ?? this.borderStrong,
    borderControl: borderControl ?? this.borderControl,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textPlaceholder: textPlaceholder ?? this.textPlaceholder,
    textDisabled: textDisabled ?? this.textDisabled,
    textOnNavy: textOnNavy ?? this.textOnNavy,
    textOnNavy2: textOnNavy2 ?? this.textOnNavy2,
    textAction: textAction ?? this.textAction,
    textAccent: textAccent ?? this.textAccent,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    primaryPressed: primaryPressed ?? this.primaryPressed,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    accentLine: accentLine ?? this.accentLine,
    focusRing: focusRing ?? this.focusRing,
    dybCorrect: dybCorrect ?? this.dybCorrect,
    dybWrong: dybWrong ?? this.dybWrong,
    dybBlank: dybBlank ?? this.dybBlank,
    dybOn: dybOn ?? this.dybOn,
    dybCorrectBg: dybCorrectBg ?? this.dybCorrectBg,
    dybWrongBg: dybWrongBg ?? this.dybWrongBg,
    dybBlankBg: dybBlankBg ?? this.dybBlankBg,
    delta: delta ?? this.delta,
    eksik: eksik ?? this.eksik,
    eksikBg: eksikBg ?? this.eksikBg,
    error: error ?? this.error,
    onError: onError ?? this.onError,
    errorBg: errorBg ?? this.errorBg,
    success: success ?? this.success,
    successBg: successBg ?? this.successBg,
    warning: warning ?? this.warning,
    warningBg: warningBg ?? this.warningBg,
    info: info ?? this.info,
    infoBg: infoBg ?? this.infoBg,
    chartLine: chartLine ?? this.chartLine,
    chartArea: chartArea ?? this.chartArea,
    chartHighlight: chartHighlight ?? this.chartHighlight,
    chartGrid: chartGrid ?? this.chartGrid,
    inverseSurface: inverseSurface ?? this.inverseSurface,
    onInverseSurface: onInverseSurface ?? this.onInverseSurface,
    inverseInfo: inverseInfo ?? this.inverseInfo,
    inverseSuccess: inverseSuccess ?? this.inverseSuccess,
    inverseError: inverseError ?? this.inverseError,
    chartSeries: chartSeries ?? this.chartSeries,
    subjects: subjects ?? this.subjects,
  );

  @override
  SmapColors lerp(ThemeExtension<SmapColors>? other, double t) {
    if (other is! SmapColors) return this;
    return SmapColors(
      bgCanvas: Color.lerp(bgCanvas, other.bgCanvas, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgRaised: Color.lerp(bgRaised, other.bgRaised, t)!,
      bgSunken: Color.lerp(bgSunken, other.bgSunken, t)!,
      bgNavy: Color.lerp(bgNavy, other.bgNavy, t)!,
      bgNavyRaised: Color.lerp(bgNavyRaised, other.bgNavyRaised, t)!,
      bgContext: Color.lerp(bgContext, other.bgContext, t)!,
      bgBar: Color.lerp(bgBar, other.bgBar, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderControl: Color.lerp(borderControl, other.borderControl, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textPlaceholder: Color.lerp(textPlaceholder, other.textPlaceholder, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textOnNavy: Color.lerp(textOnNavy, other.textOnNavy, t)!,
      textOnNavy2: Color.lerp(textOnNavy2, other.textOnNavy2, t)!,
      textAction: Color.lerp(textAction, other.textAction, t)!,
      textAccent: Color.lerp(textAccent, other.textAccent, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentLine: Color.lerp(accentLine, other.accentLine, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      dybCorrect: Color.lerp(dybCorrect, other.dybCorrect, t)!,
      dybWrong: Color.lerp(dybWrong, other.dybWrong, t)!,
      dybBlank: Color.lerp(dybBlank, other.dybBlank, t)!,
      dybOn: Color.lerp(dybOn, other.dybOn, t)!,
      dybCorrectBg: Color.lerp(dybCorrectBg, other.dybCorrectBg, t)!,
      dybWrongBg: Color.lerp(dybWrongBg, other.dybWrongBg, t)!,
      dybBlankBg: Color.lerp(dybBlankBg, other.dybBlankBg, t)!,
      delta: Color.lerp(delta, other.delta, t)!,
      eksik: Color.lerp(eksik, other.eksik, t)!,
      eksikBg: Color.lerp(eksikBg, other.eksikBg, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      chartLine: Color.lerp(chartLine, other.chartLine, t)!,
      chartArea: Color.lerp(chartArea, other.chartArea, t)!,
      chartHighlight: Color.lerp(chartHighlight, other.chartHighlight, t)!,
      chartGrid: Color.lerp(chartGrid, other.chartGrid, t)!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      onInverseSurface: Color.lerp(
        onInverseSurface,
        other.onInverseSurface,
        t,
      )!,
      inverseInfo: Color.lerp(inverseInfo, other.inverseInfo, t)!,
      inverseSuccess: Color.lerp(inverseSuccess, other.inverseSuccess, t)!,
      inverseError: Color.lerp(inverseError, other.inverseError, t)!,
      chartSeries: [
        for (var i = 0; i < chartSeries.length; i++)
          Color.lerp(chartSeries[i], other.chartSeries[i], t)!,
      ],
      subjects: {
        for (final key in SubjectKey.values)
          key: SubjectTone.lerp(subjects[key]!, other.subjects[key]!, t),
      },
    );
  }
}
