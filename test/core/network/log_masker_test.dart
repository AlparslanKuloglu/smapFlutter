import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:smap/core/network/log_masker.dart';
import 'package:smap/core/network/masking_log_interceptor.dart';
import 'package:smap/core/services/app_logger.dart';

import 'fake_adapter.dart';

void main() {
  const masker = LogMasker();

  group('LogMasker', () {
    test('sensitive headers are replaced whatever their spelling', () {
      final masked = masker.maskHeaders({
        'Cookie': 'connect.sid=abc',
        'set-cookie': 'connect.sid=abc; Path=/',
        'Authorization': 'Bearer x',
        'Accept': 'application/json',
      });

      expect(masked['Cookie'], LogMasker.mask);
      expect(masked['set-cookie'], LogMasker.mask);
      expect(masked['Authorization'], LogMasker.mask);
      expect(masked['Accept'], 'application/json');
    });

    test('credential fields are replaced at any depth', () {
      final masked =
          masker.maskBody({
                'username': 'ada',
                'password': 'secret',
                'new_password': 'secret2',
                'data': {'refreshToken': 't', 'name': 'Ada'},
                'list': [
                  {'code': '123456'},
                ],
              })!
              as Map<Object?, Object?>;

      expect(masked['username'], 'ada');
      expect(masked['password'], LogMasker.mask);
      expect(masked['new_password'], LogMasker.mask);
      expect(masked['data'], {'refreshToken': LogMasker.mask, 'name': 'Ada'});
      expect(masked['list'], [
        {'code': LogMasker.mask},
      ]);
    });

    test('long strings and lists are cut', () {
      final text = masker.maskBody('a' * 500)! as String;
      final list =
          masker.maskBody(List<int>.generate(25, (i) => i))! as List<Object?>;

      expect(text.length, lessThan(160));
      expect(text, contains('500 chars'));
      expect(list, hasLength(11));
      expect(list.last, '...(15 more)');
    });

    test('form data is described by names only', () {
      final form = FormData.fromMap({
        'user_data': '{"name":"Ada"}',
        'note': 'hi',
        'image': MultipartFile.fromBytes([1, 2, 3], filename: 'a.jpg'),
      });

      final masked = masker.maskBody(form)! as Map<Object?, Object?>;

      expect(masked['files'], ['image']);
      expect(masked['fields'], {'user_data': LogMasker.mask, 'note': 'hi'});
    });

    test('sensitive query parameters are replaced', () {
      final uri = masker.maskUri(
        Uri.parse('https://x.test/a?token=abc&page=2'),
      );

      expect(uri.queryParameters, {'token': LogMasker.mask, 'page': '2'});
    });

    test('unknown objects are printed by type only', () {
      expect(masker.maskBody(Object()), '<Object>');
    });
  });

  group('MaskingLogInterceptor', () {
    test('logs the call but never a password or cookie', () async {
      final output = MemoryOutput();
      final logger = AppLogger(
        enabled: true,
        logger: Logger(
          filter: ProductionFilter(),
          printer: SimplePrinter(colors: false),
          output: output,
        ),
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://x.test'))
        ..httpClientAdapter = FakeAdapter.json({'ok': true})
        ..interceptors.add(MaskingLogInterceptor(logger));

      await dio.post<Object?>(
        '/student/login',
        data: {'username': 'ada', 'password': 'hunter2'},
        options: Options(headers: {'Cookie': 'connect.sid=s3cr3t'}),
      );

      final text = output.buffer.expand((e) => e.lines).join('\n');
      expect(text, contains('/student/login'));
      expect(text, contains('ada'));
      expect(text, isNot(contains('hunter2')));
      expect(text, isNot(contains('s3cr3t')));
    });
  });
}
