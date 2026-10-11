import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/startup/application/launch_handover.dart';
import 'package:smap/features/startup/application/startup_gate.dart';
import 'package:smap/features/startup/presentation/startup/startup_viewmodel.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/session_manager.dart';
import 'package:smap/shared/ui/identity/app_logo.dart';
import 'package:smap/shared/ui/indicators/app_spinner.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';

/// The launch screen (pano 2.1 kare 1; spec §4.A "2.1-1 Açılış").
///
/// Navy full screen with the vertical lockup (S-route mark with the white top
/// hook, "SMAP" under it), the same picture as the native splash, so the
/// hand-over has no seam. When opening takes longer than a second a 24 pt white
/// spinner appears 32 pt under the lockup. Once the session is decided the
/// router replaces this screen (250 ms fade, set on the target routes).
@RoutePage()
class StartupView extends StackedView<StartupViewModel> {
  const StartupView({super.key});

  @override
  bool get reactive => false;

  @override
  StartupViewModel viewModelBuilder(BuildContext context) => StartupViewModel(
    router: locator<AppRouter>(),
    session: locator<SessionManager>(),
    preferences: locator<DevicePreferences>(),
    gate: locator<StartupGate>(),
    handover: locator<LaunchHandover>(),
  );

  @override
  void onViewModelReady(StartupViewModel viewModel) =>
      viewModel.start().ignore();

  @override
  Widget builder(
    BuildContext context,
    StartupViewModel viewModel,
    Widget? child,
  ) {
    final colors = context.appColors;
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.band,
      child: ColoredBox(
        color: colors.bgNavy,
        child: Center(
          child: _LockupWithSpinner(visible: viewModel.showSpinner),
        ),
      ),
    );
  }
}

/// The lockup, centered exactly like the native splash image, with the
/// spinner below it. The spinner's room is reserved on both sides of the
/// lockup so showing it does not move the lockup.
class _LockupWithSpinner extends StatelessWidget {
  const _LockupWithSpinner({required this.visible});

  final ValueListenable<bool> visible;

  /// Gap between the lockup and the spinner (spec "32 altta").
  static const double _gap = AppSpacing.s32;
  static const double _spinner = 24;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    const reserved = _gap + _spinner;
    return SizedBox(
      height: AppLockup.verticalHeight + 2 * reserved,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const AppLockup(layout: AppLockupLayout.vertical, onNavy: true),
          Align(
            alignment: Alignment.bottomCenter,
            child: ValueListenableBuilder<bool>(
              valueListenable: visible,
              builder: (context, show, _) => AnimatedOpacity(
                opacity: show ? 1 : 0,
                duration: context.motion(
                  AppMotion.base,
                  reduced: AppMotion.reducedFade,
                ),
                child: show
                    ? AppSpinner(
                        color: colors.textOnNavy,
                        trackColor: colors.textOnNavy.withValues(alpha: 0.24),
                        semanticLabel: l10n.startup_loadingLabel,
                      )
                    : const SizedBox.square(dimension: _spinner),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
