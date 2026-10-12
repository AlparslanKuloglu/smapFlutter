import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/application/account_band_metrics.dart';

void main() {
  group('extents', () {
    test('the open band with a three line summary is 206 (pano 9.1)', () {
      const metrics = AccountBandMetrics(safeTop: 62, summaryLines: 2);

      expect(metrics.summaryHeight, 64);
      expect(metrics.maxExtent, 206);
      expect(metrics.minExtent, 110);
    });

    test('a short summary is as high as the avatar', () {
      const metrics = AccountBandMetrics(safeTop: 62, summaryLines: 1);

      expect(metrics.summaryHeight, 56);
      expect(metrics.maxExtent, 62 + 56 + 4 + 56 + 20);
    });

    test('without a summary it is the plain root band: 134', () {
      const metrics = AccountBandMetrics(
        safeTop: 62,
        hasSummary: false,
        summaryLines: 2,
      );

      expect(metrics.summaryHeight, 0);
      expect(metrics.maxExtent, 134);
    });

    test('grows with the text size', () {
      const metrics = AccountBandMetrics(
        safeTop: 62,
        summaryLines: 2,
        textScaler: TextScaler.linear(1.3),
      );

      expect(metrics.summaryHeight, closeTo(1.3 * 64, 0.001));
      expect(metrics.maxExtent, greaterThan(206));
    });
  });

  group('the shrink', () {
    const metrics = AccountBandMetrics(safeTop: 62, summaryLines: 2);

    test('follows the scroll one point per point', () {
      expect(metrics.progressAt(0), 0);
      expect(metrics.progressAt(48), 0.5);
      expect(metrics.progressAt(96), 1);
      expect(metrics.progressAt(500), 1);
    });

    test('the title row, the corners and the summary follow the progress', () {
      expect(AccountBandMetrics.titleRowAt(0), 56);
      expect(AccountBandMetrics.titleRowAt(1), 48);
      expect(AccountBandMetrics.cornerAt(0), 24);
      expect(AccountBandMetrics.cornerAt(1), 0);
    });

    test('the summary is gone before the band is half shrunk', () {
      expect(AccountBandMetrics.summaryOpacityAt(0), 1);
      expect(AccountBandMetrics.summaryOpacityAt(0.25), 0.5);
      expect(AccountBandMetrics.summaryOpacityAt(0.5), 0);
      expect(AccountBandMetrics.summaryOpacityAt(1), 0);
    });
  });
}
