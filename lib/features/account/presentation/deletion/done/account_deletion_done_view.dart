import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/presentation/deletion/done/account_deletion_done_viewmodel.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/session_manager.dart';
import 'package:smap/shared/ui/feedback/app_status_view.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';

/// Hesabın silindi (pano 9.4 kare 5 "Silindi"; flow 13.10; route
/// `/account/delete/done`, on the root stack: no bottom bar).
///
/// The green circle with the check (96 pt), "Hesabın silindi", "Verilerin
/// silindi. İstersen yeni bir hesapla yeniden başlayabilirsin." and the
/// primary "Tamam". No back button and the system back does nothing. "Tamam"
/// ends the session on the device and the app lands on "Hoş geldin"; there is
/// no haptic.
@RoutePage()
class AccountDeletionDoneView
    extends StackedView<AccountDeletionDoneViewModel> {
  const AccountDeletionDoneView({super.key});

  @override
  bool get reactive => false;

  @override
  AccountDeletionDoneViewModel viewModelBuilder(BuildContext context) =>
      AccountDeletionDoneViewModel(session: locator<SessionManager>());

  @override
  Widget builder(
    BuildContext context,
    AccountDeletionDoneViewModel viewModel,
    Widget? child,
  ) {
    final l10n = AppLocalizations.of(context);
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.bar,
      child: Scaffold(
        backgroundColor: context.appColors.bgCanvas,
        body: AppStatusView(
          title: l10n.deletion_doneTitle,
          message: l10n.deletion_doneBody,
          icon: PhosphorIconsRegular.checkCircle,
          tone: AppStatusTone.success,
          smallTitle: true,
          blocking: true,
          primary: AppStatusAction(
            label: l10n.common_ok,
            onPressed: viewModel.finish,
          ),
        ),
      ),
    );
  }
}
