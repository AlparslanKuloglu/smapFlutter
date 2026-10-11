import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/extensions/either_extensions.dart';

void main() {
  const failure = AppException(code: AppErrorCode.offline);
  const Either<AppException, int> right = Right(4);
  const Either<AppException, int> left = Left(failure);

  group('EitherAccessors', () {
    test('rightOrNull and leftOrNull never throw', () {
      expect(right.rightOrNull, 4);
      expect(right.leftOrNull, isNull);
      expect(left.rightOrNull, isNull);
      expect(left.leftOrNull, same(failure));
    });

    test('rightOr gives the fallback for a failure', () {
      expect(right.rightOr(9), 4);
      expect(left.rightOr(9), 9);
    });

    test('when reads like fold with names', () {
      expect(right.when(failure: (_) => 'f', success: (v) => 's$v'), 's4');
      expect(left.when(failure: (_) => 'f', success: (v) => 's$v'), 'f');
    });

    test('onRight and onLeft run for their side only and chain', () {
      final seen = <String>[];

      right.onRight((v) => seen.add('r$v')).onLeft((_) => seen.add('l'));
      left.onRight((v) => seen.add('r$v')).onLeft((_) => seen.add('l'));

      expect(seen, ['r4', 'l']);
    });
  });

  group('AppResultAccessors', () {
    test('errorCode and failedWith', () {
      expect(left.errorCode, AppErrorCode.offline);
      expect(right.errorCode, isNull);
      expect(left.failedWith(AppErrorCode.offline), isTrue);
      expect(left.failedWith(AppErrorCode.server), isFalse);
      expect(right.failedWith(AppErrorCode.offline), isFalse);
    });
  });

  group('FutureEitherChain', () {
    test('mapRight maps a value and leaves a failure alone', () async {
      expect(
        await Future.value(right).mapRight((v) => v * 2),
        const Right<AppException, int>(8),
      );
      expect(await Future.value(left).mapRight((v) => v * 2), left);
    });

    test('bindRight continues only after a value', () async {
      var calls = 0;
      Future<Either<AppException, String>> next(int v) async {
        calls++;
        return Right('v$v');
      }

      expect(
        await Future.value(right).bindRight(next),
        const Right<AppException, String>('v4'),
      );
      expect(
        (await Future.value(left).bindRight(next)).leftOrNull,
        same(failure),
      );
      expect(calls, 1);
    });
  });
}
