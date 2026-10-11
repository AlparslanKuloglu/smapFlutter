import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/shared/ui/navigation/band_math.dart';

void main() {
  group('BandMath', () {
    test('progress is the shrink offset over the shrink range, clamped', () {
      double at(double offset) =>
          BandMath.progress(offset, maxExtent: 134, minExtent: 110);
      expect(at(0), 0);
      expect(at(12), 0.5);
      expect(at(24), 1);
      expect(at(400), 1);
      expect(at(-20), 0);
    });

    test('a band that cannot shrink stays at progress 0', () {
      expect(BandMath.progress(50, maxExtent: 178, minExtent: 178), 0);
    });

    test(
      'extent follows the scroll one point per point down to the minimum',
      () {
        expect(BandMath.extentAt(0, maxExtent: 134, minExtent: 110), 134);
        expect(BandMath.extentAt(10, maxExtent: 134, minExtent: 110), 124);
        expect(BandMath.extentAt(90, maxExtent: 134, minExtent: 110), 110);
      },
    );

    test('lerp is linear', () {
      expect(BandMath.lerp(24, 0, 0.25), 18);
      expect(BandMath.lerp(56, 48, 1), 48);
    });
  });

  group('RootBandMetrics (C80)', () {
    const plain = RootBandMetrics(safeTop: 62);

    test('plain band is 134 and shrinks to 110', () {
      expect(plain.maxExtent, 134);
      expect(plain.minExtent, 110);
      expect(plain.collapses, isTrue);
    });

    test('band with a segment is 178 and does not shrink', () {
      const band = RootBandMetrics(
        safeTop: 62,
        bottom: RootBandBottomKind.segment,
      );
      expect(band.maxExtent, 178);
      expect(band.minExtent, 178);
      expect(band.collapses, isFalse);
      expect(band.progressAt(500), 0);
      expect(band.extentAt(500), 178);
    });

    test('band with a tab row is 174 and does not shrink', () {
      const band = RootBandMetrics(
        safeTop: 62,
        bottom: RootBandBottomKind.tabs,
        bottomHeight: 48,
      );
      expect(band.maxExtent, 174);
      expect(band.minExtent, 174);
    });

    test('a measured bottom height replaces the default', () {
      const band = RootBandMetrics(
        safeTop: 62,
        bottom: RootBandBottomKind.segment,
        bottomHeight: 56,
      );
      expect(band.maxExtent, 190);
    });

    test('the safe area is added on top', () {
      expect(const RootBandMetrics(safeTop: 47).maxExtent, 119);
      expect(const RootBandMetrics(safeTop: 0).minExtent, 48);
    });

    test('height, title row and corners interpolate with the scroll', () {
      expect(plain.extentAt(0), 134);
      expect(plain.extentAt(12), 122);
      expect(plain.extentAt(24), 110);
      expect(RootBandMetrics.titleRowAt(0), 56);
      expect(RootBandMetrics.titleRowAt(1), 48);
      expect(RootBandMetrics.titleRowAt(0.5), 52);
      expect(RootBandMetrics.cornerAt(0), 24);
      expect(RootBandMetrics.cornerAt(0.5), 12);
      expect(RootBandMetrics.cornerAt(plain.progressAt(24)), 0);
    });

    test('default bottom heights at text scale 1 and 1,3', () {
      const one = TextScaler.noScaling;
      const large = TextScaler.linear(1.3);
      double height(RootBandBottomKind kind, TextScaler s, {bool c = false}) =>
          RootBandMetrics.defaultBottomHeight(kind, s, counter: c);
      expect(height(RootBandBottomKind.segment, one), 44);
      expect(height(RootBandBottomKind.segment, one, c: true), 56);
      expect(height(RootBandBottomKind.tabs, one), closeTo(51, 0.01));
      expect(
        height(RootBandBottomKind.segment, large, c: true),
        greaterThan(56),
      );
      expect(
        height(RootBandBottomKind.tabs, large),
        greaterThan(height(RootBandBottomKind.tabs, one)),
      );
    });
  });

  group('HomeBandMetrics (C81)', () {
    test('student with a counter is 194, shrinks to 110', () {
      const band = HomeBandMetrics(role: AppHomeBandRole.student, safeTop: 62);
      expect(band.maxExtent, 194);
      expect(band.minExtent, 110);
    });

    test('student without a counter and coach are 138', () {
      const noCounter = HomeBandMetrics(
        role: AppHomeBandRole.student,
        safeTop: 62,
        hasCounter: false,
      );
      const coach = HomeBandMetrics(role: AppHomeBandRole.coach, safeTop: 62);
      expect(noCounter.maxExtent, 138);
      expect(coach.maxExtent, 138);
      expect(coach.minExtent, 110);
    });

    test('the band grows with the text scale', () {
      const large = HomeBandMetrics(
        role: AppHomeBandRole.student,
        safeTop: 62,
        textScaler: TextScaler.linear(1.3),
      );
      expect(large.counterRow, closeTo(62.4, 0.01));
      expect(large.maxExtent, greaterThan(194));
    });

    test('avatar shrinks 40 to 32 with the band', () {
      expect(HomeBandMetrics.avatarAt(0), 40);
      expect(HomeBandMetrics.avatarAt(1), 32);
    });

    test('open content is gone by half, collapsed content comes in after', () {
      expect(HomeBandMetrics.openContentOpacity(0), 1);
      expect(HomeBandMetrics.openContentOpacity(0.25), 0.5);
      expect(HomeBandMetrics.openContentOpacity(0.5), 0);
      expect(HomeBandMetrics.collapsedContentOpacity(0.5), 0);
      expect(HomeBandMetrics.collapsedContentOpacity(0.75), 0.5);
      expect(HomeBandMetrics.collapsedContentOpacity(1), 1);
    });

    test('progress runs over the shrink range of the band', () {
      const band = HomeBandMetrics(role: AppHomeBandRole.student, safeTop: 62);
      expect(band.progressAt(0), 0);
      expect(band.progressAt(42), 0.5);
      expect(band.progressAt(84), 1);
      expect(band.extentAt(84), 110);
    });
  });

  group('DetailBarMetrics (C82)', () {
    test('bar is the safe area plus 48 and does not move', () {
      const bar = DetailBarMetrics(safeTop: 62);
      expect(bar.extent, 110);
      expect(bar.rowHeight, 48);
    });

    test('the row fits two compact title lines at text scale 1,3', () {
      const bar = DetailBarMetrics(
        safeTop: 62,
        textScaler: TextScaler.linear(1.3),
      );
      expect(bar.rowHeight, closeTo(62.4, 0.01));
    });

    test(
      'title and divider fade in over 16 points before the title is gone',
      () {
        // A one-line title: 8 + 32 = 40 points to scroll it away.
        double at(double offset) =>
            DetailBarMetrics.revealProgress(offset, titleBottom: 40);
        expect(at(0), 0);
        expect(at(24), 0);
        expect(at(32), 0.5);
        expect(at(40), 1);
        expect(at(300), 1);
      },
    );

    test('a title shorter than the range starts revealing at once', () {
      expect(DetailBarMetrics.revealProgress(0, titleBottom: 10), 0);
      expect(DetailBarMetrics.revealProgress(8, titleBottom: 10), 0.5);
      expect(DetailBarMetrics.revealProgress(16, titleBottom: 10), 1);
    });
  });

  group('LargeTitleMetrics', () {
    test('title bottom is the top padding plus the title height', () {
      expect(LargeTitleMetrics.titleBottom(32), 40);
      expect(LargeTitleMetrics.titleBottom(96), 104);
    });

    test('a long title is capped at three lines', () {
      const style = TextStyle(fontSize: 24, height: 32 / 24);
      double height(String title, double width) =>
          LargeTitleMetrics.titleHeight(
            title: title,
            style: style,
            width: width,
            textScaler: TextScaler.noScaling,
            textDirection: TextDirection.ltr,
          );
      expect(height('Türkçe', 300), 32);
      expect(height('Türkçe ' * 40, 120), 96);
    });
  });
}
