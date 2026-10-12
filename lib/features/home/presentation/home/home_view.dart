import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/presentation/widgets/exam_summary_card.dart';
import 'package:smap/features/home/application/avatar_asset.dart';
import 'package:smap/features/home/application/last_exam_summary.dart';
import 'package:smap/features/home/application/subject_strip.dart';
import 'package:smap/features/home/application/today_summary.dart';
import 'package:smap/features/home/presentation/home/home_viewmodel.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_tile.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/presentation/widgets/program_item_row.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/app_state_level.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_home_band.dart';
import 'package:smap/shared/ui/navigation/band_math.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';
import 'package:smap/shared/ui/text/section_header.dart';

part 'widgets/home_band.dart';
part 'widgets/home_last_exam.dart';
part 'widgets/home_skeletons.dart';
part 'widgets/home_subjects.dart';
part 'widgets/home_today.dart';

/// The gap between the sections of the page (pano 3.1: `.pg` "bölümler
/// arası aralık 28"); a section's content starts 12 below its header
/// (`SectionHeader`).
const double _sectionGap = 28;

/// Anasayfa, student (pano 3.1 kare 1 to 3, 3.2 kare 1 to 4, 3.3; flow 13.3).
///
/// The band with the greeting and the YKS counter, then at most three
/// sections: "Bugün", "Son denemen" and "Derslerin". Each is its own selector
/// of the ViewModel with its own skeleton, error and empty state, so one
/// failing leaves the others working (the home screen "tek soruyu cevaplar:
/// Bugün ne yapmalıyım?"). The old person card, the menu grid and the month
/// calendar are gone.
///
/// One `CustomScrollView`: the pinned band shrinks to one line as the page
/// scrolls (kare 2); pulling down refreshes the three sections with a
/// selection haptic on release. The page scrolls under the bottom bar, so
/// its last section ends `AppBottomBar.heightOf` above the edge. The
/// offline strip is the shell's (pano 3.2 kare 3).
@RoutePage()
class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  bool get reactive => false;

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel(
    schedule: locator<ScheduleService>(),
    lessons: locator<LessonsService>(),
    exams: locator<ExamRepository>(),
    currentUser: locator<CurrentUserService>(),
    router: locator<AppRouter>(),
    yksDate: locator<AppConfig>().yksDate,
  );

  @override
  void onViewModelReady(HomeViewModel viewModel) => unawaited(viewModel.init());

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) => const _HomePage();
}

/// The page: the scroll view with its pull-to-refresh.
class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final collapsedBand = HomeBandMetrics(
      role: AppHomeBandRole.student,
      safeTop: media.padding.top,
      textScaler: media.textScaler,
    ).minExtent;
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: RefreshIndicator(
        edgeOffset: collapsedBand,
        onRefresh: getParentViewModel<HomeViewModel>(
          context,
          listen: false,
        ).refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const _HomeBand(),
            SliverPadding(
              padding: EdgeInsets.only(
                top: AppSpacing.s24,
                bottom: AppBottomBar.heightOf(context) + AppSpacing.s32,
              ),
              sliver: const SliverList(
                delegate: SliverChildListDelegate.fixed([
                  _TodaySection(),
                  SizedBox(height: _sectionGap),
                  _LastExamSection(),
                  SizedBox(height: _sectionGap),
                  _SubjectsSection(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The page edge of a section's content (a section pads itself so the
/// subject strip can run to the screen edge).
const EdgeInsets _gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutter);

// ── Where the links go ────────────────────────────────────────────────────
//
// Every destination is opened from one function here. Deneme Detay lives in
// the Analizlerim tab's stack, Ders and Konu Detayı in the Derslerim tab's,
// Programım in this tab's and the new-program flow on the root stack (spec
// §3.6).

/// "Analizi Gör": the result detail of the last exam, in the Analizlerim tab
/// (spec §3.6).
void _openExam(BuildContext context, String examId) => unawaited(
  context.navigateTo(
    AnalyticsTabRoute(
      children: [
        AnalyticsRoute(),
        ExamDetailRoute(examId: examId),
      ],
    ),
  ),
);

/// A lesson tile: the lesson detail, in the Derslerim tab.
void _openLesson(BuildContext context, String lessonId) => unawaited(
  context.navigateTo(
    LessonsTabRoute(
      children: [
        const LessonsRoute(),
        LessonDetailRoute(lessonId: lessonId),
      ],
    ),
  ),
);

/// A row of "Bugün": the topic of the planned task, in the Derslerim tab.
/// A task without a lesson or topic id (very old programs) has nowhere to go.
void _openTopic(BuildContext context, TodayRow row) {
  final lessonId = row.lessonId;
  final topicId = row.mainSubjectId;
  if (lessonId == null || topicId == null) return;
  unawaited(
    context.navigateTo(
      LessonsTabRoute(
        children: [
          const LessonsRoute(),
          TopicDetailRoute(lessonId: lessonId, topicId: topicId),
        ],
      ),
    ),
  );
}

/// "Programım": the program list, on this tab's stack.
void _openProgram(BuildContext context) =>
    unawaited(context.router.push(const ProgramListRoute()));

/// "Haftalık Programını Kur": the new-program flow, full screen.
void _openProgramSetup(BuildContext context) =>
    unawaited(context.router.root.push(const NewProgramRoute()));
