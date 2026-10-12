import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/question_detail_model.dart';
import 'package:smap/features/exams/application/question_status.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/domain/question_detail.dart';
import 'package:smap/features/exams/presentation/exam_detail/stack_exam_detail_navigator.dart';
import 'package:smap/features/exams/presentation/question_detail/question_detail_viewmodel.dart';
import 'package:smap/features/exams/presentation/widgets/dyb_glyph.dart';
import 'package:smap/features/exams/presentation/widgets/exam_test_name.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_context_strip.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

part 'widgets/question_detail_answer.dart';
part 'widgets/question_detail_analysis.dart';
part 'widgets/question_detail_header.dart';
part 'widgets/question_detail_states.dart';

/// Soru Detay (pano 5.7 "Soru Detay · 2 kare"; spec §4.B 5.7; route
/// `/analytics/exam/:examId/question?lesson=&q=`; flow 13.6).
///
/// One screen for one question: "31. soru" with "Türk Dili ve Edebiyatı–Sosyal
/// Bilimler 1 · Tarih" under it, the answer card (how it came out), "Soru
/// Analizi" (the explanation, or "Bu soru için çözüm açıklaması yok."), the
/// related cards in a horizontal carousel with the one primary "Kartları
/// Çalış", and the copyright note. A related card opens its sheet. There is
/// no "Fotoğraf Çek", no "Soru Bankam" and no previous/next question.
///
/// [lesson] is the test's 0-based order and [q] the question's number (both
/// query values); [exam] is the result when Deneme Detay hands it over, and
/// [student] the student a coach is looking at.
@RoutePage()
class QuestionDetailView extends StackedView<QuestionDetailViewModel> {
  const QuestionDetailView({
    @PathParam('examId') required this.examId,
    @QueryParam('lesson') this.lesson = 0,
    @QueryParam('q') this.q = 1,
    this.student,
    this.exam,
    super.key,
  });

  final String examId;
  final int lesson;
  final int q;
  final StudentRef? student;
  final ExamDetail? exam;

  @override
  bool get reactive => false;

  @override
  QuestionDetailViewModel viewModelBuilder(BuildContext context) =>
      QuestionDetailViewModel(
        examId: examId,
        testIndex: lesson,
        questionOrder: q,
        exams: locator<ExamRepository>(),
        navigator: StackExamDetailNavigator(context.router),
        student: student,
        initial: exam,
      );

  @override
  void onViewModelReady(QuestionDetailViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    QuestionDetailViewModel viewModel,
    Widget? child,
  ) => _QuestionPage(number: q, student: student);
}

/// The page: the bar and the title, the context strip of a coach, then the
/// sections in one scroll view.
class _QuestionPage extends StatelessWidget {
  const _QuestionPage({required this.number, required this.student});

  final int number;
  final StudentRef? student;

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(
      context,
    ).examDetail_questionTitle(TrFormat.sira(number));
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        slivers: [
          AppDetailBar(title: title),
          if (student case final student?)
            PinnedHeaderSliver(child: AppContextStrip(student: student)),
          LargeTitleSliver(title: title),
          const _QuestionContext(),
          const _QuestionScreenError(),
          const _AnswerSection(),
          const _AnalysisSection(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppBottomBar.heightOf(context) + AppSpacing.s16,
            ),
          ),
        ],
      ),
    );
  }
}

/// An empty sliver: a section that is not showing.
const Widget _noSliver = SliverToBoxAdapter(child: SizedBox.shrink());

/// The gap between the sections (pano 5.7: 16 between the answer card and
/// "Soru Analizi").
const double _sectionGap = AppSpacing.s16;
