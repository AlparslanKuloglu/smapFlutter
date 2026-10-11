import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/schedule/application/hour_range.dart';
import 'package:smap/features/schedule/application/new_program_summary.dart';
import 'package:smap/features/schedule/application/program_detail.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/presentation/new_program/new_program_viewmodel.dart';
import 'package:smap/features/schedule/presentation/program_navigator.dart';
import 'package:smap/features/schedule/presentation/sheets/sheet_program_dialogs.dart';
import 'package:smap/features/schedule/presentation/widgets/hour_slot.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/inputs/app_text_field.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';
import 'package:smap/shared/ui/pickers/app_calendar.dart';
import 'package:smap/shared/ui/pickers/app_day_chip.dart';
import 'package:smap/shared/ui/pickers/calendar_math.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

part 'widgets/new_program_frame.dart';
part 'widgets/new_program_days.dart';
part 'widgets/new_program_grid.dart';
part 'widgets/new_program_name.dart';

/// Yeni Program (pano 3.5 kare 1 to 4; flow 13.3): Günler → Izgara → Ad ve
/// motto.
///
/// A full screen on the root navigator (`/program/new`): no bottom bar, a
/// fixed band at the bottom with one primary button. One page with three
/// steps; "Adım N/3" at the right of the bar, X "Vazgeç" on the first step
/// and Back on the others. The system back goes one step back, and from the
/// first step asks "Program kaydedilmesin mi?" when something was entered.
/// Saving closes the flow with the new program's id (the list opens it).
///
/// The strings: step 1 "Hangi günler çalışacaksın?" with the calendar; step 2
/// "Konuları yerleştir" with the day chips and the hour slots; step 3
/// "Programına ad ver" with the name, the motto and the summary.
@RoutePage()
class NewProgramView extends StackedView<NewProgramViewModel> {
  const NewProgramView({super.key});

  @override
  bool get reactive => false;

  @override
  NewProgramViewModel viewModelBuilder(BuildContext context) {
    final schedule = locator<ScheduleService>();
    final l10n = AppLocalizations.of(context);
    return NewProgramViewModel(
      schedule: schedule,
      toast: locator<ToastService>(),
      dialogs: SheetProgramDialogs(l10n: l10n, schedule: schedule),
      navigator: RouterProgramNavigator(context.router),
      online: locator<ConnectivityService>().online,
      defaultName: (month, week) =>
          l10n.schedule_defaultName(month, TrFormat.sira(week)),
    );
  }

  @override
  Widget builder(
    BuildContext context,
    NewProgramViewModel viewModel,
    Widget? child,
  ) => const _NewProgramPage();
}

/// The page: the scroll view of the step and the band under it.
class _NewProgramPage extends StatelessWidget {
  const _NewProgramPage();

  @override
  Widget build(BuildContext context) {
    return const _BackGuard(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [_StepBar(), _StepContent()],
              ),
            ),
            _BottomBand(),
          ],
        ),
      ),
    );
  }
}
