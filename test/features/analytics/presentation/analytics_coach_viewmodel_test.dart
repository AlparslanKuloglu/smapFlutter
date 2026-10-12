import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/analytics/application/analytics_filter.dart';
import 'package:smap/features/analytics/application/analytics_general.dart';
import 'package:smap/features/analytics/application/exam_favorites.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/analytics/data/analytics_repository.dart';
import 'package:smap/features/analytics/presentation/analytics/analytics_viewmodel.dart';
import 'package:smap/features/auth/domain/session_state.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../core/network/fake_adapter.dart';
import '../../../core/services/fake_connectivity.dart';
import '../../exams/data/data_harness.dart';
import '../../exams/data/exam_fixtures.dart';

/// Analiz and Denemeler in a coach's view (pano 10.4 kare 1 and 2): the
/// numbers of pano 6.1 / Ek C (6 TYT exams, 67,79 average net, +3,25), read
/// for Alparslan with his id and his field (Eşit Ağırlık, `aimType` 2).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const alparslan = StudentRef(
    id: 'stu-alparslan',
    name: 'Alparslan Kuloğlu',
    detail: '12. Sınıf · EA',
    aimType: 2,
  );

  late ConnectivityService connectivity;
  late DevicePreferences preferences;
  late AppRouter router;
  late FakeAdapter adapter;
  late AnalyticsViewModel viewModel;
  late Map<String, Object? Function(RequestOptions)> routes;

  Map<String, Object?> chart() => {
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

  Future<void> build({
    StudentRef? student = alparslan,
    String? studentId,
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
      userField: AytField.fromWire(student?.aimType),
      student: student,
      studentId: studentId,
      clock: () => DateTime(2026, 10, 11, 12),
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
    connectivity = ConnectivityService(connectivity: FakeConnectivity());
    await connectivity.initialize();
    addTearDown(connectivity.dispose);
    routes = {
      '/student/getTotal': (o) => {
        'success': true,
        'total': {
          'count': o.queryParameters['type'] == '1' ? 6 : 4,
          'ortNet': 67.79,
        },
      },
      '/student/getLineChartData': (_) => chart(),
      '/student/getMyMockExams': (_) => examsAnswer([
        for (var i = 1; i <= 3; i++) tytResultJson(id: 'res-$i'),
      ]),
    };
  });

  /// The `studentId` each request carried.
  List<Object?> studentIds() => [
    for (final request in adapter.requests)
      request.queryParameters['studentId'],
  ];

  test('every request of Analiz carries the student\'s id', () async {
    await build();

    viewModel.init();
    await settle();

    final content = viewModel.general.data!;
    expect(viewModel.general.state, SectionState.ready);
    expect(content.chartKind, GeneralChartKind.line);
    expect(content.points, hasLength(6));
    expect(content.averageNet, 67.79);
    expect(content.netDelta, 3.25);
    expect(viewModel.isCoachView, isTrue);
    expect(viewModel.studentId, 'stu-alparslan');
    expect(viewModel.student, alparslan);
    expect(studentIds(), isNotEmpty);
    expect(studentIds().toSet(), {'stu-alparslan'});
  });

  test(
    'an AYT overview asks with the student\'s field, not a constant',
    () async {
      await build();
      viewModel.init();
      await settle();
      adapter.requests.clear();

      viewModel.applyFilter(const AnalyticsFilter(exam: NetExamType.ayt));
      await settle();

      final ayt = adapter.requests.where(
        (r) =>
            r.path == '/student/getTotal' && r.queryParameters['type'] == '2',
      );
      expect(ayt, isNotEmpty);
      for (final request in ayt) {
        expect(request.queryParameters['aimType'], 2);
        expect(request.queryParameters['studentId'], 'stu-alparslan');
      }
    },
  );

  test('Denemeler reads the student\'s exams when asked, once', () async {
    await build();
    viewModel.init();
    await settle();
    expect(
      adapter.requests.any((r) => r.path == '/student/getMyMockExams'),
      isFalse,
    );

    await viewModel.loadExams();
    await viewModel.loadExams();

    final lists = adapter.requests.where(
      (r) => r.path == '/student/getMyMockExams',
    );
    expect(lists, hasLength(1));
    expect(lists.single.queryParameters['studentId'], 'stu-alparslan');
    expect(viewModel.examList.state, SectionState.ready);
    expect(viewModel.examSummaries, hasLength(3));
    // A row opens the detail with the student (the list hands over the exam).
    expect(viewModel.detailOf('res-1'), isNotNull);
    expect(viewModel.student!.id, 'stu-alparslan');
  });

  test('a backend that refuses the student ends in the error state', () async {
    routes['/student/getLineChartData'] = (_) => {'success': false};
    await build();

    viewModel.init();
    await settle();

    expect(viewModel.general.state, SectionState.error);
    expect(viewModel.general.data, isNull);
  });

  test('the student id alone is a coach view without a reference', () async {
    await build(student: null, studentId: 'stu-1');

    viewModel.init();
    await settle();

    expect(viewModel.isCoachView, isTrue);
    expect(viewModel.student, isNull);
    expect(studentIds().toSet(), {'stu-1'});
  });

  test(
    'the student\'s own screen sends no id and is not a coach view',
    () async {
      await build(student: null);

      viewModel.init();
      await settle();

      expect(viewModel.isCoachView, isFalse);
      expect(studentIds().toSet(), {null});
    },
  );
}
