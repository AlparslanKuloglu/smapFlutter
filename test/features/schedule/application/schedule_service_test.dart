import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/data/schedule_repository.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';

import '../../../core/network/fake_adapter.dart';
import '../network_harness.dart';

Map<String, Object?> _weekly(String id, {String day = '2026-10-12'}) => {
  '_id': id,
  'name': 'Program $id',
  'content': [
    {
      'id': 't-$id',
      'day': day,
      'hour': 9,
      'minute': 0,
      'lesson': 'l',
      'title': 'Konu',
    },
  ],
};

WeeklyDraft _draft([String name = 'Hafta']) => WeeklyDraft(
  name: name,
  tasks: [
    ProgramTaskDraft(
      id: 'a',
      day: DateTime(2026, 10, 12),
      hour: 9,
      minute: 0,
      lessonId: 'l',
      title: 'Konu',
    ),
  ],
);

/// A tiny stateful backend: the stored programs, the requests it saw.
class _Server {
  List<Map<String, Object?>> weeklies = [_weekly('w1')];
  bool echoSaved = true;
  int listCalls = 0;
  int subjectCalls = 0;
  final List<String> writes = [];
  Completer<void>? holdFirstWrite;

  FakeAdapter get adapter => FakeAdapter((options) async {
    switch (options.path) {
      case '/student/getMyWeeklies':
        listCalls++;
        return jsonResponse({
          'success': true,
          'weeklies': weeklies,
          'bagItems': [
            {
              'mainSubject': 'm',
              'data': {'_id': 'i1', 'name': 'Çanta konusu'},
            },
          ],
        });
      case '/student/getAllMainSubjects':
        subjectCalls++;
        return jsonResponse({
          'success': true,
          'subjectsJson': {
            'l': [
              {'_id': 's', 'name': 'Fiiller'},
            ],
          },
        });
      case '/student/addNewProgram':
        final created = _weekly('w${weeklies.length + 1}');
        final hold = holdFirstWrite;
        if (hold != null) {
          holdFirstWrite = null;
          await hold.future;
        }
        writes.add('add:${(options.data as Map)['dataObj']['name']}');
        weeklies = [created, ...weeklies];
        return jsonResponse({
          'success': true,
          if (echoSaved) 'weekly': created,
        });
      case '/student/updateProgram':
        final dataObj = (options.data as Map)['dataObj'] as Map;
        final hold = holdFirstWrite;
        if (hold != null) {
          holdFirstWrite = null;
          await hold.future;
        }
        writes.add('update:${dataObj['weeklyId']}:${dataObj['name']}');
        final updated = {
          ..._weekly(dataObj['weeklyId'] as String),
          'name': dataObj['name'],
        };
        weeklies = [
          for (final w in weeklies) w['_id'] == updated['_id'] ? updated : w,
        ];
        return jsonResponse({
          'success': true,
          if (echoSaved) 'weekly': updated,
        });
    }
    return jsonResponse({'success': false}, status: 404);
  });
}

void main() {
  late _Server server;
  late NetworkService network;
  late ScheduleService service;
  late DateTime now;

  setUp(() {
    server = _Server();
    now = DateTime(2026, 10, 12, 8);
    network = buildNetwork(server.adapter);
    service = ScheduleService(
      repository: ScheduleRepository(network),
      clock: () => now,
      staleAfter: const Duration(minutes: 2),
    );
  });

  tearDown(() {
    service.dispose();
    network.dispose();
  });

  group('load', () {
    test(
      'fetches once, then answers from the cache while it is fresh',
      () async {
        final first = await service.load();
        now = now.add(const Duration(minutes: 1));
        final second = await service.load();

        expect(first.rightOrNull?.weeklies, hasLength(1));
        expect(second.rightOrNull, same(first.rightOrNull));
        expect(server.listCalls, 1);
      },
    );

    test(
      'fetches again when the snapshot is stale or a refresh is forced',
      () async {
        await service.load();
        now = now.add(const Duration(minutes: 3));
        await service.load();
        await service.load(forceRefresh: true);

        expect(server.listCalls, 3);
      },
    );

    test('joins a fetch that is already running', () async {
      final a = service.load();
      final b = service.load();
      await Future.wait([a, b]);

      expect(server.listCalls, 1);
    });

    test('keeps one snapshot per student', () async {
      await service.load();
      await service.load(studentId: 'student-7');

      expect(server.listCalls, 2);
      expect(service.snapshot(), isNotNull);
      expect(service.snapshot(studentId: 'student-7')?.studentId, 'student-7');
      expect(service.snapshot(studentId: 'other'), isNull);
    });

    test('a blank studentId is the signed-in user', () async {
      await service.load();
      await service.load(studentId: ' ');

      expect(server.listCalls, 1);
    });

    test('the bag lives in the snapshot', () async {
      await service.load();

      expect(service.snapshot()!.bagItems.single.data?.name, 'Çanta konusu');
    });

    test(
      'a failed refresh keeps the old snapshot and reports the failure',
      () async {
        var healthy = true;
        final backend = server.adapter;
        network.dispose();
        network = buildNetwork(
          FakeAdapter((options) {
            if (!healthy) return jsonResponse({}, status: 500);
            return backend.handler(options);
          }),
        );
        service = ScheduleService(
          repository: ScheduleRepository(network),
          clock: () => now,
        );

        await service.load();
        healthy = false;
        final failed = await service.load(forceRefresh: true);

        expect(failureOf(failed).code, AppErrorCode.server);
        expect(service.snapshot()?.weeklies, hasLength(1));
      },
    );

    test('invalidate makes the next load fetch', () async {
      await service.load();
      service.invalidate();
      await service.load();
      service.invalidate(studentId: 'nobody');

      expect(server.listCalls, 2);
    });

    test('notifies listeners when the snapshot changes', () async {
      var notified = 0;
      service.addListener(() => notified++);
      await Future<void>.delayed(Duration.zero);
      final before = notified;

      await service.load();
      await Future<void>.delayed(Duration.zero);

      expect(notified, greaterThan(before));
    });
  });

  group('today', () {
    test(
      'is empty before the first load, then filters by the clock day',
      () async {
        expect(service.today(), isEmpty);

        await service.load();

        expect(service.today().map((t) => t.task.id), ['t-w1']);
        expect(service.today(now: DateTime(2026, 10, 13)), isEmpty);
      },
    );
  });

  group('writes', () {
    test('a created program goes to the top of the snapshot', () async {
      await service.load();

      final result = await service.createWeekly(_draft());

      expect(result.rightOrNull?.id, 'w2');
      expect(service.snapshot()!.weeklies.map((w) => w.id), ['w2', 'w1']);
      expect(server.listCalls, 1, reason: 'the echo made a reload unnecessary');
    });

    test('an updated program replaces the old one in place', () async {
      await service.load();

      final result = await service.updateWeekly('w1', _draft('Yeni ad'));

      expect(result.rightOrNull?.name, 'Yeni ad');
      expect(service.snapshot()!.weeklies.single.name, 'Yeni ad');
    });

    test(
      'without an echo the list is fetched and the new program found',
      () async {
        server.echoSaved = false;
        await service.load();

        final created = await service.createWeekly(_draft());
        final updated = await service.updateWeekly('w1', _draft('Başka'));

        expect(created.rightOrNull?.id, 'w2');
        expect(updated.rightOrNull?.name, 'Başka');
        expect(server.listCalls, 3);
      },
    );

    test('a write before the first load does not invent a snapshot', () async {
      final result = await service.createWeekly(_draft());

      expect(result.isRight(), isTrue);
      expect(service.snapshot(), isNull);
    });

    test('a refusal is reported and the snapshot is untouched', () async {
      await service.load();
      network.dispose();
      network = buildNetwork(
        FakeAdapter.json({'success': false, 'message': 'Ad boş'}),
      );
      final refusing = ScheduleService(
        repository: ScheduleRepository(network),
        clock: () => now,
      );

      final result = await refusing.updateWeekly('w1', _draft());

      expect(failureOf(result).code, AppErrorCode.validation);
      expect(failureOf(result).serverMessage, 'Ad boş');
    });

    test('writes reach the server one after the other, in order', () async {
      await service.load();
      final gate = Completer<void>();
      server.holdFirstWrite = gate;

      final first = service.updateWeekly('w1', _draft('bir'));
      final second = service.updateWeekly('w1', _draft('iki'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(server.writes, isEmpty, reason: 'the second waits for the first');

      gate.complete();
      await Future.wait([first, second]);

      expect(server.writes, ['update:w1:bir', 'update:w1:iki']);
      expect(service.snapshot()!.weeklies.single.name, 'iki');
    });

    test('a failed write does not block the next one', () async {
      await service.load();
      var failNext = true;
      final backend = server.adapter;
      network.dispose();
      network = buildNetwork(
        FakeAdapter((options) {
          if (options.path == '/student/updateProgram' && failNext) {
            failNext = false;
            return jsonResponse({}, status: 500);
          }
          return backend.handler(options);
        }),
      );
      service = ScheduleService(
        repository: ScheduleRepository(network),
        clock: () => now,
      );
      await service.load();

      final failed = await service.updateWeekly('w1', _draft('bir'));
      final fine = await service.updateWeekly('w1', _draft('iki'));

      expect(failed.isLeft(), isTrue);
      expect(fine.rightOrNull?.name, 'iki');
    });

    test('a coach write goes out with the studentId', () async {
      final adapter = server.adapter;
      network.dispose();
      final recording = FakeAdapter(adapter.handler);
      network = buildNetwork(recording);
      service = ScheduleService(
        repository: ScheduleRepository(network),
        clock: () => now,
      );
      await service.load(studentId: 'student-7');

      await service.createWeekly(_draft(), studentId: 'student-7');

      expect(recording.requests.map((r) => r.queryParameters['studentId']), [
        'student-7',
        'student-7',
      ]);
      expect(service.snapshot(studentId: 'student-7')!.weeklies.first.id, 'w2');
      expect(service.snapshot(), isNull);
    });
  });

  group('mainSubjects', () {
    test('are cached for the session and can be refreshed', () async {
      final a = await service.mainSubjects();
      final b = await service.mainSubjects();
      await service.mainSubjects(forceRefresh: true);

      expect(a.rightOrNull!['l']!.single.name, 'Fiiller');
      expect(b.rightOrNull, same(a.rightOrNull));
      expect(server.subjectCalls, 2);
    });

    test('are kept per student and dropped by clear', () async {
      await service.mainSubjects();
      await service.mainSubjects(studentId: 'student-7');
      service.clear();
      await service.mainSubjects();

      expect(server.subjectCalls, 3);
    });

    test('are fetched once for concurrent callers', () async {
      await Future.wait([service.mainSubjects(), service.mainSubjects()]);

      expect(server.subjectCalls, 1);
    });
  });

  test('clear forgets every snapshot', () async {
    await service.load();
    service.clear();

    expect(service.snapshot(), isNull);
  });
}
