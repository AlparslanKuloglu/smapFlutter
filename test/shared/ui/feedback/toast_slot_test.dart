import 'package:flutter_test/flutter_test.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';

import 'fake_timers.dart';

void main() {
  late FakeTimers timers;
  late ToastSlot slot;

  setUp(() {
    timers = FakeTimers();
    slot = ToastSlot(timerFactory: timers.create);
  });

  ToastEntry show({
    AppToastKind kind = AppToastKind.info,
    void Function()? onUndo,
    bool persistent = false,
  }) => slot.show(
    kind: kind,
    title: (_) => 'x',
    onUndo: onUndo,
    persistent: persistent,
  );

  test('durations are 4 s, and 6 s with "Geri Al"', () {
    expect(ToastSlot.durationFor(hasUndo: false), const Duration(seconds: 4));
    expect(ToastSlot.durationFor(hasUndo: true), const Duration(seconds: 6));
    expect(show().autoClose, const Duration(seconds: 4));
    expect(show(onUndo: () {}).autoClose, const Duration(seconds: 6));
  });

  test('closes itself after its time', () {
    show();
    timers.advance(const Duration(milliseconds: 3999));
    expect(slot.isShowing, isTrue);
    timers.advance(const Duration(milliseconds: 1));
    expect(slot.isShowing, isFalse);
  });

  test('an undo toast stays 6 s', () {
    show(onUndo: () {});
    timers.advance(const Duration(seconds: 5));
    expect(slot.isShowing, isTrue);
    timers.advance(const Duration(seconds: 1));
    expect(slot.isShowing, isFalse);
  });

  test('a new toast replaces the old one and restarts the clock', () {
    final first = show();
    timers.advance(const Duration(seconds: 3));
    final second = show(kind: AppToastKind.error);
    expect(second.id, greaterThan(first.id));
    expect(slot.current.value, second);
    timers.advance(const Duration(seconds: 3));
    expect(slot.isShowing, isTrue, reason: 'old timer must not close it');
    timers.advance(const Duration(seconds: 1));
    expect(slot.isShowing, isFalse);
  });

  test('persistent (screen reader) toast has no timer', () {
    final e = show(persistent: true);
    expect(e.autoClose, isNull);
    expect(timers.pending, 0);
    timers.advance(const Duration(minutes: 5));
    expect(slot.isShowing, isTrue);
    slot.dismiss();
    expect(slot.isShowing, isFalse);
  });

  test('dismiss with a stale id leaves the newer toast alone', () {
    final first = show();
    show();
    slot.dismiss(first.id);
    expect(slot.isShowing, isTrue);
    slot.dismiss();
    expect(slot.isShowing, isFalse);
  });

  test('undo runs the callback once and closes the toast', () {
    var calls = 0;
    final e = show(onUndo: () => calls++);
    expect(slot.undo(e.id), isTrue);
    expect(calls, 1);
    expect(slot.isShowing, isFalse);
    expect(slot.undo(e.id), isFalse);
    expect(calls, 1);
  });

  test('the undo of a replaced toast can no longer run', () {
    var calls = 0;
    final e = show(onUndo: () => calls++);
    show();
    expect(slot.undo(e.id), isFalse);
    expect(calls, 0);
  });

  test('a toast without an undo action ignores undo()', () {
    final e = show();
    expect(slot.undo(e.id), isFalse);
    expect(slot.isShowing, isTrue);
  });

  group('ToastPlacement.bottom', () {
    test('sits 8 above the bar and the safe area', () {
      expect(ToastPlacement.bottom(safeBottom: 34, barHeight: 64), 34 + 64 + 8);
    });

    test('without a bar it is safe area plus 16', () {
      expect(ToastPlacement.bottom(safeBottom: 34), 34 + 16);
      expect(ToastPlacement.bottom(safeBottom: 0), 16);
    });
  });
}
