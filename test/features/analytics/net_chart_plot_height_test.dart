import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/analytics/presentation/widgets/net_chart_plot.dart';

void main() {
  group('NetChartPlot.heightFor', () {
    test('is the board height at the normal text size', () {
      expect(
        NetChartPlot.heightFor(TextScaler.noScaling),
        NetChartPlot.baseHeight,
      );
    });

    test('grows with the text so the balloon never covers the last point', () {
      final normal = NetChartPlot.heightFor(TextScaler.noScaling);
      final large = NetChartPlot.heightFor(const TextScaler.linear(1.35));
      expect(large, greaterThan(normal));
      // The drawing area (plot minus the x label strip) scales with the text:
      // 186 pt at 1,0 (the balloon above the 62 % point just fits) and 1,35
      // times that at 1,35.
      const strip = 20 + 8;
      expect(large - (20 * 1.35 + 8), closeTo((normal - strip) * 1.35, 0.001));
    });
  });
}
