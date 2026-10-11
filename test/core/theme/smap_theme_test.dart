import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/smap_text.dart';
import 'package:smap/core/theme/smap_theme.dart';

void main() {
  group('SmapTheme', () {
    for (final brightness in Brightness.values) {
      final name = brightness.name;
      final colors = SmapColors.of(brightness);
      final theme = SmapTheme.of(brightness);

      group(name, () {
        test('is the cached instance of light() / dark()', () {
          expect(
            theme,
            same(
              brightness == Brightness.dark
                  ? SmapTheme.dark()
                  : SmapTheme.light(),
            ),
          );
        });

        test('registers SmapColors and SmapText', () {
          expect(theme.extension<SmapColors>(), same(colors));
          expect(theme.extension<SmapText>(), same(SmapText.standard));
        });

        test('uses the Tur 1 ColorScheme', () {
          final expected = colors.toColorScheme(brightness);
          expect(theme.colorScheme.brightness, brightness);
          expect(theme.colorScheme.primary, expected.primary);
          expect(theme.colorScheme.onPrimary, expected.onPrimary);
          expect(theme.colorScheme.secondary, expected.secondary);
          expect(theme.colorScheme.surface, expected.surface);
          expect(theme.colorScheme.onSurface, expected.onSurface);
          expect(theme.colorScheme.outline, expected.outline);
          expect(theme.colorScheme.outlineVariant, expected.outlineVariant);
          expect(theme.colorScheme.error, expected.error);
          expect(theme.colorScheme.scrim, expected.scrim);
          expect(theme.colorScheme.inverseSurface, colors.inverseSurface);
          expect(theme.colorScheme.surfaceTint, const Color(0x00000000));
        });

        test('scaffold is bgCanvas, not white', () {
          expect(theme.scaffoldBackgroundColor, colors.bgCanvas);
        });

        test(
          'textTheme is the base merged with SmapText, so no slot is null',
          () {
            final t = theme.textTheme;
            expect(t.displayLarge, isNotNull);
            expect(t.displayMedium, isNotNull);
            expect(t.headlineLarge, isNotNull);
            expect(t.headlineMedium, isNotNull);
            expect(t.bodyMedium!.fontSize, 15);
            expect(t.bodyMedium!.height! * 15, closeTo(24, 1e-9));
            expect(t.displaySmall!.fontSize, 32);
            expect(t.labelSmall!.fontSize, 12);
            expect(t.bodyMedium!.fontFamily, SmapText.family);
            expect(t.bodyMedium!.color, colors.textPrimary);
            expect(
              t.bodyMedium!.fontFeatures,
              contains(const FontFeature.tabularFigures()),
            );
          },
        );

        test('no ripple, 48 dp tap targets, Plus Jakarta Sans', () {
          expect(theme.splashFactory, NoSplash.splashFactory);
          expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
          expect(theme.useMaterial3, isTrue);
        });
      });
    }

    test('light and dark differ', () {
      expect(SmapTheme.light().brightness, Brightness.light);
      expect(SmapTheme.dark().brightness, Brightness.dark);
      expect(
        SmapTheme.light().scaffoldBackgroundColor,
        isNot(SmapTheme.dark().scaffoldBackgroundColor),
      );
    });
  });
}
