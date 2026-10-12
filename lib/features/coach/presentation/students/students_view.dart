import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/application/account_header.dart';
import 'package:smap/features/coach/application/coach_code_actions.dart';
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/application/student_avatars.dart';
import 'package:smap/features/coach/application/student_rows.dart';
import 'package:smap/features/coach/presentation/add_student/add_student_sheet.dart';
import 'package:smap/features/coach/presentation/students/stack_students_navigator.dart';
import 'package:smap/features/coach/presentation/students/students_texts.dart';
import 'package:smap/features/coach/presentation/students/students_viewmodel.dart';
import 'package:smap/features/coach/presentation/widgets/coach_avatars.dart';
import 'package:smap/features/coach/presentation/widgets/student_row.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/identity/app_avatar_stack.dart';
import 'package:smap/shared/ui/inputs/app_search_field.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_root_band.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

part 'widgets/students_band.dart';
part 'widgets/students_list.dart';
part 'widgets/students_search.dart';
part 'widgets/students_states.dart';

/// Öğrencilerim, the root of the coach's Öğrencilerim tab (pano 10.2 "Öğrencilerim
/// · 4 kare"; spec §4.I 10.2; flow 13.11; route `/coach/students`).
///
/// The navy band "Öğrencilerim" with one Plus action ("Öğrenci ekle"), the
/// search field "Öğrenci ara", the counter "5 öğrenci" and one card of student
/// rows in Turkish alphabetical order (kare 1). The search folds case and the
/// Turkish marks and marks what matched (kare 2); a query nobody matches
/// says so and offers "Aramayı Temizle" (kare 3). A coach with no student gets
/// three avatars, "Henüz öğrencin yok", "Öğrenci Ekle" and "Kodunu Paylaş"
/// (kare 4). The first load is a skeleton of the same rows (15 s at most, then
/// the error state with "Tekrar Dene"); the offline strip is the shell's.
///
/// A row opens the student's profile; the Plus and "Öğrenci Ekle" open the
/// add-student sheet (pano 10.3).
@RoutePage()
class StudentsView extends StackedView<StudentsViewModel> {
  const StudentsView({super.key});

  @override
  bool get reactive => false;

  @override
  StudentsViewModel viewModelBuilder(BuildContext context) => StudentsViewModel(
    students: locator<CoachStudentsService>(),
    navigator: StackStudentsNavigator(context.router),
    openAddStudent: AddStudentSheet.show,
    codeActions: CoachCodeActions.system(toast: locator<ToastService>()),
    online: locator<ConnectivityService>().online,
    coachCode: () {
      final user = locator<CurrentUserService>().user;
      return user == null ? null : AccountHeader.of(user).coachCode;
    },
  );

  @override
  void onViewModelReady(StudentsViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    StudentsViewModel viewModel,
    Widget? child,
  ) => const _StudentsPage();
}

/// The page: the band, the search field, the list and the room under it for
/// the bottom bar, in one `CustomScrollView` (the tab runs under the bar). It
/// owns the search field's controller (the ViewModel holds none), so
/// "Aramayı Temizle" can empty the field.
class _StudentsPage extends StatefulWidget {
  const _StudentsPage();

  @override
  State<_StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<_StudentsPage> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// "Aramayı Temizle": empties the field and the query.
  void _clearSearch() {
    _search.clear();
    getParentViewModel<StudentsViewModel>(context, listen: false).clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          const _StudentsBand(),
          _StudentsSearch(controller: _search),
          const _StudentsCounter(),
          _StudentsListSection(onClearSearch: _clearSearch),
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
