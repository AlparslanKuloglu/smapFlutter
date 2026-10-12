import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/presentation/notification_primer/notification_primer.dart';
import 'package:smap/features/exams/presentation/result_moment/result_moment_viewmodel.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

import '../../../../core/network/fake_adapter.dart';
import '../../application/exam_detail_fixtures.dart';
import '../../data/data_harness.dart';
import '../../data/exam_fixtures.dart' show examsAnswer;
import 'result_moment_harness.dart';

/// `getTotalInfoCard`: 21 literature cards and 2 Tarih cards (pano 5.1 kare
/// 1: "Bu denemeden 23 bilgi kartı eklendi").
Map<String, Object?> _cardsAnswer() => {
  'success': true,
  'data': [
    for (var i = 0; i < 21; i++) {'lesson': 'edebiyat', 'item': 'e-$i'},
    for (var i = 0; i < 2; i++) {'lesson': 'tarih', 'item': 't-$i'},
  ],
};

Map<String, Object?> _tyt(String id, {num net = 71.5}) => {
  ...tytDetailJson(),
  '_id': id,
  'net': net,
};

void main() {
  late FakeAdapter adapter;
  late Map<String, Object? Function(RequestOptions)> routes;
  late List<String> log;
  late MemoryPrimerFlag flag;
  late RecordingMomentNavigator navigator;
  late ResultMomentViewModel viewModel;
  late int arrivals;
  late int retryFailures;

  /// A ViewModel over [routes]; [primerEnabled] is `FeatureFlags
  /// .notificationsEnabled`.
  Future<void> build({
    String examId = 'res-6',
    AytField? field = AytField.equalWeight,
    bool primerEnabled = false,
    bool primerShown = false,
    FakeAdapter? customAdapter,
    Duration timeout = const Duration(seconds: 15),
    bool init = true,
  }) async {
    adapter = customAdapter ?? routedAdapter(routes);
    final network = networkOver(adapter);
    addTearDown(network.dispose);
    log = [];
    flag = MemoryPrimerFlag(shown: primerShown);
    navigator = RecordingMomentNavigator(log);
    arrivals = 0;
    retryFailures = 0;
    viewModel = ResultMomentViewModel(
      examId: examId,
      exams: ExamRepository(network),
      navigator: navigator,
      primer: NotificationPrimer(
        enabled: primerEnabled,
        flag: flag,
        presenter: RecordingPrimerPresenter(log, flag: flag),
      ),
      cdnBaseUrl: 'https://cdn.example',
      userField: field,
      onArrive: () => arrivals++,
      onRetryFailed: () => retryFailures++,
      timeout: timeout,
    );
    addTearDown(viewModel.dispose);
    if (init) {
      viewModel.init();
      await pumpEventQueue();
    }
  }

  setUp(() {
    routes = {
      '/student/getMyMockExams': (_) => examsAnswer([
        aytDetailJson(),
        _tyt('tyt-old'),
        {...aytDetailJson(), '_id': 'ayt-old', 'net': 59.25},
      ]),
      '/student/getTotalInfoCard': (_) => _cardsAnswer(),
    };
  });

  group('the result (pano 5.1 kare 1)', () {
    test('reads the list and the card count; the screen is ready', () async {
      await build();
      expect(viewModel.screenState, SectionState.ready);
      final model = viewModel.model!;
      expect(model.name, 'Türkiye Geneli Deneme 6');
      expect(model.net, 67.5);
      expect(model.delta, 8.25);
      expect(viewModel.cardTotal, 23);
      expect(viewModel.coverUrl, 'https://cdn.example/uploads/c6.png');
      // One list request (the result is first, the previous AYT is on the
      // same page) and one card request; both are the student's own.
      expect(
        adapter.requests.where((r) => r.path == '/student/getMyMockExams'),
        hasLength(1),
      );
      expect(
        adapter.requests.any((r) => r.queryParameters['studentId'] != null),
        isFalse,
      );
    });

    test(
      'the segment opens on the student\'s field and swaps the figures',
      () async {
        await build(field: AytField.numeric);
        expect(viewModel.selectedField, AytField.numeric);
        expect(viewModel.score.fieldNet, 37.5);
        viewModel.selectField(AytField.verbal);
        expect(viewModel.selectedField, AytField.verbal);
        expect(viewModel.score.fieldNet, 30);
      },
    );

    test('choosing the selected score type again does not notify', () async {
      await build();
      var notified = 0;
      viewModel.addListener(() => notified++);
      viewModel.selectField(AytField.equalWeight);
      expect(notified, 0);
      viewModel.selectField(AytField.numeric);
      expect(notified, 1);
    });

    test('success haptic plays once, when the result first shows', () async {
      await build();
      expect(arrivals, 1);
      viewModel.selectField(AytField.numeric);
      await viewModel.retry();
      await pumpEventQueue();
      // A reload of the same result is not a new arrival.
      expect(arrivals, 1);
      expect(retryFailures, 0);
    });
  });

  group('a TYT result with missing data (pano 5.1 kare 2)', () {
    setUp(() {
      routes['/student/getMyMockExams'] = (_) =>
          examsAnswer([tytDetailJson(), _tyt('tyt-old')]);
      // No card count in the answer.
      routes['/student/getTotalInfoCard'] = (_) => {
        'success': true,
        'data': <Object?>[],
      };
    });

    test('net, counts and the change; no segment and no card row', () async {
      await build(examId: 'res-9', field: null);
      expect(viewModel.screenState, SectionState.ready);
      final model = viewModel.model!;
      expect(model.kind, NetExamType.tyt);
      expect(model.delta, 3.25);
      expect(model.hasFieldSegment, isFalse);
      expect(viewModel.selectedField, isNull);
      expect(viewModel.score.isEmpty, isTrue);
      expect(viewModel.cardTotal, isNull);
    });
  });

  group('the card count', () {
    test('a failing request only leaves the row out', () async {
      routes['/student/getTotalInfoCard'] = (_) => {'success': false};
      await build();
      expect(viewModel.screenState, SectionState.ready);
      expect(viewModel.cardTotal, isNull);
    });

    test('a request that breaks leaves the row out too', () async {
      adapter = routedAdapter({
        '/student/getMyMockExams': routes['/student/getMyMockExams']!,
        '/student/getTotalInfoCard': (_) => throw StateError('unreachable'),
      });
      await build(customAdapter: adapter);
      expect(viewModel.cardTotal, isNull);
      expect(viewModel.screenState, SectionState.ready);
    });
  });

  group('the screen states', () {
    test('a failing list is the error state; no success haptic', () async {
      routes['/student/getMyMockExams'] = (_) => {'success': false};
      await build();
      expect(viewModel.screenState, SectionState.error);
      expect(viewModel.model, isNull);
      expect(arrivals, 0);
      expect(retryFailures, 0);
    });

    test('no connection is the offline state', () async {
      await build(customAdapter: offlineAdapter());
      expect(viewModel.screenState, SectionState.offline);
    });

    test('a result that is not listed is an error', () async {
      await build(examId: 'unknown');
      expect(viewModel.screenState, SectionState.error);
    });

    test(
      'a result with no D/Y/B is an error, not a half-empty moment',
      () async {
        routes['/student/getMyMockExams'] = (_) => examsAnswer([
          {...aytDetailJson()}
            ..remove('true')
            ..remove('wrong')
            ..remove('pass'),
        ]);
        await build();
        expect(viewModel.screenState, SectionState.error);
      },
    );

    test('a list that never answers ends in the error state', () async {
      await build(
        customAdapter: FakeAdapter((_) => Completer<ResponseBody>().future),
        timeout: const Duration(milliseconds: 30),
      );
      expect(viewModel.screenState, SectionState.loading);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(viewModel.screenState, SectionState.error);
    });

    test('Tekrar Dene goes back to loading, then to the content; a repeated '
        'failure plays the error haptic', () async {
      var failing = true;
      routes['/student/getMyMockExams'] = (_) =>
          failing ? {'success': false} : examsAnswer([aytDetailJson()]);
      await build();
      expect(viewModel.screenState, SectionState.error);

      // Fails again: the haptic.
      final again = viewModel.retry();
      expect(viewModel.screenState, SectionState.loading);
      await again;
      expect(viewModel.screenState, SectionState.error);
      expect(retryFailures, 1);

      failing = false;
      await viewModel.retry();
      await pumpEventQueue();
      expect(viewModel.screenState, SectionState.ready);
      expect(arrivals, 1);
      expect(retryFailures, 1);
    });
  });

  group('leaving (flow 13.4 step 15)', () {
    test(
      '"Detaylı Analiz" opens Genel with the result, no second request',
      () async {
        await build();
        await viewModel.openDetail();
        expect(log, ['detail:res-6:genel']);
        expect(navigator.openedExams.single!.id, 'res-6');
      },
    );

    test('the cards row opens Kartlar', () async {
      await build();
      await viewModel.openCards();
      expect(log, ['detail:res-6:kartlar']);
    });

    test('"Anasayfa" (and the close button) open Anasayfa', () async {
      await build();
      await viewModel.openHome();
      expect(log, ['home']);
    });

    test('the destinations work while the result could not be read', () async {
      routes['/student/getMyMockExams'] = (_) => {'success': false};
      await build();
      await viewModel.openDetail();
      // The detail reads the result itself: nothing is handed over.
      expect(log, ['detail:res-6:genel']);
      expect(navigator.openedExams.single, isNull);
    });

    test('a second tap while leaving is ignored', () async {
      await build();
      final first = viewModel.openDetail();
      final second = viewModel.openHome();
      await Future.wait([first, second]);
      expect(log, ['detail:res-6:genel']);
    });
  });

  group('the notification permission sheet (pano 5.2)', () {
    test(
      'closed while notifications are off: leaving goes straight on',
      () async {
        await build();
        await viewModel.openDetail();
        expect(log, ['detail:res-6:genel']);
        expect(flag.writes, 0);
      },
    );

    test(
      'open and never asked: the sheet comes first, then the destination',
      () async {
        await build(primerEnabled: true);
        await viewModel.openDetail();
        expect(log, ['sheet', 'detail:res-6:genel']);
        expect(flag.shown, isTrue);
      },
    );

    test('it comes before every way out', () async {
      await build(primerEnabled: true);
      await viewModel.openHome();
      expect(log, ['sheet', 'home']);
    });

    test('once answered it never comes back', () async {
      await build(primerEnabled: true, primerShown: true);
      await viewModel.openHome();
      expect(log, ['home']);
    });

    test(
      'the sheet is asked once even when the first way out is repeated',
      () async {
        await build(primerEnabled: true);
        await viewModel.openCards();
        await viewModel.openDetail();
        expect(log, ['sheet', 'detail:res-6:kartlar', 'detail:res-6:genel']);
      },
    );
  });
}
