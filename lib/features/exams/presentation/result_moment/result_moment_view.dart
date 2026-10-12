import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/config/feature_flags.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/presentation/notification_primer/notification_primer.dart';
import 'package:smap/features/exams/presentation/notification_primer/notification_primer_sheet.dart';
import 'package:smap/features/exams/presentation/result_moment/result_moment_model.dart';
import 'package:smap/features/exams/presentation/result_moment/result_moment_viewmodel.dart';
import 'package:smap/features/exams/presentation/result_moment/stack_result_moment_navigator.dart';
import 'package:smap/features/exams/presentation/widgets/exam_header.dart';
import 'package:smap/features/exams/presentation/widgets/exam_test_name.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/indicators/app_stat_box.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

part 'widgets/result_moment_actions.dart';
part 'widgets/result_moment_cards.dart';
part 'widgets/result_moment_header.dart';
part 'widgets/result_moment_scores.dart';
part 'widgets/result_moment_states.dart';

/// Sonuç Anı (pano 5.1, three frames: AYT, TYT with missing data, AYT dark;
/// spec §4.D 5.1; route `/scan/result/:examId`, a root page above the shell, no
/// bottom bar; flow 13.4 step 14).
///
/// Right after a read: the close button, the exam's identity (the 56 x 76
/// cover, publisher, name, type and date), the net at metric-xl with the
/// change against the previous exam of the type, the large D/Y/B counter,
/// then, when the data has them, the "Puan türü" segment with the placement
/// score and rank, the field's net, and the row "Bu denemeden 23 bilgi kartı
/// eklendi"; pinned at the bottom the quiet "Anasayfa" and the one primary
/// "Detaylı Analiz". A field the data does not have is not drawn, never a
/// zero or a dash (frame 2). The content rises 8 pt while fading in; the
/// success haptic plays once; no confetti, no spinning number.
///
/// Leaving first offers the notification permission sheet once (pano 5.2,
/// closed while `FeatureFlags.notificationsEnabled` is off), then closes the
/// camera flow and opens the destination: Deneme Detay on the Analizlerim
/// stack, or Anasayfa. The system Back does what the close button does.
///
/// The old three-step result flow (`omd_result_flow_view.dart`) goes with
/// the scan task's own cleanup.
@RoutePage()
class ResultMomentView extends StackedView<ResultMomentViewModel> {
  const ResultMomentView({
    @PathParam('examId') required this.examId,
    super.key,
  });

  /// The result's id (what `answerArray` named `mexamFound`).
  final String examId;

  @override
  bool get reactive => false;

  @override
  ResultMomentViewModel viewModelBuilder(BuildContext context) =>
      ResultMomentViewModel(
        examId: examId,
        exams: locator<ExamRepository>(),
        navigator: StackResultMomentNavigator(context.router),
        primer: NotificationPrimer(
          enabled: FeatureFlags.notificationsEnabled,
          flag: PreferencesNotificationPrimerFlag(locator<DevicePreferences>()),
          presenter: const SheetNotificationPrimerPresenter(),
        ),
        cdnBaseUrl: locator<AppConfig>().cdnBaseUrl,
        userField: locator.isRegistered<CurrentUserService>()
            ? AytField.fromWire(locator<CurrentUserService>().user?.aimType)
            : null,
      );

  @override
  void onViewModelReady(ResultMomentViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    ResultMomentViewModel viewModel,
    Widget? child,
  ) => const _ResultMomentPage();
}

/// The page: the scrolling moment and, under it, the two buttons that stay
/// at the bottom (pano 5.1 "Eylem satırı, alta sabit"). The system Back
/// leaves like the close button does.
class _ResultMomentPage extends StatelessWidget {
  const _ResultMomentPage();

  @override
  Widget build(BuildContext context) {
    final viewModel = getParentViewModel<ResultMomentViewModel>(
      context,
      listen: false,
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) viewModel.openHome();
      },
      child: Scaffold(
        backgroundColor: context.appColors.bgCanvas,
        body: const Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  _MomentBar(),
                  _MomentHeaderSection(),
                  _MomentScoresSection(),
                  _MomentCardsSection(),
                  _MomentErrorSection(),
                ],
              ),
            ),
            _MomentActions(),
          ],
        ),
      ),
    );
  }
}

/// An empty sliver: a section that is not showing.
const Widget _noSliver = SliverToBoxAdapter(child: SizedBox.shrink());

/// The name of the exam as the screen writes it: the server's, else "AYT
/// denemesi" (pano 6.2).
String _momentTitle(BuildContext context, ResultMomentModel model) =>
    model.name ??
    AppLocalizations.of(context).analytics_examUntitled(model.typeLabel);

/// The name of an AYT score type ("Eşit Ağırlık").
String _fieldName(AppLocalizations l10n, AytField field) => switch (field) {
  AytField.equalWeight => l10n.analytics_fieldEqualWeight,
  AytField.numeric => l10n.analytics_fieldNumeric,
  AytField.verbal => l10n.analytics_fieldVerbal,
};
