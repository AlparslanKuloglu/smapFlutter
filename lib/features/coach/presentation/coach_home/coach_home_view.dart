import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/config/feature_flags.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/application/avatar_catalog.dart';
import 'package:smap/features/coach/application/coach_code_actions.dart';
import 'package:smap/features/coach/application/coach_home_models.dart';
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/application/new_meeting_flow.dart';
import 'package:smap/features/coach/data/interview_repository.dart';
import 'package:smap/features/coach/domain/attention_item.dart';
import 'package:smap/features/coach/presentation/coach_home/coach_home_viewmodel.dart';
import 'package:smap/features/coach/presentation/meetings/sheet_meetings_dialogs.dart';
import 'package:smap/features/coach/presentation/widgets/attention_copy.dart';
import 'package:smap/features/coach/presentation/widgets/attention_row.dart';
import 'package:smap/features/coach/presentation/widgets/code_card.dart';
import 'package:smap/features/coach/presentation/widgets/coach_avatars.dart';
import 'package:smap/features/coach/presentation/widgets/meeting_row.dart';
import 'package:smap/features/coach/presentation/widgets/student_tile.dart';
import 'package:smap/features/coach/application/meeting_models.dart';
import 'package:smap/features/coach/presentation/add_student/add_student_sheet.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_empty_state.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/identity/app_avatar_stack.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_home_band.dart';
import 'package:smap/shared/ui/navigation/band_math.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';
import 'package:smap/shared/ui/text/section_header.dart';

part 'widgets/coach_home_attention.dart';
part 'widgets/coach_home_band.dart';
part 'widgets/coach_home_empty.dart';
part 'widgets/coach_home_meetings.dart';
part 'widgets/coach_home_skeletons.dart';
part 'widgets/coach_home_students.dart';

/// The gap between the sections of the page (pano 10.1: "bölümler arası 28");
/// a section's content starts 12 below its header (`SectionHeader`).
const double _sectionGap = 28;

/// The page edge of a section's content (a section pads itself so the student
/// strip can run to the screen edge).
const EdgeInsets _gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutter);

/// Koç Anasayfa (pano 10.1 kare 1 to 4; flow 13.11).
///
/// The band with the greeting and "5 öğrenci · önümüzdeki 7 günde 2 görüşme",
/// then the sections "Öğrencilerin" (a strip of `StudentTile`s and the one
/// link "Öğrenci Ekle"), "Dikkat gerektirenler" (`AttentionRow`s; behind
/// `FeatureFlags.attentionListEnabled`, so not on the screen today) and
/// "Yaklaşan görüşmeler" (`MeetingRow`s). A coach with no student gets the page
/// of kare 3 instead: three avatars, "İlk öğrencini ekle", the one primary
/// button and the `CodeCard`. Each section is its own selector of the
/// ViewModel with its own skeleton, error and empty state, so one failing
/// leaves the others working. The old student cards, the menu grid and the
/// navy header are gone.
///
/// One `CustomScrollView`: the pinned band shrinks to one line as the page
/// scrolls; pulling down refreshes the sections with a selection haptic on
/// release. The page scrolls under the bottom bar, so its last section ends
/// `AppBottomBar.heightOf` above the edge. The offline strip is the shell's.
@RoutePage()
class CoachHomeView extends StackedView<CoachHomeViewModel> {
  const CoachHomeView({super.key});

  @override
  bool get reactive => false;

  @override
  CoachHomeViewModel viewModelBuilder(BuildContext context) =>
      CoachHomeViewModel(
        students: locator<CoachStudentsService>(),
        interviews: locator<InterviewRepository>(),
        currentUser: locator<CurrentUserService>(),
        codeActions: CoachCodeActions.system(toast: locator<ToastService>()),
        // Closed until the backend works the two rules out (spec §6.3 #28).
        attention: FeatureFlags.attentionListEnabled
            ? locator<AttentionRepository>()
            : null,
        newMeeting: NewMeetingFlow(
          dialogs: SheetMeetingsDialogs(l10n: AppLocalizations.of(context)),
          interviews: locator<InterviewRepository>(),
          toast: locator<ToastService>(),
          students: locator<CoachStudentsService>(),
        ),
      );

  @override
  void onViewModelReady(CoachHomeViewModel viewModel) =>
      unawaited(viewModel.init());

  @override
  Widget builder(
    BuildContext context,
    CoachHomeViewModel viewModel,
    Widget? child,
  ) => const _CoachHomePage();
}

/// The page: the scroll view with its pull-to-refresh.
class _CoachHomePage extends StatelessWidget {
  const _CoachHomePage();

  /// The first section starts 44 under the band (pano 10.1: band 138, content
  /// from 182).
  static const double _contentTop = 44;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final collapsedBand = HomeBandMetrics(
      role: AppHomeBandRole.coach,
      safeTop: media.padding.top,
      textScaler: media.textScaler,
    ).minExtent;
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: RefreshIndicator(
        edgeOffset: collapsedBand,
        onRefresh: getParentViewModel<CoachHomeViewModel>(
          context,
          listen: false,
        ).refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const _CoachBand(),
            SliverPadding(
              padding: EdgeInsets.only(
                top: _contentTop,
                bottom: AppBottomBar.heightOf(context) + AppSpacing.s32,
              ),
              sliver: const SliverToBoxAdapter(child: _CoachBody()),
            ),
          ],
        ),
      ),
    );
  }
}

/// The body under the band: the sections, or the page of a coach with no
/// student (kare 3). It rebuilds only when that fact changes.
class _CoachBody extends SelectorViewModelWidget<CoachHomeViewModel, bool> {
  const _CoachBody();

  @override
  bool selector(CoachHomeViewModel viewModel) => viewModel.hasNoStudents;

  @override
  Widget build(BuildContext context, bool hasNoStudents) {
    if (hasNoStudents) return const _NoStudentsPage();
    final attention = getParentViewModel<CoachHomeViewModel>(
      context,
      listen: false,
    ).attentionEnabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StudentsSection(),
        if (attention) ...[
          const SizedBox(height: _sectionGap),
          const _AttentionSection(),
        ],
        const SizedBox(height: _sectionGap),
        const _MeetingsSection(),
      ],
    );
  }
}

// ── Where the links go ────────────────────────────────────────────────────
//
// Every destination is opened from one function here.

/// A student tile or an attention row: the student's profile, in the
/// Öğrencilerim tab (pano 10.1 "Gezinme": "→ 10.4"). The tab switches and its
/// stack becomes the list and the profile, so Back returns to the list.
void _openStudent(BuildContext context, {required String id}) => unawaited(
  context.navigateTo(
    CoachStudentsTabRoute(
      children: [
        const StudentsRoute(),
        StudentProfileRoute(studentId: id),
      ],
    ),
  ),
);

/// "Öğrenci Ekle": the add-student sheet (10.3), then the list is read again.
Future<void> _openAddStudent(BuildContext context) async {
  final viewModel = getParentViewModel<CoachHomeViewModel>(
    context,
    listen: false,
  );
  final added = await AddStudentSheet.show(context);
  if (added != null) await viewModel.reloadStudents();
}

/// A meeting row: the meeting's detail (10.5 kare 3) in the Görüşmelerim tab.
/// The detail reads the meeting again, so the row's fields are enough.
void _openMeeting(BuildContext context, HomeMeeting meeting) => unawaited(
  context.navigateTo(
    CoachMeetingsTabRoute(
      children: [
        const MeetingsRoute(),
        MeetingDetailRoute(
          meetingId: meeting.id,
          meeting: MeetingEntry(
            id: meeting.id,
            type: meeting.type,
            moment: meeting.date,
            studentId: meeting.studentId,
            studentName: meeting.studentName,
            photo: meeting.photo,
          ),
        ),
      ],
    ),
  ),
);

/// "Yeni Görüşme": the new-meeting flow of Görüşmelerim (sheet, save, toast),
/// then the upcoming list is read again.
void _openNewMeeting(BuildContext context) => unawaited(
  getParentViewModel<CoachHomeViewModel>(context, listen: false).newMeeting(),
);
