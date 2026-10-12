import 'package:flutter_test/flutter_test.dart';
import 'package:smap/shared/ui/pickers/app_day_chip.dart';

void main() {
  group('AppDayChip.dotClearance (FIN14E)', () {
    test('keeps the tile padding of 8 at text scale 1 and below', () {
      expect(AppDayChip.dotClearance(1), 8);
      expect(AppDayChip.dotClearance(0.9), 8);
    });

    test('grows with the text scale so the dot clears the number', () {
      expect(AppDayChip.dotClearance(1.35), closeTo(10.8, 1e-9));
      expect(
        AppDayChip.dotClearance(2),
        greaterThan(AppDayChip.dotClearance(1.35)),
      );
    });
  });
}
