import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/exam_detail_model.dart';
import 'package:smap/features/exams/application/exam_questions_model.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/presentation/exam_detail/exam_detail_viewmodel.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';

import '../../../core/network/fake_adapter.dart';
import '../application/exam_detail_fixtures.dart';
import '../data/data_harness.dart';
import '../data/exam_fixtures.dart' show examsAnswer;
import 'exam_detail_harness.dart';

/// The Konu Analizi of pano 5.5 (literature topics) as the server sends it.
Map<String, Object?> _topicsAnswer() => {
  'success': true,
  'data': {
    'Türk Dili ve Edebiyatı': {
      'Cumhuriyet Edebiyatı': {'trueValue': 5, 'wrongValue': 7, 'passValue': 0},
      'Nazım Bilgisi': {'trueValue': 0, 'wrongValue': 1, 'passValue': 0},
    },
  },
};

/// `getMexamItemDetail`: two Tarih cards and twenty-one literature ones.
Map<String, Object?> _cardsAnswer() => {
  'success': true,
  'data': {
    '66b0e7e5c99f8fc189ff35ff': {'totalCards': 2},
    '66b0e776c99f8fc189ff35fd': {'totalCards': 21},
  },
};

void main() {
  late FakeAdapter adapter;
  late Map<String, Object? Function(RequestOptions)> routes;
  late RecordingExamNavigator navigator;
  late ExamDetailViewModel viewModel;
  final aytExam = aytDetail();

  Future<void> build({
    ExamDetail? initial,
    ExamDetailTab tab = ExamDetailTab.general,
    StudentRef? student,
    AytField? field = AytField.equalWeight,
    Duration timeout = const Duration(seconds: 15),
    FakeAdapter? customAdapter,
  }) async {
    adapter = customAdapter ?? routedAdapter(routes);
    final network = networkOver(adapter);
    addTearDown(network.dispose);
    navigator = RecordingExamNavigator();
    viewModel = ExamDetailViewModel(
      examId: 'res-6',
      exams: ExamRepository(network),
      lessons: LessonContentRepository(network),
      navigator: navigator,
      toast: recordingToast(),
      cdnBaseUrl: 'https://cdn.example',
      student: student,
      userField: field,
      initial: initial,
      initialTab: tab,
      timeout: timeout,
    );
    addTearDown(viewModel.dispose);
    viewModel.init();
    await pumpEventQueue();
  }

  int callsTo(String path) =>
      adapter.requests.where((r) => r.path == path).length;

  setUp(() {
    routes = {
      '/student/getMyMockExams': (_) => examsAnswer([aytDetailJson()]),
      '/student/getMexamSubjectDetail': (_) => _topicsAnswer(),
      '/student/getMexamItemDetail': (_) => _cardsAnswer(),
      '/student/mainSubjects': (_) => {
        'success': true,
        'subjects': [
          {'_id': 'topic-cumhuriyet', 'name': 'Cumhuriyet Edebiyatı'},
        ],
      },
    };
  });

  group('the result', () {
    test('handed over: no request, everything is derived', () async {
      await build(initial: aytExam);
      expect(viewModel.screenState, SectionState.ready);
      expect(adapter.requests, isEmpty);
      expect(viewModel.header!.name, 'Türkiye Geneli Deneme 6');
      expect(viewModel.header!.score!.field, AytField.equalWeight);
      expect(viewModel.general!.tests, hasLength(4));
      expect(viewModel.questions!.total, 160);
      expect(viewModel.coverUrl, 'https://cdn.example/uploads/c6.png');
    });

    test('from a link: the list is read until the id turns up', () async {
      await build();
      expect(viewModel.screenState, SectionState.ready);
      expect(callsTo('/student/getMyMockExams'), 1);
      expect(viewModel.exam!.id, 'res-6');
    });

    test('an id that is not listed fails the screen; retry reloads', () async {
      routes['/student/getMyMockExams'] = (_) => examsAnswer([tytDetailJson()]);
      await build();
      expect(viewModel.screenState, SectionState.error);
      expect(viewModel.header, isNull);
      routes['/student/getMyMockExams'] = (_) => examsAnswer([aytDetailJson()]);
      await viewModel.retry();
      expect(viewModel.screenState, SectionState.ready);
    });

    test('no connection is the offline state, not a skeleton', () async {
      await build(customAdapter: offlineAdapter());
      expect(viewModel.screenState, SectionState.offline);
    });

    test('a request that never answers ends in the error state', () async {
      await build(
        customAdapter: hangingAdapter(),
        timeout: const Duration(milliseconds: 20),
      );
      expect(viewModel.screenState, SectionState.loading);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(viewModel.screenState, SectionState.error);
    });

    test('a coach\'s student id goes with the request', () async {
      await build(
        student: const StudentRef(id: 'stu-1', name: 'Alparslan Kuloğlu'),
        field: null,
      );
      expect(adapter.requests.first.queryParameters['studentId'], 'stu-1');
      expect(viewModel.isCoachView, isTrue);
    });
  });

  group('Sorular', () {
    test('the filter keeps the counters and changes the list', () async {
      await build(initial: aytExam);
      viewModel.selectFilter(QuestionFilter.wrong);
      expect(viewModel.filter, QuestionFilter.wrong);
      expect(
        viewModel.questions!.filtered(viewModel.filter).first.questions,
        hasLength(17),
      );
      expect(viewModel.questions!.total, 160);
    });

    test('a cell opens Soru Detay with the result', () async {
      await build(initial: aytExam);
      await viewModel.openQuestion(testIndex: 0, questionOrder: 31);
      expect(navigator.calls, ['question:res-6:0:31:null']);
      expect(navigator.openedExams.single, aytExam);
    });
  });

  group('Konular', () {
    test('loads only when the tab is first shown', () async {
      await build(initial: aytExam);
      expect(callsTo('/student/getMexamSubjectDetail'), 0);
      expect(viewModel.topics.state, SectionState.loading);
      viewModel.selectTab(ExamDetailTab.topics);
      await pumpEventQueue();
      expect(callsTo('/student/getMexamSubjectDetail'), 1);
      expect(viewModel.topics.state, SectionState.ready);
      final worst = viewModel.topics.data!.mostMissed!;
      expect(worst.topic.name, 'Cumhuriyet Edebiyatı');
      viewModel.selectTab(ExamDetailTab.general);
      viewModel.selectTab(ExamDetailTab.topics);
      await pumpEventQueue();
      expect(callsTo('/student/getMexamSubjectDetail'), 1);
    });

    test('a link to ?tab=konular loads it at once', () async {
      await build(initial: aytExam, tab: ExamDetailTab.topics);
      expect(viewModel.tab, ExamDetailTab.topics);
      expect(viewModel.topics.state, SectionState.ready);
    });

    test(
      'a failure is a section error that does not touch the result',
      () async {
        routes['/student/getMexamSubjectDetail'] = (_) => {'success': false};
        await build(initial: aytExam, tab: ExamDetailTab.topics);
        expect(viewModel.topics.state, SectionState.error);
        expect(viewModel.screenState, SectionState.ready);
        routes['/student/getMexamSubjectDetail'] = (_) => _topicsAnswer();
        await viewModel.retryTopics();
        expect(viewModel.topics.state, SectionState.ready);
      },
    );

    test('an analysis without topics is empty', () async {
      routes['/student/getMexamSubjectDetail'] = (_) => {
        'success': true,
        'data': <String, Object?>{},
      };
      await build(initial: aytExam, tab: ExamDetailTab.topics);
      expect(viewModel.topics.state, SectionState.empty);
    });

    test('"Bu Konuyu Çalış" opens the topic in Derslerim', () async {
      await build(initial: aytExam, tab: ExamDetailTab.topics);
      await viewModel.openTopic(
        lessonName: 'Türk Dili ve Edebiyatı',
        topicName: 'Cumhuriyet Edebiyatı',
      );
      expect(navigator.calls, [
        'topic:${LessonCatalog.generalLessons[3].id}:topic-cumhuriyet:null',
      ]);
      expect(
        adapter.requests.last.queryParameters['lessonId'],
        '66b0e776c99f8fc189ff35fd',
      );
    });

    test('a topic that is not among the lesson\'s opens the lesson', () async {
      await build(initial: aytExam, tab: ExamDetailTab.topics);
      await viewModel.openTopic(
        lessonName: 'Türk Dili ve Edebiyatı',
        topicName: 'Nazım Bilgisi',
      );
      expect(navigator.calls, [
        'lesson:${LessonCatalog.generalLessons[3].id}:null',
      ]);
    });

    test('Matematik has no topic screen; a coach cannot study', () async {
      await build(initial: aytExam, tab: ExamDetailTab.topics);
      expect(viewModel.canStudyLesson('Matematik'), isFalse);
      expect(viewModel.canStudyLesson('Türk Dili ve Edebiyatı'), isTrue);
      await viewModel.openTopic(lessonName: 'Matematik', topicName: 'Türev');
      expect(navigator.calls, isEmpty);

      await build(
        initial: aytExam,
        student: const StudentRef(id: 'stu-1', name: 'Alparslan Kuloğlu'),
        field: null,
      );
      expect(viewModel.canStudyLesson('Türk Dili ve Edebiyatı'), isFalse);
      await viewModel.openTopic(
        lessonName: 'Türk Dili ve Edebiyatı',
        topicName: 'Cumhuriyet Edebiyatı',
      );
      expect(navigator.calls, isEmpty);
    });
  });

  group('Kartlar', () {
    test('counts the cards of the lessons', () async {
      await build(initial: aytExam, tab: ExamDetailTab.cards);
      final cards = viewModel.cards.data!;
      expect(cards.total, 23);
      expect(cards.groups.map((g) => (g.name, g.count)), [
        ('Türk Dili ve Edebiyatı', 21),
        ('Tarih', 2),
      ]);
    });

    test('no card is the empty state', () async {
      routes['/student/getMexamItemDetail'] = (_) => {
        'success': true,
        'data': <String, Object?>{},
      };
      await build(initial: aytExam, tab: ExamDetailTab.cards);
      expect(viewModel.cards.state, SectionState.empty);
    });

    test('"Kartları Çalış" starts on the first lesson with cards', () async {
      await build(initial: aytExam, tab: ExamDetailTab.cards);
      await viewModel.studyCards();
      expect(navigator.calls, [
        'deck:res-6:66b0e776c99f8fc189ff35fd:Türk Dili ve Edebiyatı',
      ]);
    });

    test('a lesson row opens that lesson\'s deck; a coach has none', () async {
      await build(initial: aytExam, tab: ExamDetailTab.cards);
      await viewModel.studyLessonCards(viewModel.cards.data!.groups.last);
      expect(navigator.calls.single, startsWith('deck:res-6:66b0e7e5'));

      await build(
        initial: aytExam,
        tab: ExamDetailTab.cards,
        student: const StudentRef(id: 'stu-1', name: 'Alparslan Kuloğlu'),
        field: null,
      );
      await viewModel.studyCards();
      await viewModel.studyLessonCards(viewModel.cards.data!.groups.first);
      expect(navigator.calls, isEmpty);
    });
  });

  test('NetExamType of the result reaches the topic resolution', () async {
    await build(initial: aytExam);
    expect(viewModel.exam!.kind, NetExamType.ayt);
  });
}
