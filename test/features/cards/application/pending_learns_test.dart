import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/cards/application/pending_learns.dart';

/// A timer the test fires by hand.
class _Timer implements Timer {
  _Timer(this.run);

  final void Function() run;
  bool cancelled = false;
  bool fired = false;

  void fire() {
    if (cancelled || fired) return;
    fired = true;
    run();
  }

  @override
  void cancel() => cancelled = true;

  @override
  bool get isActive => !cancelled && !fired;

  @override
  int get tick => fired ? 1 : 0;
}

void main() {
  const delay = Duration(seconds: 6);
  late List<_Timer> timers;
  late List<Duration> delays;
  late List<String> sent;
  late PendingLearns pending;

  setUp(() {
    timers = [];
    delays = [];
    sent = [];
    pending = PendingLearns(
      delay: delay,
      send: (key) async => sent.add(key),
      timerFactory: (duration, run) {
        delays.add(duration);
        return _Timer(run)..let(timers.add);
      },
    );
  });

  test('holds the request for the whole window and then sends it', () {
    pending.schedule('edirne');

    expect(delays, [delay], reason: '6 s of "Geri Al"');
    expect(pending.isPending('edirne'), isTrue);
    expect(sent, isEmpty, reason: 'nothing leaves while it is held');

    timers.single.fire();

    expect(sent, ['edirne']);
    expect(pending.isPending('edirne'), isFalse);
    expect(pending.length, 0);
  });

  test('"Geri Al" first means the request never goes out', () {
    pending.schedule('edirne');

    expect(pending.cancel('edirne'), isTrue);
    timers.single.fire();

    expect(sent, isEmpty);
    expect(timers.single.cancelled, isTrue);
  });

  test('"Geri Al" after the request went out cannot take it back', () {
    pending.schedule('edirne');
    timers.single.fire();

    expect(pending.cancel('edirne'), isFalse);
    expect(sent, ['edirne']);
  });

  test('each card has its own window', () {
    pending
      ..schedule('a')
      ..schedule('b');

    expect(pending.length, 2);
    expect(pending.cancel('a'), isTrue);
    timers[0].fire();
    timers[1].fire();

    expect(sent, ['b']);
  });

  test('scheduling a card again restarts its window', () {
    pending
      ..schedule('a')
      ..schedule('a');

    expect(timers.first.cancelled, isTrue);
    expect(pending.length, 1);
    timers.first.fire();
    expect(sent, isEmpty);
    timers.last.fire();
    expect(sent, ['a']);
  });

  test('leaving the screen sends what is still held', () async {
    pending
      ..schedule('a')
      ..schedule('b');

    await pending.flush();

    expect(sent, ['a', 'b']);
    expect(pending.length, 0);
    expect(timers.every((t) => t.cancelled), isTrue);
  });

  test('dispose drops the held requests without sending them', () {
    pending
      ..schedule('a')
      ..dispose();

    expect(pending.length, 0);
    expect(sent, isEmpty);
    expect(timers.single.cancelled, isTrue);
  });
}

extension on _Timer {
  void let(void Function(_Timer timer) block) => block(this);
}
