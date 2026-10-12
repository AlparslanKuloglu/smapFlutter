import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/analytics/presentation/analytics/student_analytics_view.dart';
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/application/new_meeting_flow.dart';
import 'package:smap/features/coach/application/student_profile.dart';
import 'package:smap/features/coach/data/interview_repository.dart';
import 'package:smap/features/coach/presentation/meetings/sheet_meetings_dialogs.dart';
import 'package:smap/features/coach/presentation/student_profile/student_profile_texts.dart';
import 'package:smap/features/coach/presentation/student_profile/student_profile_viewmodel.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/presentation/program_detail/program_detail_view.dart';
import 'package:smap/features/schedule/presentation/program_list/program_list_viewmodel.dart';
import 'package:smap/features/schedule/presentation/program_navigator.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_bar_action.dart';
import 'package:smap/shared/ui/controls/app_tab_bar.dart';
import 'package:smap/shared/ui/feedback/app_empty_state.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_context_strip.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';
import 'package:smap/shared/ui/surfaces/app_notice_box.dart';
import 'package:smap/shared/ui/surfaces/app_row.dart';
import 'package:smap/shared/ui/surfaces/app_row_group.dart';

part 'widgets/student_profile_bar.dart';
part 'widgets/student_profile_body.dart';
part 'widgets/student_profile_header.dart';
part 'widgets/student_profile_program.dart';
part 'widgets/student_profile_states.dart';
part 'widgets/student_profile_tabs.dart';

/// Öğrenci Profili, koç bağlamında (pano 10.4 kare 1 to 4; flow 13.11; Tur 12
/// A; route `/coach/students/:studentId?tab=analysis|exams|program`).
///
/// The back button and "Görüşme Planla" (the new meeting sheet with this
/// student chosen), the context strip ("Alparslan Kuloğlu'nun verileri",
/// "12. Sınıf · EA"; it stays with the bar), the student's name and the line
/// "alparslan.k · 10 deneme", the three tabs that pin under the strip once the
/// header has scrolled away, and the selected tab:
///
/// - **Analiz** and **Denemeler**: the sections of Analizlerim (pano 6.1 and
///   6.2) with the student's id (`StudentAnalyticsView`). A row of Denemeler
///   opens the exam detail in the coach's view (`ExamDetailRoute` with the
///   student: the strip stays, "Bu Konuyu Çalış" and "Kartları Çalış" do not
///   show).
/// - **Program**: the student's current program with "Düzenle" (Tur 12 A
///   overrules "salt okunur" of pano 10.4 kare 3), and the list of the
///   student's programs under it.
///
/// A tab is built when first opened and kept. The student's own facts come
/// from the coach's student list; while it loads there is a skeleton, a list
/// that cannot be read is an error with "Tekrar Dene", and an id that is not
/// in it says so.
///
/// [student] is the student when the caller already has the reference (it
/// then replaces what the list would give).
@RoutePage()
class StudentProfileView extends StackedView<StudentProfileViewModel> {
  const StudentProfileView({
    @PathParam('studentId') required this.studentId,
    @QueryParam('tab') this.tab,
    this.student,
    super.key,
  });

  final String studentId;

  /// The `?tab=` value; Analiz when absent.
  final String? tab;
  final StudentRef? student;

  @override
  bool get reactive => false;

  @override
  StudentProfileViewModel viewModelBuilder(BuildContext context) {
    final students = locator<CoachStudentsService>();
    final given = student;
    return StudentProfileViewModel(
      studentId: studentId,
      students: students,
      newMeeting: NewMeetingFlow(
        dialogs: SheetMeetingsDialogs(l10n: AppLocalizations.of(context)),
        interviews: locator<InterviewRepository>(),
        toast: locator<ToastService>(),
        students: students,
      ),
      initial: given == null
          ? null
          : StudentProfile(
              id: given.id,
              name: given.name,
              aimType: given.aimType,
            ),
      initialTab: StudentProfileTab.parse(tab),
    );
  }

  @override
  void onViewModelReady(StudentProfileViewModel viewModel) =>
      unawaited(viewModel.init());

  @override
  Widget builder(
    BuildContext context,
    StudentProfileViewModel viewModel,
    Widget? child,
  ) => _ProfilePage(given: student);
}

/// The page: one `CustomScrollView` with the bar, the strip, the header, the
/// pinned tabs and the body. Its `State` owns the scroll controller and the
/// key of the header (to keep the tabs pinned when the tab changes).
class _ProfilePage extends StatefulWidget {
  const _ProfilePage({required this.given});

  final StudentRef? given;

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
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
    return _PageAnchors(
      given: widget.given,
      headerKey: _headerKey,
      settleScroll: _settleScroll,
      child: Scaffold(
        backgroundColor: context.appColors.bgCanvas,
        body: CustomScrollView(
          controller: _scroll,
          slivers: [
            const _ProfileBar(),
            const _ProfileStrip(),
            const _ProfileHeader(),
            const _ProfileTabs(),
            const _ProfileStates(),
            const _ProfileBody(),
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

/// Hands the page's given reference, the header's key and the scroll fix to
/// the sections.
class _PageAnchors extends InheritedWidget {
  const _PageAnchors({
    required this.given,
    required this.headerKey,
    required this.settleScroll,
    required super.child,
  });

  final StudentRef? given;
  final GlobalKey headerKey;
  final VoidCallback settleScroll;

  static _PageAnchors of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_PageAnchors>()!;

  /// The student of the page: the caller's reference, else the one made from
  /// the list's facts; `null` until they are known.
  StudentRef? studentOf(AppLocalizations l10n, StudentProfile? profile) =>
      given ??
      (profile == null ? null : StudentProfileTexts.ref(l10n, profile));

  @override
  bool updateShouldNotify(_PageAnchors oldWidget) => false;
}

/// An empty sliver: a section that is not showing.
const Widget _noSliver = SliverToBoxAdapter(child: SizedBox.shrink());
