import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/analytics/data/analytics_repository.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';

import '../../../core/network/fake_adapter.dart';
import '../../exams/data/data_harness.dart';
import 'analytics_fixtures.dart';

const _objectId = '663e37a24fb443839593141b';

void main() {
  late NetworkService network;

  AnalyticsRepository repositoryOver(FakeAdapter adapter) {
    network = networkOver(adapter);
    return AnalyticsRepository(network);
  }

  tearDown(() => network.dispose());

  group('request parameters', () {
    test('TYT sends the type only', () async {
      final adapter = FakeAdapter.json(totalAnswer());
      final repository = repositoryOver(adapter);

      await repository.getTotal(exam: NetExamType.tyt, field: AytField.numeric);

      expect(adapter.last.method, 'GET');
      expect(adapter.last.path, '/student/getTotal');
      expect(adapter.last.queryParameters, {'type': '1'});
    });

    test('AYT sends the field as aimType, not a constant', () async {
      final adapter = FakeAdapter.json(lineChartAnswer());
      final repository = repositoryOver(adapter);

      await repository.getLineChartData(
        exam: NetExamType.ayt,
        field: AytField.verbal,
      );
      expect(adapter.last.path, '/student/getLineChartData');
      expect(adapter.last.queryParameters, {'type': '2', 'aimType': 4});

      await repository.getLineChartData(
        exam: NetExamType.ayt,
        field: AytField.numeric,
      );
      expect(adapter.last.queryParameters['aimType'], 3);

      await repository.getLineChartData(exam: NetExamType.ayt);
      expect(adapter.last.queryParameters, {'type': '2'});
    });

    test('a lesson id goes out only when it is an ObjectId', () async {
      final adapter = FakeAdapter.json(totalAnswer());
      final repository = repositoryOver(adapter);

      await repository.getTotal(exam: NetExamType.tyt, lessonId: _objectId);
      expect(adapter.last.queryParameters, {'type': '1', 'lesson': _objectId});

      for (final sentinel in ['geneltyt', 'genelea', '7', '10', '', '  ']) {
        await repository.getTotal(exam: NetExamType.tyt, lessonId: sentinel);
        expect(adapter.last.queryParameters, {
          'type': '1',
        }, reason: '"$sentinel" is not a lesson id');
      }
    });

    test('a coach adds the student id', () async {
      final adapter = FakeAdapter.json(totalAnswer());
      final repository = repositoryOver(adapter);

      await repository.getTotal(exam: NetExamType.tyt, studentId: 'stu-3');

      expect(adapter.last.queryParameters, {'type': '1', 'studentId': 'stu-3'});
    });
  });

  group('getTotal', () {
    test('reads the headline figures and the distribution', () async {
      final repository = repositoryOver(FakeAdapter.json(totalAnswer()));

      final totals = (await repository.getTotal(
        exam: NetExamType.tyt,
      )).rightOrNull!;

      expect(totals.examCount, 12);
      expect(totals.averageNet, 68.4);
      expect(totals.shares.map((s) => (s.label, s.value)), [
        ('TYT Türkçe', 17.0),
        ('TYT Tarih', 4.0),
        ('TYT Matematik', 18.5),
      ]);
      expect(totals.subjects.map((s) => (s.name, s.missed)), [
        ('Sözcükte Anlam', 3),
        ('Paragraf', 0),
      ]);
    });

    test('misaligned or broken bars are skipped, not shifted', () async {
      final repository = repositoryOver(
        FakeAdapter.json({
          'success': true,
          'total': {
            'count': '5',
            'ortNet': 'x',
            'lessOrSubjects': ['A', null, 'C', 'D'],
            'data': [1, 2, 'no'],
          },
          'items': [
            {'subject': 'id-only', 'count': 4},
            {'count': 3},
            'junk',
          ],
        }),
      );

      final totals = (await repository.getTotal(
        exam: NetExamType.tyt,
      )).rightOrNull!;

      expect(totals.examCount, 5);
      expect(totals.averageNet, isNull);
      expect(totals.shares.map((s) => s.label), ['A']);
      expect(totals.subjects, isEmpty);
    });

    test('a user without exams is empty totals', () async {
      final repository = repositoryOver(FakeAdapter.json({'success': true}));

      final totals = (await repository.getTotal(
        exam: NetExamType.tyt,
      )).rightOrNull!;

      expect(totals.examCount, isNull);
      expect(totals.shares, isEmpty);
    });

    test('failures come back as values', () async {
      expect(
        (await repositoryOver(
          FakeAdapter.json({'success': false, 'message': 'x'}),
        ).getTotal(exam: NetExamType.tyt)).leftOrNull?.code,
        AppErrorCode.validation,
      );
      network.dispose();
      expect(
        (await repositoryOver(
          FakeAdapter((_) => textResponse('', contentType: 'text/plain')),
        ).getTotal(exam: NetExamType.tyt)).leftOrNull?.code,
        AppErrorCode.server,
      );
      network.dispose();
      expect(
        (await repositoryOver(
          offlineAdapter(),
        ).getTotal(exam: NetExamType.tyt)).leftOrNull?.code,
        AppErrorCode.offline,
      );
      network.dispose();
      expect(
        (await repositoryOver(
          FakeAdapter.failing(
            (options) => DioException(
              requestOptions: options,
              type: DioExceptionType.receiveTimeout,
            ),
          ),
        ).getTotal(exam: NetExamType.tyt)).leftOrNull?.code,
        AppErrorCode.timeout,
      );
    });
  });

  group('getLineChartData', () {
    test('reads the exams and drops the ones without a net', () async {
      final repository = repositoryOver(
        FakeAdapter.json(lineChartAnswer(totalQuestion: 40)),
      );

      final series = (await repository.getLineChartData(
        exam: NetExamType.tyt,
      )).rightOrNull!;

      expect(series.points, hasLength(3));
      expect(series.totalQuestion, 40);
      expect(series.userField, AytField.numeric);
      expect(series.points.first.name, 'TYT Genel Deneme 8');
      expect(series.points[2].net, 67.5);
      expect(series.points[2].counts, isNull);
    });

    test('turns the points into chart points, oldest first', () async {
      final repository = repositoryOver(
        FakeAdapter.json({
          'success': true,
          'mockexams': [
            {'date': '2026-10-05', 'net': 10},
            {'date': '2026-09-01', 'net': 20},
            {'net': 30},
          ],
        }),
      );

      final series = (await repository.getLineChartData(
        exam: NetExamType.tyt,
      )).rightOrNull!;
      final chart = series.toChartPoints();

      expect(series.points, hasLength(3));
      expect(chart.map((p) => p.net), [20, 10], reason: 'no date, no point');
      expect(chart.first.date, DateTime(2026, 9, 1));
      expect(chart.first.name, isNull);
    });

    test('an empty list is an empty series', () async {
      final repository = repositoryOver(
        FakeAdapter.json({'success': true, 'mockexams': <Object>[]}),
      );

      final series = (await repository.getLineChartData(
        exam: NetExamType.tyt,
      )).rightOrNull!;

      expect(series.isEmpty, isTrue);
      expect(series.toChartPoints(), isEmpty);
      expect(series.userField, isNull);
    });

    test('a failed answer is a failure', () async {
      final repository = repositoryOver(
        FakeAdapter.json({'success': false}, status: 500),
      );

      expect(
        (await repository.getLineChartData(
          exam: NetExamType.tyt,
        )).leftOrNull?.code,
        AppErrorCode.server,
      );
    });
  });

  group('getOverview and the summary', () {
    FakeAdapter overviewAdapter({int? totalQuestion}) => routedAdapter({
      '/student/getTotal': (_) => totalAnswer(),
      '/student/getLineChartData': (_) =>
          lineChartAnswer(totalQuestion: totalQuestion),
    });

    test('works the four boxes out for TYT', () async {
      final repository = repositoryOver(overviewAdapter());

      final overview = (await repository.getOverview(
        exam: NetExamType.tyt,
      )).rightOrNull!;
      final summary = overview.summary;

      expect(summary.examCount, 12);
      expect(summary.averageNet, 68.4, reason: 'the server average');
      expect(summary.averageRank, 45000, reason: 'mean of 50.000 and 40.000');
      expect(summary.averagePoint, closeTo(390.25, 1e-9));
      expect(summary.counts, isNull, reason: 'general chart');
    });

    test('reads the slot of the AYT field', () async {
      final repository = repositoryOver(overviewAdapter());

      final summary = (await repository.getOverview(
        exam: NetExamType.ayt,
        field: AytField.numeric,
      )).rightOrNull!.summary;

      expect(summary.averageRank, 2000, reason: 'only the 2nd exam has slot 3');
      expect(summary.averagePoint, 420);
    });

    test('an AYT without a field has no rank and no points', () async {
      final repository = repositoryOver(overviewAdapter());

      final summary = (await repository.getOverview(
        exam: NetExamType.ayt,
      )).rightOrNull!.summary;

      expect(summary.averageRank, isNull);
      expect(summary.averagePoint, isNull);
    });

    test('a lesson chart averages the exams and adds the counts', () async {
      final adapter = routedAdapter({
        '/student/getTotal': (_) => totalAnswer(),
        '/student/getLineChartData': (_) => {
          'success': true,
          'totalQuestion': 40,
          'mockexams': [
            {
              'date': '2026-09-14',
              'net': 30,
              'true': 32,
              'wrong': 4,
              'pass': 4,
            },
            {
              'date': '2026-09-28',
              'net': 20,
              'true': 24,
              'wrong': 16,
              'pass': 0,
            },
          ],
        },
      });
      final repository = repositoryOver(adapter);

      final summary = (await repository.getOverview(
        exam: NetExamType.tyt,
        lessonId: _objectId,
      )).rightOrNull!.summary;

      expect(summary.averageNet, 25);
      expect(summary.counts!.correct, 56);
      expect(summary.counts!.wrong, 20);
      expect(summary.counts!.blank, 4);
    });

    test('lesson counts are null when an exam lacks them', () async {
      final adapter = routedAdapter({
        '/student/getTotal': (_) => totalAnswer(),
        '/student/getLineChartData': (_) => {
          'success': true,
          'mockexams': [
            {
              'date': '2026-09-14',
              'net': 30,
              'true': 32,
              'wrong': 4,
              'pass': 4,
            },
            {'date': '2026-09-28', 'net': 20},
          ],
        },
      });
      final repository = repositoryOver(adapter);

      final summary = (await repository.getOverview(
        exam: NetExamType.tyt,
        lessonId: _objectId,
      )).rightOrNull!.summary;

      expect(summary.counts, isNull);
    });

    test('without a server average the mean of the series is used', () async {
      final adapter = routedAdapter({
        '/student/getTotal': (_) => {'success': true},
        '/student/getLineChartData': (_) => {
          'success': true,
          'mockexams': [
            {'date': '2026-09-14', 'net': 30},
            {'date': '2026-09-28', 'net': 20},
          ],
        },
      });
      final repository = repositoryOver(adapter);

      final summary = (await repository.getOverview(
        exam: NetExamType.tyt,
      )).rightOrNull!.summary;

      expect(summary.averageNet, 25);
      expect(summary.examCount, isNull);
    });

    test('a student without exams has no figures at all', () async {
      final adapter = routedAdapter({
        '/student/getTotal': (_) => {'success': true},
        '/student/getLineChartData': (_) => {'success': true},
      });
      final repository = repositoryOver(adapter);

      final summary = (await repository.getOverview(
        exam: NetExamType.tyt,
      )).rightOrNull!.summary;

      expect(summary.examCount, isNull);
      expect(summary.averageNet, isNull);
      expect(summary.averageRank, isNull);
      expect(summary.averagePoint, isNull);
    });

    test('one failing call fails the overview', () async {
      final adapter = routedAdapter({
        '/student/getTotal': (_) => totalAnswer(),
        '/student/getLineChartData': (_) =>
            jsonResponse({'success': false}, status: 500),
      });
      final repository = repositoryOver(adapter);

      final failure = (await repository.getOverview(
        exam: NetExamType.tyt,
      )).leftOrNull!;

      expect(failure.code, AppErrorCode.server);
    });
  });
}
