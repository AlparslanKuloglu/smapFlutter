import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/exam_cards_model.dart';
import 'package:smap/features/exams/application/exam_detail_model.dart';
import 'package:smap/features/exams/application/exam_questions_model.dart';
import 'package:smap/features/exams/application/exam_topics_model.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/presentation/exam_detail/exam_detail_viewmodel.dart';
import 'package:smap/features/exams/presentation/exam_detail/stack_exam_detail_navigator.dart';
import 'package:smap/features/exams/presentation/widgets/dyb_counter.dart';
import 'package:smap/features/exams/presentation/widgets/exam_header.dart';
import 'package:smap/features/exams/presentation/widgets/exam_score_card.dart';
import 'package:smap/features/exams/presentation/widgets/exam_test_name.dart';
import 'package:smap/features/exams/presentation/widgets/question_cell.dart';
import 'package:smap/features/exams/presentation/widgets/test_bar_row.dart';
import 'package:smap/features/exams/presentation/widgets/topic_result_row.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_glyph.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/controls/app_tab_bar.dart';
import 'package:smap/shared/ui/feedback/app_empty_state.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_context_strip.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';
import 'package:smap/shared/ui/surfaces/app_accordion.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

part 'widgets/exam_detail_cards.dart';
part 'widgets/exam_detail_general.dart';
part 'widgets/exam_detail_header.dart';
part 'widgets/exam_detail_questions.dart';
part 'widgets/exam_detail_states.dart';
part 'widgets/exam_detail_tabs.dart';
part 'widgets/exam_detail_topics.dart';

/// Deneme Detay (pano 5.3 to 5.10; spec §4.B; route
/// `/analytics/exam/:examId?tab=genel|sorular|konular|kartlar`; flow 13.6).
///
/// The back button, then the exam header (cover, publisher, name, type and
/// date, the net, the large D/Y/B counter and, when the data has them, the
/// score card), the four in-screen tabs that pin under the bar when the
/// header has scrolled away, and the selected tab: **Genel** (a bar per
/// test), **Sorular** (the filter and one accordion per test with a 5-column
/// grid of question cells), **Konular** (the most missed topic and the topics
/// of each lesson, weakest first) and **Kartlar** (the cards the exam added).
/// Sorular, Konular and Kartlar have their own skeleton, empty and error
/// states; only a result that cannot be read fails the screen (pano 5.8).
///
/// [examId] is the result's id; [tab] the `?tab=` value; [student] the
/// student a coach is looking at (a context strip shows under the bar and
/// every request carries the student's id). [exam] is the result when the
/// caller already has it (the Denemelerim list does), so no request is made;
/// a link without it reads the list until the id turns up.
@RoutePage()
class ExamDetailView extends StackedView<ExamDetailViewModel> {
  const ExamDetailView({
    @PathParam('examId') required this.examId,
    @QueryParam('tab') this.tab,
    this.student,
    this.exam,
    super.key,
  });

  final String examId;
  final String? tab;
  final StudentRef? student;
  final ExamDetail? exam;

  @override
  bool get reactive => false;

  @override
  ExamDetailViewModel viewModelBuilder(BuildContext context) =>
      ExamDetailViewModel(
        examId: examId,
        exams: locator<ExamRepository>(),
        lessons: locator<LessonContentRepository>(),
        navigator: StackExamDetailNavigator(context.router),
        toast: locator<ToastService>(),
        cdnBaseUrl: locator<AppConfig>().cdnBaseUrl,
        student: student,
        // A coach's student brings the field in the ref; the signed-in
        // student's is on the account (none in the shell preview).
        userField: student != null
            ? AytField.fromWire(student?.aimType)
            : !locator.isRegistered<CurrentUserService>()
            ? null
            : AytField.fromWire(locator<CurrentUserService>().user?.aimType),
        initial: exam,
        initialTab: ExamDetailTab.parse(tab),
      );

  @override
  void onViewModelReady(ExamDetailViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    ExamDetailViewModel viewModel,
    Widget? child,
  ) => const _ExamDetailPage();
}

/// The page: one `CustomScrollView` with the bar, the header, the pinned tabs
/// and the selected tab's body. Its `State` owns the scroll controller and
/// the key of the header (to keep the tabs pinned when the tab changes).
class _ExamDetailPage extends StatefulWidget {
  const _ExamDetailPage();

  @override
  State<_ExamDetailPage> createState() => _ExamDetailPageState();
}

class _ExamDetailPageState extends State<_ExamDetailPage> {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _headerKey = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// The tab changed: a page scrolled past the header stays at the pinned
  /// tabs (the new body starts at its top), a page still showing the header
  /// stays where it is.
  void _settleScroll() {
    final box = _headerKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !_scroll.hasClients) return;
    if (_scroll.offset > box.size.height) _scroll.jumpTo(box.size.height);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = getParentViewModel<ExamDetailViewModel>(
      context,
      listen: false,
    );
    return _PageAnchors(
      headerKey: _headerKey,
      settleScroll: _settleScroll,
      child: Scaffold(
        backgroundColor: context.appColors.bgCanvas,
        body: CustomScrollView(
          controller: _scroll,
          slivers: [
            const _ExamBar(),
            if (viewModel.student case final student?)
              _ExamContextStrip(student: student),
            const _ExamHeaderSection(),
            const _ExamTabsBar(),
            const _ExamScreenError(),
            const _ExamTabBody(),
            SliverToBoxAdapter(
              child: SizedBox(
                height: AppBottomBar.heightOf(context) + AppSpacing.s16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hands the header's key and the scroll fix to the sections.
class _PageAnchors extends InheritedWidget {
  const _PageAnchors({
    required this.headerKey,
    required this.settleScroll,
    required super.child,
  });

  final GlobalKey headerKey;
  final VoidCallback settleScroll;

  static _PageAnchors of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_PageAnchors>()!;

  @override
  bool updateShouldNotify(_PageAnchors oldWidget) => false;
}

/// The gap between the parts of a tab (pano 5.3: tabs end y=478, list y=494).
const double _sectionGap = AppSpacing.s16;

/// An empty sliver: a section that is not showing.
const Widget _noSliver = SliverToBoxAdapter(child: SizedBox.shrink());
