import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/application/deletion_consequences.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/presentation/deletion/account_deletion_viewmodel.dart';
import 'package:smap/features/account/presentation/deletion/deletion_dialogs.dart';
import 'package:smap/features/account/presentation/deletion/deletion_navigator.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/features/account/presentation/account_bar_clearance.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';
import 'package:smap/shared/ui/surfaces/app_notice_box.dart';

part 'widgets/deletion_actions.dart';
part 'widgets/deletion_list.dart';

/// Hesabını sil (pano 9.4 kare 2 "Açıklama", kare 3 "Tehlikeli onay"; flow
/// 13.10; spec §4.C 9.4; route `/account/delete`).
///
/// The back button, the title "Hesabını sil", "Hesabını silersen:" with the
/// list of what is lost (each line with a red X), the line "Yalnız bir süre
/// ara vermek istiyorsan çıkış yapman yeterli; verilerin hesabında kalır.",
/// and the two buttons pinned above the bottom bar: the red "Hesabımı Sil"
/// and "Vazgeç". "Hesabımı Sil" asks "Hesabın silinsin mi?" in the dangerous
/// confirm sheet; on "Hesabımı Sil" there the full-screen "Hesabın
/// siliniyor" opens (`AccountDeletionProgressView`), then "Hesabın silindi"
/// (`AccountDeletionDoneView`).
///
/// The entry is the red "Hesabı Sil" at the bottom of Profil (kare 1; E14a);
/// it is not in the Hesap list, so nobody taps it by accident.
@RoutePage()
class AccountDeletionView extends StackedView<AccountDeletionViewModel> {
  const AccountDeletionView({super.key});

  @override
  bool get reactive => false;

  @override
  AccountDeletionViewModel viewModelBuilder(BuildContext context) =>
      AccountDeletionViewModel(
        currentUser: locator<CurrentUserService>(),
        account: locator<AccountRepository>(),
        dialogs: SheetAccountDeletionDialogs(
          l10n: AppLocalizations.of(context),
        ),
        navigator: RouterAccountDeletionNavigator(context.router),
      );

  @override
  void onViewModelReady(AccountDeletionViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    AccountDeletionViewModel viewModel,
    Widget? child,
  ) => const _AccountDeletionPage();
}

/// The page: the scrolling explanation and, under it, the two buttons that
/// stay above the bottom bar.
class _AccountDeletionPage extends StatelessWidget {
  const _AccountDeletionPage();

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context).deletion_title;
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                AppDetailBar(title: title),
                LargeTitleSliver(title: title),
                const _DeletionFailureSliver(),
                const _DeletionListSliver(),
              ],
            ),
          ),
          const _DeletionActions(),
        ],
      ),
    );
  }
}
