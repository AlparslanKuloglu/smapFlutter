import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/coach/application/note_delete_hold.dart';

import '../meetings_fakes.dart';

void main() {
  late ManualTimers timers;
  late List<PendingNoteDelete> sent;
  late NoteDeleteHold hold;

  const first = PendingNoteDelete(index: 0, text: 'ilk');
  const second = PendingNoteDelete(index: 1, text: 'ikinci');

  setUp(() {
    timers = ManualTimers();
    sent = [];
    hold = NoteDeleteHold(
      delay: const Duration(seconds: 6),
      commit: (note) async => sent.add(note),
      timerFactory: timers.create,
    );
  });

  test('the request waits out the window, then goes out', () async {
    hold.hold(first);
    expect(hold.pending, first);
    expect(sent, isEmpty);

    timers.fire();
    await pumpEventQueue();

    expect(sent, [first]);
    expect(hold.pending, isNull);
  });

  test('"Geri Al" brings the note back and nothing is sent', () async {
    hold.hold(first);

    expect(hold.cancel(), first);
    expect(hold.pending, isNull);
    expect(timers.waiting, 0);
    await pumpEventQueue();
    expect(sent, isEmpty);
  });

  test('undo after the request went out finds nothing to undo', () async {
    hold.hold(first);
    timers.fire();
    await pumpEventQueue();

    expect(hold.cancel(), isNull);
  });

  test('flush sends the waiting request now and stops the timer', () async {
    hold.hold(first);

    await hold.flush();

    expect(sent, [first]);
    expect(timers.waiting, 0);
    await hold.flush();
    expect(sent, [first], reason: 'nothing waits any more');
  });

  test('a second deletion sends the first (never two at once)', () async {
    hold.hold(first);
    hold.hold(second);
    await pumpEventQueue();

    expect(sent, [first]);
    expect(hold.pending, second);
  });

  test('dispose drops the request without sending it', () async {
    hold.hold(first);

    hold.dispose();
    await pumpEventQueue();

    expect(sent, isEmpty);
    expect(hold.pending, isNull);
    expect(timers.waiting, 0);
  });

  test('pending notes are equal by content', () {
    expect(
      const PendingNoteDelete(index: 0, text: 'a'),
      const PendingNoteDelete(index: 0, text: 'a'),
    );
    expect(
      const PendingNoteDelete(index: 0, text: 'a').hashCode,
      const PendingNoteDelete(index: 0, text: 'a').hashCode,
    );
  });
}
