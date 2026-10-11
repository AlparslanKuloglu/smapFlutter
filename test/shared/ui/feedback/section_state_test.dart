import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import 'fake_timers.dart';

void main() {
  group('AsyncSection', () {
    test('constructors map to their state and carry data only when ready', () {
      expect(const AsyncSection<int>.loading().isLoading, isTrue);
      expect(const AsyncSection<int>.ready(3).data, 3);
      expect(const AsyncSection<int>.ready(3).isReady, isTrue);
      expect(const AsyncSection<int>.empty().data, isNull);
      expect(const AsyncSection<int>.empty().isEmpty, isTrue);
      expect(const AsyncSection<int>.error('x').isError, isTrue);
      expect(const AsyncSection<int>.offline().isOffline, isTrue);
    });

    test('equality is by state, data and error text', () {
      expect(
        const AsyncSection<int>.ready(1),
        const AsyncSection<int>.ready(1),
      );
      expect(
        const AsyncSection<int>.ready(1),
        isNot(const AsyncSection<int>.ready(2)),
      );
      expect(
        const AsyncSection<int>.loading(),
        isNot(const AsyncSection<int>.empty()),
      );
      expect(
        const AsyncSection<int>.ready(1).hashCode,
        const AsyncSection<int>.ready(1).hashCode,
      );
    });

    test('of() turns an empty value into the empty state', () {
      final empty = AsyncSection.of<List<int>>(
        const [],
        isEmpty: (l) => l.isEmpty,
      );
      expect(empty.state, SectionState.empty);
      final ready = AsyncSection.of<List<int>>(const [
        1,
      ], isEmpty: (l) => l.isEmpty);
      expect(ready.state, SectionState.ready);
      expect(ready.data, [1]);
      expect(AsyncSection.of<List<int>>(const []).state, SectionState.ready);
    });

    test('failed() separates "no connection" from every other failure', () {
      expect(
        AsyncSection.failed<int>(
          const AppException(code: AppErrorCode.offline),
        ).state,
        SectionState.offline,
      );
      expect(
        AsyncSection.failed<int>(
          const AppException(code: AppErrorCode.server),
        ).state,
        SectionState.error,
      );
      expect(
        AsyncSection.failed<int>(StateError('x')).state,
        SectionState.error,
      );
      expect(
        AsyncSection.failed<int>(TimeoutException('slow')).state,
        SectionState.error,
      );
    });

    test(
      'load() maps data, empty, offline and error and never throws',
      () async {
        expect((await AsyncSection.load<int>(() async => 4)).data, 4);
        expect(
          (await AsyncSection.load<List<int>>(
            () async => const [],
            isEmpty: (l) => l.isEmpty,
          )).state,
          SectionState.empty,
        );
        expect(
          (await AsyncSection.load<int>(
            () async => throw const AppException(code: AppErrorCode.offline),
          )).state,
          SectionState.offline,
        );
        expect(
          (await AsyncSection.load<int>(
            () async => throw StateError('boom'),
          )).state,
          SectionState.error,
        );
      },
    );

    test(
      'load() ends in the error state when the fetch outlasts the limit',
      () async {
        final never = Completer<int>();
        final section = await AsyncSection.load<int>(
          () => never.future,
          timeout: const Duration(milliseconds: 20),
        );
        expect(section.state, SectionState.error);
        expect(section.error, isA<TimeoutException>());
      },
    );
  });

  group('withSkeletonTimeout', () {
    test('default limit is the 15 s of the skeleton', () {
      expect(SmapDurations.skeletonTimeout, const Duration(seconds: 15));
    });

    test('passes a value that arrives in time', () async {
      expect(await withSkeletonTimeout(Future<int>.value(7)), 7);
    });

    test('throws TimeoutException after the limit', () async {
      final never = Completer<int>();
      await expectLater(
        withSkeletonTimeout(
          never.future,
          timeout: const Duration(milliseconds: 10),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });
  });

  group('SkeletonWatchdog', () {
    test('fires once after the limit when never stopped', () {
      final timers = FakeTimers();
      var fired = 0;
      final dog = SkeletonWatchdog(
        onTimeout: () => fired++,
        timerFactory: timers.create,
      )..start();
      expect(dog.running, isTrue);
      timers.advance(const Duration(seconds: 14));
      expect(fired, 0);
      timers.advance(const Duration(seconds: 1));
      expect(fired, 1);
      expect(dog.running, isFalse);
      timers.advance(const Duration(minutes: 1));
      expect(fired, 1);
    });

    test('stop() before the limit means no timeout', () {
      final timers = FakeTimers();
      var fired = 0;
      SkeletonWatchdog(onTimeout: () => fired++, timerFactory: timers.create)
        ..start()
        ..stop();
      timers.advance(const Duration(minutes: 1));
      expect(fired, 0);
    });

    test('start() again restarts the count', () {
      final timers = FakeTimers();
      var fired = 0;
      final dog = SkeletonWatchdog(
        onTimeout: () => fired++,
        timerFactory: timers.create,
      )..start();
      timers.advance(const Duration(seconds: 10));
      dog.start();
      timers.advance(const Duration(seconds: 10));
      expect(fired, 0);
      timers.advance(const Duration(seconds: 5));
      expect(fired, 1);
    });
  });
}
