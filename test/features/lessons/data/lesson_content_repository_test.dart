import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';

import '../../../core/network/fake_adapter.dart';
import '../../exams/data/data_harness.dart';
import 'lesson_fixtures.dart';

void main() {
  late NetworkService network;

  LessonContentRepository repositoryOver(FakeAdapter adapter) {
    network = networkOver(adapter);
    return LessonContentRepository(network);
  }

  tearDown(() => network.dispose());

  group('getGeneralLessons', () {
    test('reads the lessons without needing a success flag', () async {
      final adapter = FakeAdapter.json(generalLessonsAnswer());
      final repository = repositoryOver(adapter);

      final lessons = (await repository.getGeneralLessons()).rightOrNull!;

      expect(lessons.map((l) => l.name), ['Tarih', 'Türkçe', 'Matematik']);
      expect(adapter.last.method, 'GET');
      expect(adapter.last.path, '/ajax/getGeneralLessons');
    });

    test('an empty list is a normal answer', () async {
      final repository = repositoryOver(
        FakeAdapter.json({'generalLessons': <Object>[]}),
      );

      expect((await repository.getGeneralLessons()).rightOrNull, isEmpty);
    });

    test('an answer without the list is a server failure', () async {
      for (final body in [
        <String, Object?>{},
        {'success': true},
      ]) {
        final repository = repositoryOver(FakeAdapter.json(body));
        expect(
          (await repository.getGeneralLessons()).leftOrNull?.code,
          AppErrorCode.server,
        );
        network.dispose();
      }
    });

    test('success: false and a foreign body are failures', () async {
      var repository = repositoryOver(
        FakeAdapter.json({'success': false, 'message': 'Oturum yok'}),
      );
      var failure = (await repository.getGeneralLessons()).leftOrNull!;
      expect(failure.code, AppErrorCode.validation);
      expect(failure.serverMessage, 'Oturum yok');
      network.dispose();

      repository = repositoryOver(
        FakeAdapter((_) => textResponse('<html>x</html>')),
      );
      failure = (await repository.getGeneralLessons()).leftOrNull!;
      expect(failure.code, AppErrorCode.server);
    });

    test('network failures are values', () async {
      var repository = repositoryOver(offlineAdapter());
      expect(
        (await repository.getGeneralLessons()).leftOrNull?.code,
        AppErrorCode.offline,
      );
      network.dispose();
      repository = repositoryOver(FakeAdapter.json({'x': 1}, status: 401));
      expect(
        (await repository.getGeneralLessons()).leftOrNull?.code,
        AppErrorCode.sessionExpired,
      );
    });
  });

  group('getLessonsMissing', () {
    test('reads the counts and sends the student id', () async {
      final adapter = FakeAdapter.json(lessonsMissingAnswer());
      final repository = repositoryOver(adapter);

      final missing = (await repository.getLessonsMissing(
        studentId: 'stu-1',
      )).rightOrNull!;

      expect(missing.of(tarihId)!.total, 8);
      expect(adapter.last.path, '/student/getLessonsTotalMissing');
      expect(adapter.last.queryParameters, {'studentId': 'stu-1'});
    });

    test('no student id means no query', () async {
      final adapter = FakeAdapter.json(lessonsMissingAnswer());
      final repository = repositoryOver(adapter);

      await repository.getLessonsMissing();

      expect(adapter.last.queryParameters, isEmpty);
    });

    test('a student with nothing missing is an empty map', () async {
      final repository = repositoryOver(
        FakeAdapter.json({'success': true, 'lessonObj': <String, Object?>{}}),
      );

      final missing = (await repository.getLessonsMissing()).rightOrNull!;

      expect(missing.byLesson, isEmpty);
    });

    test('failures come back as values', () async {
      var repository = repositoryOver(FakeAdapter.json({'success': false}));
      expect((await repository.getLessonsMissing()).isLeft(), isTrue);
      network.dispose();
      repository = repositoryOver(
        FakeAdapter((_) => textResponse('', contentType: 'text/plain')),
      );
      expect(
        (await repository.getLessonsMissing()).leftOrNull?.code,
        AppErrorCode.server,
      );
    });
  });

  group('getMainSubjects', () {
    test('asks with the lesson id and reads the answer', () async {
      final adapter = FakeAdapter.json(mainSubjectsAnswer());
      final repository = repositoryOver(adapter);

      final subjects = (await repository.getMainSubjects(
        lessonId: '66214a6982ff212039ea3294',
        studentId: 's',
      )).rightOrNull!;

      expect(subjects.subjects, hasLength(2));
      expect(adapter.last.path, '/student/mainSubjects');
      expect(adapter.last.queryParameters, {
        'lessonId': '66214a6982ff212039ea3294',
        'studentId': 's',
      });
    });

    test(
      'a lesson without subjects is empty, a refusal is a failure',
      () async {
        var repository = repositoryOver(
          FakeAdapter.json({'success': true, 'subjects': <Object>[]}),
        );
        expect(
          (await repository.getMainSubjects(
            lessonId: 'x',
          )).rightOrNull!.subjects,
          isEmpty,
        );
        network.dispose();
        repository = repositoryOver(
          FakeAdapter.json({'success': false, 'message': 'yok'}),
        );
        expect(
          (await repository.getMainSubjects(lessonId: 'x')).leftOrNull?.code,
          AppErrorCode.validation,
        );
      },
    );
  });

  group('getAuthorMainSubjects', () {
    test('reads the eras', () async {
      final adapter = FakeAdapter.json({
        'success': true,
        'mainSubjects': [
          {'_id': 'm', 'name': 'Divan', 'itemDataCount': 3},
        ],
      });
      final repository = repositoryOver(adapter);

      final subjects = (await repository.getAuthorMainSubjects()).rightOrNull!;

      expect(subjects.single.missingCount, 3);
      expect(adapter.last.path, '/student/yazarEserMainSubjects');
    });
  });

  group('getSubSubjects', () {
    test('lists the sub-subjects without items', () async {
      final adapter = FakeAdapter.json(subSubjectsAnswer());
      final repository = repositoryOver(adapter);

      final subs = (await repository.getSubSubjects(
        mainSubjectId: 'main-1',
      )).rightOrNull!;

      expect(subs.map((s) => s.name), ['Türklerin ilk yurdu', 'Kurumlar']);
      expect(subs.first.items, isEmpty);
      expect(adapter.last.path, '/student/getSubSubjects');
      expect(adapter.last.queryParameters, {'mainSubjectId': 'main-1'});
    });
  });

  group('getSubjectContent', () {
    FakeAdapter contentAdapter({
      Object? subs,
      Object? items,
      int itemsStatus = 200,
    }) => FakeAdapter((options) {
      switch (options.path) {
        case '/student/getSubSubjects':
          return jsonResponse(subs ?? subSubjectsAnswer());
        case '/student/getItems':
          return jsonResponse(items ?? itemsAnswer(), status: itemsStatus);
      }
      return jsonResponse({'error': 'no route'}, status: 404);
    });

    test('asks for the sub-subjects, then their items, in order', () async {
      final adapter = contentAdapter();
      final repository = repositoryOver(adapter);

      final subs = (await repository.getSubjectContent(
        mainSubjectId: 'main-1',
        type: 3,
        studentId: 'stu-9',
      )).rightOrNull!;

      expect(adapter.requests.map((r) => r.path), [
        '/student/getSubSubjects',
        '/student/getItems',
      ]);
      final itemsRequest = adapter.last;
      expect(itemsRequest.method, 'POST');
      expect(itemsRequest.queryParameters, {'type': 3, 'studentId': 'stu-9'});
      expect(itemsRequest.data, {
        'subjectIds': ['ss-1', 'ss-2'],
        'type': 3,
      });
      expect(subs.map((s) => s.name), ['Türklerin ilk yurdu', 'Kurumlar']);
      expect(subs.first.items.map((i) => i.name), ['Orta Asya', 'Bağımsız']);
      expect(subs.last.items, isEmpty);
    });

    test('the author tree sends the two flags', () async {
      final adapter = contentAdapter(
        subs: authorSubSubjectsAnswer(),
        items: eraItemsAnswer(),
      );
      final repository = repositoryOver(adapter);

      final subs = (await repository.getSubjectContent(
        mainSubjectId: 'main-era',
        authorMode: true,
      )).rightOrNull!;

      expect(adapter.last.queryParameters, {
        'edebiyat': 'true',
        'yazarEserMode': 'true',
      });
      expect(adapter.last.data, {
        'subjectIds': ['ss-era'],
        'type': null,
      });
      expect(subs.single.items.first.progressRecords, hasLength(2));
      expect(subs.single.missing, 2);
    });

    test('no sub-subjects skips the second call', () async {
      final adapter = contentAdapter(
        subs: {'success': true, 'subSubjects': <Object>[]},
      );
      final repository = repositoryOver(adapter);

      final subs = (await repository.getSubjectContent(
        mainSubjectId: 'main-1',
      )).rightOrNull!;

      expect(subs, isEmpty);
      expect(adapter.requests, hasLength(1));
    });

    test('items that do not come back leave the sub-subjects bare', () async {
      final adapter = contentAdapter(
        items: {'success': true, 'itemsArray': <Object>[]},
      );
      final repository = repositoryOver(adapter);

      final subs = (await repository.getSubjectContent(
        mainSubjectId: 'main-1',
      )).rightOrNull!;

      expect(subs, hasLength(2));
      expect(subs.every((s) => s.items.isEmpty), isTrue);
    });

    test('a failing second call fails the whole read', () async {
      final repository = repositoryOver(contentAdapter(itemsStatus: 500));

      final failure = (await repository.getSubjectContent(
        mainSubjectId: 'main-1',
      )).leftOrNull!;

      expect(failure.code, AppErrorCode.server);
    });

    test('a failing first call never reaches the second', () async {
      final adapter = FakeAdapter.json({'success': false, 'message': 'yok'});
      final repository = repositoryOver(adapter);

      final failure = (await repository.getSubjectContent(
        mainSubjectId: 'main-1',
      )).leftOrNull!;

      expect(failure.code, AppErrorCode.validation);
      expect(adapter.requests, hasLength(1));
    });
  });

  group('getSubjectAuthors', () {
    test('reads the authors of an era', () async {
      final adapter = FakeAdapter.json(authorsAnswer());
      final repository = repositoryOver(adapter);

      final authors = (await repository.getSubjectAuthors(
        itemId: 'era-1',
      )).rightOrNull!;

      expect(authors.map((a) => a.name), ['Fuzuli', 'Baki']);
      expect(adapter.last.path, '/student/getSubjectAuthors');
      expect(adapter.last.queryParameters, {'itemId': 'era-1'});
    });

    test('an era without authors is empty', () async {
      final repository = repositoryOver(
        FakeAdapter.json({'success': true, 'authors': <Object>[]}),
      );

      expect(
        (await repository.getSubjectAuthors(itemId: 'e')).rightOrNull,
        isEmpty,
      );
    });
  });

  group('markItemLearned', () {
    test('sends the item id and no student id', () async {
      final adapter = FakeAdapter.json({'success': true});
      final repository = repositoryOver(adapter);

      final result = await repository.markItemLearned(itemId: 'w-1');

      expect(result.isRight(), isTrue);
      expect(adapter.last.method, 'GET');
      expect(adapter.last.path, '/student/learnedItem');
      expect(adapter.last.queryParameters, {'itemId': 'w-1'});
    });

    test('a refusal or a broken connection is a failure', () async {
      var repository = repositoryOver(
        FakeAdapter.json({'success': false, 'message': 'Zaten öğrenildi'}),
      );
      var failure = (await repository.markItemLearned(itemId: 'w')).leftOrNull!;
      expect(failure.code, AppErrorCode.validation);
      expect(failure.serverMessage, 'Zaten öğrenildi');
      network.dispose();

      repository = repositoryOver(
        FakeAdapter.failing(
          (options) => DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
          ),
        ),
      );
      failure = (await repository.markItemLearned(itemId: 'w')).leftOrNull!;
      expect(failure.code, AppErrorCode.timeout);
    });
  });
}
