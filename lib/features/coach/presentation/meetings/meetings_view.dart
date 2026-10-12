import 'dart:async';

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
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/application/meeting_models.dart';
import 'package:smap/features/coach/data/interview_repository.dart';
import 'package:smap/features/coach/domain/interview_type.dart';
import 'package:smap/features/coach/presentation/meetings/meetings_viewmodel.dart';
import 'package:smap/features/coach/presentation/meetings/sheet_meetings_dialogs.dart';
import 'package:smap/features/coach/presentation/meetings/stack_meetings_navigator.dart';
import 'package:smap/features/home/application/avatar_asset.dart';
import 'package:smap/gen/assets.gen.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/controls/app_chip.dart';
import 'package:smap/shared/ui/controls/app_chip_group.dart';
import 'package:smap/shared/ui/feedback/app_empty_state.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';
import 'package:smap/shared/ui/indicators/app_spinner.dart';
import 'package:smap/shared/ui/inputs/app_search_field.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_root_band.dart';
import 'package:smap/shared/ui/navigation/band_math.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/surfaces/app_row.dart';
import 'package:smap/shared/ui/surfaces/app_row_group.dart';

part 'widgets/meetings_band.dart';
part 'widgets/meetings_controls.dart';
part 'widgets/meetings_list.dart';
part 'widgets/meetings_states.dart';

/// Görüşmelerim, the root of the coach's Görüşmelerim tab (pano 10.5 "Görüşmelerim ·
/// 4 kare"; spec §4.C 10.5; route `/coach/meetings`; flow 13.11).
///
/// The navy band "Görüşmelerim" with the Plus ("Yeni görüşme"), the search
/// field "Görüşme ara", the "Kiminle" chips "Tümü · Öğrenci · Veli" and the
/// meetings in two groups: "Yaklaşan · 2" (nearest first) and the past ones
/// (newest first). A row opens Görüşme Detayı. With no meeting at all the
/// screen is the empty state "Henüz görüşme yok" with "Yeni Görüşme" (kare 4:
/// no search, no chips). Each part has its skeleton, empty, error and offline
/// state; the first load is bounded by 15 s.
///
/// The search runs on the loaded pages (the server has no search parameter,
/// spec §6.3 #31); the "Kiminle" choice goes to the server as a filter.
@RoutePage()
class MeetingsView extends StackedView<MeetingsViewModel> {
  const MeetingsView({super.key});

  @override
  bool get reactive => false;

  @override
  void onViewModelReady(MeetingsViewModel viewModel) => viewModel.init();

  @override
  MeetingsViewModel viewModelBuilder(BuildContext context) => MeetingsViewModel(
    interviews: locator<InterviewRepository>(),
    navigator: StackMeetingsNavigator(context.router),
    dialogs: SheetMeetingsDialogs(l10n: AppLocalizations.of(context)),
    toast: locator<ToastService>(),
    online: locator<ConnectivityService>().online,
    // The shell preview (no account) has no session scope.
    students: locator.isRegistered<CoachStudentsService>()
        ? locator<CoachStudentsService>()
        : null,
  );

  @override
  Widget builder(
    BuildContext context,
    MeetingsViewModel viewModel,
    Widget? child,
  ) => _MeetingsPage(viewModel: viewModel);
}

/// The page: the scroll view and the search controller. The controller
/// belongs to the widget (a ViewModel holds none) and is cleared by "Aramayı
/// Temizle". The next page is asked for whenever the end of the list is near,
/// also when the loaded rows do not fill the screen (a search or a choice
/// keeps few of them): the scroll metrics say so even without a scroll.
class _MeetingsPage extends StatefulWidget {
  const _MeetingsPage({required this.viewModel});

  final MeetingsViewModel viewModel;

  @override
  State<_MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<_MeetingsPage> {
  final TextEditingController _search = TextEditingController();

  /// How close to the end of the list the next page is asked for.
  static const double _loadAhead = 400;

  @override
  void initState() {
    super.initState();
    widget.viewModel.searchCleared.addListener(_onSearchCleared);
  }

  @override
  void dispose() {
    widget.viewModel.searchCleared.removeListener(_onSearchCleared);
    _search.dispose();
    super.dispose();
  }

  void _onSearchCleared() => _search.clear();

  bool _onMetrics(ScrollMetrics metrics) {
    if (metrics.extentAfter < _loadAhead) {
      unawaited(widget.viewModel.loadMore());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final collapsedBand = RootBandMetrics(
      safeTop: media.padding.top,
      textScaler: media.textScaler,
    ).minExtent;
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: NotificationListener<ScrollMetricsNotification>(
        onNotification: (notification) => _onMetrics(notification.metrics),
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (notification) => _onMetrics(notification.metrics),
          child: RefreshIndicator(
            edgeOffset: collapsedBand,
            onRefresh: widget.viewModel.refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const _MeetingsBand(),
                _MeetingsControls(search: _search),
                const _MeetingsListSection(),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: AppBottomBar.heightOf(context) + AppSpacing.s16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
