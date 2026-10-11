import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/startup/application/store_launcher.dart';
import 'package:smap/features/startup/presentation/force_update/force_update_viewmodel.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/feedback/app_status_view.dart';
import 'package:smap/shared/ui/identity/app_logo.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';

/// "Yeni sürüm gerekli" (pano 2.7 kare 1; spec §4.A "2.7 Genel ekranlar").
///
/// Opens at launch when the version is not supported
/// (`StartupGate`, closed until the backend has a public config). A 96 pt
/// navy app icon (radius 21,5), the title "Yeni sürüm gerekli", the sentence
/// "Bu sürüm artık desteklenmiyor. Devam etmek için SMAP'i güncelle; verilerin
/// hesabında duruyor." and one primary "Güncelle" that opens the store. The
/// back gesture and the Android back button do nothing.
@RoutePage()
class ForceUpdateView extends StackedView<ForceUpdateViewModel> {
  const ForceUpdateView({super.key});

  @override
  bool get reactive => false;

  @override
  ForceUpdateViewModel viewModelBuilder(BuildContext context) =>
      ForceUpdateViewModel(launcher: locator<StoreLauncher>());

  @override
  Widget builder(
    BuildContext context,
    ForceUpdateViewModel viewModel,
    Widget? child,
  ) {
    final l10n = AppLocalizations.of(context);
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.bar,
      child: AppStatusView(
        title: l10n.startup_forceUpdateTitle,
        message: l10n.startup_forceUpdateBody,
        leading: const _AppIcon(),
        blocking: true,
        primary: AppStatusAction(
          label: l10n.startup_forceUpdateAction,
          onPressed: viewModel.update,
        ),
      ),
    );
  }
}

/// The app icon (board 1.26 "lacivert pafta"): the white-hook mark on navy.
class _AppIcon extends StatelessWidget {
  const _AppIcon();

  /// Corner radius of the 96 pt icon (spec 2.7 kare 1: "radius 21,5").
  static const double _radius = 21.5;

  /// Height of the mark inside the tile.
  static const double _mark = 56;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.startup_appIconLabel,
      image: true,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.appColors.bgNavy,
          borderRadius: const BorderRadius.all(Radius.circular(_radius)),
        ),
        child: const Center(
          child: AppLogoMark(
            height: _mark,
            tone: AppLogoTone.onNavy,
            decorative: true,
          ),
        ),
      ),
    );
  }
}
