import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/schedule/application/program_summary.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/presentation/program_list/program_list_viewmodel.dart';
import 'package:smap/features/schedule/presentation/program_navigator.dart';
import 'package:smap/features/schedule/presentation/widgets/program_row.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_bar_action.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_empty_state.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/inputs/app_search_field.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_context_strip.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

part 'widgets/program_list_header.dart';
part 'widgets/program_list_body.dart';
part 'widgets/program_list_states.dart';

/// Programım (pano 3.4 kare 1 and 2, 3.7 kare 1 to 4; flow 13.3).
///
/// Opened from Anasayfa's "Programım" on the Anasayfa tab's stack
/// (`/home/program`), under the bottom bar. A detail bar with "Programım" and
/// the "Yeni Program" action, the search field, and one card of
/// [ProgramRow]s. The states are the board's: the skeleton with the title and
/// the search field at once (15 s limit), the empty state with the clay bulb
/// and "Haftalık Programını Kur", the full-screen error with "Tekrar Dene"
/// (no title), and offline (the saved list, "Yeni Program" off and the note
/// under the list).
///
/// A tap on a row opens the program on its Gün view; the shell's offline strip
/// is the app's, not drawn here.
///
/// A coach opens a student's programs with [student] (Tur 12 A, brief 14.1
/// kare 2: "Programlar"): the context strip sits under the bar, every request
/// carries the student's id, the coach may set up a new program for the
/// student, and the empty state names the student.
@RoutePage()
class ProgramListView extends StackedView<ProgramListViewModel> {
  const ProgramListView({this.student, super.key});

  /// The student a coach is looking at; `null` for the user's own programs.
  final StudentRef? student;

  @override
  bool get reactive => false;

  @override
  ProgramListViewModel viewModelBuilder(BuildContext context) =>
      ProgramListViewModel(
        schedule: locator<ScheduleService>(),
        navigator: RouterProgramNavigator(context.router, student: student),
        online: locator<ConnectivityService>().online,
        studentId: student?.id,
      );

  @override
  void onViewModelReady(ProgramListViewModel viewModel) => viewModel.load();

  @override
  Widget builder(
    BuildContext context,
    ProgramListViewModel viewModel,
    Widget? child,
  ) => StudentScope(
    student: student,
    child: _ProgramListPage(student: student),
  );
}

/// The page: one scroll view of the bar, the title, the search field and the
/// body. It owns the search field's controller (the ViewModel holds none).
class _ProgramListPage extends StatefulWidget {
  const _ProgramListPage({required this.student});

  final StudentRef? student;

  @override
  State<_ProgramListPage> createState() => _ProgramListPageState();
}

class _ProgramListPageState extends State<_ProgramListPage> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// "Aramayı Temizle" of the no-match card: empties the field and the query.
  void clearSearch() {
    _search.clear();
    getParentViewModel<ProgramListViewModel>(
      context,
      listen: false,
    ).setQuery('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          const _ListBar(),
          if (widget.student case final student?)
            PinnedHeaderSliver(child: AppContextStrip(student: student)),
          const _ListTitle(),
          _ListSearch(controller: _search),
          const _ListBody(),
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
