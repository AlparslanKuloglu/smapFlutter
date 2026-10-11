import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/shared/ui/feedback/toast_host.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';

import '../../shared/ui/feedback/fake_timers.dart';

class _FakePresenter implements ToastPresenter {
  @override
  bool screenReaderOn = false;
  bool available = true;
  int presented = 0;
  ValueListenable<double?>? lastBarHeight;

  @override
  bool present(ToastSlot slot, ValueListenable<double?> barHeight) {
    if (!available) return false;
    presented++;
    lastBarHeight = barHeight;
    return true;
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = binding.defaultBinaryMessenger;
  final haptics = <String>[];
  late FakeTimers timers;
  late _FakePresenter presenter;
  late ToastService service;

  setUp(() {
    haptics.clear();
    AppHaptics.enabled = true;
    messenger.setMockMethodCallHandler(AppHaptics.channel, (call) async {
      haptics.add(call.method);
      return null;
    });
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        haptics.add(call.arguments as String);
      }
      return null;
    });
    timers = FakeTimers();
    presenter = _FakePresenter();
    service = ToastService(
      presenter: presenter,
      slot: ToastSlot(timerFactory: timers.create),
    );
  });

  tearDown(() {
    AppHaptics.enabled = true;
    messenger.setMockMethodCallHandler(AppHaptics.channel, null);
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    service.dispose();
  });

  final l10n = AppLocalizationsTr();

  test('info shows an info toast for 4 s and plays no haptic', () {
    service.info((l) => l.kit2_connectedStrip);
    final entry = service.slot.current.value!;
    expect(entry.kind, AppToastKind.info);
    expect(entry.title(l10n), 'Bağlandın');
    expect(presenter.presented, 1);
    expect(service.visible.value, isTrue);
    expect(haptics, isEmpty);
    timers.advance(const Duration(seconds: 4));
    expect(service.visible.value, isFalse);
  });

  test('success and error play their haptic unless told not to', () async {
    service.success((l) => l.kit2_connectedStrip);
    service.error((l) => l.kit2_connectedStrip);
    service.success((l) => l.kit2_connectedStrip, haptic: false);
    service.error((l) => l.kit2_connectedStrip, haptic: false);
    await Future<void>.delayed(Duration.zero);
    expect(haptics.length, 2);
  });

  test('undo keeps the toast 6 s, runs once and plays no haptic', () {
    var undone = 0;
    service.undo((l) => l.kit2_connectedStrip, onUndo: () => undone++);
    final entry = service.slot.current.value!;
    expect(entry.autoClose, const Duration(seconds: 6));
    expect(entry.kind, AppToastKind.success);
    expect(haptics, isEmpty);
    service.slot.undo(entry.id);
    expect(undone, 1);
    expect(service.visible.value, isFalse);
  });

  test('a new toast replaces the one on screen', () {
    service.info((l) => 'one');
    final first = service.slot.current.value!;
    service.info((l) => 'two');
    final second = service.slot.current.value!;
    expect(second.id, isNot(first.id));
    expect(second.title(l10n), 'two');
    timers.advance(const Duration(seconds: 3));
    service.info((l) => 'three');
    timers.advance(const Duration(seconds: 3));
    expect(service.visible.value, isTrue);
  });

  test('a screen reader keeps the toast until it is dismissed', () {
    presenter.screenReaderOn = true;
    service.info((l) => 'x');
    expect(service.slot.current.value!.autoClose, isNull);
    timers.advance(const Duration(minutes: 2));
    expect(service.visible.value, isTrue);
    service.dismiss();
    expect(service.visible.value, isFalse);
  });

  test('without anything to draw on the toast is dropped', () {
    presenter.available = false;
    service.info((l) => 'x');
    expect(service.visible.value, isFalse);
  });

  test('the bar height is passed on to the presenter', () {
    service.bottomBarHeight.value = 64;
    service.info((l) => 'x');
    expect(presenter.lastBarHeight!.value, 64);
    service.bottomBarHeight.value = null;
    expect(presenter.lastBarHeight!.value, isNull);
  });

  test('visible notifies when the toast appears and goes', () {
    final seen = <bool>[];
    service.visible.addListener(() => seen.add(service.visible.value));
    service.info((l) => 'x');
    service.dismiss();
    expect(seen, [true, false]);
  });
}
