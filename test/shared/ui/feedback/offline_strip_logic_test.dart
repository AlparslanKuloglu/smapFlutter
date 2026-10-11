import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/shared/ui/feedback/offline_strip_logic.dart';

import 'fake_timers.dart';

void main() {
  late FakeTimers timers;
  late ValueNotifier<bool> online;

  OfflineStripController make({bool startOnline = true}) {
    online = ValueNotifier<bool>(startOnline);
    return OfflineStripController(online: online, timerFactory: timers.create);
  }

  setUp(() => timers = FakeTimers());

  test('starting online shows nothing, starting offline shows the strip', () {
    expect(make().phase.value, OfflineStripPhase.hidden);
    expect(make(startOnline: false).phase.value, OfflineStripPhase.offline);
  });

  test('going offline shows the strip at once', () {
    final c = make();
    online.value = false;
    expect(c.phase.value, OfflineStripPhase.offline);
  });

  test('coming back shows "Bağlandın" for 2 s, then hides', () {
    final c = make(startOnline: false);
    online.value = true;
    expect(c.phase.value, OfflineStripPhase.connected);
    timers.advance(const Duration(milliseconds: 1999));
    expect(c.phase.value, OfflineStripPhase.connected);
    timers.advance(const Duration(milliseconds: 1));
    expect(c.phase.value, OfflineStripPhase.hidden);
  });

  test('dropping again during the notice cancels the countdown', () {
    final c = make(startOnline: false);
    online.value = true;
    timers.advance(const Duration(seconds: 1));
    online.value = false;
    expect(c.phase.value, OfflineStripPhase.offline);
    expect(timers.pending, 0);
    timers.advance(const Duration(seconds: 5));
    expect(c.phase.value, OfflineStripPhase.offline);
  });

  test('an online notification while already online announces nothing', () {
    final c = make();
    online.value = false;
    online.value = true;
    timers.advance(const Duration(seconds: 2));
    expect(c.phase.value, OfflineStripPhase.hidden);
    // A repeated "online" reading stays hidden.
    online.notifyListeners();
    expect(c.phase.value, OfflineStripPhase.hidden);
  });

  test('dispose stops listening and cancels the timer', () {
    final c = make(startOnline: false);
    online.value = true;
    c.dispose();
    expect(timers.pending, 0);
    online.value = false; // must not throw
  });
}
