import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/smap_text.dart';
import 'package:smap/gen/fonts.gen.dart';

/// (size, line height, weight, letter spacing) of handoff 11.12 "Tipografi"
/// and spec §1.11, typed by style name.
const _spec = <String, (double, double, FontWeight, double)>{
  'display': (32, 40, FontWeight.w800, -0.5),
  'titleLg': (24, 32, FontWeight.w700, -0.3),
  'titleMd': (20, 28, FontWeight.w700, -0.2),
  'headline': (17, 24, FontWeight.w700, -0.1),
  'titleSm': (16, 24, FontWeight.w600, 0),
  'bodyLg': (16, 24, FontWeight.w400, 0),
  'bodyReading': (16, 26, FontWeight.w400, 0),
  'body': (15, 24, FontWeight.w400, 0),
  'bodyStrong': (15, 24, FontWeight.w600, 0),
  'caption': (13, 20, FontWeight.w500, 0),
  'labelLg': (16, 24, FontWeight.w600, 0),
  'labelMd': (14, 20, FontWeight.w600, 0),
  'labelSm': (12, 16, FontWeight.w600, 0),
  'metricXl': (56, 64, FontWeight.w800, -1.5),
  'metricLg': (40, 48, FontWeight.w800, -1),
  'metricMd': (24, 32, FontWeight.w700, -0.4),
  'metricSm': (17, 24, FontWeight.w700, 0),
  'barTitle': (17, 24, FontWeight.w700, -0.1),
  'barTitleCompact': (15, 20, FontWeight.w600, 0),
};

Map<String, TextStyle> _byName(SmapText t) => {
  'display': t.display,
  'titleLg': t.titleLg,
  'titleMd': t.titleMd,
  'headline': t.headline,
  'titleSm': t.titleSm,
  'bodyLg': t.bodyLg,
  'bodyReading': t.bodyReading,
  'body': t.body,
  'bodyStrong': t.bodyStrong,
  'caption': t.caption,
  'labelLg': t.labelLg,
  'labelMd': t.labelMd,
  'labelSm': t.labelSm,
  'metricXl': t.metricXl,
  'metricLg': t.metricLg,
  'metricMd': t.metricMd,
  'metricSm': t.metricSm,
  'barTitle': t.barTitle,
  'barTitleCompact': t.barTitleCompact,
};

void main() {
  final text = SmapText.standard;
  final styles = _byName(text);

  test('every style is covered by the spec table and the other way round', () {
    expect(styles.keys.toSet(), _spec.keys.toSet());
    expect(text.styles.length, styles.length);
    expect(text.styles, styles.values.toList());
  });

  group('font family', () {
    test('is the generated FontFamily constant, not a typed string', () {
      expect(SmapText.family, FontFamily.plusJakartaSans);
      expect(SmapText.family, 'PlusJakartaSans');
    });

    test('equals the family in pubspec.yaml and its five weights exist', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('- family: ${SmapText.family}'));
      for (final weight in [400, 500, 600, 700, 800]) {
        expect(pubspec, contains('weight: $weight'));
      }
      final assets = RegExp(
        r'asset: (assets/fonts/\S+\.ttf)',
      ).allMatches(pubspec).map((m) => m.group(1)!).toList();
      expect(assets.length, 5);
      for (final path in assets) {
        expect(File(path).existsSync(), isTrue, reason: '$path is missing');
      }
    });

    for (final entry in styles.entries) {
      test('${entry.key} uses Plus Jakarta Sans', () {
        expect(entry.value.fontFamily, SmapText.family);
      });
    }
  });

  group('tabular figures', () {
    for (final entry in styles.entries) {
      test('${entry.key} has FontFeature.tabularFigures()', () {
        expect(
          entry.value.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      });
    }
  });

  group('metrics equal the spec', () {
    for (final entry in _spec.entries) {
      test(entry.key, () {
        final style = styles[entry.key]!;
        final (size, line, weight, spacing) = entry.value;
        expect(style.fontSize, size);
        expect(style.height, closeTo(line / size, 1e-9));
        // The line height in points lands on the 4 pt grid (15/20 and 16/26
        // are the board's own values; every other line is a multiple of 4).
        expect(style.fontSize! * style.height!, closeTo(line, 1e-9));
        expect(style.fontWeight, weight);
        expect(style.letterSpacing, spacing);
      });
    }

    test('styles carry no color, so the call site decides', () {
      for (final entry in styles.entries) {
        expect(entry.value.color, isNull, reason: entry.key);
      }
    });

    test('lines are centered in the box so İ and Ş are not clipped', () {
      for (final entry in styles.entries) {
        expect(
          entry.value.leadingDistribution,
          TextLeadingDistribution.even,
          reason: entry.key,
        );
      }
    });

    test('the body is at least 15 pt and secondary text at least 13 pt', () {
      expect(text.body.fontSize, greaterThanOrEqualTo(15));
      expect(text.bodyStrong.fontSize, greaterThanOrEqualTo(15));
      expect(text.caption.fontSize, greaterThanOrEqualTo(13));
      // The one exception is the bottom bar label.
      final small = styles.entries.where((e) => e.value.fontSize! < 13);
      expect(small.map((e) => e.key), ['labelSm']);
    });
  });

  group('TextTheme mapping', () {
    final theme = text.toTextTheme();

    test('the eleven slots of the 11.12 "Flutter" column', () {
      expect(theme.displaySmall, text.display);
      expect(theme.headlineSmall, text.titleLg);
      expect(theme.titleLarge, text.titleMd);
      expect(theme.titleMedium, text.headline);
      expect(theme.titleSmall, text.titleSm);
      expect(theme.bodyLarge, text.bodyLg);
      expect(theme.bodyMedium, text.body);
      expect(theme.bodySmall, text.caption);
      expect(theme.labelLarge, text.labelLg);
      expect(theme.labelMedium, text.labelMd);
      expect(theme.labelSmall, text.labelSm);
    });

    test('slots the design does not name stay null (merge, never assign)', () {
      expect(theme.displayLarge, isNull);
      expect(theme.displayMedium, isNull);
      expect(theme.headlineLarge, isNull);
      expect(theme.headlineMedium, isNull);
    });
  });

  group('copyWith and lerp', () {
    test('copyWith replaces only what is passed', () {
      const changed = TextStyle(fontSize: 99);
      final copy = text.copyWith(display: changed);
      expect(copy.display, changed);
      expect(copy.body, text.body);
      expect(text.copyWith().styles, text.styles);
    });

    test('lerp at 0 and 1 gives the ends', () {
      final other = text.copyWith(body: text.body.copyWith(fontSize: 25));
      expect(text.lerp(other, 0).body.fontSize, 15);
      expect(text.lerp(other, 1).body.fontSize, 25);
      expect(text.lerp(other, 0.5).body.fontSize, 20);
      expect(text.lerp(null, 0.5), same(text));
    });
  });
}
