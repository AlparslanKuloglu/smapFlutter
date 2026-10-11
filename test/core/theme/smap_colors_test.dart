import 'dart:ui' show Brightness, Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/subject_tone.dart';

/// Role values of handoff 11.12 / spec §1.3 and §1.7, typed here by role
/// name as (light, dark) so a change to SmapColors has to change the spec
/// table too.
const Map<String, (int, int)> _spec = {
  'bgCanvas': (0xFFF2F4F7, 0xFF0A1424),
  'bgSurface': (0xFFFFFFFF, 0xFF121D31),
  'bgRaised': (0xFFFFFFFF, 0xFF18263D),
  'bgSunken': (0xFFE8ECF1, 0xFF213049),
  'bgNavy': (0xFF0F294A, 0xFF0F294A),
  'bgNavyRaised': (0xFF1A3357, 0xFF1A3357),
  'bgContext': (0xFFF1F5FA, 0xFF1A2B45),
  'bgBar': (0xEBFFFFFF, 0xEB121D31),
  'scrim': (0x7A091A31, 0xA302060E),
  'borderSubtle': (0xFFDCE2E9, 0xFF26354D),
  'borderStrong': (0xFFC3CBD6, 0xFF34445F),
  'borderControl': (0xFF697586, 0xFF6B7D97),
  'textPrimary': (0xFF1B2232, 0xFFEDF1F6),
  'textSecondary': (0xFF556173, 0xFFA9B5C6),
  'textPlaceholder': (0xFF697586, 0xFF8B9AAF),
  'textDisabled': (0xFF9AA5B4, 0xFF56657C),
  'textOnNavy': (0xFFFFFFFF, 0xFFFFFFFF),
  'textOnNavy2': (0xFFC5D4E8, 0xFFC5D4E8),
  'textAction': (0xFF1A3357, 0xFF9BB3D3),
  'textAccent': (0xFFB34400, 0xFFFF9A57),
  'primary': (0xFF0F294A, 0xFFC5D4E8),
  'onPrimary': (0xFFFFFFFF, 0xFF091A31),
  'primaryPressed': (0xFF091A31, 0xFF9BB3D3),
  'accent': (0xFFFF6600, 0xFFFF6600),
  'onAccent': (0xFF0F294A, 0xFF0F294A),
  'accentLine': (0xFFE05500, 0xFFFF8533),
  'focusRing': (0xFF36537C, 0xFF9BB3D3),
  'dybCorrect': (0xFF0B6E3E, 0xFF52CC8E),
  'dybWrong': (0xFFD8333A, 0xFFF07575),
  'dybBlank': (0xFF7E8A9B, 0xFF6E7C92),
  'dybOn': (0xFFFFFFFF, 0xFF0A1424),
  'dybCorrectBg': (0xFFE4F4EA, 0xFF133325),
  'dybWrongBg': (0xFFFCEAEA, 0xFF3B1D22),
  'dybBlankBg': (0xFFE8ECF1, 0xFF213049),
  'delta': (0xFF36537C, 0xFF9BB3D3),
  'eksik': (0xFF8A5A00, 0xFFF2C46D),
  'eksikBg': (0xFFFCF1D9, 0xFF33270F),
  'error': (0xFFC42D35, 0xFFFF8F8F),
  'onError': (0xFFFFFFFF, 0xFF3B0A10),
  'errorBg': (0xFFFCEAEA, 0xFF3B1D22),
  'success': (0xFF0B6E3E, 0xFF52CC8E),
  'successBg': (0xFFE4F4EA, 0xFF15301F),
  'warning': (0xFF8A5A00, 0xFFF2C46D),
  'warningBg': (0xFFFCF1D9, 0xFF33270F),
  'info': (0xFF36537C, 0xFF9BB3D3),
  'infoBg': (0xFFE2EAF4, 0xFF1A2B45),
  'chartLine': (0xFF264066, 0xFF9BB3D3),
  'chartArea': (0x1A264066, 0x249BB3D3),
  'chartHighlight': (0xFFE05500, 0xFFFF8533),
  'chartGrid': (0xFFDCE2E9, 0xFF26354D),
  'inverseSurface': (0xFF0F294A, 0xFFE8ECF1),
  'onInverseSurface': (0xFFFFFFFF, 0xFF1B2232),
  'inverseInfo': (0xFFC5D4E8, 0xFF36537C),
  'inverseSuccess': (0xFF52CC8E, 0xFF0B6E3E),
  'inverseError': (0xFFFF8F8F, 0xFFC42D35),
};

Map<String, Color> _byName(SmapColors c) => {
  'bgCanvas': c.bgCanvas,
  'bgSurface': c.bgSurface,
  'bgRaised': c.bgRaised,
  'bgSunken': c.bgSunken,
  'bgNavy': c.bgNavy,
  'bgNavyRaised': c.bgNavyRaised,
  'bgContext': c.bgContext,
  'bgBar': c.bgBar,
  'scrim': c.scrim,
  'borderSubtle': c.borderSubtle,
  'borderStrong': c.borderStrong,
  'borderControl': c.borderControl,
  'textPrimary': c.textPrimary,
  'textSecondary': c.textSecondary,
  'textPlaceholder': c.textPlaceholder,
  'textDisabled': c.textDisabled,
  'textOnNavy': c.textOnNavy,
  'textOnNavy2': c.textOnNavy2,
  'textAction': c.textAction,
  'textAccent': c.textAccent,
  'primary': c.primary,
  'onPrimary': c.onPrimary,
  'primaryPressed': c.primaryPressed,
  'accent': c.accent,
  'onAccent': c.onAccent,
  'accentLine': c.accentLine,
  'focusRing': c.focusRing,
  'dybCorrect': c.dybCorrect,
  'dybWrong': c.dybWrong,
  'dybBlank': c.dybBlank,
  'dybOn': c.dybOn,
  'dybCorrectBg': c.dybCorrectBg,
  'dybWrongBg': c.dybWrongBg,
  'dybBlankBg': c.dybBlankBg,
  'delta': c.delta,
  'eksik': c.eksik,
  'eksikBg': c.eksikBg,
  'error': c.error,
  'onError': c.onError,
  'errorBg': c.errorBg,
  'success': c.success,
  'successBg': c.successBg,
  'warning': c.warning,
  'warningBg': c.warningBg,
  'info': c.info,
  'infoBg': c.infoBg,
  'chartLine': c.chartLine,
  'chartArea': c.chartArea,
  'chartHighlight': c.chartHighlight,
  'chartGrid': c.chartGrid,
  'inverseSurface': c.inverseSurface,
  'onInverseSurface': c.onInverseSurface,
  'inverseInfo': c.inverseInfo,
  'inverseSuccess': c.inverseSuccess,
  'inverseError': c.inverseError,
};

void main() {
  const light = SmapColors.light;
  const dark = SmapColors.dark;

  group('field set', () {
    test('light and dark expose the same fields', () {
      expect(_byName(light).keys, _byName(dark).keys);
      expect(light.colors.length, dark.colors.length);
      expect(light.chartSeries.length, dark.chartSeries.length);
      expect(light.subjects.keys.toSet(), dark.subjects.keys.toSet());
    });

    test('colors lists every color field, in the same order as the fields', () {
      expect(light.colors.length, _byName(light).length);
      expect(light.colors, _byName(light).values.toList());
      expect(dark.colors, _byName(dark).values.toList());
    });

    test('every field is a spec role and every spec role is a field', () {
      expect(_byName(light).keys.toSet(), _spec.keys.toSet());
    });

    test('no color is Color(0), light or dark', () {
      for (final theme in {'light': light, 'dark': dark}.entries) {
        for (final entry in _byName(theme.value).entries) {
          expect(
            entry.value,
            isNot(const Color(0x00000000)),
            reason: '${theme.key}.${entry.key} is Color(0)',
          );
          expect(
            entry.value.a,
            greaterThan(0),
            reason: '${theme.key}.${entry.key} is transparent',
          );
        }
        for (final color in theme.value.chartSeries) {
          expect(color, isNot(const Color(0x00000000)));
        }
        for (final key in SubjectKey.values) {
          final tone = theme.value.subjects[key]!;
          expect(
            tone.bg,
            isNot(const Color(0x00000000)),
            reason: '${theme.key} ${key.name} bg',
          );
          expect(
            tone.fg,
            isNot(const Color(0x00000000)),
            reason: '${theme.key} ${key.name} fg',
          );
        }
      }
    });

    test('there are nine subjects and each has a tone in both themes', () {
      expect(SubjectKey.values.length, 9);
      expect(SubjectTone.light.keys.toSet(), SubjectKey.values.toSet());
      expect(SubjectTone.dark.keys.toSet(), SubjectKey.values.toSet());
    });

    test('light and dark are different sets', () {
      expect(light.colors, isNot(dark.colors));
      expect(light.subjects, isNot(dark.subjects));
    });

    test('of() picks by brightness', () {
      expect(SmapColors.of(Brightness.light), same(light));
      expect(SmapColors.of(Brightness.dark), same(dark));
    });
  });

  group('values equal the spec table', () {
    for (final theme in {'light': 0, 'dark': 1}.entries) {
      final colors = theme.key == 'light' ? light : dark;
      final byName = _byName(colors);
      for (final entry in _spec.entries) {
        test('${theme.key} ${entry.key}', () {
          final expected = theme.value == 0 ? entry.value.$1 : entry.value.$2;
          expect(byName[entry.key]!.toARGB32(), expected);
        });
      }
    }

    test('subject tones (board 1.5)', () {
      const lightSpec = {
        SubjectKey.turkce: (0xFFF6ECE6, 0xFF93573C),
        SubjectKey.edebiyat: (0xFFF6E7EC, 0xFF8A2F4E),
        SubjectKey.tarih: (0xFFFBF1DA, 0xFF8C6106),
        SubjectKey.cografya: (0xFFE1EFFA, 0xFF1E6FAE),
        SubjectKey.matematik: (0xFFFDE8E8, 0xFFC42A36),
        SubjectKey.geometri: (0xFFE7E9FB, 0xFF4450BE),
        SubjectKey.fizik: (0xFFDDF2F2, 0xFF08737A),
        SubjectKey.kimya: (0xFFF7E8F7, 0xFF93359A),
        SubjectKey.biyoloji: (0xFFE4F3E3, 0xFF2B7A35),
      };
      const darkSpec = {
        SubjectKey.turkce: (0xFF2D211C, 0xFFE2A98D),
        SubjectKey.edebiyat: (0xFF301A27, 0xFFE494BE),
        SubjectKey.tarih: (0xFF2C2513, 0xFFE3B651),
        SubjectKey.cografya: (0xFF12293C, 0xFF7DB9EC),
        SubjectKey.matematik: (0xFF341B1B, 0xFFF7847F),
        SubjectKey.geometri: (0xFF1D2144, 0xFFA3ABF4),
        SubjectKey.fizik: (0xFF0E2B2D, 0xFF5FCBD0),
        SubjectKey.kimya: (0xFF271B33, 0xFFC89AE3),
        SubjectKey.biyoloji: (0xFF16291A, 0xFF80CC89),
      };
      for (final key in SubjectKey.values) {
        expect(
          light.subjects[key]!.bg.toARGB32(),
          lightSpec[key]!.$1,
          reason: key.name,
        );
        expect(
          light.subjects[key]!.fg.toARGB32(),
          lightSpec[key]!.$2,
          reason: key.name,
        );
        expect(
          dark.subjects[key]!.bg.toARGB32(),
          darkSpec[key]!.$1,
          reason: key.name,
        );
        expect(
          dark.subjects[key]!.fg.toARGB32(),
          darkSpec[key]!.$2,
          reason: key.name,
        );
      }
    });

    test('chart series (Tur 1 light; dark is a decision)', () {
      expect(light.chartSeries.map((c) => c.toARGB32()), [
        0xFF264066,
        0xFFE05500,
        0xFF6C8BB6,
        0xFF7E8A9B,
      ]);
      expect(dark.chartSeries.map((c) => c.toARGB32()), [
        0xFF9BB3D3,
        0xFFFF8533,
        0xFF6C8BB6,
        0xFF6E7C92,
      ]);
    });
  });

  group('aliases that must stay equal', () {
    test(
      'delta, info and focusRing share navy-600 in light and navy-300 in dark',
      () {
        expect(light.delta, light.focusRing);
        expect(light.info, light.focusRing);
        expect(dark.delta, dark.focusRing);
        expect(dark.info, dark.focusRing);
      },
    );

    test('eksik equals warning, in both themes', () {
      expect(light.eksik, light.warning);
      expect(light.eksikBg, light.warningBg);
      expect(dark.eksik, dark.warning);
      expect(dark.eksikBg, dark.warningBg);
    });

    test('textAction is the input focus edge (no separate role)', () {
      expect(light.textAction.toARGB32(), 0xFF1A3357);
      expect(dark.textAction.toARGB32(), 0xFF9BB3D3);
    });

    test('the band stays navy in both themes', () {
      expect(light.bgNavy, dark.bgNavy);
      expect(light.bgNavyRaised, dark.bgNavyRaised);
      expect(light.textOnNavy, dark.textOnNavy);
      expect(light.textOnNavy2, dark.textOnNavy2);
    });

    test('accent is orange-500 in both themes and only the camera uses it', () {
      expect(light.accent.toARGB32(), 0xFFFF6600);
      expect(dark.accent.toARGB32(), 0xFFFF6600);
      expect(light.onAccent.toARGB32(), 0xFF0F294A);
    });

    test('bgBar is 92% and scrim 48% / 64%', () {
      expect(light.bgBar.a, closeTo(0.92, 0.005));
      expect(dark.bgBar.a, closeTo(0.92, 0.005));
      expect(light.scrim.a, closeTo(0.48, 0.005));
      expect(dark.scrim.a, closeTo(0.64, 0.005));
    });

    test('chartArea is chartLine at 10% (dark 14%)', () {
      expect(light.chartArea.a, closeTo(0.10, 0.005));
      expect(dark.chartArea.a, closeTo(0.14, 0.005));
      expect(
        light.chartArea.toARGB32() & 0x00FFFFFF,
        light.chartLine.toARGB32() & 0x00FFFFFF,
      );
      expect(
        dark.chartArea.toARGB32() & 0x00FFFFFF,
        dark.chartLine.toARGB32() & 0x00FFFFFF,
      );
    });

    test(
      'the inverse surface of dark is the sunken tone, of light the band',
      () {
        expect(dark.inverseSurface, light.bgSunken);
        expect(light.inverseSurface, light.bgNavy);
      },
    );

    test('status icons on the inverse surface are the other themes colors', () {
      expect(light.inverseInfo, SmapColors.light.textOnNavy2);
      expect(light.inverseSuccess, dark.success);
      expect(light.inverseError, dark.error);
      expect(dark.inverseSuccess, light.success);
      expect(dark.inverseError, light.error);
      expect(dark.inverseInfo, light.info);
    });
  });

  group('toColorScheme equals the Tur 1 code (11.1 "ColorScheme")', () {
    test('light', () {
      final scheme = light.toColorScheme(Brightness.light);
      expect(scheme.brightness, Brightness.light);
      expect(scheme.primary, const Color(0xFF0F294A));
      expect(scheme.onPrimary, const Color(0xFFFFFFFF));
      expect(scheme.secondary, const Color(0xFFFF6600));
      expect(scheme.onSecondary, const Color(0xFF0F294A));
      expect(scheme.error, const Color(0xFFC42D35));
      expect(scheme.onError, const Color(0xFFFFFFFF));
      expect(scheme.surface, const Color(0xFFF2F4F7));
      expect(scheme.onSurface, const Color(0xFF1B2232));
      expect(scheme.onSurfaceVariant, const Color(0xFF556173));
      expect(scheme.outline, const Color(0xFF697586));
      expect(scheme.outlineVariant, const Color(0xFFDCE2E9));
      expect(scheme.surfaceContainerLowest, const Color(0xFFFFFFFF));
      expect(scheme.surfaceContainerLow, const Color(0xFFFFFFFF));
      expect(scheme.surfaceContainerHighest, const Color(0xFFE8ECF1));
      expect(scheme.scrim, const Color(0x7A091A31));
    });

    test('dark', () {
      final scheme = dark.toColorScheme(Brightness.dark);
      expect(scheme.brightness, Brightness.dark);
      expect(scheme.primary, const Color(0xFFC5D4E8));
      expect(scheme.onPrimary, const Color(0xFF091A31));
      expect(scheme.secondary, const Color(0xFFFF6600));
      expect(scheme.onSecondary, const Color(0xFF0F294A));
      expect(scheme.error, const Color(0xFFFF8F8F));
      expect(scheme.onError, const Color(0xFF3B0A10));
      expect(scheme.surface, const Color(0xFF0A1424));
      expect(scheme.onSurface, const Color(0xFFEDF1F6));
      expect(scheme.onSurfaceVariant, const Color(0xFFA9B5C6));
      expect(scheme.outline, const Color(0xFF6B7D97));
      expect(scheme.outlineVariant, const Color(0xFF26354D));
      expect(scheme.surfaceContainerLowest, const Color(0xFF121D31));
      expect(scheme.surfaceContainerLow, const Color(0xFF18263D));
      expect(scheme.surfaceContainerHighest, const Color(0xFF213049));
      expect(scheme.scrim, const Color(0xA302060E));
    });

    test('the open slots follow the spec decisions', () {
      final scheme = light.toColorScheme(Brightness.light);
      expect(scheme.surfaceTint, const Color(0x00000000));
      expect(scheme.surfaceContainer, light.bgSunken);
      expect(scheme.surfaceContainerHigh, light.bgSunken);
      expect(scheme.inverseSurface, light.inverseSurface);
      expect(scheme.onInverseSurface, light.onInverseSurface);
      final darkScheme = dark.toColorScheme(Brightness.dark);
      expect(darkScheme.inverseSurface.toARGB32(), 0xFFE8ECF1);
      expect(darkScheme.onInverseSurface.toARGB32(), 0xFF1B2232);
    });
  });

  group('copyWith and lerp', () {
    test('copyWith replaces only what is passed', () {
      const red = Color(0xFFFF0000);
      final changed = light.copyWith(bgCanvas: red);
      expect(changed.bgCanvas, red);
      expect(changed.bgSurface, light.bgSurface);
      expect(changed.subjects, light.subjects);
      expect(changed.chartSeries, light.chartSeries);
      expect(light.copyWith().colors, light.colors);
    });

    test('lerp at 0 and 1 gives the ends', () {
      expect(light.lerp(dark, 0).colors, light.colors);
      expect(light.lerp(dark, 1).colors, dark.colors);
      expect(
        light.lerp(dark, 0).subjects[SubjectKey.fizik],
        light.subjects[SubjectKey.fizik],
      );
      expect(
        light.lerp(dark, 1).subjects[SubjectKey.fizik],
        dark.subjects[SubjectKey.fizik],
      );
    });

    test('lerp at 0.5 is between the ends', () {
      final mid = light.lerp(dark, 0.5);
      expect(mid.bgCanvas, Color.lerp(light.bgCanvas, dark.bgCanvas, 0.5));
      expect(mid.subjects.length, 9);
    });

    test('lerp with a foreign extension returns this', () {
      expect(light.lerp(null, 0.5), same(light));
    });
  });
}
