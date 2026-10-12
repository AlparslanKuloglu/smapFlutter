import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/analytics/application/analytics_filter.dart';
import 'package:smap/features/analytics/application/analytics_general.dart';
import 'package:smap/features/analytics/application/exam_favorites.dart';
import 'package:smap/features/analytics/application/exam_list_query.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/analytics/data/analytics_repository.dart';
import 'package:smap/features/analytics/presentation/analytics/analytics_viewmodel.dart';
import 'package:smap/features/analytics/presentation/analytics/sheets/analytics_filter_sheet.dart';
import 'package:smap/features/analytics/presentation/analytics/sheets/exam_filter_sheet.dart';
import 'package:smap/features/analytics/presentation/widgets/net_chart.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/domain/exam_summary.dart';
import 'package:smap/features/exams/presentation/widgets/exam_row.dart';
import 'package:smap/gen/assets.gen.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/controls/app_chip.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/controls/app_tab_bar.dart';
import 'package:smap/shared/ui/feedback/app_empty_state.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/indicators/app_spinner.dart';
import 'package:smap/shared/ui/indicators/app_stat_box.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_root_band.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';
import 'package:smap/shared/ui/text/section_header.dart';

part 'widgets/analytics_band.dart';
part 'widgets/analytics_body.dart';
part 'widgets/analytics_exams_body.dart';
part 'widgets/analytics_exams_controls.dart';
part 'widgets/analytics_exams_list.dart';
part 'widgets/analytics_exams_states.dart';
part 'widgets/analytics_general_body.dart';
part 'widgets/analytics_general_chart.dart';
part 'widgets/analytics_general_filter.dart';
part 'widgets/analytics_general_states.dart';
part 'widgets/analytics_general_stats.dart';

/// The gap between the sections of a tab (pano 6.1: 16).
const double _sectionGap = AppSpacing.s16;

/// The gap between the columns and rows of the stat grid (pano 6.1: 8).
const double _boxGap = AppSpacing.s8;

/// Analizlerim (pano 6.1 to 6.4; flow 13.7): the tab root of the student
/// shell.
///
/// A navy root band "Analizlerim" with the tabs "Genel" and "Denemelerim",
/// then the selected tab's sections in the one scroll view: Genel has the
/// filter pill, the net chart and the stat boxes; Denemelerim has the type
/// segment, the summary line with "Süz ve Sırala" and the paged list. Each
/// section has its own skeleton, empty, error and offline state; the tabs
/// load separately.
///
/// [tab] is the `?tab=genel|denemelerim` query of the route.
@RoutePage()
class AnalyticsView extends StackedView<AnalyticsViewModel> {
  const AnalyticsView({@QueryParam('tab') this.tab, super.key});

  /// `genel` (default) or `denemelerim`.
  final String? tab;

  @override
  bool get reactive => false;

  @override
  void onViewModelReady(AnalyticsViewModel viewModel) => viewModel.init();

  @override
  AnalyticsViewModel viewModelBuilder(BuildContext context) =>
      AnalyticsViewModel(
        analytics: locator<AnalyticsRepository>(),
        exams: locator<ExamRepository>(),
        connectivity: locator<ConnectivityService>(),
        favorites: ExamFavorites(locator<DevicePreferences>()),
        router: locator<AppRouter>(),
        // The shell preview (no account) has no session scope.
        userField: locator.isRegistered<CurrentUserService>()
            ? AytField.fromWire(locator<CurrentUserService>().user?.aimType)
            : null,
        initialTab: tab == 'denemelerim'
            ? AnalyticsTab.exams
            : AnalyticsTab.general,
      );

  @override
  Widget builder(
    BuildContext context,
    AnalyticsViewModel viewModel,
    Widget? child,
  ) => _AnalyticsPage(viewModel: viewModel);
}

/// The page: the scroll view with its controller. The controller belongs to
/// the widget (a ViewModel holds none): it asks for the next page near the
/// end of the Denemelerim list and gives each tab back its scroll position.
class _AnalyticsPage extends StatefulWidget {
  const _AnalyticsPage({required this.viewModel});

  final AnalyticsViewModel viewModel;

  @override
  State<_AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<_AnalyticsPage> {
  final ScrollController _scroll = ScrollController();
  final Map<AnalyticsTab, double> _offsets = {};
  late AnalyticsTab _shown = widget.viewModel.tab;

  /// How close to the end of the list the next page is asked for.
  static const double _loadAhead = 400;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    widget.viewModel.tabChanges.addListener(_onTab);
  }

  @override
  void dispose() {
    widget.viewModel.tabChanges.removeListener(_onTab);
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_shown != AnalyticsTab.exams || !_scroll.hasClients) return;
    if (_scroll.position.extentAfter < _loadAhead) {
      unawaited(widget.viewModel.loadMore());
    }
  }

  /// Remembers where the tab that is leaving was, and puts the new one back
  /// where it was left (the first visit starts at the top).
  void _onTab() {
    if (_scroll.hasClients) _offsets[_shown] = _scroll.offset;
    _shown = widget.viewModel.tabChanges.value;
    final target = _offsets[_shown] ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.jumpTo(target.clamp(0, _scroll.position.maxScrollExtent));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          const _AnalyticsBand(),
          const _AnalyticsBody(),
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

/// A row opens the exam's detail on this tab's stack (pano 6.2 → 5.3; a
/// coach's [student] goes along: the detail shows the context strip, pano
/// 10.4 kare 4).
void _openExam(BuildContext context, ExamDetail exam, {StudentRef? student}) =>
    unawaited(
      context.router.push(
        ExamDetailRoute(examId: exam.id, exam: exam, student: student),
      ),
    );

/// The Genel sections as one sliver (a coach's profile, pano 10.4 kare 1);
/// needs an `AnalyticsViewModel` above it (`StudentAnalyticsView`).
class AnalyticsGeneralSliver extends StatelessWidget {
  const AnalyticsGeneralSliver({super.key});

  @override
  Widget build(BuildContext context) => const _GeneralBody();
}

/// The Denemelerim sections as one sliver (pano 10.4 kare 2); loads the list
/// the first time it is built.
class AnalyticsExamsSliver extends StatefulWidget {
  const AnalyticsExamsSliver({super.key});

  @override
  State<AnalyticsExamsSliver> createState() => _AnalyticsExamsSliverState();
}

class _AnalyticsExamsSliverState extends State<AnalyticsExamsSliver> {
  @override
  void initState() {
    super.initState();
    // The load notifies at once: not while the tree is building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final model = getParentViewModel<AnalyticsViewModel>(
        context,
        listen: false,
      );
      unawaited(model.loadExams());
    });
  }

  @override
  Widget build(BuildContext context) => const _ExamsBody();
}

/// "TYT denemesi" for an exam the server did not name (pano 6.2).
String _examTitle(AppLocalizations l10n, String? name, NetExamType? type) {
  final trimmed = name?.trim();
  if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  return l10n.analytics_examUntitled(type?.label ?? '').trim();
}
