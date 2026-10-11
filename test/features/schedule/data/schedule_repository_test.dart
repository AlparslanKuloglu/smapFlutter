import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/schedule/data/schedule_repository.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';

import '../../../core/network/fake_adapter.dart';
import '../network_harness.dart';

Map<String, Object?> _task(String id, String day, int hour) => {
  'id': id,
  'day': day,
  'hour': hour,
  'minute': 0,
  'lesson': 'lesson-1',
  'title': 'Konu $id',
};

Map<String, Object?> _weekly(String id, {List<Object?>? content}) => {
  '_id': id,
  'name': 'Program $id',
  'motto': '',
  'content': content ?? [_task('t1', '2026-10-12', 9)],
};

WeeklyDraft _draft() => WeeklyDraft(
  name: 'Hafta',
  tasks: [
    ProgramTaskDraft(
      id: 'a',
      day: DateTime(2026, 10, 12),
      hour: 9,
      minute: 0,
      lessonId: 'lesson-1',
      title: 'Konu',
    ),
  ],
);

void main() {
  late NetworkService network;
  late FakeAdapter adapter;
  late ScheduleRepository repository;

  void backend(FakeAdapter fake) {
    adapter = fake;
    network = buildNetwork(fake);
    repository = ScheduleRepository(network);
  }

  tearDown(() => network.dispose());

  group('getWeeklies', () {
    test('reads programs and the bag', () async {
      backend(
        FakeAdapter.json({
          'success': true,
          'weeklies': [_weekly('w1'), _weekly('w2')],
          'bagItems': [
            {
              'mainSubject': 'm1',
              'data': {'_id': 'i1', 'name': 'Konu', 'konu': 'k1'},
              'lesson': {'_id': 'lesson-1', 'name': 'TYT Tarih'},
            },
          ],
        }),
      );

      final result = await repository.getWeeklies();

      final response = result.rightOrNull!;
      expect(response.weeklies.map((w) => w.id), ['w1', 'w2']);
      expect(response.weeklies.first.tasks, hasLength(1));
      expect(response.bagItems.single.data?.name, 'Konu');
      expect(adapter.last.method, 'POST');
      expect(adapter.last.path, '/student/getMyWeeklies');
      expect(adapter.last.data, {
        'filter': {'dates': <String>[]},
      });
      expect(adapter.last.queryParameters, isEmpty);
    });

    test('sends the studentId for a coach and the day filter', () async {
      backend(FakeAdapter.json({'success': true, 'weeklies': []}));

      await repository.getWeeklies(
        studentId: 'student-7',
        days: [DateTime(2026, 10, 12)],
      );

      expect(adapter.last.queryParameters, {'studentId': 'student-7'});
      expect(adapter.last.data, {
        'filter': {
          'dates': ['2026-10-12'],
        },
      });
    });

    test('a blank studentId is not sent', () async {
      backend(FakeAdapter.json({'success': true, 'weeklies': []}));

      await repository.getWeeklies(studentId: '  ');

      expect(adapter.last.queryParameters, isEmpty);
    });

    test('no programs yet is a value, not a failure', () async {
      backend(FakeAdapter.json({'success': true}));

      final response = (await repository.getWeeklies()).rightOrNull!;

      expect(response.weeklies, isEmpty);
      expect(response.bagItems, isEmpty);
    });

    test('a broken program does not hide the others', () async {
      backend(
        FakeAdapter.json({
          'success': true,
          'weeklies': [
            'nonsense',
            _weekly('w1'),
            {'_id': 'w2', 'content': 'not json'},
          ],
        }),
      );

      final response = (await repository.getWeeklies()).rightOrNull!;

      expect(response.weeklies.map((w) => w.id), ['w1', 'w2']);
      expect(response.weeklies.last.tasks, isEmpty);
    });

    test(
      'success false is a validation failure with the server text',
      () async {
        backend(FakeAdapter.json({'success': false, 'message': 'Yetkin yok'}));

        final error = failureOf(await repository.getWeeklies());

        expect(error.code, AppErrorCode.validation);
        expect(error.serverMessage, 'Yetkin yok');
        expect(error.path, '/student/getMyWeeklies');
      },
    );

    test('an empty body is an unusable answer', () async {
      backend(FakeAdapter((_) => textResponse('', contentType: 'text/plain')));

      expect(
        failureOf(await repository.getWeeklies()).code,
        AppErrorCode.server,
      );
    });

    test('a page instead of JSON is an unusable answer', () async {
      backend(FakeAdapter((_) => textResponse('<html>login</html>')));

      expect(
        failureOf(await repository.getWeeklies()).code,
        AppErrorCode.server,
      );
    });

    test('a lost session is reported as such', () async {
      backend(FakeAdapter.json({}, status: 401));

      expect(
        failureOf(await repository.getWeeklies()).code,
        AppErrorCode.sessionExpired,
      );
    });

    test('a server error is a server failure', () async {
      backend(FakeAdapter.json({'success': false}, status: 500));

      expect(
        failureOf(await repository.getWeeklies()).code,
        AppErrorCode.server,
      );
    });

    test('a transport failure is a network failure', () async {
      backend(
        FakeAdapter.failing(
          (options) => DioException.connectionError(
            requestOptions: options,
            reason: 'refused',
          ),
        ),
      );

      expect(
        failureOf(await repository.getWeeklies()).code,
        AppErrorCode.network,
      );
    });
  });

  group('getMainSubjects', () {
    test('reads the lists keyed by lesson id', () async {
      backend(
        FakeAdapter.json({
          'success': true,
          'subjectsJson': {
            'lesson-1': [
              {'_id': 's1', 'name': 'Fiiller'},
              'junk',
              {'_id': 's2', 'name': 'Sözcükte Anlam'},
            ],
            'lesson-2': <Object?>[],
            'lesson-3': 'not a list',
          },
        }),
      );

      final subjects = (await repository.getMainSubjects(
        studentId: 'st1',
      )).rightOrNull!;

      expect(subjects.keys, ['lesson-1', 'lesson-2']);
      expect(subjects['lesson-1']!.map((s) => s.name), [
        'Fiiller',
        'Sözcükte Anlam',
      ]);
      expect(subjects['lesson-2'], isEmpty);
      expect(adapter.last.method, 'GET');
      expect(adapter.last.path, '/student/getAllMainSubjects');
      expect(adapter.last.queryParameters, {'studentId': 'st1'});
    });

    test('a missing subjectsJson is an unusable answer', () async {
      backend(FakeAdapter.json({'success': true}));

      expect(
        failureOf(await repository.getMainSubjects()).code,
        AppErrorCode.server,
      );
    });

    test('an empty body fails', () async {
      backend(FakeAdapter((_) => textResponse('', contentType: 'text/plain')));

      expect(
        failureOf(await repository.getMainSubjects()).code,
        AppErrorCode.server,
      );
    });
  });

  group('createWeekly', () {
    test('posts the dataObj and reads the created program', () async {
      backend(FakeAdapter.json({'success': true, 'weekly': _weekly('new')}));

      final result = await repository.createWeekly(
        _draft(),
        studentId: 'student-7',
      );

      expect(result.rightOrNull?.id, 'new');
      expect(adapter.last.method, 'POST');
      expect(adapter.last.path, '/student/addNewProgram');
      expect(adapter.last.queryParameters, {'studentId': 'student-7'});
      final body = adapter.last.data as Map;
      final dataObj = body['dataObj'] as Map;
      expect(dataObj['name'], 'Hafta');
      expect(dataObj.containsKey('weeklyId'), isFalse);
      expect((dataObj['tasks'] as List).single['day'], '2026-10-12');
    });

    test('reads a program echoed under data', () async {
      backend(FakeAdapter.json({'success': true, 'data': _weekly('d1')}));

      expect((await repository.createWeekly(_draft())).rightOrNull?.id, 'd1');
    });

    test('success without an echo is a value of null', () async {
      backend(FakeAdapter.json({'success': true}));

      final result = await repository.createWeekly(_draft());

      expect(result.isRight(), isTrue);
      expect(result.rightOrNull, isNull);
    });

    test('a refusal carries the server text', () async {
      backend(FakeAdapter.json({'success': false, 'message': 'Ad boş'}));

      final error = failureOf(await repository.createWeekly(_draft()));

      expect(error.code, AppErrorCode.validation);
      expect(error.serverMessage, 'Ad boş');
    });

    test('an empty body fails instead of looking saved', () async {
      backend(FakeAdapter((_) => textResponse('', contentType: 'text/plain')));

      expect(
        failureOf(await repository.createWeekly(_draft())).code,
        AppErrorCode.server,
      );
    });
  });

  group('updateWeekly', () {
    test('posts the whole program with its weeklyId', () async {
      backend(FakeAdapter.json({'success': true, 'weekly': _weekly('w1')}));

      final result = await repository.updateWeekly('w1', _draft());

      expect(result.rightOrNull?.id, 'w1');
      expect(adapter.last.path, '/student/updateProgram');
      expect(adapter.last.queryParameters, isEmpty);
      final dataObj = (adapter.last.data as Map)['dataObj'] as Map;
      expect(dataObj['weeklyId'], 'w1');
      expect(dataObj['tasks'], hasLength(1));
    });

    test('a refusal is a failure', () async {
      backend(FakeAdapter.json({'success': false}));

      expect(
        failureOf(await repository.updateWeekly('w1', _draft())).code,
        AppErrorCode.validation,
      );
    });

    test('a timeout is a timeout failure', () async {
      backend(
        FakeAdapter.failing(
          (options) => DioException.receiveTimeout(
            timeout: const Duration(seconds: 30),
            requestOptions: options,
          ),
        ),
      );

      expect(
        failureOf(await repository.updateWeekly('w1', _draft())).code,
        AppErrorCode.timeout,
      );
    });
  });
}
