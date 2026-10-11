import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/coach/data/interview_repository.dart';
import 'package:smap/features/coach/domain/interview_filter.dart';
import 'package:smap/features/coach/domain/interview_type.dart';

import '../../../core/network/fake_adapter.dart';
import '../../schedule/network_harness.dart';
import '../coach_fixtures.dart';

void main() {
  late NetworkService network;
  late FakeAdapter adapter;
  late InterviewRepository repository;

  void backend(FakeAdapter fake) {
    adapter = fake;
    network = buildNetwork(fake);
    repository = InterviewRepository(network);
  }

  FakeAdapter emptyBody() =>
      FakeAdapter((_) => textResponse('', contentType: 'text/plain'));

  tearDown(() => network.dispose());

  group('getInterviews', () {
    test('asks for a page with the filter and reads the interviews', () async {
      backend(
        FakeAdapter.json({
          'success': true,
          'interviews': [interviewJson(), interviewJson(id: 'iv-2', type: 2)],
        }),
      );

      final page = (await repository.getInterviews(
        page: 2,
        limit: 8,
        filter: InterviewFilter(
          types: const [InterviewType.parent],
          dates: [DateTime(2026, 6, 28)],
        ),
      )).rightOrNull!;

      expect(page.items.map((i) => i.id), ['iv-1', 'iv-2']);
      expect(page.page, 2);
      expect(page.limit, 8);
      expect(adapter.last.method, 'POST');
      expect(adapter.last.path, '/coach/getInterviews');
      expect(adapter.last.queryParameters, {'page': 2, 'limit': 8});
      expect(adapter.last.data, {
        'filter': {
          'types': [2],
          'dates': ['2026-06-28'],
        },
      });
    });

    test('defaults to page 1, 8 per page and no filter', () async {
      backend(FakeAdapter.json({'success': true, 'interviews': <Object?>[]}));

      await repository.getInterviews();

      expect(adapter.last.queryParameters, {'page': 1, 'limit': 8});
      expect(adapter.last.data, {
        'filter': {'types': <int>[], 'dates': <String>[]},
      });
    });

    test('a full page may have more, a short one is the end', () async {
      backend(
        FakeAdapter.json({
          'success': true,
          'interviews': [interviewJson(), interviewJson(id: 'b')],
        }),
      );

      final full = (await repository.getInterviews(limit: 2)).rightOrNull!;
      final short = (await repository.getInterviews(limit: 3)).rightOrNull!;

      expect(full.hasMore, isTrue);
      expect(short.hasMore, isFalse);
    });

    test('no interviews yet is a value', () async {
      backend(FakeAdapter.json({'success': true, 'interviews': <Object?>[]}));

      final page = (await repository.getInterviews()).rightOrNull!;

      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
    });

    test('a broken entry does not hide the others', () async {
      backend(
        FakeAdapter.json({
          'success': true,
          'interviews': [5, interviewJson(), 'x'],
        }),
      );

      expect(
        (await repository.getInterviews()).rightOrNull!.items,
        hasLength(1),
      );
    });

    test('success false is a validation failure', () async {
      backend(FakeAdapter.json({'success': false, 'message': 'Yok'}));

      expect(
        failureOf(await repository.getInterviews()).code,
        AppErrorCode.validation,
      );
    });

    test('an empty body is an unusable answer', () async {
      backend(emptyBody());

      expect(
        failureOf(await repository.getInterviews()).code,
        AppErrorCode.server,
      );
    });

    test('a lost session is reported as such', () async {
      backend(FakeAdapter.json({}, status: 403));

      expect(
        failureOf(await repository.getInterviews()).code,
        AppErrorCode.sessionExpired,
      );
    });
  });

  group('createInterview', () {
    final when = DateTime.utc(2026, 7, 1, 11, 30);

    test('sends the date as a UTC instant and returns the interview', () async {
      backend(
        FakeAdapter.json({
          'success': true,
          'newInterview': interviewJson(id: 'new', student: 'student-1'),
        }),
      );

      final created = (await repository.createInterview(
        studentId: 'student-1',
        type: InterviewType.student,
        date: when,
      )).rightOrNull!;

      expect(created.id, 'new');
      expect(adapter.last.method, 'POST');
      expect(adapter.last.path, '/coach/addNewInterview');
      expect(adapter.last.data, {
        'dataObj': {
          'date': '2026-07-01T11:30:00.000Z',
          'type': 1,
          'student': 'student-1',
        },
      });
    });

    test('a local time is converted to UTC before it is sent', () async {
      backend(FakeAdapter.json({'success': true}));
      final local = DateTime(2026, 7, 1, 14, 30);

      await repository.createInterview(
        studentId: 's',
        type: InterviewType.parent,
        date: local,
      );

      final sent =
          ((adapter.last.data as Map)['dataObj'] as Map)['date'] as String;
      // Legacy wire format: zoneless local time.
      expect(sent, isNot(endsWith('Z')));
      expect(sent, '2026-07-01T14:30:00.000');
      expect(((adapter.last.data as Map)['dataObj'] as Map)['type'], 2);
    });

    test('success without the interview is a value of null', () async {
      backend(FakeAdapter.json({'success': true}));

      final result = await repository.createInterview(
        studentId: 's',
        type: InterviewType.student,
        date: when,
      );

      expect(result.isRight(), isTrue);
      expect(result.rightOrNull, isNull);
    });

    test('a refusal and an empty body are failures', () async {
      backend(FakeAdapter.json({'success': false, 'message': 'Öğrenci yok'}));
      final refused = await repository.createInterview(
        studentId: 's',
        type: InterviewType.student,
        date: when,
      );
      expect(failureOf(refused).code, AppErrorCode.validation);
      expect(failureOf(refused).serverMessage, 'Öğrenci yok');
      network.dispose();

      backend(emptyBody());
      final empty = await repository.createInterview(
        studentId: 's',
        type: InterviewType.student,
        date: when,
      );
      expect(failureOf(empty).code, AppErrorCode.server);
    });
  });

  group('notes', () {
    test('addNote posts the interview id and the text', () async {
      backend(FakeAdapter.json({'success': true}));

      final result = await repository.addNote(interviewId: 'iv-1', note: 'Not');

      expect(result.isRight(), isTrue);
      expect(adapter.last.path, '/coach/addNewNote');
      expect(adapter.last.data, {
        'dataObj': {'interview': 'iv-1', 'note': 'Not'},
      });
    });

    test('editNote posts the position', () async {
      backend(FakeAdapter.json({'success': true}));

      await repository.editNote(interviewId: 'iv-1', index: 2, note: 'Yeni');

      expect(adapter.last.path, '/coach/editNote');
      expect(adapter.last.data, {
        'dataObj': {'interview': 'iv-1', 'note': 'Yeni', 'editIndex': 2},
      });
    });

    test('deleteNote posts the position', () async {
      backend(FakeAdapter.json({'success': true}));

      await repository.deleteNote(interviewId: 'iv-1', index: 0);

      expect(adapter.last.path, '/coach/deleteNote');
      expect(adapter.last.data, {
        'dataObj': {'interview': 'iv-1', 'deleteIndex': 0},
      });
    });

    test('a refusal carries the server text', () async {
      backend(FakeAdapter.json({'success': false, 'message': 'Not yok'}));

      final error = failureOf(
        await repository.deleteNote(interviewId: 'iv-1', index: 9),
      );

      expect(error.code, AppErrorCode.validation);
      expect(error.serverMessage, 'Not yok');
    });

    test('an empty body is not a success', () async {
      backend(emptyBody());

      expect(
        failureOf(await repository.addNote(interviewId: 'iv', note: 'n')).code,
        AppErrorCode.server,
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
        failureOf(
          await repository.editNote(interviewId: 'iv', index: 0, note: 'n'),
        ).code,
        AppErrorCode.timeout,
      );
    });
  });
}
