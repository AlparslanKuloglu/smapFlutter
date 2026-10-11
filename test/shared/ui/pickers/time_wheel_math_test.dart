import 'package:flutter_test/flutter_test.dart';
import 'package:smap/shared/ui/pickers/time_wheel_math.dart';

void main() {
  test('minutes run 0..55 in steps of 5', () {
    final m = TimeWheelMath.minutes();
    expect(m.first, 0);
    expect(m.last, 55);
    expect(m.length, 12);
    expect(TimeWheelMath.minuteCount(), 12);
  });

  test('snapMinute floors to the step and never carries', () {
    expect(TimeWheelMath.snapMinute(58), 55);
    expect(TimeWheelMath.snapMinute(5), 5);
    expect(TimeWheelMath.snapMinute(7), 5);
    expect(TimeWheelMath.snapMinute(-4), 0);
    expect(TimeWheelMath.snapMinute(99), 55);
  });

  test('indexes and looped lookups agree', () {
    expect(TimeWheelMath.hourIndex(22), 22);
    expect(TimeWheelMath.hourIndex(30), 23);
    expect(TimeWheelMath.minuteIndex(58), 11);
    expect(TimeWheelMath.hourAt(24), 0);
    expect(TimeWheelMath.hourAt(-1), 23);
    expect(TimeWheelMath.minuteAt(12), 0);
    expect(TimeWheelMath.minuteAt(-1), 55);
    expect(TimeWheelMath.minuteAt(13), 5);
  });

  test('nudge steps minutes, carrying into the hour and wrapping midnight', () {
    expect(TimeWheelMath.nudge(22, 55, notches: 1), (hour: 23, minute: 0));
    expect(TimeWheelMath.nudge(23, 55, notches: 1), (hour: 0, minute: 0));
    expect(TimeWheelMath.nudge(0, 0, notches: -1), (hour: 23, minute: 55));
    expect(TimeWheelMath.nudge(7, 30, notches: 2), (hour: 7, minute: 40));
    expect(TimeWheelMath.nudge(7, 33, notches: 0), (hour: 7, minute: 30));
  });

  test('shortestHourMove goes the short way round', () {
    expect(TimeWheelMath.shortestHourMove(23, 0), 1);
    expect(TimeWheelMath.shortestHourMove(0, 23), -1);
    expect(TimeWheelMath.shortestHourMove(5, 8), 3);
    expect(TimeWheelMath.shortestHourMove(8, 5), -3);
    expect(TimeWheelMath.shortestHourMove(0, 12), 12);
  });
}
