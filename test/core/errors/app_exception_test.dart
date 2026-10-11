import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';

void main() {
  group('AppException.from', () {
    test('an AppException passes through unchanged', () {
      const original = AppException(code: AppErrorCode.offline);

      expect(AppException.from(original), same(original));
    });

    test('any other error becomes unknown and keeps its cause', () {
      final error = StateError('boom');
      final exception = AppException.from(error, StackTrace.current);

      expect(exception.code, AppErrorCode.unknown);
      expect(exception.cause, same(error));
      expect(exception.stackTrace, isNotNull);
      expect(exception.message, contains('boom'));
    });
  });

  test('AppException.parse is unknown and names the path', () {
    final exception = AppException.parse(
      const FormatException('bad'),
      null,
      '/student/me',
    );

    expect(exception.code, AppErrorCode.unknown);
    expect(exception.path, '/student/me');
  });

  test('toString has code, status, path and message', () {
    const exception = AppException(
      code: AppErrorCode.notFound,
      statusCode: 404,
      path: '/a',
      message: 'HTTP 404',
    );

    expect(exception.toString(), 'AppException(notFound) [404] /a: HTTP 404');
  });

  test('flags follow the code', () {
    expect(const AppException(code: AppErrorCode.offline).isOffline, isTrue);
    expect(
      const AppException(code: AppErrorCode.sessionExpired).isSessionExpired,
      isTrue,
    );
    expect(
      const AppException(code: AppErrorCode.cancelled).isCancelled,
      isTrue,
    );
    expect(const AppException(code: AppErrorCode.server).isOffline, isFalse);
  });

  group('guard', () {
    test('guardAsync returns Right for a value', () async {
      final result = await guardAsync(() async => 3);

      expect(result.isRight(), isTrue);
    });

    test('guardAsync turns a throw into Left(unknown)', () async {
      final result = await guardAsync<int>(() async => throw StateError('x'));

      result.fold(
        (e) => expect(e.code, AppErrorCode.unknown),
        (_) => fail('expected a failure'),
      );
    });

    test('guard keeps an AppException a callee threw', () {
      final result = guard<int>(
        () => throw const AppException(code: AppErrorCode.forbidden),
      );

      result.fold(
        (e) => expect(e.code, AppErrorCode.forbidden),
        (_) => fail('expected a failure'),
      );
    });
  });
}
