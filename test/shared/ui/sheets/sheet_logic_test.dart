import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/shared/ui/sheets/sheet_layout.dart';
import 'package:smap/shared/ui/sheets/sheet_outcome.dart';

void main() {
  group('SheetOutcome', () {
    test('a popped value is submitted, null is dismissed', () {
      expect(SheetOutcome.of<int>(3), const SheetSubmitted<int>(3));
      expect(SheetOutcome.of<int>(null), const SheetDismissed<int>());
    });

    test('valueOr / valueOrNull / isDismissed', () {
      expect(const SheetSubmitted<int>(3).valueOr(9), 3);
      expect(const SheetDismissed<int>().valueOr(9), 9);
      expect(const SheetSubmitted<int>(3).valueOrNull, 3);
      expect(const SheetDismissed<int>().valueOrNull, isNull);
      expect(const SheetDismissed<int>().isDismissed, isTrue);
      expect(const SheetSubmitted<int>(3).isDismissed, isFalse);
    });

    test('when() picks the branch', () {
      String run(SheetOutcome<int> o) =>
          o.when(onSubmitted: (v) => 'v$v', onDismissed: () => 'none');
      expect(run(const SheetSubmitted(1)), 'v1');
      expect(run(const SheetDismissed()), 'none');
    });

    test('a bool result tells "false" apart from dismissed', () {
      expect(SheetOutcome.of<bool>(false), const SheetSubmitted<bool>(false));
      expect(SheetOutcome.of<bool>(false).isDismissed, isFalse);
    });

    test('Future.outcome wraps the sheet result', () async {
      expect(await Future<int?>.value(5).outcome, const SheetSubmitted<int>(5));
      expect(await Future<int?>.value().outcome, const SheetDismissed<int>());
    });

    test('exhaustive switch works on the sealed type', () {
      const SheetOutcome<int> o = SheetSubmitted(2);
      final r = switch (o) {
        SheetSubmitted(:final value) => value,
        SheetDismissed() => -1,
      };
      expect(r, 2);
    });
  });

  group('SheetLayoutMath', () {
    test('full and small leave safe area plus 8', () {
      for (final size in [AppSheetSize.full, AppSheetSize.small]) {
        expect(
          SheetLayoutMath.topInset(
            size: size,
            viewportHeight: 874,
            safeTop: 62,
          ),
          70,
        );
      }
    });

    test('medium leaves the top third, never less than full', () {
      expect(
        SheetLayoutMath.topInset(
          size: AppSheetSize.medium,
          viewportHeight: 874,
          safeTop: 62,
        ),
        closeTo(874 * 0.34, 0.001),
      );
      expect(
        SheetLayoutMath.topInset(
          size: AppSheetSize.medium,
          viewportHeight: 100,
          safeTop: 62,
        ),
        70,
      );
    });

    test('footer bottom: 16 with the keyboard, safe area + 8 without', () {
      expect(
        SheetLayoutMath.footerBottom(keyboardOpen: true, safeBottom: 34),
        16,
      );
      expect(
        SheetLayoutMath.footerBottom(keyboardOpen: false, safeBottom: 34),
        42,
      );
      expect(
        SheetLayoutMath.footerBottom(keyboardOpen: false, safeBottom: 0),
        8,
      );
    });

    test('a drag past 25 % or a fast fling closes, otherwise it stays', () {
      expect(AppMotion.sheetDismissFraction, 0.25);
      expect(SheetLayoutMath.dismisses(dragged: 0.26, velocity: 0), isTrue);
      expect(SheetLayoutMath.dismisses(dragged: 0.25, velocity: 0), isFalse);
      expect(SheetLayoutMath.dismisses(dragged: 0.05, velocity: 900), isTrue);
      expect(SheetLayoutMath.dismisses(dragged: 0.05, velocity: 100), isFalse);
      expect(SheetLayoutMath.keepOpenFraction, 0.75);
    });

    test('fling ratio is the velocity over the viewport height', () {
      expect(
        SheetLayoutMath.flingVelocityRatio(700),
        AppMotion.sheetFlingVelocity / 700,
      );
      expect(SheetLayoutMath.flingVelocityRatio(0), 1);
    });
  });
}
