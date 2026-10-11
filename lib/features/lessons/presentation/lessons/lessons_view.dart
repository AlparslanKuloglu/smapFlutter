import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;
import 'package:url_launcher/url_launcher.dart';

import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/cards/data/card_repository.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/lesson_rows.dart';
import 'package:smap/features/lessons/application/lesson_segments.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/presentation/lessons/lessons_viewmodel.dart';
import 'package:smap/features/lessons/presentation/lessons_navigator.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_row.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_root_band.dart';
import 'package:smap/shared/ui/surfaces/app_row_group.dart';

part 'widgets/lessons_band.dart';
part 'widgets/lessons_list.dart';
part 'widgets/lessons_states.dart';

/// Derslerim, the root of the Derslerim tab (pano 7.1 "Derslerim · 3 kare",
/// 7.5 kare 1 and 4; spec §4.F 7.1; route `/lessons`).
///
/// The navy band with the TYT / AYT segment under the title, then one card of
/// lesson rows (C20): glyph tile, name, the missing count, the card progress
/// where the deck is known, and for Matematik and Geometri "Web'de" with its
/// sheet. The choice of TYT or AYT is kept on the device and opens a lesson on
/// its own category. The offline strip is the shell's; offline the web-only
/// lessons are left out.
@RoutePage()
class LessonsView extends StackedView<LessonsViewModel> {
  const LessonsView({super.key});

  @override
  bool get reactive => false;

  @override
  LessonsViewModel viewModelBuilder(BuildContext context) => LessonsViewModel(
    lessons: locator<LessonsService>(),
    cards: locator<CardRepository>(),
    preferences: locator<DevicePreferences>(),
    online: locator<ConnectivityService>().online,
    webUri: Uri.parse(locator<AppConfig>().apiBaseUrl),
    navigator: StackLessonsNavigator(context.router),
    openUrl: (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
  );

  @override
  void onViewModelReady(LessonsViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    LessonsViewModel viewModel,
    Widget? child,
  ) => const _LessonsPage();
}

/// The page: the band, the list and the room under it for the bottom bar, in
/// one `CustomScrollView` (the tab runs under the bar).
class _LessonsPage extends StatelessWidget {
  const _LessonsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        slivers: [
          const _LessonsBand(),
          const _LessonsListSection(),
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
