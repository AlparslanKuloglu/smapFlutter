import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/home/application/yks_countdown.dart';

void main() {
  final exam = DateTime(2027, 6, 19);

  group('daysLeft', () {
    test('counts the days of the board: 252 on 10 Oct 2026 (pano 3.1)', () {
      expect(YksCountdown.daysLeft(DateTime(2026, 10, 10, 14, 30), exam), 252);
    });

    test('ignores the time of day', () {
      expect(YksCountdown.daysLeft(DateTime(2027, 6, 18, 0, 0, 1), exam), 1);
      expect(YksCountdown.daysLeft(DateTime(2027, 6, 18, 23, 59, 59), exam), 1);
    });

    test('is 0 on the exam day', () {
      expect(YksCountdown.daysLeft(DateTime(2027, 6, 19, 8), exam), 0);
    });

    test('is null once the exam day has passed', () {
      expect(YksCountdown.daysLeft(DateTime(2027, 6, 20), exam), isNull);
    });

    test('a daylight-saving change does not move the count', () {
      // Whatever the zone of the test machine, two calendar dates are 7 days
      // apart across a clock change.
      expect(
        YksCountdown.daysLeft(DateTime(2026, 3, 25, 12), DateTime(2026, 4, 1)),
        7,
      );
      expect(
        YksCountdown.daysLeft(
          DateTime(2026, 10, 25, 12),
          DateTime(2026, 11, 1),
        ),
        7,
      );
    });

    test('reads the exam date as a day, not a moment', () {
      expect(
        YksCountdown.daysLeft(
          DateTime(2027, 6, 19, 23),
          DateTime(2027, 6, 19, 10),
        ),
        0,
      );
    });
  });

  group('untilNextMidnight', () {
    test('is the time to the next local midnight plus a second', () {
      expect(
        YksCountdown.untilNextMidnight(DateTime(2026, 10, 10, 23, 0)),
        const Duration(hours: 1, seconds: 1),
      );
    });

    test('at midnight sharp a whole day is left', () {
      expect(
        YksCountdown.untilNextMidnight(DateTime(2026, 10, 10)),
        const Duration(days: 1, seconds: 1),
      );
    });

    test('crosses the end of a month and a year', () {
      expect(
        YksCountdown.untilNextMidnight(DateTime(2026, 12, 31, 18)),
        const Duration(hours: 6, seconds: 1),
      );
    });
  });
}
