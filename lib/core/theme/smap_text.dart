import 'package:flutter/material.dart';
import 'package:smap/gen/fonts.gen.dart';

/// Every text style of the SMAP design (handoff 11.12 "Tipografi", board
/// 1.6; Plus Jakarta Sans, tabular figures).
///
/// Read it with `context.appText`. Styles carry no color: give it at the
/// call site with `copyWith(color: context.appColors.textPrimary)`. Every
/// style has `FontFeature.tabularFigures()`, so digits line up in lists and
/// counters do not shift (11.12: "tüm rakam stillerinde").
///
/// Line heights sit on a 4 pt grid; Flutter's `height` is line / size.
/// `leadingDistribution: even` keeps the dot of "İ" and the cedilla of "Ş" /
/// "Ç" from being clipped in tight lines.
///
/// The 11.12 "Flutter" column maps eleven styles to `TextTheme` slots
/// ([toTextTheme]); the rest live only on this extension.
@immutable
class SmapText extends ThemeExtension<SmapText> {
  const SmapText({
    required this.display,
    required this.titleLg,
    required this.titleMd,
    required this.headline,
    required this.titleSm,
    required this.bodyLg,
    required this.bodyReading,
    required this.body,
    required this.bodyStrong,
    required this.caption,
    required this.labelLg,
    required this.labelMd,
    required this.labelSm,
    required this.metricXl,
    required this.metricLg,
    required this.metricMd,
    required this.metricSm,
    required this.barTitle,
    required this.barTitleCompact,
  });

  /// The family name; same string as `pubspec.yaml`'s `fonts:` entry and
  /// `FontFamily.plusJakartaSans` in `lib/gen/fonts.gen.dart`.
  static const String family = FontFamily.plusJakartaSans;

  /// `display` 32/40 · 800 · -0.5. Flutter: `displaySmall`. Onboarding and
  /// general screen title, result moment; two lines at most.
  final TextStyle display;

  /// `title-lg` 24/32 · 700 · -0.3. Flutter: `headlineSmall`. Root band
  /// title, detail page title.
  final TextStyle titleLg;

  /// `title-md` 20/28 · 700 · -0.2. Flutter: `titleLarge`. Sheet title,
  /// section title, empty-state title, exam name.
  final TextStyle titleMd;

  /// `headline` 17/24 · 700 · -0.1. Flutter: `titleMedium`. Section and sub
  /// title.
  final TextStyle headline;

  /// `title-sm` 16/24 · 600. Flutter: `titleSmall`. Row and card title;
  /// wraps to two lines, never truncated.
  final TextStyle titleSm;

  /// `body-lg` 16/24 · 400. Flutter: `bodyLarge`. Input value (16 stops iOS
  /// from zooming), item text.
  final TextStyle bodyLg;

  /// `body-lg-reading` 16/26 · 400. Flutter: `ext.bodyReading`. Reading
  /// text: intro body, topic definition, example, contract, author, card
  /// body, empty/status body (spec Ç-50).
  final TextStyle bodyReading;

  /// `body` 15/24 · 400. Flutter: `bodyMedium`. Body, description, sheet
  /// text.
  final TextStyle body;

  /// `body-strong` 15/24 · 600. Flutter: `ext.bodyStrong`. Emphasis inside
  /// body, list value, program time.
  final TextStyle bodyStrong;

  /// `caption` 13/20 · 500. Flutter: `bodySmall`. Meta, help, axis, label.
  final TextStyle caption;

  /// `label-lg` 16/24 · 600. Flutter: `labelLarge`. 48 pt button.
  final TextStyle labelLg;

  /// `label-md` 14/20 · 600. Flutter: `labelMedium`. 40 pt button, segment,
  /// chip, tab, input label.
  final TextStyle labelMd;

  /// `label-sm` 12/16 · 600. Flutter: `labelSmall`. Bottom bar label only.
  final TextStyle labelSm;

  /// `metric-xl` 56/64 · 800 · -1.5. Flutter: `ext.metricXl`. Result-moment
  /// net.
  final TextStyle metricXl;

  /// `metric-lg` 40/48 · 800 · -1. Flutter: `ext.metricLg`. Exam detail and
  /// home net, YKS counter.
  final TextStyle metricLg;

  /// `metric-md` 24/32 · 700 · -0.4. Flutter: `ext.metricMd`. Stat box,
  /// score, coaching code, date block, rank, D/Y/B large value.
  final TextStyle metricMd;

  /// `metric-sm` 17/24 · 700. Flutter: `ext.metricSm`. D/Y/B counters,
  /// subject net.
  final TextStyle metricSm;

  /// Short detail-bar title, 17/24 · 700, left aligned, two lines at most:
  /// the title that moves up into the bar when the page scrolls (spec Ç-21;
  /// board 1.18 had 15/20 · 600, see [barTitleCompact]). Same metrics as
  /// [headline].
  final TextStyle barTitle;

  /// The shrunken detail-bar title of the kit (board 1.18): 15/20 · 600.
  /// Spec Ç-21 chose [barTitle] for the screens; this one stays for kit
  /// parts that still follow 1.18.
  final TextStyle barTitleCompact;

  static TextStyle _style(
    double size,
    double line,
    FontWeight weight, [
    double letterSpacing = 0,
  ]) => TextStyle(
    fontFamily: family,
    fontSize: size,
    height: line / size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    leadingDistribution: TextLeadingDistribution.even,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// The one set of styles; `SmapTheme` registers it on the theme.
  static final SmapText standard = SmapText(
    display: _style(32, 40, FontWeight.w800, -0.5),
    titleLg: _style(24, 32, FontWeight.w700, -0.3),
    titleMd: _style(20, 28, FontWeight.w700, -0.2),
    headline: _style(17, 24, FontWeight.w700, -0.1),
    titleSm: _style(16, 24, FontWeight.w600),
    bodyLg: _style(16, 24, FontWeight.w400),
    bodyReading: _style(16, 26, FontWeight.w400),
    body: _style(15, 24, FontWeight.w400),
    bodyStrong: _style(15, 24, FontWeight.w600),
    caption: _style(13, 20, FontWeight.w500),
    labelLg: _style(16, 24, FontWeight.w600),
    labelMd: _style(14, 20, FontWeight.w600),
    labelSm: _style(12, 16, FontWeight.w600),
    metricXl: _style(56, 64, FontWeight.w800, -1.5),
    metricLg: _style(40, 48, FontWeight.w800, -1),
    metricMd: _style(24, 32, FontWeight.w700, -0.4),
    metricSm: _style(17, 24, FontWeight.w700),
    barTitle: _style(17, 24, FontWeight.w700, -0.1),
    barTitleCompact: _style(15, 20, FontWeight.w600),
  );

  /// Every style, in declaration order. Used by tests and by [lerp].
  List<TextStyle> get styles => [
    display,
    titleLg,
    titleMd,
    headline,
    titleSm,
    bodyLg,
    bodyReading,
    body,
    bodyStrong,
    caption,
    labelLg,
    labelMd,
    labelSm,
    metricXl,
    metricLg,
    metricMd,
    metricSm,
    barTitle,
    barTitleCompact,
  ];

  /// The 11.12 "Flutter" column: `displaySmall` = display, `headlineSmall` =
  /// title-lg, `titleLarge` = title-md, `titleMedium` = headline,
  /// `titleSmall` = title-sm, `bodyLarge` = body-lg, `bodyMedium` = body,
  /// `bodySmall` = caption, `labelLarge` / `labelMedium` / `labelSmall` =
  /// label-lg / md / sm.
  ///
  /// The slots the design does not name (`displayLarge`, `displayMedium`,
  /// `headlineLarge`, `headlineMedium`) stay null; merge this into the base
  /// theme's `TextTheme` instead of assigning it (Düzeltmeler #27).
  TextTheme toTextTheme() => TextTheme(
    displaySmall: display,
    headlineSmall: titleLg,
    titleLarge: titleMd,
    titleMedium: headline,
    titleSmall: titleSm,
    bodyLarge: bodyLg,
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: labelLg,
    labelMedium: labelMd,
    labelSmall: labelSm,
  );

  @override
  SmapText copyWith({
    TextStyle? display,
    TextStyle? titleLg,
    TextStyle? titleMd,
    TextStyle? headline,
    TextStyle? titleSm,
    TextStyle? bodyLg,
    TextStyle? bodyReading,
    TextStyle? body,
    TextStyle? bodyStrong,
    TextStyle? caption,
    TextStyle? labelLg,
    TextStyle? labelMd,
    TextStyle? labelSm,
    TextStyle? metricXl,
    TextStyle? metricLg,
    TextStyle? metricMd,
    TextStyle? metricSm,
    TextStyle? barTitle,
    TextStyle? barTitleCompact,
  }) => SmapText(
    display: display ?? this.display,
    titleLg: titleLg ?? this.titleLg,
    titleMd: titleMd ?? this.titleMd,
    headline: headline ?? this.headline,
    titleSm: titleSm ?? this.titleSm,
    bodyLg: bodyLg ?? this.bodyLg,
    bodyReading: bodyReading ?? this.bodyReading,
    body: body ?? this.body,
    bodyStrong: bodyStrong ?? this.bodyStrong,
    caption: caption ?? this.caption,
    labelLg: labelLg ?? this.labelLg,
    labelMd: labelMd ?? this.labelMd,
    labelSm: labelSm ?? this.labelSm,
    metricXl: metricXl ?? this.metricXl,
    metricLg: metricLg ?? this.metricLg,
    metricMd: metricMd ?? this.metricMd,
    metricSm: metricSm ?? this.metricSm,
    barTitle: barTitle ?? this.barTitle,
    barTitleCompact: barTitleCompact ?? this.barTitleCompact,
  );

  @override
  SmapText lerp(ThemeExtension<SmapText>? other, double t) {
    if (other is! SmapText) return this;
    TextStyle mix(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return SmapText(
      display: mix(display, other.display),
      titleLg: mix(titleLg, other.titleLg),
      titleMd: mix(titleMd, other.titleMd),
      headline: mix(headline, other.headline),
      titleSm: mix(titleSm, other.titleSm),
      bodyLg: mix(bodyLg, other.bodyLg),
      bodyReading: mix(bodyReading, other.bodyReading),
      body: mix(body, other.body),
      bodyStrong: mix(bodyStrong, other.bodyStrong),
      caption: mix(caption, other.caption),
      labelLg: mix(labelLg, other.labelLg),
      labelMd: mix(labelMd, other.labelMd),
      labelSm: mix(labelSm, other.labelSm),
      metricXl: mix(metricXl, other.metricXl),
      metricLg: mix(metricLg, other.metricLg),
      metricMd: mix(metricMd, other.metricMd),
      metricSm: mix(metricSm, other.metricSm),
      barTitle: mix(barTitle, other.barTitle),
      barTitleCompact: mix(barTitleCompact, other.barTitleCompact),
    );
  }
}
