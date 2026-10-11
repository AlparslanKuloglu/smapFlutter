import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/analytics/application/analytics_filter.dart';
import 'package:smap/features/analytics/application/analytics_general.dart';
import 'package:smap/features/analytics/application/exam_favorites.dart';
import 'package:smap/features/analytics/application/exam_list_query.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/analytics/data/analytics_repository.dart';
import 'package:smap/features/analytics/presentation/analytics/analytics_viewmodel.dart';
import 'package:smap/features/auth/domain/session_state.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../core/network/fake_adapter.dart';
import '../../../core/services/fake_connectivity.dart';
import '../../exams/data/data_harness.dart';
import '../../exams/data/exam_fixtures.dart';

/// The TYT exams of pano 6.1 kare 1 as `getLineChartData` sends them.
Map<String, Object?> _tytChart() => {
  'success': true,
  'user': {'aimType': 2},
  'mockexams': [
    for (final (i, net) in [61.5, 64.25, 68, 66.75, 71.5, 74.75].indexed)
      {
        'itemName': 'TYT Genel Deneme ${4 + i}',
        'date': '2026-0${4 + i}-1${i}T10:00:00.000Z',
        'net': net,
        'points': [380 + i * 2.2],
        'ranks': [190000 - i * 4000],
      },
  ],
};

Map<String, Object?> _total(int count, {double? ortNet}) => {
  'success': true,
  'total': {'count': count, 'ortNet': ortNet},
};

Map<String, Object?> _result(int n, {String? date}) =>
    tytResultJson(id: 'res-$n')
      ..['date'] =
          date ??
          '2026-09-${(30 - n).toString().padLeft(2, '0')}T09:00:00.000Z';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeConnectivity plugin;
  late ConnectivityService connectivity;
  late DevicePreferences preferences;
  late AppRouter router;
  late FakeAdapter adapter;
  late AnalyticsViewModel viewModel;

  /// What each endpoint answers; tests replace entries.
  late Map<String, Object? Function(RequestOptions)> routes;

  Future<void> build({
    AytField? userField,
    AnalyticsTab tab = AnalyticsTab.general,
    DateTime? now,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    adapter = routedAdapter(routes);
    final network = networkOver(adapter);
    addTearDown(network.dispose);
    viewModel = AnalyticsViewModel(
      analytics: AnalyticsRepository(network),
      exams: ExamRepository(network),
      connectivity: connectivity,
      favorites: ExamFavorites(preferences),
      router: router,
      userField: userField,
      initialTab: tab,
      clock: () => now ?? DateTime(2026, 10, 11, 12),
      timeout: timeout,
    );
    addTearDown(viewModel.dispose);
  }

  Future<void> settle() async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    preferences = await DevicePreferences.load();
    router = AppRouter(
      session: () => const SessionState.signedOut(),
      preferences: preferences,
    );
    plugin = FakeConnectivity();
    connectivity = ConnectivityService(connectivity: plugin);
    await connectivity.initialize();
    addTearDown(connectivity.dispose);
    routes = {
      '/student/getTotal': (o) =>
          _total(o.queryParameters['type'] == '1' ? 6 : 4, ortNet: 67.79),
      '/student/getLineChartData': (_) => _tytChart(),
      '/student/getMyMockExams': (_) =>
          examsAnswer([for (var i = 1; i <= 3; i++) _result(i)]),
    };
  });

  group('Genel', () {
    test('loads the TYT overview and the type counters', () async {
      await build();
      expect(viewModel.general.isLoading, isTrue);
      expect(viewModel.generalSettled, isFalse);

      viewModel.init();
      await settle();

      final content = viewModel.general.data!;
      expect(viewModel.general.state, SectionState.ready);
      expect(content.chartKind, GeneralChartKind.line);
      expect(content.points, hasLength(6));
      expect(content.netDelta, 3.25);
      expect(content.averageNet, 67.79);
      expect(content.examCount, 6);
      expect(viewModel.generalSettled, isTrue);
      expect(viewModel.counts, (all: 10, tyt: 6, ayt: 4));
      expect(viewModel.noExamsAtAll, isFalse);
    });

    test('an AYT filter sends the user field as aimType, never 2', () async {
      await build(userField: AytField.numeric);
      viewModel.init();
      await settle();

      viewModel.applyFilter(
        AnalyticsFilter.tyt.switchTo(NetExamType.ayt, field: AytField.verbal),
      );
      await settle();
      var chart = adapter.requests.lastWhere(
        (r) => r.path == '/student/getLineChartData',
      );
      expect(chart.queryParameters, {'type': '2', 'aimType': 4});

      // No field in the filter: the user's own.
      viewModel.applyFilter(const AnalyticsFilter(exam: NetExamType.ayt));
      await settle();
      chart = adapter.requests.lastWhere(
        (r) => r.path == '/student/getLineChartData',
      );
      expect(chart.queryParameters, {'type': '2', 'aimType': 3});
      expect(viewModel.filter.exam, NetExamType.ayt);
    });

    test('a lesson filter asks for that lesson', () async {
      await build();
      viewModel.init();
      await settle();
      final lesson = ExamLessonCatalog.of(NetExamType.tyt).first;

      viewModel.applyFilter(AnalyticsFilter.tyt.withLesson(lesson));
      await settle();

      final total = adapter.requests.lastWhere(
        (r) => r.path == '/student/getTotal',
      );
      expect(total.queryParameters['lesson'], lesson.id);
      expect(viewModel.general.data!.filter.lesson, lesson);
    });

    test('a filter seen before shows at once and refreshes', () async {
      await build();
      viewModel.init();
      await settle();
      final tyt = viewModel.general.data!;

      viewModel.applyFilter(const AnalyticsFilter(exam: NetExamType.ayt));
      expect(viewModel.general.isLoading, isTrue);
      await settle();
      viewModel.applyFilter(AnalyticsFilter.tyt);

      expect(viewModel.general.data, tyt);
      await settle();
      expect(viewModel.general.isReady, isTrue);
    });

    test('no exam at all is empty, and both counters say so', () async {
      routes['/student/getTotal'] = (_) => _total(0);
      routes['/student/getLineChartData'] = (_) => {'success': true};
      await build();
      viewModel.init();
      await settle();

      expect(viewModel.general.isEmpty, isTrue);
      expect(viewModel.counts, (all: 0, tyt: 0, ayt: 0));
      expect(viewModel.noExamsAtAll, isTrue);
    });

    test('a failed answer is the error state, then retry recovers', () async {
      var fail = true;
      routes['/student/getLineChartData'] = (_) =>
          fail ? {'success': false} : _tytChart();
      await build();
      viewModel.init();
      await settle();
      expect(viewModel.general.isError, isTrue);
      expect(viewModel.generalSettled, isTrue);

      fail = false;
      viewModel.retryGeneral();
      expect(viewModel.general.isLoading, isTrue);
      await settle();
      expect(viewModel.general.isReady, isTrue);
    });

    test('no link and nothing saved is the offline state', () async {
      final offline = offlineAdapter();
      adapter = offline;
      final network = networkOver(offline);
      addTearDown(network.dispose);
      viewModel = AnalyticsViewModel(
        analytics: AnalyticsRepository(network),
        exams: ExamRepository(network),
        connectivity: connectivity,
        favorites: ExamFavorites(preferences),
        router: router,
      );
      addTearDown(viewModel.dispose);

      viewModel.init();
      await settle();

      expect(viewModel.general.isOffline, isTrue);
      expect(viewModel.counts, (all: null, tyt: null, ayt: null));
    });

    test('a failed refresh keeps what the filter showed', () async {
      await build();
      viewModel.init();
      await settle();
      final tyt = viewModel.general.data!;

      routes['/student/getLineChartData'] = (_) => {'success': false};
      viewModel.applyFilter(const AnalyticsFilter(exam: NetExamType.ayt));
      await settle();
      expect(viewModel.general.isError, isTrue);

      viewModel.applyFilter(AnalyticsFilter.tyt);
      await settle();
      expect(viewModel.general.data, tyt);
      expect(viewModel.general.isReady, isTrue);
    });

    test('a first load that never answers ends in the error state', () async {
      adapter = FakeAdapter((options) async {
        if (options.path == '/student/getLineChartData') {
          await Future<void>.delayed(const Duration(milliseconds: 200));
        }
        return jsonResponse(_total(1));
      });
      final network = networkOver(adapter);
      addTearDown(network.dispose);
      viewModel = AnalyticsViewModel(
        analytics: AnalyticsRepository(network),
        exams: ExamRepository(network),
        connectivity: connectivity,
        favorites: ExamFavorites(preferences),
        router: router,
        timeout: const Duration(milliseconds: 20),
      );
      addTearDown(viewModel.dispose);

      viewModel.init();
      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(viewModel.general.isError, isTrue);
    });

    test('the offline flag follows the connection', () async {
      await build();
      expect(viewModel.offline, isFalse);
      viewModel.init();
      var notified = 0;
      viewModel.addListener(() => notified++);

      plugin.emit([ConnectivityResult.none]);
      await settle();

      expect(viewModel.offline, isTrue);
      expect(notified, greaterThan(0));
    });
  });

  group('Denemelerim', () {
    test('loads on the first visit only', () async {
      await build();
      viewModel.init();
      await settle();
      expect(
        adapter.requests.where((r) => r.path == '/student/getMyMockExams'),
        isEmpty,
      );
      expect(viewModel.examList.isLoading, isTrue);

      viewModel.selectTab(AnalyticsTab.exams);
      await settle();
      expect(viewModel.tab, AnalyticsTab.exams);
      expect(viewModel.tabChanges.value, AnalyticsTab.exams);
      expect(viewModel.examList.data!.exams, hasLength(3));
      expect(viewModel.examList.data!.hasMore, isFalse);

      viewModel.selectTab(AnalyticsTab.general);
      viewModel.selectTab(AnalyticsTab.exams);
      await settle();
      expect(
        adapter.requests.where((r) => r.path == '/student/getMyMockExams'),
        hasLength(1),
        reason: 'the pages stay when the student comes back',
      );
    });

    test('starts on Denemelerim when asked to', () async {
      await build(tab: AnalyticsTab.exams);
      viewModel.init();
      await settle();
      expect(viewModel.examList.isReady, isTrue);
    });

    test('pages 8 at a time and appends the next page', () async {
      routes['/student/getMyMockExams'] = (o) {
        final page = o.queryParameters['page'] as int;
        return examsAnswer([
          for (var i = 0; i < (page == 1 ? 8 : 3); i++) _result(page * 10 + i),
        ]);
      };
      await build(tab: AnalyticsTab.exams);
      viewModel.init();
      await settle();

      var data = viewModel.examList.data!;
      expect(data.exams, hasLength(8));
      expect(data.hasMore, isTrue);
      final first = adapter.requests.firstWhere(
        (r) => r.path == '/student/getMyMockExams',
      );
      expect(first.queryParameters, {'page': 1, 'perPage': 8});

      final loading = viewModel.loadMore();
      expect(viewModel.examList.data!.loadingMore, isTrue);
      await loading;
      data = viewModel.examList.data!;
      expect(data.exams, hasLength(11));
      expect(data.hasMore, isFalse);
      expect(data.loadingMore, isFalse);
      expect(viewModel.detailOf('res-20')?.id, 'res-20');
      expect(viewModel.detailOf('nope'), isNull);

      await viewModel.loadMore();
      expect(
        adapter.requests.where((r) => r.path == '/student/getMyMockExams'),
        hasLength(2),
        reason: 'no page after the last one',
      );
    });

    test('a failed next page keeps the list and can be retried', () async {
      var fail = false;
      routes['/student/getMyMockExams'] = (o) {
        if (o.queryParameters['page'] == 2 && fail) return {'success': false};
        return examsAnswer([for (var i = 0; i < 8; i++) _result(i)]);
      };
      await build(tab: AnalyticsTab.exams);
      viewModel.init();
      await settle();

      fail = true;
      await viewModel.loadMore();
      var data = viewModel.examList.data!;
      expect(data.exams, hasLength(8));
      expect(data.moreFailed, isTrue);

      fail = false;
      await viewModel.loadMore();
      data = viewModel.examList.data!;
      expect(data.moreFailed, isFalse);
      expect(data.exams, hasLength(16));
    });

    test('the type goes to the server and reloads from page 1', () async {
      await build(tab: AnalyticsTab.exams);
      viewModel.init();
      await settle();

      viewModel.selectType(ExamTypeFilter.ayt);
      expect(viewModel.examList.isLoading, isTrue);
      await settle();

      final request = adapter.requests.lastWhere(
        (r) => r.path == '/student/getMyMockExams',
      );
      expect(request.queryParameters['page'], 1);
      expect(request.data, {
        'filter': {
          'types': ['2'],
          'nets': <String>[],
          'dates': <String>[],
        },
      });
      expect(viewModel.query.type, ExamTypeFilter.ayt);
    });

    test(
      'a date range cuts the list and ends it at the first older exam',
      () async {
        routes['/student/getMyMockExams'] = (o) => examsAnswer([
          _result(1, date: '2026-10-01T09:00:00.000Z'),
          _result(2, date: '2026-09-20T09:00:00.000Z'),
          _result(3, date: '2026-08-15T09:00:00.000Z'),
          for (var i = 4; i < 9; i++) _result(i, date: '2026-07-01'),
        ]);
        await build(tab: AnalyticsTab.exams);
        viewModel.init();
        await settle();
        expect(viewModel.examList.data!.exams, hasLength(8));

        viewModel.applyDate(ExamDatePreset.academicYear);
        await settle();

        final data = viewModel.examList.data!;
        expect(data.exams.map((e) => e.id), ['res-1', 'res-2']);
        expect(data.hasMore, isFalse, reason: 'later pages are older still');
      },
    );

    test(
      'a range that keeps nothing on a page asks for the next one',
      () async {
        routes['/student/getMyMockExams'] = (o) {
          final page = o.queryParameters['page'] as int;
          // Page 1: eight undated results; page 2: one inside the range.
          return examsAnswer(
            page == 1
                ? [for (var i = 0; i < 8; i++) _result(i)..remove('date')]
                : [_result(40, date: '2026-10-05T09:00:00.000Z')],
          );
        };
        await build(tab: AnalyticsTab.exams);
        viewModel.init();
        await settle();

        viewModel.applyDate(ExamDatePreset.last30Days);
        await settle();

        expect(viewModel.examList.data!.exams.map((e) => e.id), ['res-40']);
      },
    );

    test('an empty list is the empty state, a reset returns to all', () async {
      routes['/student/getMyMockExams'] = (_) => examsAnswer(const []);
      await build(tab: AnalyticsTab.exams);
      viewModel.init();
      await settle();
      expect(viewModel.examList.isEmpty, isTrue);

      viewModel.selectType(ExamTypeFilter.tyt);
      await settle();
      expect(viewModel.query.isInitial, isFalse);
      viewModel.resetExamQuery();
      expect(viewModel.query.isInitial, isTrue);
      await settle();
    });

    test('a failure is the error state and retry reloads', () async {
      var fail = true;
      routes['/student/getMyMockExams'] = (_) =>
          fail ? {'success': false} : examsAnswer([_result(1)]);
      await build(tab: AnalyticsTab.exams);
      viewModel.init();
      await settle();
      expect(viewModel.examList.isError, isTrue);

      fail = false;
      viewModel.retryExams();
      await settle();
      expect(viewModel.examList.isReady, isTrue);
    });

    test('Genel and Denemelerim fail on their own', () async {
      routes['/student/getLineChartData'] = (_) => {'success': false};
      await build(tab: AnalyticsTab.exams);
      viewModel.init();
      await settle();

      expect(viewModel.general.isError, isTrue);
      expect(viewModel.examList.isReady, isTrue);
    });

    test(
      'a slow answer for an old filter does not replace a newer one',
      () async {
        final gate = Completer<void>();
        adapter = FakeAdapter((options) async {
          if (options.path == '/student/getMyMockExams') {
            final types = (options.data as Map)['filter']['types'] as List;
            if (types.isEmpty) await gate.future;
            return jsonResponse(examsAnswer([_result(types.isEmpty ? 1 : 2)]));
          }
          return jsonResponse(_total(1));
        });
        final network = networkOver(adapter);
        addTearDown(network.dispose);
        viewModel = AnalyticsViewModel(
          analytics: AnalyticsRepository(network),
          exams: ExamRepository(network),
          connectivity: connectivity,
          favorites: ExamFavorites(preferences),
          router: router,
          initialTab: AnalyticsTab.exams,
        );
        addTearDown(viewModel.dispose);

        viewModel.init();
        await settle();
        viewModel.selectType(ExamTypeFilter.tyt);
        await settle();
        gate.complete();
        await settle();

        expect(viewModel.examList.data!.exams.map((e) => e.id), ['res-2']);
      },
    );
  });

  group('favorites', () {
    test('toggling stars on the device and survives a new ViewModel', () async {
      await build(tab: AnalyticsTab.exams);
      viewModel.init();
      await settle();

      expect(viewModel.favoriteIds, isEmpty);
      await viewModel.toggleFavorite('res-1');
      expect(viewModel.favoriteIds, {'res-1'});

      await build();
      expect(viewModel.favoriteIds, {'res-1'});
      await viewModel.toggleFavorite('res-1');
      expect(viewModel.favoriteIds, isEmpty);
    });
  });
}
