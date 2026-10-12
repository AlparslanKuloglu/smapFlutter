import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/presentation/result_moment/result_moment_loader.dart';

import '../../../../core/network/fake_adapter.dart';
import '../../application/exam_detail_fixtures.dart';
import '../../data/data_harness.dart';
import '../../data/exam_fixtures.dart' show examsAnswer;

Map<String, Object?> _tyt(String id, {num net = 70}) => {
  ...tytDetailJson(),
  '_id': id,
  'net': net,
};

Map<String, Object?> _ayt(String id, {num net = 60}) => {
  ...aytDetailJson(),
  '_id': id,
  'net': net,
};

void main() {
  late FakeAdapter adapter;

  ResultMomentLoader loader(
    Map<int, Object?> pages, {
    int maxPages = ResultMomentLoader.defaultMaxPages,
  }) {
    adapter = routedAdapter({
      '/student/getMyMockExams': (RequestOptions options) {
        final page = options.queryParameters['page'] as int;
        final answer = pages[page];
        if (answer is Map<String, Object?> && answer['success'] == false) {
          return answer;
        }
        return examsAnswer((answer as List<Object?>?) ?? const []);
      },
    });
    final network = networkOver(adapter);
    addTearDown(network.dispose);
    return ResultMomentLoader(ExamRepository(network), maxPages: maxPages);
  }

  List<Object?> fullPage(int from) => [
    for (var i = 0; i < 8; i++) _tyt('filler-${from + i}'),
  ];

  test('the new result is first: the next exam of the type is the previous '
      'one (pano 5.1 "59,25 → +8,25")', () async {
    final source = (await loader({
      1: [
        aytDetailJson(),
        _tyt('tyt-old', net: 71),
        _ayt('ayt-old', net: 59.25),
      ],
    }).load('res-6')).rightOrNull!;
    expect(source.exam.id, 'res-6');
    // The TYT in between is not the previous AYT.
    expect(source.previousNet, 59.25);
    expect(adapter.requests, hasLength(1));
  });

  test('no earlier exam of the type: no previous net', () async {
    final source = (await loader({
      1: [aytDetailJson(), _tyt('tyt-old')],
    }).load('res-6')).rightOrNull!;
    expect(source.exam.id, 'res-6');
    expect(source.previousNet, isNull);
  });

  test('the previous exam may be on the next page', () async {
    final first = [aytDetailJson(), ...fullPage(0).skip(1)];
    final source = (await loader({
      1: first,
      2: [_ayt('ayt-old', net: 50.5)],
    }).load('res-6')).rightOrNull!;
    expect(source.previousNet, 50.5);
    expect(adapter.requests, hasLength(2));
  });

  test(
    'the result itself may be on a later page; only exams after it count',
    () async {
      final source = (await loader({
        1: [..._pageOf(_ayt('ayt-newer', net: 99))],
        2: [aytDetailJson(), _ayt('ayt-old', net: 61)],
      }).load('res-6')).rightOrNull!;
      expect(source.exam.id, 'res-6');
      expect(source.previousNet, 61);
    },
  );

  test(
    'a page that fails after the result was found only loses the change',
    () async {
      final source = (await loader({
        1: [aytDetailJson(), ...fullPage(0).skip(1)],
        2: {'success': false},
      }).load('res-6')).rightOrNull!;
      expect(source.exam.id, 'res-6');
      expect(source.previousNet, isNull);
    },
  );

  test('a page that fails before the result is found is the failure', () async {
    final result = await loader({
      1: {'success': false},
    }).load('res-6');
    expect(result.isLeft(), isTrue);
  });

  test('a result that is not listed is not found', () async {
    final result = await loader({
      1: [_tyt('other')],
    }).load('res-6');
    expect(result.leftOrNull!.code, AppErrorCode.notFound);
    expect(adapter.requests, hasLength(1));
  });

  test('the search stops after maxPages', () async {
    final stopped = await loader({
      1: fullPage(0),
      2: fullPage(8),
      3: [aytDetailJson()],
    }, maxPages: 2).load('res-6');
    expect(stopped.leftOrNull!.code, AppErrorCode.notFound);
    expect(adapter.requests, hasLength(2));
  });
}

List<Object?> _pageOf(Map<String, Object?> first) => [
  first,
  for (var i = 0; i < 7; i++) _tyt('filler-$i'),
];
