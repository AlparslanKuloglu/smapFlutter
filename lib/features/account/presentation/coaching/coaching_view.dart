import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/application/coaching_logic.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/presentation/coaching/coaching_dialogs.dart';
import 'package:smap/features/account/presentation/coaching/coaching_viewmodel.dart';
import 'package:smap/features/home/application/avatar_asset.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';
import 'package:smap/shared/ui/inputs/app_text_field.dart';
import 'package:smap/shared/ui/inputs/input_masks.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';
import 'package:smap/shared/ui/surfaces/app_notice_box.dart';

part 'widgets/coaching_linked.dart';
part 'widgets/coaching_states.dart';
part 'widgets/coaching_unlinked.dart';

/// Koçluk (pano 9.5 "Koçluk · 4 kare", Tur 12 F; flow 13.10; spec §4.C 9.5;
/// route `/account/coaching`; student only).
///
/// **Koçun var** (kare 1): the coach card (avatar 64, name, "Koçun"), the
/// info box "Mehmet Özkan denemelerini, analizlerini ve programını
/// görebilir.", the text button "Koçunu Değiştir" (Tur 12 F) and the red text
/// button "Bağlantıyı Kaldır", which asks "Koç bağlantısı kaldırılsın mı?"
/// (kare 2). **Koçun yok** (kare 3): "Koçunun verdiği kodu gir; ..." with the
/// masked field "Koçluk kodu" (`AAAA-0000`), the primary "Koça Bağlan" and
/// "Koçluk Kodu Nedir?", which opens the explanation sheet (kare 4).
///
/// The card's "Sıradaki görüşme" line is not drawn: no endpoint tells the
/// student's next meeting (spec "kaynağı belirtilmemiş").
@RoutePage()
class CoachingView extends StackedView<CoachingViewModel> {
  const CoachingView({super.key});

  @override
  bool get reactive => false;

  @override
  CoachingViewModel viewModelBuilder(BuildContext context) => CoachingViewModel(
    account: locator<AccountRepository>(),
    currentUser: locator<CurrentUserService>(),
    dialogs: SheetCoachingDialogs(l10n: AppLocalizations.of(context)),
    toast: locator<ToastService>(),
    online: locator<ConnectivityService>().online,
  );

  @override
  void onViewModelReady(CoachingViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    CoachingViewModel viewModel,
    Widget? child,
  ) => const _CoachingPage();
}

/// The page: the bar, the title and the state's content in one
/// `CustomScrollView`; the tab runs under the bottom bar.
class _CoachingPage extends StatelessWidget {
  const _CoachingPage();

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context).coaching_title;
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          AppDetailBar(title: title),
          LargeTitleSliver(title: title),
          const _CoachingContent(),
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

/// Chooses what the page shows for the load's state: the skeleton, "Koçun
/// var", "Koçun yok" or the error (an offline load reads as the error too,
/// with the same "Tekrar Dene").
class _CoachingContent
    extends SelectorViewModelWidget<CoachingViewModel, SectionState> {
  const _CoachingContent();

  @override
  SectionState selector(CoachingViewModel viewModel) => viewModel.state;

  @override
  Widget build(BuildContext context, SectionState state) => switch (state) {
    SectionState.loading => const _CoachingSkeleton(),
    SectionState.ready => const _LinkedSection(),
    SectionState.empty => const _UnlinkedSection(),
    SectionState.error || SectionState.offline => const _CoachingError(),
  };
}
