import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/presentation/exam_detail/exam_detail_navigator.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/shared/ui/feedback/toast_host.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';

import '../../../core/network/fake_adapter.dart';

/// Records where the exam screens lead.
class RecordingExamNavigator implements ExamDetailNavigator {
  final List<String> calls = [];
  final List<ExamDetail> openedExams = [];

  @override
  Future<void> openQuestion({
    required ExamDetail exam,
    required int testIndex,
    required int questionOrder,
    StudentRef? student,
  }) async {
    openedExams.add(exam);
    calls.add('question:${exam.id}:$testIndex:$questionOrder:${student?.id}');
  }

  @override
  Future<void> openTopic({
    required String lessonId,
    required String topicId,
    LessonCat? cat,
  }) async => calls.add('topic:$lessonId:$topicId:${cat?.key}');

  @override
  Future<void> openLesson({required String lessonId, LessonCat? cat}) async =>
      calls.add('lesson:$lessonId:${cat?.key}');

  @override
  Future<void> openCardDeck({
    required String examId,
    String? backendLessonId,
    String? lessonName,
  }) async => calls.add('deck:$examId:$backendLessonId:$lessonName');
}

class _Presenter implements ToastPresenter {
  @override
  bool screenReaderOn = false;

  @override
  bool present(ToastSlot slot, ValueListenable<double?> barHeight) => true;
}

/// A toast service that draws nowhere; read what it shows with [toastText].
ToastService recordingToast() => ToastService(presenter: _Presenter());

/// The words of the toast on screen, `null` when none.
String? toastText(ToastService toast) =>
    toast.slot.current.value?.title(AppLocalizationsTr());

/// An adapter whose request never answers (for the 15 s limit).
FakeAdapter hangingAdapter() =>
    FakeAdapter((_) => Completer<ResponseBody>().future);
