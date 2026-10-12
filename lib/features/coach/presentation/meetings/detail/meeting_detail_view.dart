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
import 'package:smap/features/coach/application/interview_locator.dart';
import 'package:smap/features/coach/application/meeting_models.dart';
import 'package:smap/features/coach/data/interview_repository.dart';
import 'package:smap/features/coach/domain/interview_type.dart';
import 'package:smap/features/coach/presentation/meetings/detail/meeting_detail_viewmodel.dart';
import 'package:smap/features/coach/presentation/meetings/sheet_meetings_dialogs.dart';
import 'package:smap/features/coach/presentation/meetings/stack_meetings_navigator.dart';
import 'package:smap/features/home/application/avatar_asset.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_empty_state.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';
import 'package:smap/shared/ui/surfaces/app_row.dart';
import 'package:smap/shared/ui/surfaces/app_row_group.dart';
import 'package:smap/shared/ui/text/section_header.dart';

// The route argument's type, visible to the router file that imports this
// view (auto_route's generated `MeetingDetailRoute` names it).
export 'package:smap/features/coach/application/meeting_models.dart'
    show MeetingEntry;

part 'widgets/meeting_detail_header.dart';
part 'widgets/meeting_detail_notes.dart';
part 'widgets/meeting_detail_states.dart';

/// The gap between the header and the card, and the card and "Notlar" (pano
/// 10.5 kare 3: "aralık 20", then the section gap).
const double _blockGap = 20;
const double _sectionGap = AppSpacing.s24;

/// Görüşme Detayı (pano 10.5 kare 3 and 10.6; spec §4.C 10.5; route
/// `/coach/meetings/:meetingId`; flow 13.11).
///
/// The bar with Back, then the student's avatar, name and "Öğrenci görüşmesi"
/// (or "Veli görüşmesi"), one card with the day and the time and the row
/// "Öğrencinin verileri · Analiz, denemeler, program", and "Notlar" with
/// "Not Ekle": one card per note with "Düzenle" and "Sil" (kare 10.6), or
/// "Henüz not yok." The bar's "Düzenle" of the board is not drawn: the server
/// has no call to edit or delete a meeting (spec §6.3 #31).
///
/// [meeting] is what the list knew: the header is drawn from it at once; a
/// link that carries only [meetingId] shows the skeleton until the meeting is
/// found. The notes are always read again before they are shown (they are
/// addressed by position).
@RoutePage()
class MeetingDetailView extends StackedView<MeetingDetailViewModel> {
  const MeetingDetailView({
    @PathParam('meetingId') required this.meetingId,
    this.meeting,
    super.key,
  });

  final String meetingId;

  /// The meeting as the list has it; `null` for a deep link.
  final MeetingEntry? meeting;

  @override
  bool get reactive => false;

  @override
  void onViewModelReady(MeetingDetailViewModel viewModel) => viewModel.init();

  @override
  MeetingDetailViewModel viewModelBuilder(BuildContext context) {
    final interviews = locator<InterviewRepository>();
    return MeetingDetailViewModel(
      meetingId: meetingId,
      meeting: meeting,
      interviews: interviews,
      locator: InterviewLocator(interviews),
      navigator: StackMeetingsNavigator(context.router),
      dialogs: SheetMeetingsDialogs(l10n: AppLocalizations.of(context)),
      toast: locator<ToastService>(),
      online: locator<ConnectivityService>().online,
    );
  }

  @override
  Widget builder(
    BuildContext context,
    MeetingDetailViewModel viewModel,
    Widget? child,
  ) => const _MeetingDetailPage();
}

/// The page: the bar and the screen's content in one `CustomScrollView`, with
/// the room under it for the bottom bar (the tab runs under it).
class _MeetingDetailPage extends StatelessWidget {
  const _MeetingDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        slivers: [
          const _DetailBar(),
          const _DetailBody(),
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
