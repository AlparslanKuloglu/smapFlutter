import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/startup/application/store_launcher.dart';
import 'package:smap/features/startup/presentation/unknown_role/unknown_role_viewmodel.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/session_manager.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_status_view.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';

/// "Hesabın açılamadı" (pano 2.7 kare 4).
///
/// A 96 pt `errorBg` circle with a warning icon, "Hesap türün tanınmadı.
/// Çıkış yapıp yeniden giriş yapmayı dene; sorun sürerse bize yaz." (no raw
/// error, no code), a primary "Yeniden Giriş Yap" and a text "Destek'e Yaz"
/// that opens a mail draft (shown only when a support address is configured).
@RoutePage()
class UnknownRoleView extends StackedView<UnknownRoleViewModel> {
  const UnknownRoleView({super.key});

  @override
  bool get reactive => false;

  @override
  UnknownRoleViewModel viewModelBuilder(BuildContext context) =>
      UnknownRoleViewModel(
        session: locator<SessionManager>(),
        launcher: locator<StoreLauncher>(),
      );

  @override
  Widget builder(
    BuildContext context,
    UnknownRoleViewModel viewModel,
    Widget? child,
  ) {
    final l10n = AppLocalizations.of(context);
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.bar,
      child: Material(
        color: context.appColors.bgCanvas,
        child: AppStatusView(
          title: l10n.startup_unknownRoleTitle,
          message: l10n.startup_unknownRoleBody,
          icon: PhosphorIconsRegular.warningCircle,
          tone: AppStatusTone.error,
          primary: AppStatusAction(
            label: l10n.startup_unknownRoleReLogin,
            onPressed: viewModel.signInAgain,
          ),
          secondary: viewModel.canWriteSupport
              ? AppStatusAction(
                  label: l10n.startup_unknownRoleContact,
                  variant: AppButtonVariant.text,
                  onPressed: viewModel.writeSupport,
                )
              : null,
        ),
      ),
    );
  }
}
