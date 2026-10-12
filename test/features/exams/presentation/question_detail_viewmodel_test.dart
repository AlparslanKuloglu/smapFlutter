import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/exams/application/question_status.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/presentation/question_detail/question_detail_viewmodel.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';

import '../../../core/network/fake_adapter.dart';
import '../application/exam_detail_fixtures.dart';
import '../data/data_harness.dart';
import '../data/exam_fixtures.dart' show examsAnswer;
import 'exam_detail_harness.dart';

/// `getQuestion` of pano 5.7 kare 1: an explanation and two cards.
Map<String, Object?> _questionAnswer() => {
  'success': true,
  'question': {
    'desc':
        'Edirne-Segedin Antlaşması (1444), Haçlılarla Osmanlı Devleti '
        'arasında imzalanan ilk antlaşmadır.',
    'items': [
      {
        'name': 'Edirne-Segedin Antlaşması (1444)',
        'desc': ['Haçlılarla Osmanlı Devleti\'nin imzaladığı ilk antlaşma.'],
        'mainSubject': {'name': 'Osmanlı Tarihi'},
      },
      {
        'name': 'Otlukbeli Savaşı (1473)',
        'desc': ['Fatih Sultan Mehmet – Uzun Hasan (Akkoyunlu).'],
      },
    ],
  },
};

void main() {
  late FakeAdapter adapter;
  late Map<String, Object? Function(RequestOptions)> routes;
  late RecordingExamNavigator navigator;
  late QuestionDetailViewModel viewModel;
  final exam = aytDetail();

  Future<void> build({
    ExamDetail? initial,
    int test = 0,
    int question = 31,
    StudentRef? student,
  }) async {
    adapter = routedAdapter(routes);
    final network = networkOver(adapter);
    addTearDown(network.dispose);
    navigator = RecordingExamNavigator();
    viewModel = QuestionDetailViewModel(
      examId: 'res-6',
      testIndex: test,
      questionOrder: question,
      exams: ExamRepository(network),
      navigator: navigator,
      student: student,
      initial: initial,
    );
    addTearDown(viewModel.dispose);
    viewModel.init();
    await pumpEventQueue();
  }

  setUp(() {
    routes = {
      '/student/getMyMockExams': (_) => examsAnswer([aytDetailJson()]),
      '/student/getQuestion': (_) => _questionAnswer(),
    };
  });

  test(
    'place: question 31 of the first AYT test is a wrong Tarih question',
    () async {
      await build(initial: exam);
      final place = viewModel.place!;
      expect(place.number, 31);
      expect(place.outcome, QuestionOutcome.wrong);
      expect(place.lessonName, 'Tarih');
      expect(place.lessonId, '66b0e7e5c99f8fc189ff35ff');
      expect(place.hasLetters, isFalse);
    },
  );

  test('a right question: question 6', () async {
    await build(initial: exam, question: 6);
    expect(viewModel.place!.outcome, QuestionOutcome.correct);
    expect(viewModel.place!.lessonName, 'Türk Dili ve Edebiyatı');
  });

  test('the explanation and cards come from getQuestion', () async {
    await build(initial: exam);
    expect(viewModel.question.state, SectionState.ready);
    final detail = viewModel.question.data!;
    expect(detail.cards, hasLength(2));
    expect(detail.cards.first.mainSubjectName, 'Osmanlı Tarihi');
    final request = adapter.requests.single;
    expect(request.path, '/student/getQuestion');
    final body = request.data as Map<String, dynamic>;
    expect(body['questionOrder'], 31);
    expect(body['lessonOrder'], 0);
    expect((body['mexam'] as Map)['_id'], 'exam-6');
    expect(jsonEncode(body), isNot(contains('studentId')));
  });

  test('from a link the result is found first', () async {
    await build();
    expect(adapter.requests.first.path, '/student/getMyMockExams');
    expect(viewModel.screenState, SectionState.ready);
    expect(viewModel.question.state, SectionState.ready);
  });

  test('a result that is not listed fails the screen', () async {
    routes['/student/getMyMockExams'] = (_) => examsAnswer([tytDetailJson()]);
    await build();
    expect(viewModel.screenState, SectionState.error);
    expect(viewModel.place, isNull);
    expect(
      adapter.requests.where((r) => r.path == '/student/getQuestion'),
      isEmpty,
    );
  });

  test('a failed question is a section error; the answer stays', () async {
    routes['/student/getQuestion'] = (_) => {'success': false};
    await build(initial: exam);
    expect(viewModel.question.state, SectionState.error);
    expect(viewModel.screenState, SectionState.ready);
    expect(viewModel.place!.outcome, QuestionOutcome.wrong);
    routes['/student/getQuestion'] = (_) => _questionAnswer();
    await viewModel.retryQuestion();
    expect(viewModel.question.state, SectionState.ready);
  });

  test('an answer without a question object is a failure', () async {
    routes['/student/getQuestion'] = (_) => {'success': true};
    await build(initial: exam);
    expect(viewModel.question.state, SectionState.error);
  });

  test(
    'a coach\'s student id goes with the request; no study button',
    () async {
      await build(
        initial: exam,
        student: const StudentRef(id: 'stu-1', name: 'Alparslan Kuloğlu'),
      );
      expect(adapter.requests.single.queryParameters['studentId'], 'stu-1');
      expect(viewModel.canStudyCards, isFalse);
      await viewModel.studyCards();
      expect(navigator.calls, isEmpty);
    },
  );

  test('"Kartları Çalış": the deck of the question\'s lesson', () async {
    await build(initial: exam);
    expect(viewModel.canStudyCards, isTrue);
    await viewModel.studyCards();
    expect(navigator.calls, ['deck:res-6:66b0e7e5c99f8fc189ff35ff:Tarih']);
  });

  test('no related card: no study button', () async {
    routes['/student/getQuestion'] = (_) => {
      'success': true,
      'question': {'desc': ''},
    };
    await build(initial: exam, question: 6);
    expect(viewModel.question.data!.cards, isEmpty);
    expect(viewModel.canStudyCards, isFalse);
  });
}
