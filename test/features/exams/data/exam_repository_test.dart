import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/exam_page.dart';

import '../../../core/network/fake_adapter.dart';
import 'data_harness.dart';
import 'exam_fixtures.dart';

void main() {
  late NetworkService network;

  ExamRepository repositoryOver(FakeAdapter adapter) {
    network = networkOver(adapter);
    return ExamRepository(network);
  }

  tearDown(() => network.dispose());

  group('getMyExams', () {
    test('posts the page, the size and the empty filter', () async {
      final adapter = FakeAdapter.json(
        examsAnswer([tytResultJson(), aytResultJson()]),
      );
      final repository = repositoryOver(adapter);

      final result = await repository.getMyExams(page: 2);

      final page = result.rightOrNull!;
      expect(page.page, 2);
      expect(page.exams.map((e) => e.id), ['res-1', 'res-2']);
      expect(page.summaries.first.name, 'TYT Genel Deneme 9');
      expect(page.hasMore, isFalse, reason: 'two of eight: the last page');
      final request = adapter.last;
      expect(request.method, 'POST');
      expect(request.path, '/student/getMyMockExams');
      expect(request.queryParameters, {'page': 2, 'perPage': 8});
      expect(request.data, {
        'filter': {
          'types': <String>[],
          'nets': <String>[],
          'dates': <String>[],
        },
      });
    });

    test('a full page says there may be more', () async {
      final repository = repositoryOver(
        FakeAdapter.json(
          examsAnswer([for (var i = 0; i < 8; i++) tytResultJson(id: 'r$i')]),
        ),
      );

      final page = (await repository.getMyExams()).rightOrNull!;

      expect(page.exams, hasLength(8));
      expect(page.hasMore, isTrue);
    });

    test('sends the type filter and the coach studentId', () async {
      final adapter = FakeAdapter.json(examsAnswer(const []));
      final repository = repositoryOver(adapter);

      await repository.getMyExams(
        filter: const ExamListFilter(
          types: {NetExamType.ayt},
          nets: ['50-100'],
          dates: ['2026-09'],
        ),
        studentId: 'student-7',
      );

      expect(adapter.last.queryParameters, {
        'page': 1,
        'perPage': 8,
        'studentId': 'student-7',
      });
      expect(adapter.last.data, {
        'filter': {
          'types': ['2'],
          'nets': ['50-100'],
          'dates': ['2026-09'],
        },
      });
    });

    test('an empty list is a normal answer', () async {
      final repository = repositoryOver(
        FakeAdapter.json(examsAnswer(const [])),
      );

      final page = (await repository.getMyExams()).rightOrNull!;

      expect(page.exams, isEmpty);
      expect(page.hasMore, isFalse);
    });

    test('an answer without the list is an empty page', () async {
      final repository = repositoryOver(FakeAdapter.json({'success': true}));

      final page = (await repository.getMyExams()).rightOrNull!;

      expect(page.exams, isEmpty);
    });

    test(
      'results without an id are left out but still fill the page',
      () async {
        final repository = repositoryOver(
          FakeAdapter.json(
            examsAnswer([
              {'itemName': 'no id'},
              'junk',
              tytResultJson(),
            ]),
          ),
        );

        final page = (await repository.getMyExams(pageSize: 3)).rightOrNull!;

        expect(page.exams.map((e) => e.id), ['res-1']);
        expect(page.hasMore, isFalse, reason: 'two readable objects of three');
      },
    );

    test('an empty body is a server failure', () async {
      final repository = repositoryOver(
        FakeAdapter((_) => textResponse('', contentType: 'text/plain')),
      );

      final failure = (await repository.getMyExams()).leftOrNull!;

      expect(failure.code, AppErrorCode.server);
    });

    test('a foreign body is a server failure', () async {
      final repository = repositoryOver(
        FakeAdapter((_) => textResponse('<html>maintenance</html>')),
      );

      expect(
        (await repository.getMyExams()).leftOrNull?.code,
        AppErrorCode.server,
      );
    });

    test('success: false carries the backend message', () async {
      final repository = repositoryOver(
        FakeAdapter.json({'success': false, 'message': 'Yetkin yok'}),
      );

      final failure = (await repository.getMyExams()).leftOrNull!;

      expect(failure.code, AppErrorCode.validation);
      expect(failure.serverMessage, 'Yetkin yok');
    });

    test('a 500 is a server failure and a 401 an expired session', () async {
      var repository = repositoryOver(
        FakeAdapter.json({'success': false}, status: 500),
      );
      expect(
        (await repository.getMyExams()).leftOrNull?.code,
        AppErrorCode.server,
      );
      network.dispose();

      repository = repositoryOver(
        FakeAdapter.json({'success': false}, status: 401),
      );
      expect(
        (await repository.getMyExams()).leftOrNull?.code,
        AppErrorCode.sessionExpired,
      );
    });

    test('no connection is an offline failure', () async {
      final repository = repositoryOver(offlineAdapter());

      expect(
        (await repository.getMyExams()).leftOrNull?.code,
        AppErrorCode.offline,
      );
    });
  });

  group('getTopicAnalysis', () {
    test('asks with the result id and reads the lessons', () async {
      final adapter = FakeAdapter.json(topicAnalysisAnswer());
      final repository = repositoryOver(adapter);

      final analysis = (await repository.getTopicAnalysis(
        examId: 'res-1',
        studentId: 's-1',
      )).rightOrNull!;

      expect(adapter.last.method, 'GET');
      expect(adapter.last.path, '/student/getMexamSubjectDetail');
      expect(adapter.last.queryParameters, {
        'mexamId': 'res-1',
        'studentId': 's-1',
      });
      expect(analysis.lessons, hasLength(2));
    });

    test('an exam without topics is an empty analysis', () async {
      final repository = repositoryOver(
        FakeAdapter.json({'success': true, 'data': <String, Object>{}}),
      );

      final analysis = (await repository.getTopicAnalysis(
        examId: 'x',
      )).rightOrNull!;

      expect(analysis.isEmpty, isTrue);
    });

    test('failures come back as values', () async {
      var repository = repositoryOver(FakeAdapter.json({'success': false}));
      expect((await repository.getTopicAnalysis(examId: 'x')).isLeft(), isTrue);
      network.dispose();
      repository = repositoryOver(
        FakeAdapter((_) => textResponse('', contentType: 'text/plain')),
      );
      expect(
        (await repository.getTopicAnalysis(examId: 'x')).leftOrNull?.code,
        AppErrorCode.server,
      );
    });
  });

  group('card counts', () {
    test('getCardBreakdown reads the per-lesson tally', () async {
      final adapter = FakeAdapter.json({
        'success': true,
        'data': {
          'l1': {'totalCards': 2, 'totalItems': 1, 'totalMapItems': 0},
        },
      });
      final repository = repositoryOver(adapter);

      final breakdown = (await repository.getCardBreakdown(
        examId: 'res-1',
      )).rightOrNull!;

      expect(adapter.last.path, '/student/getMexamItemDetail');
      expect(adapter.last.queryParameters, {'mexamId': 'res-1'});
      expect(breakdown.total, 3);
    });

    test(
      'getEarnedCardCounts counts cards per lesson on the API host',
      () async {
        final adapter = FakeAdapter.json({
          'success': true,
          'data': [
            {'lesson': 'a'},
            {'lesson': 'a'},
            {'lesson': 'b'},
          ],
        });
        final repository = repositoryOver(adapter);

        final counts = (await repository.getEarnedCardCounts(
          examId: 'res-1',
        )).rightOrNull!;

        expect(adapter.last.path, '/student/getTotalInfoCard');
        expect(adapter.last.baseUrl, 'https://www.smaptr.com');
        expect(adapter.last.queryParameters, {'mexamId': 'res-1'});
        expect(counts.total, 3);
        expect(counts.byLesson, {'a': 2, 'b': 1});
      },
    );

    test('an exam that earned no cards is zero', () async {
      final repository = repositoryOver(
        FakeAdapter.json({'success': true, 'data': <Object>[]}),
      );

      final counts = (await repository.getEarnedCardCounts(
        examId: 'res-1',
      )).rightOrNull!;

      expect(counts.total, 0);
    });
  });

  group('getQuestion', () {
    final exam = repositoryExam();

    test('posts the exam object back as it came', () async {
      final adapter = FakeAdapter.json({
        'success': true,
        'question': {'desc': 'Soru', 'items': <Object>[]},
      });
      final repository = repositoryOver(adapter);

      final detail = (await repository.getQuestion(
        exam: exam,
        questionOrder: 4,
        lessonOrder: 2,
        studentId: 's-1',
      )).rightOrNull!;

      expect(detail.description, 'Soru');
      expect(adapter.last.method, 'POST');
      expect(adapter.last.path, '/student/getQuestion');
      expect(adapter.last.queryParameters, {'studentId': 's-1'});
      expect(adapter.last.data, {
        'mexam': exam.serverObject,
        'questionOrder': 4,
        'lessonOrder': 2,
      });
      expect(
        (adapter.last.data as Map)['mexam'],
        containsPair('questionCount', 120),
      );
    });

    test('without the original object it sends the known fields', () async {
      final adapter = FakeAdapter.json({
        'success': true,
        'question': {'desc': 'Soru'},
      });
      final repository = repositoryOver(adapter);
      final plain = repositoryExam(withObject: false);

      await repository.getQuestion(
        exam: plain,
        questionOrder: 1,
        lessonOrder: 0,
      );

      expect(adapter.last.queryParameters, isEmpty);
      expect((adapter.last.data as Map)['mexam'], {
        '_id': 'exam-9',
        'order': 9,
        'type': 1,
      });
    });

    test('an answer without a question is not found', () async {
      final repository = repositoryOver(FakeAdapter.json({'success': true}));

      final failure = (await repository.getQuestion(
        exam: exam,
        questionOrder: 1,
        lessonOrder: 0,
      )).leftOrNull!;

      expect(failure.code, AppErrorCode.notFound);
    });

    test('a failed answer is a failure', () async {
      final repository = repositoryOver(
        FakeAdapter.failing(
          (options) => DioException(
            requestOptions: options,
            type: DioExceptionType.receiveTimeout,
          ),
        ),
      );

      final failure = (await repository.getQuestion(
        exam: exam,
        questionOrder: 1,
        lessonOrder: 0,
      )).leftOrNull!;

      expect(failure.code, AppErrorCode.timeout);
    });
  });
}
