import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_shadows.dart';
import 'package:smap/core/theme/app_spacing.dart';

void main() {
  group('AppSpacing (4 pt grid, 11.12)', () {
    test('values', () {
      expect(
        [
          AppSpacing.s4,
          AppSpacing.s8,
          AppSpacing.s12,
          AppSpacing.s16,
          AppSpacing.s24,
          AppSpacing.s32,
          AppSpacing.s48,
          AppSpacing.s64,
        ],
        [4, 8, 12, 16, 24, 32, 48, 64],
      );
    });

    test('every step is on the 4 pt grid', () {
      for (final v in [4.0, 8, 12, 16, 24, 32, 48, 64]) {
        expect(v % 4, 0);
      }
    });

    test('page edge is 16, auth screens 24, touch 48', () {
      expect(AppSpacing.gutter, 16);
      expect(AppSpacing.gutterAuth, 24);
      expect(AppSpacing.touch, 48);
      expect(AppSize.touch, 48);
    });

    test('fixed measures of spec §1.12', () {
      expect(AppSize.rowMin, 56);
      expect(AppSize.rowMinTwoLine, 72);
      expect(AppSize.bandExpanded, 134);
      expect(AppSize.bandWithTabs, 178);
      expect(AppSize.bandCollapsed, 110);
      expect(AppSize.detailBar, 110);
      expect(AppSize.bottomBar, 68);
      expect(AppSize.cameraButton, 56);
      expect(AppSize.sheetHandleWidth, 36);
      expect(AppSize.sheetHandleHeight, 4);
      expect(AppSize.input, 48);
      expect(AppSize.touchVisible + 2 * 4, AppSize.touch);
    });
  });

  group('AppRadius (11.12)', () {
    test('values', () {
      expect(
        [
          AppRadius.xs,
          AppRadius.sm,
          AppRadius.md,
          AppRadius.lg,
          AppRadius.xl,
          AppRadius.full,
        ],
        [4, 8, 12, 16, 24, 999],
      );
    });

    test('md is 12, not mihr_ui\'s 8', () {
      expect(AppRadius.borderMd, BorderRadius.circular(12));
    });

    test('helpers', () {
      expect(
        AppRadius.sheetTop,
        const BorderRadius.vertical(top: Radius.circular(24)),
      );
      expect(
        AppRadius.bandBottom,
        const BorderRadius.vertical(bottom: Radius.circular(24)),
      );
      expect(AppRadius.barTop, AppRadius.sheetTop);
    });

    test('a nested surface is the outer radius minus the gap', () {
      expect(AppRadius.inner(16, 8), 8);
      expect(AppRadius.inner(12, 4), 8);
      expect(AppRadius.inner(4, 8), 0);
    });
  });

  group('AppShadows and AppBlur (11.12, Ç-51)', () {
    test('shadow-raised', () {
      final light = AppShadows.raised(Brightness.light).single;
      final dark = AppShadows.raised(Brightness.dark).single;
      expect(light.offset, const Offset(0, 2));
      expect(light.blurRadius, 8);
      expect(light.spreadRadius, 0);
      expect(light.color.toARGB32(), 0x140F294A); // #0F294A at 8%
      expect(dark.color.toARGB32(), 0x66000000); // black at 40%
      expect(dark.offset, light.offset);
    });

    test('shadow-overlay', () {
      final light = AppShadows.overlay(Brightness.light).single;
      final dark = AppShadows.overlay(Brightness.dark).single;
      expect(light.offset, const Offset(0, 8));
      expect(light.blurRadius, 24);
      expect(light.color.toARGB32(), 0x290F294A); // #0F294A at 16%
      expect(dark.color.toARGB32(), 0x8F000000); // black at 56%
    });

    test('the alpha bytes are the rounded percentages', () {
      expect((0.08 * 255).round(), 0x14);
      expect((0.16 * 255).round(), 0x29);
      expect((0.40 * 255).round(), 0x66);
      expect((0.56 * 255).round(), 0x8F);
    });

    test('blur sigma is the CSS value', () {
      expect(AppBlur.bar, 20);
      expect(AppBlur.scrim, 8);
    });
  });

  group('AppMotion (11.12, 11.15)', () {
    test('durations', () {
      expect(AppMotion.instant, const Duration(milliseconds: 100));
      expect(AppMotion.fast, const Duration(milliseconds: 150));
      expect(AppMotion.base, const Duration(milliseconds: 250));
      expect(AppMotion.slow, const Duration(milliseconds: 350));
      expect(AppMotion.loop, const Duration(milliseconds: 1200));
    });

    test('reduce motion is a 150 ms fade', () {
      expect(AppMotion.reducedFade, const Duration(milliseconds: 150));
    });

    test('curves', () {
      expect(AppMotion.standard, const Cubic(0.2, 0, 0, 1));
      expect(AppMotion.enter, const Cubic(0, 0, 0, 1));
      expect(AppMotion.exit, const Cubic(0.3, 0, 1, 1));
      expect(AppMotion.linear, Curves.linear);
    });

    test('an exit lasts 70% of the entrance', () {
      expect(
        AppMotion.exitOf(AppMotion.slow),
        const Duration(milliseconds: 245),
      );
      expect(
        AppMotion.exitOf(const Duration(milliseconds: 100)),
        const Duration(milliseconds: 70),
      );
      // The spec rounds the sheet's 245 ms to 250.
      expect(AppMotion.sheetClose, const Duration(milliseconds: 250));
    });

    test('thresholds', () {
      expect(AppMotion.pressedScale, 0.98);
      expect(AppMotion.shutterScale, 0.92);
      expect(AppMotion.sheetDismissFraction, 0.25);
      expect(AppMotion.sheetFlingVelocity, 700);
      expect(AppMotion.swipeCommitFraction, 0.30);
      expect(AppMotion.swipeCommitVelocity, 800);
    });
  });

  group('SmapDurations (UI guide §4.5)', () {
    test('values', () {
      expect(SmapDurations.toast, const Duration(seconds: 4));
      expect(SmapDurations.undoToast, const Duration(seconds: 6));
      expect(SmapDurations.skeletonTimeout, const Duration(seconds: 15));
      expect(SmapDurations.connectedNotice, const Duration(seconds: 2));
      expect(SmapDurations.codeResend, const Duration(seconds: 30));
      expect(SmapDurations.submitTimeout, const Duration(seconds: 60));
      expect(SmapDurations.readTimeout, const Duration(seconds: 30));
      expect(SmapDurations.searchDebounce, const Duration(milliseconds: 150));
      expect(SmapDurations.usernameDebounce, const Duration(milliseconds: 400));
    });
  });
}
