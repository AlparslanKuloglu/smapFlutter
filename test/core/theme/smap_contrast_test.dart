import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/subject_tone.dart';

import 'contrast.dart';

/// Contrast of the pairs the design allows (spec §1.14, boards 1.2/1.3).
///
/// Thresholds (Düzeltmeler #17): text 4.5:1, large text 3:1, control edge
/// and icon 3:1. Only the allowed pairs are checked. The matrix also has
/// pairs that are forbidden by rule (placeholder on canvas, navy text on
/// light surfaces, `text-on-navy` on light fills) and the exempt roles
/// `textDisabled` and `borderStrong` (disabled controls, decorative); they
/// are not tested for a ratio on purpose.
typedef _Pick = Color Function(SmapColors c);

class _Pair {
  const _Pair(this.name, this.fg, this.bg, this.min);
  final String name;
  final _Pick fg;
  final _Pick bg;
  final double min;
}

const double _text = 4.5;
const double _nonText = 3.0;

final _surfaces = <(String, _Pick)>[
  ('bgSurface', (c) => c.bgSurface),
  ('bgCanvas', (c) => c.bgCanvas),
  ('bgSunken', (c) => c.bgSunken),
];

/// Text roles allowed on the three light surfaces (and, in dark, on all
/// five dark surfaces).
final _textOnSurface = <(String, _Pick)>[
  ('textPrimary', (c) => c.textPrimary),
  ('textSecondary', (c) => c.textSecondary),
  ('textAction', (c) => c.textAction),
  ('textAccent', (c) => c.textAccent),
  ('error', (c) => c.error),
  ('success', (c) => c.success),
];

List<_Pair> _lightPairs() => [
  for (final (fgName, fg) in _textOnSurface)
    for (final (bgName, bg) in _surfaces)
      _Pair('$fgName on $bgName', fg, bg, _text),
  // The placeholder is allowed only on the white input fill.
  _Pair(
    'textPlaceholder on bgSurface',
    (c) => c.textPlaceholder,
    (c) => c.bgSurface,
    _text,
  ),
  // Text on the navy band: only the two on-navy roles.
  _Pair('textOnNavy on bgNavy', (c) => c.textOnNavy, (c) => c.bgNavy, _text),
  _Pair('textOnNavy2 on bgNavy', (c) => c.textOnNavy2, (c) => c.bgNavy, _text),
  _Pair(
    'textOnNavy2 on bgNavyRaised (inactive band segment)',
    (c) => c.textOnNavy2,
    (c) => c.bgNavyRaised,
    _text,
  ),
];

List<_Pair> _darkPairs() => [
  // Dark matrix: every text role is usable on every dark surface.
  for (final (fgName, fg) in [
    ..._textOnSurface,
    ('textPlaceholder', (SmapColors c) => c.textPlaceholder),
    ('textOnNavy', (SmapColors c) => c.textOnNavy),
    ('textOnNavy2', (SmapColors c) => c.textOnNavy2),
  ])
    for (final (bgName, bg) in [
      ..._surfaces,
      ('bgRaised', (SmapColors c) => c.bgRaised),
      ('bgNavy', (SmapColors c) => c.bgNavy),
    ])
      _Pair('$fgName on $bgName', fg, bg, _text),
  _Pair(
    'textOnNavy2 on bgNavyRaised (inactive band segment)',
    (c) => c.textOnNavy2,
    (c) => c.bgNavyRaised,
    _text,
  ),
];

/// Pairs that hold in both themes.
List<_Pair> _componentPairs() => [
  _Pair(
    'onPrimary on primary (primary button)',
    (c) => c.onPrimary,
    (c) => c.primary,
    _text,
  ),
  _Pair(
    'onPrimary on primaryPressed',
    (c) => c.onPrimary,
    (c) => c.primaryPressed,
    _text,
  ),
  _Pair(
    'onError on error (danger button)',
    (c) => c.onError,
    (c) => c.error,
    _text,
  ),
  _Pair(
    'onInverseSurface on inverseSurface (toast, offline strip)',
    (c) => c.onInverseSurface,
    (c) => c.inverseSurface,
    _text,
  ),
  _Pair(
    'textSecondary on bgSunken (inactive segment)',
    (c) => c.textSecondary,
    (c) => c.bgSunken,
    _text,
  ),
  _Pair(
    'textPrimary on bgContext (coach strip)',
    (c) => c.textPrimary,
    (c) => c.bgContext,
    _text,
  ),
  _Pair(
    'textPrimary on bgRaised (sheet)',
    (c) => c.textPrimary,
    (c) => c.bgRaised,
    _text,
  ),
  _Pair(
    'textSecondary on bgRaised (sheet)',
    (c) => c.textSecondary,
    (c) => c.bgRaised,
    _text,
  ),
  _Pair('delta on bgSurface', (c) => c.delta, (c) => c.bgSurface, _text),
  _Pair(
    'dybCorrect on dybWrongBg (right option in a wrong cell)',
    (c) => c.dybCorrect,
    (c) => c.dybWrongBg,
    _text,
  ),
  _Pair(
    'textPrimary on dybCorrectBg',
    (c) => c.textPrimary,
    (c) => c.dybCorrectBg,
    _text,
  ),
  _Pair(
    'textPrimary on dybWrongBg',
    (c) => c.textPrimary,
    (c) => c.dybWrongBg,
    _text,
  ),
  _Pair(
    'textPrimary on dybBlankBg',
    (c) => c.textPrimary,
    (c) => c.dybBlankBg,
    _text,
  ),
  _Pair('error on errorBg', (c) => c.error, (c) => c.errorBg, _text),
  _Pair('success on successBg', (c) => c.success, (c) => c.successBg, _text),
  _Pair('warning on warningBg', (c) => c.warning, (c) => c.warningBg, _text),
  _Pair('eksik on eksikBg', (c) => c.eksik, (c) => c.eksikBg, _text),
  _Pair('info on infoBg', (c) => c.info, (c) => c.infoBg, _text),
  _Pair(
    'textPrimary on errorBg',
    (c) => c.textPrimary,
    (c) => c.errorBg,
    _text,
  ),
  _Pair('textPrimary on infoBg', (c) => c.textPrimary, (c) => c.infoBg, _text),
  _Pair(
    'textPrimary on warningBg',
    (c) => c.textPrimary,
    (c) => c.warningBg,
    _text,
  ),
  _Pair(
    'textPrimary on successBg',
    (c) => c.textPrimary,
    (c) => c.successBg,
    _text,
  ),
  // Icons, control edges, indicators: 3:1.
  _Pair(
    'onAccent on accent (camera icon)',
    (c) => c.onAccent,
    (c) => c.accent,
    _nonText,
  ),
  _Pair(
    'dybOn on dybCorrect (chip glyph)',
    (c) => c.dybOn,
    (c) => c.dybCorrect,
    _nonText,
  ),
  _Pair(
    'dybOn on dybWrong (chip glyph)',
    (c) => c.dybOn,
    (c) => c.dybWrong,
    _nonText,
  ),
  _Pair(
    'dybOn on dybBlank (chip glyph)',
    (c) => c.dybOn,
    (c) => c.dybBlank,
    _nonText,
  ),
  for (final (bgName, bg) in [
    ('bgSurface', (SmapColors c) => c.bgSurface),
    ('bgCanvas', (SmapColors c) => c.bgCanvas),
  ]) ...[
    _Pair(
      'borderControl on $bgName (input, chip, checkbox edge)',
      (c) => c.borderControl,
      bg,
      _nonText,
    ),
    _Pair(
      'accentLine on $bgName (indicator, progress, today)',
      (c) => c.accentLine,
      bg,
      _nonText,
    ),
    _Pair('focusRing on $bgName', (c) => c.focusRing, bg, _nonText),
    _Pair('chartLine on $bgName', (c) => c.chartLine, bg, _nonText),
    _Pair('chartHighlight on $bgName', (c) => c.chartHighlight, bg, _nonText),
    _Pair(
      'dybCorrect on $bgName (chip fill)',
      (c) => c.dybCorrect,
      bg,
      _nonText,
    ),
    _Pair('dybWrong on $bgName (chip fill)', (c) => c.dybWrong, bg, _nonText),
    _Pair('dybBlank on $bgName (chip fill)', (c) => c.dybBlank, bg, _nonText),
  ],
];

void _run(String theme, SmapColors colors, List<_Pair> pairs) {
  group(theme, () {
    for (final pair in pairs) {
      test('${pair.name} >= ${pair.min}', () {
        final ratio = contrast(pair.fg(colors), pair.bg(colors));
        expect(
          ratio,
          greaterThanOrEqualTo(pair.min),
          reason: '${pair.name} is ${ratio.toStringAsFixed(2)}:1',
        );
      });
    }
  });
}

void main() {
  group('contrast function', () {
    // Ratios printed on the boards (1.1 "beyaza karşı", 1.3).
    test('matches the boards', () {
      const white = Color(0xFFFFFFFF);
      expect(contrast(const Color(0xFF0F294A), white), closeTo(14.62, 0.02));
      expect(contrast(const Color(0xFFFF6600), white), closeTo(2.94, 0.02));
      expect(contrast(const Color(0xFF697586), white), closeTo(4.68, 0.02));
      expect(contrast(const Color(0xFF556173), white), closeTo(6.28, 0.02));
      expect(contrast(const Color(0xFFB34400), white), closeTo(5.61, 0.02));
      expect(
        contrast(const Color(0xFF0F294A), const Color(0xFFFF6600)),
        closeTo(4.98, 0.02),
      );
    });
  });

  group('allowed pairs', () {
    _run('light', SmapColors.light, [..._lightPairs(), ..._componentPairs()]);
    _run('dark', SmapColors.dark, [..._darkPairs(), ..._componentPairs()]);
  });

  group('subject tones', () {
    for (final entry in {
      'light': SmapColors.light,
      'dark': SmapColors.dark,
    }.entries) {
      for (final key in SubjectKey.values) {
        test('${entry.key} ${key.name}: accent on tile >= 4.5', () {
          final tone = entry.value.subjects[key]!;
          expect(contrast(tone.fg, tone.bg), greaterThanOrEqualTo(_text));
        });
        test('${entry.key} ${key.name}: progress fill on the track >= 3', () {
          final tone = entry.value.subjects[key]!;
          expect(
            contrast(tone.fg, entry.value.bgSunken),
            greaterThanOrEqualTo(_nonText),
          );
        });
      }
    }
  });

  group('rules the design states', () {
    test('white text on orange is forbidden: it fails 3:1', () {
      expect(
        contrast(SmapColors.light.textOnNavy, SmapColors.light.accent),
        lessThan(_nonText),
      );
    });

    test('orange-500 as text on white fails, textAccent passes', () {
      expect(
        contrast(SmapColors.light.accent, SmapColors.light.bgSurface),
        lessThan(_text),
      );
      expect(
        contrast(SmapColors.light.textAccent, SmapColors.light.bgSurface),
        greaterThanOrEqualTo(_text),
      );
    });

    test(
      'light placeholder fails on canvas, which is why it is input-only',
      () {
        expect(
          contrast(SmapColors.light.textPlaceholder, SmapColors.light.bgCanvas),
          lessThan(_text),
        );
      },
    );

    test('textDisabled and borderStrong are exempt and below 3:1 in light', () {
      expect(
        contrast(SmapColors.light.textDisabled, SmapColors.light.bgSurface),
        lessThan(_nonText),
      );
      expect(
        contrast(SmapColors.light.borderStrong, SmapColors.light.bgSurface),
        lessThan(_nonText),
      );
    });

    test('dark D/Y/B lightness order is reversed (D lightest)', () {
      const c = SmapColors.dark;
      expect(luminance(c.dybCorrect), greaterThan(luminance(c.dybWrong)));
      expect(luminance(c.dybWrong), greaterThan(luminance(c.dybBlank)));
    });

    test('light D/Y/B differ in lightness so they separate in grayscale', () {
      const c = SmapColors.light;
      expect(luminance(c.dybCorrect), lessThan(luminance(c.dybWrong)));
      expect(luminance(c.dybWrong), lessThan(luminance(c.dybBlank)));
    });
  });
}
