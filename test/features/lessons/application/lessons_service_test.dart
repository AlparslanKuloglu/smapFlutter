import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/features/lessons/domain/general_lesson.dart';

import '../../../core/network/fake_adapter.dart';
import '../../exams/data/data_harness.dart';
import '../data/lesson_fixtures.dart';

/// A backend that counts calls and can be told to fail one of the two
/// endpoints or to wait.
class _Backend {
  int lessonCalls = 0;
  int missingCalls = 0;
  final List<String?> missingStudents = [];
  bool lessonsFail = false;
  bool missingFail = false;
  Completer<void>? gate;
  Map<String, Object?> missingBody = lessonsMissingAnswer();

  late final FakeAdapter adapter = FakeAdapter((options) async {
    final wait = gate;
    if (wait != null) await wait.future;
    switch (options.path) {
      case '/ajax/getGeneralLessons':
        lessonCalls++;
        return lessonsFail
            ? jsonResponse({'success': false}, status: 500)
            : jsonResponse(generalLessonsAnswer());
      case '/student/getLessonsTotalMissing':
        missingCalls++;
        missingStudents.add(options.queryParameters['studentId'] as String?);
        return missingFail
            ? jsonResponse({'success': false}, status: 500)
            : jsonResponse(missingBody);
    }
    return jsonResponse({'error': 'no route'}, status: 404);
  });
}

void main() {
  late _Backend backend;
  late NetworkService network;
  late LessonsService service;
  late DateTime now;
  late int notifications;

  setUp(() {
    backend = _Backend();
    network = networkOver(backend.adapter);
    now = DateTime(2026, 10, 11, 12);
    service = LessonsService(
      repository: LessonContentRepository(network),
      clock: () => now,
    );
    notifications = 0;
    service.addListener(() => notifications++);
  });

  tearDown(() {
    service.dispose();
    network.dispose();
  });

  test('starts empty', () {
    expect(service.entries, isEmpty);
    expect(service.isLoading, isFalse);
    expect(service.error, isNull);
    expect(service.state.hasData, isFalse);
  });

  group('load', () {
    test('fetches both answers and joins them in strip order', () async {
      await service.load();

      expect(service.entries.map((e) => e.lesson.name), [
        'Türkçe',
        'Tarih',
        'Matematik',
      ]);
      final tarih = service.entryOf(tarihId)!;
      expect(tarih.missingOf(LessonTrack.tyt), 3);
      expect(tarih.missingOf(LessonTrack.ayt), 5);
      expect(tarih.totalMissing, 8);
      expect(service.entryOf(turkceId)!.totalMissing, 12);
      expect(
        service.entryOf(matematikId)!.missing,
        isNull,
        reason: 'not counted: unknown, not zero',
      );
      expect(service.error, isNull);
      expect(service.state.hasData, isTrue);
      expect(service.isLoading, isFalse);
      expect(service.entryOf('nope'), isNull);
    });

    test('shows a loading state while it fetches, then settles', () async {
      backend.gate = Completer<void>();
      final done = service.load();
      await Future<void>.delayed(Duration.zero);

      expect(service.isLoading, isTrue);

      backend.gate!.complete();
      await done;

      expect(service.isLoading, isFalse);
      expect(notifications, greaterThanOrEqualTo(2));
    });

    test('uses the cache while it is fresh', () async {
      await service.load();
      now = now.add(const Duration(minutes: 4));
      await service.load();

      expect(backend.lessonCalls, 1);
      expect(backend.missingCalls, 1);
    });

    test('fetches again once the cache is stale', () async {
      await service.load();
      now = now.add(const Duration(minutes: 6));
      await service.load();

      expect(backend.lessonCalls, 2);
      expect(backend.missingCalls, 2);
    });

    test('a failed load is retried by the next load', () async {
      backend.lessonsFail = true;
      backend.missingFail = true;
      await service.load();
      expect(service.error, isNotNull);
      expect(service.entries, isEmpty);

      backend
        ..lessonsFail = false
        ..missingFail = false;
      await service.load();

      expect(service.error, isNull);
      expect(service.entries, hasLength(3));
    });
  });

  group('refresh', () {
    test('always fetches', () async {
      await service.load();
      await service.refresh();

      expect(backend.lessonCalls, 2);
    });

    test('calls that overlap share one fetch', () async {
      backend.gate = Completer<void>();
      final first = service.refresh();
      final second = service.refresh();

      expect(identical(first, second), isTrue);
      backend.gate!.complete();
      await Future.wait([first, second]);

      expect(backend.lessonCalls, 1);
      expect(backend.missingCalls, 1);
    });

    test('keeps the earlier lessons when a refresh fails', () async {
      await service.load();
      backend
        ..lessonsFail = true
        ..missingFail = true;

      await service.refresh();

      expect(service.entries, hasLength(3));
      expect(service.entryOf(tarihId)!.totalMissing, 8);
      expect(service.error?.code, AppErrorCode.server);
      expect(service.state.hasData, isTrue);
    });

    test(
      'a failed count keeps the old counts and still updates lessons',
      () async {
        await service.load();
        backend.missingFail = true;

        await service.refresh();

        expect(service.entryOf(tarihId)!.totalMissing, 8);
        expect(
          service.error,
          isNotNull,
          reason: 'the count failure is reported',
        );
        expect(service.entries, hasLength(3));
      },
    );

    test('lessons without counts show up when only the counts fail', () async {
      backend.missingFail = true;

      await service.refresh();

      expect(service.entries, hasLength(3));
      expect(service.entries.every((e) => e.missing == null), isTrue);
      expect(service.error, isNotNull);
    });

    test('counts are applied even when the lessons fail', () async {
      await service.load();
      backend
        ..lessonsFail = true
        ..missingBody = {
          'success': true,
          'lessonObj': {
            tarihId: {'1': 1},
          },
        };

      await service.refresh();

      expect(service.entryOf(tarihId)!.missing, const LessonMissing(tyt: 1));
      expect(service.entryOf(turkceId)!.missing, isNull);
    });
  });

  group('students', () {
    test('a coach passes the student id and gets that student', () async {
      await service.load(studentId: 'stu-1');

      expect(backend.missingStudents, ['stu-1']);
      expect(service.state.studentId, 'stu-1');
    });

    test('the cache does not cross students', () async {
      await service.load(studentId: 'stu-1');
      await service.load(studentId: 'stu-1');
      expect(backend.lessonCalls, 1);

      await service.load(studentId: 'stu-2');
      expect(backend.lessonCalls, 2);
      expect(backend.missingStudents, ['stu-1', 'stu-2']);

      await service.load();
      expect(backend.lessonCalls, 3);
      expect(backend.missingStudents.last, isNull);
    });

    test('switching students clears the previous data first', () async {
      await service.load(studentId: 'stu-1');
      backend.gate = Completer<void>();

      final done = service.load(studentId: 'stu-2');
      await Future<void>.delayed(Duration.zero);

      expect(service.entries, isEmpty, reason: 'never stu-1 under stu-2');
      expect(service.isLoading, isTrue);

      backend.gate!.complete();
      await done;
      expect(service.entries, hasLength(3));
    });

    test('a slow answer for the old student is ignored', () async {
      backend.gate = Completer<void>();
      final stale = service.refresh(studentId: 'old');
      await Future<void>.delayed(Duration.zero);
      final fresh = service.refresh(studentId: 'new');

      backend.gate!.complete();
      await Future.wait([stale, fresh]);

      expect(service.state.studentId, 'new');
      expect(service.entries, hasLength(3));
    });
  });

  group('markLearnedLocally', () {
    test('lowers the count of one track', () async {
      await service.load();

      service.markLearnedLocally(tarihId, LessonTrack.tyt);

      expect(service.entryOf(tarihId)!.missingOf(LessonTrack.tyt), 2);
      expect(service.entryOf(tarihId)!.missingOf(LessonTrack.ayt), 5);
    });

    test('leaves unknown lessons, unknown counts and zero alone', () async {
      await service.load();
      final before = service.state;

      service.markLearnedLocally('nope', LessonTrack.tyt);
      service.markLearnedLocally(matematikId, LessonTrack.tyt);
      service.markLearnedLocally(tarihId, LessonTrack.sos2);

      expect(service.state, before);
    });
  });

  test('a fetch that ends after dispose changes nothing', () async {
    backend.gate = Completer<void>();
    final done = service.refresh();
    await Future<void>.delayed(Duration.zero);
    service.dispose();
    final seen = notifications;

    backend.gate!.complete();
    await done;

    expect(notifications, seen);
    expect(service.entries, isEmpty);
  });
}
