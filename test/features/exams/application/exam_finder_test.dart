import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/exams/application/exam_finder.dart';
import 'package:smap/features/exams/data/exam_repository.dart';

import '../../../core/network/fake_adapter.dart';
import '../data/data_harness.dart';
import '../data/exam_fixtures.dart';
import 'exam_detail_fixtures.dart';

Map<String, Object?> _other(int n) => {...tytDetailJson(), '_id': 'other-$n'};

void main() {
  late FakeAdapter adapter;

  ExamFinder finder(
    Map<int, List<Object?>> pages, {
    int maxPages = ExamFinder.defaultMaxPages,
  }) {
    adapter = routedAdapter({
      '/student/getMyMockExams': (RequestOptions options) {
        final page = options.queryParameters['page'] as int;
        return examsAnswer(pages[page] ?? const []);
      },
    });
    final network = networkOver(adapter);
    addTearDown(network.dispose);
    return ExamFinder(ExamRepository(network), maxPages: maxPages);
  }

  List<Object?> full(int from) => [
    for (var i = 0; i < 8; i++) _other(from + i),
  ];

  test('found on the first page: one request', () async {
    final result = await finder({
      1: [aytDetailJson()],
    }).find('res-6');
    expect(result.rightOrNull!.id, 'res-6');
    expect(adapter.requests, hasLength(1));
  });

  test('a full page leads to the next one', () async {
    final result = await finder({
      1: full(0),
      2: [aytDetailJson()],
    }).find('res-6');
    expect(result.rightOrNull!.summary.name, 'Türkiye Geneli Deneme 6');
    expect(adapter.requests, hasLength(2));
  });

  test('a short page ends the search: not found', () async {
    final result = await finder({
      1: [_other(1)],
    }).find('res-6');
    expect(result.leftOrNull!.code, AppErrorCode.notFound);
    expect(adapter.requests, hasLength(1));
  });

  test('the search stops after maxPages', () async {
    final result = await finder({
      1: full(0),
      2: full(8),
      3: [aytDetailJson()],
    }, maxPages: 2).find('res-6');
    expect(result.leftOrNull!.code, AppErrorCode.notFound);
    expect(adapter.requests, hasLength(2));
  });

  test('a failed page is the failure; the coach\'s id goes along', () async {
    adapter = FakeAdapter.json({'success': false, 'message': 'x'});
    final network = networkOver(adapter);
    addTearDown(network.dispose);
    final result = await ExamFinder(
      ExamRepository(network),
    ).find('res-6', studentId: 'stu-1');
    expect(result.isLeft(), isTrue);
    expect(adapter.last.queryParameters['studentId'], 'stu-1');
  });
}
