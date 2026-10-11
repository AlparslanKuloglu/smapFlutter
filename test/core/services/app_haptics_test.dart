import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/app_haptics.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = binding.defaultBinaryMessenger;
  final channelCalls = <String>[];
  final platformCalls = <String>[];

  setUp(() {
    AppHaptics.enabled = true;
    channelCalls.clear();
    platformCalls.clear();
    messenger.setMockMethodCallHandler(AppHaptics.channel, (call) async {
      channelCalls.add(call.method);
      return null;
    });
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        platformCalls.add(call.arguments as String);
      }
      return null;
    });
  });

  tearDown(() {
    AppHaptics.enabled = true;
    messenger.setMockMethodCallHandler(AppHaptics.channel, null);
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('the channel is smap/haptics', () {
    expect(AppHaptics.channel.name, 'smap/haptics');
  });

  test('selection and medium are Flutter impacts, not the channel', () async {
    AppHaptics.selection();
    AppHaptics.medium();
    await pumpEventQueue();
    expect(platformCalls, [
      'HapticFeedbackType.selectionClick',
      'HapticFeedbackType.mediumImpact',
    ]);
    expect(channelCalls, isEmpty);
  });

  test('success and error go through the channel', () async {
    AppHaptics.success();
    AppHaptics.error();
    await pumpEventQueue();
    expect(channelCalls, ['success', 'error']);
    expect(platformCalls, isEmpty);
  });

  test('enabled = false silences every call', () async {
    AppHaptics.enabled = false;
    AppHaptics.selection();
    AppHaptics.medium();
    AppHaptics.success();
    AppHaptics.error();
    await pumpEventQueue();
    expect(channelCalls, isEmpty);
    expect(platformCalls, isEmpty);
  });

  test('a missing channel (tests, desktop) is a silent no-op', () async {
    messenger.setMockMethodCallHandler(AppHaptics.channel, null);
    AppHaptics.success();
    AppHaptics.error();
    await pumpEventQueue();
  });

  test('a native failure is swallowed', () async {
    messenger.setMockMethodCallHandler(AppHaptics.channel, (call) async {
      throw PlatformException(code: 'unavailable');
    });
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      throw PlatformException(code: 'unavailable');
    });
    AppHaptics.success();
    AppHaptics.selection();
    await pumpEventQueue();
  });
}
