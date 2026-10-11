import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/analytics/presentation/screens/my_test_result_detail_screen.dart';
import 'package:smap/features/exams/application/question_status.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/legacy/legacy_theme.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';

/// Opens the legacy exam detail from the new Denemelerim list (E11), until
/// E10's `ExamDetailView` replaces it. Delete this file with the legacy
/// screen.
///
/// The page is pushed on the Analizlerim tab's own stack (the nearest
/// navigator), so Back returns to the list and the bottom bar stays. The
/// legacy screen knows nothing of the bar (the new tab screens scroll under
/// it), so the page is lifted above it the way the shell lifts a legacy tab,
/// and put under `LegacyTheme` like every legacy route page.
void openLegacyExamDetail(BuildContext context, ExamDetail exam) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _ClearOfBottomBar(
        child: LegacyTheme(
          child: MyTestResultDetailScreen(data: legacyExamMap(exam)),
        ),
      ),
    ),
  );
}

/// The raw result the legacy detail screen reads (`widget.data[...]`: the
/// map `getMyMockExams` listed), rebuilt from the typed [exam].
///
/// Fields the screen never reads (the AYT breakdown, the server's star) are
/// left out. The screen casts some counts to `int` without a null check, so
/// where a test or a lesson has no counts they are 0 here; that is the legacy
/// screen's own behavior, not a value the new screens ever show.
Map<String, dynamic> legacyExamMap(ExamDetail exam) {
  final summary = exam.summary;
  final counts = summary.counts;
  final definition = summary.definition;
  return <String, dynamic>{
    '_id': summary.id,
    'itemName': ?summary.name,
    'publisherName': ?summary.publisherName,
    'net': ?summary.net,
    'true': ?counts?.correct,
    'wrong': ?counts?.wrong,
    'pass': ?counts?.blank,
    'date': ?summary.date?.toIso8601String(),
    'mexam':
        definition.serverObject ??
        <String, dynamic>{
          '_id': ?definition.id,
          'order': ?definition.order,
          'type': ?summary.kind?.wireType,
          'image': ?definition.imageFile,
        },
    'points': exam.scores.points,
    'pointsHam': exam.scores.pointsHam,
    'ranks': exam.scores.ranks,
    'ranksHam': exam.scores.ranksHam,
    if (exam.tests.isNotEmpty) ...{
      'lessonInfo': jsonEncode([
        for (final test in exam.tests)
          {
            'true': test.counts?.correct ?? 0,
            'wrong': test.counts?.wrong ?? 0,
            'pass': test.counts?.blank ?? 0,
          },
      ]),
      'questionsArrStr': jsonEncode([
        for (final test in exam.tests)
          [
            for (final question in test.questions)
              {
                'order': question.order,
                'type': switch (question.outcome) {
                  QuestionOutcome.correct => 1,
                  QuestionOutcome.wrong => 3,
                  QuestionOutcome.blank => 2,
                },
              },
          ],
      ]),
    },
    'lessonmockexams': [
      for (final lesson in exam.lessons)
        {
          'lesson': lesson.lessonId,
          'net': ?lesson.net,
          'true': lesson.counts?.correct ?? 0,
          'wrong': lesson.counts?.wrong ?? 0,
          'pass': lesson.counts?.blank ?? 0,
        },
    ],
  };
}

/// Lifts a legacy page above the bottom bar (see [openLegacyExamDetail]).
class _ClearOfBottomBar extends StatelessWidget {
  const _ClearOfBottomBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return ColoredBox(
      color: context.appColors.bgCanvas,
      child: Padding(
        padding: EdgeInsets.only(bottom: AppBottomBar.heightOf(context)),
        child: MediaQuery(
          data: media.copyWith(
            padding: media.padding.copyWith(bottom: 0),
            viewPadding: media.viewPadding.copyWith(bottom: 0),
          ),
          child: child,
        ),
      ),
    );
  }
}
