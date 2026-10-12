import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/presentation/deletion/deletion_navigator.dart';
import 'package:smap/features/account/presentation/deletion/progress/account_deletion_progress_viewmodel.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/feedback/app_status_view.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';

/// Hesabın siliniyor (pano 9.4 kare 4 "Siliniyor"; flow 13.10; route
/// `/account/delete/progress`, on the root stack: no bottom bar).
///
/// A 48 pt spinner, "Hesabın siliniyor" and "Uygulamayı kapatma." in the
/// middle of the screen, no button, and the back gesture and the Android back
/// button closed (`AppStatusView.busy` is blocking). The call is made as the
/// screen opens; the screen then moves on by itself (to "Hesabın silindi") or
/// goes back to the explanation with `false`. Motion is the same under
/// "reduce motion" (spec 11.15: "hareketi azalt açıkken de aynı"); there is no
/// haptic.
@RoutePage()
class AccountDeletionProgressView
    extends StackedView<AccountDeletionProgressViewModel> {
  const AccountDeletionProgressView({super.key});

  @override
  bool get reactive => false;

  @override
  AccountDeletionProgressViewModel viewModelBuilder(BuildContext context) =>
      AccountDeletionProgressViewModel(
        account: locator<AccountRepository>(),
        navigator: RouterAccountDeletionProgressNavigator(context.router),
      );

  @override
  void onViewModelReady(AccountDeletionProgressViewModel viewModel) =>
      viewModel.start();

  @override
  Widget builder(
    BuildContext context,
    AccountDeletionProgressViewModel viewModel,
    Widget? child,
  ) {
    final l10n = AppLocalizations.of(context);
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.bar,
      child: Scaffold(
        backgroundColor: context.appColors.bgCanvas,
        body: AppStatusView.busy(
          title: l10n.deletion_progressTitle,
          message: l10n.deletion_progressBody,
        ),
      ),
    );
  }
}
