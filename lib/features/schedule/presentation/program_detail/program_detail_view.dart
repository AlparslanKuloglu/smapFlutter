import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/config/feature_flags.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/legacy/legacy_links_e7.dart';
import 'package:smap/features/schedule/application/program_detail.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/program_span.dart';
import 'package:smap/features/schedule/application/program_view_preference.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/presentation/program_detail/program_detail_viewmodel.dart';
import 'package:smap/features/schedule/presentation/program_navigator.dart';
import 'package:smap/features/schedule/presentation/sheets/sheet_program_dialogs.dart';
import 'package:smap/features/schedule/presentation/widgets/program_item_row.dart';
import 'package:smap/features/schedule/presentation/widgets/week_grid.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_bar_action.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';
import 'package:smap/shared/ui/pickers/app_day_chip.dart';
import 'package:smap/shared/ui/pickers/calendar_math.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

part 'widgets/program_detail_header.dart';
part 'widgets/program_detail_actions.dart';
part 'widgets/program_detail_day.dart';
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
@RoutePage()
class ProgramDetailView extends StackedView<ProgramDetailViewModel> {
  const ProgramDetailView({
    @PathParam('programId') required this.programId,
    @QueryParam('view') this.view,
    @QueryParam('date') this.date,
    super.key,
  });

  /// The program's id.
  final String programId;

  /// `day` or `week`; the remembered choice when absent.
  final String? view;

  /// `yyyy-MM-dd`: the day to open on.
  final String? date;

  @override
  bool get reactive => false;

  @override
  ProgramDetailViewModel viewModelBuilder(BuildContext context) {
    final schedule = locator<ScheduleService>();
    return ProgramDetailViewModel(
      programId: programId,
      schedule: schedule,
      toast: locator<ToastService>(),
      dialogs: SheetProgramDialogs(
        l10n: AppLocalizations.of(context),
        schedule: schedule,
      ),
      navigator: RouterProgramNavigator(context.router),
      online: locator<ConnectivityService>().online,
      preference: ProgramViewPreference(locator<DevicePreferences>()),
      requestedDay: _parseDay(date),
      requestedMode: ProgramViewMode.parse(view),
    );
  }

  @override
  void onViewModelReady(ProgramDetailViewModel viewModel) => viewModel.load();

  @override
  Widget builder(
    BuildContext context,
    ProgramDetailViewModel viewModel,
    Widget? child,
  ) => const _ProgramDetailPage();
}

/// `yyyy-MM-dd` as a calendar day; `null` for anything else.
DateTime? _parseDay(String? text) {
  if (text == null) return null;
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text.trim());
  if (match == null) return null;
  final day = DateTime(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
  return day.month == int.parse(match.group(2)!) ? day : null;
}

/// Opens the topic detail of [entry] (pano 3.4 "Bloğa ya da satıra dokununca
/// konu detayı", pano 7.3).
void _openTopic(BuildContext context, ProgramEntry entry) {
  final subject = entry.mainSubjectId;
  if (subject == null || subject.isEmpty) return;
  LegacyLinksE7.openTopicDetail(
    context,
    mainSubjectId: subject,
    topicName: entry.title,
  );
}

typedef _ModeData = ({SectionState state, ProgramViewMode mode});

/// The page: one scroll view; each slice decides by the state and the view
/// whether it draws.
class _ProgramDetailPage extends StatelessWidget {
  const _ProgramDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: const CustomScrollView(
        slivers: [
          _DetailBar(),
          _DetailHeader(),
          _DetailSegment(),
          _DetailLoading(),
          _DetailError(),
          _DayStrip(),
          _DayHeading(),
          _DayList(),
          _DayActions(),
          _WeekSection(),
          _BottomSpace(),
        ],
      ),
    );
  }
}

/// Room under the day view for the bottom bar.
class _BottomSpace
    extends SelectorViewModelWidget<ProgramDetailViewModel, ProgramViewMode> {
  const _BottomSpace();

  @override
  ProgramViewMode selector(ProgramDetailViewModel viewModel) => viewModel.mode;

  @override
  Widget build(BuildContext context, ProgramViewMode mode) {
    if (mode == ProgramViewMode.week) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: SizedBox(height: AppBottomBar.heightOf(context) + AppSpacing.s24),
    );
  }
}
