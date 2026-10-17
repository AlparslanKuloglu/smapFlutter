import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/config/feature_flags.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/schedule/application/program_detail.dart';
import 'package:smap/features/schedule/application/program_edit_link.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/program_span.dart';
import 'package:smap/features/schedule/application/program_view_preference.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/presentation/program_detail/program_detail_viewmodel.dart';
import 'package:smap/features/schedule/presentation/program_navigator.dart';
import 'package:smap/features/schedule/presentation/sheets/sheet_program_dialogs.dart';
import 'package:smap/features/schedule/presentation/widgets/program_item_row.dart';
import 'package:smap/features/schedule/presentation/widgets/program_section_skeleton.dart';
import 'package:smap/features/schedule/presentation/widgets/week_grid.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_bar_action.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_context_strip.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';
import 'package:smap/shared/ui/pickers/app_day_chip.dart';
import 'package:smap/shared/ui/pickers/calendar_math.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

part 'widgets/program_detail_header.dart';
part 'widgets/program_detail_actions.dart';
part 'widgets/program_detail_day.dart';
part 'widgets/program_detail_embedded.dart';
part 'widgets/program_detail_helpers.dart';
part 'widgets/program_detail_week.dart';
part 'widgets/program_detail_states.dart';

/// One program: Gün and Hafta, and edit mode (pano 3.4 kare 3 and 4, 3.6, 3.8;
/// flow 13.3).
///
/// On the Anasayfa tab's stack (`/home/program/:programId?view=day|week&date=`)
/// under the bottom bar. The Gün view: the program's name as the large title,
/// the motto and the date range, the "Gün | Hafta" segment, the day strip,
/// the day's heading and its topics, "Günü Sıfırla" under them. The Hafta
/// view: the name sits in the bar and the [WeekGrid] fills the page. In edit
/// mode (the bar's "Düzenle"; "Bitti" ends it) every change is saved at once
/// (see [ProgramDetailViewModel]); the topics' times and remove buttons work,
/// "Konu Ekle" opens the hour grid and the reset and cancel buttons sit at
/// the end. The Gün / Hafta choice is remembered on the device.
///
/// A tap on a topic opens the topic detail (pano 7.3).
///
/// A coach opens a student's program with [student] (Tur 12 A, brief 14.1
/// kare 2 and 3): the context strip sits under the bar, every request carries
/// the student's id, "Düzenle" is on (the changes go to the student's
/// account) and the topics do not open (a coach has no lessons).
@RoutePage()
class ProgramDetailView extends StackedView<ProgramDetailViewModel> {
  const ProgramDetailView({
    @PathParam('programId') required this.programId,
    @QueryParam('view') this.view,
    @QueryParam('date') this.date,
    this.student,
    super.key,
  });

  /// The program's id.
  final String programId;

  /// `day` or `week`; the remembered choice when absent.
  final String? view;

  /// `yyyy-MM-dd`: the day to open on.
  final String? date;

  /// The student a coach is looking at; `null` for the user's own program.
  final StudentRef? student;

  @override
  bool get reactive => false;

  @override
  ProgramDetailViewModel viewModelBuilder(BuildContext context) =>
      _detailViewModel(
        context,
        programId: programId,
        student: student,
        view: view,
        date: date,
      );

  @override
  void onViewModelReady(ProgramDetailViewModel viewModel) => viewModel.load();

  @override
  Widget builder(
    BuildContext context,
    ProgramDetailViewModel viewModel,
    Widget? child,
  ) => _ProgramDetailPage(student: student);
}

/// The program as a section of a coach's student profile, the Program tab
/// (Tur 12 A, pano 14.1 kare 1 and 3; replaces pano 10.4 kare 3): the title row
/// with the inline "Düzenle", the motto and dates, "Gün | Hafta", the day strip
/// and the day's topics, as slivers for the profile's scroll view. Same
/// ViewModel as [ProgramDetailView]; it has no bar and no context strip (the
/// profile has them), and in edit mode the profile's bar holds "Bitti" ([link]).
/// Its states are the section's own: skeleton, a section error with "Tekrar
/// Dene".
class ProgramDetailSection extends StackedView<ProgramDetailViewModel> {
  const ProgramDetailSection({
    required this.programId,
    required this.student,
    this.link,
    super.key,
  });

  final String programId;
  final StudentRef student;

  /// Tells the hosting profile about edit mode (its bar, header and tabs
  /// follow it, pano 14.1 kare 3).
  final ProgramEditLink? link;

  @override
  bool get reactive => false;

  @override
  ProgramDetailViewModel viewModelBuilder(BuildContext context) =>
      _detailViewModel(
        context,
        programId: programId,
        student: student,
        link: link,
      );

  @override
  void onViewModelReady(ProgramDetailViewModel viewModel) => viewModel.load();

  @override
  Widget builder(
    BuildContext context,
    ProgramDetailViewModel viewModel,
    Widget? child,
  ) => StudentScope(student: student, child: const _ProgramDetailSlivers());
}

ProgramDetailViewModel _detailViewModel(
  BuildContext context, {
  required String programId,
  StudentRef? student,
  String? view,
  String? date,
  ProgramEditLink? link,
}) {
  final schedule = locator<ScheduleService>();
  return ProgramDetailViewModel(
    programId: programId,
    studentId: student?.id,
    schedule: schedule,
    toast: locator<ToastService>(),
    dialogs: SheetProgramDialogs(
      l10n: AppLocalizations.of(context),
      schedule: schedule,
      studentId: student?.id,
      studentFirstName: student?.firstName,
    ),
    navigator: RouterProgramNavigator(context.router, student: student),
    online: locator<ConnectivityService>().online,
    preference: ProgramViewPreference(locator<DevicePreferences>()),
    requestedDay: _parseDay(date),
    requestedMode: ProgramViewMode.parse(view),
    link: link,
  );
}

typedef _ModeData = ({SectionState state, ProgramViewMode mode});

/// The page: one scroll view; each slice decides by the state and the view
/// whether it draws.
class _ProgramDetailPage extends StatelessWidget {
  const _ProgramDetailPage({this.student});

  final StudentRef? student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        slivers: [
          const _DetailBar(),
          if (student case final student?)
            PinnedHeaderSliver(child: AppContextStrip(student: student)),
          const _DetailHeader(),
          const _DetailSegment(),
          const _DetailLoading(),
          const _DetailError(),
          const _DayStrip(),
          const _DayHeading(),
          const _DayList(),
          const _DayActions(),
          const _WeekSection(),
          const _BottomSpace(),
        ],
      ),
    );
  }
}
