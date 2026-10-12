import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/startup/application/startup_gate.dart';
import 'package:smap/features/startup/presentation/maintenance/maintenance_viewmodel.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_status_view.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';

/// "SMAP şu an bakımda" (pano 2.7 kare 3).
///
/// A 96 pt `infoBg` circle with a wrench, the title, "Kısa süre içinde geri
/// döneceğiz. Verilerin güvende; bakım bitince kaldığın yerden devam
/// edersin." (no time promise) and a quiet "Tekrar Dene". The app also tries
/// again when it returns to the front. The back gesture does nothing.
@RoutePage()
class MaintenanceView extends StackedView<MaintenanceViewModel> {
  const MaintenanceView({super.key});

  @override
  bool get reactive => false;

  @override
  MaintenanceViewModel viewModelBuilder(BuildContext context) =>
      MaintenanceViewModel(
        router: locator<AppRouter>(),
        gate: locator<StartupGate>(),
      );

  @override
  void onViewModelReady(MaintenanceViewModel viewModel) => viewModel.attach();

  @override
  Widget builder(
    BuildContext context,
    MaintenanceViewModel viewModel,
    Widget? child,
  ) {
    final l10n = AppLocalizations.of(context);
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.bar,
      child: ValueListenableBuilder<bool>(
        valueListenable: viewModel.checking,
        builder: (context, checking, _) => AppStatusView(
          title: l10n.startup_maintenanceTitle,
          message: l10n.startup_maintenanceBody,
          icon: PhosphorIconsRegular.wrench,
          blocking: true,
          primary: AppStatusAction(
            label: l10n.common_retry,
            variant: AppButtonVariant.quiet,
            loading: checking,
            onPressed: viewModel.retry,
          ),
        ),
      ),
    );
  }
}
