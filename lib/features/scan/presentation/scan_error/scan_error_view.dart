import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/scan/application/scan_flow_state.dart';
import 'package:smap/features/scan/presentation/capture/scan_capture_dialogs.dart';
import 'package:smap/features/scan/presentation/scan_error/scan_error_viewmodel.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_actions.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_status_view.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';

/// The full-screen errors of the scan (pano 4.10 "Hata Ekranları · 4 kare";
/// flow 13.4; spec §4.C 4.10): the status pattern of board 1.22 with an 80 pt
/// badge, the title (24/32), one sentence that says why and what to do, and at
/// most two buttons, Kapat at the top left. They follow the theme. (The
/// camera failure is part of the camera stage, dark, and the maintenance note
/// is `OmrClosedSheet`.)
///
/// - [ScanErrorKind.formNotFound] "Formu bulamadık": an `errorBg` badge with a
///   WarningCircle, the primary "Yeni Fotoğraf" over the quiet "Nasıl
///   Çekilir?".
/// - [ScanErrorKind.offline] "Bağlantı yok": a `bgSunken` badge with a
///   WifiSlash, the primary "Tamam" over the quiet "Şimdi Tekrar Dene".
class ScanErrorView extends StackedView<ScanErrorViewModel> {
  const ScanErrorView({required this.kind, required this.actions, super.key});

  final ScanErrorKind kind;
  final ScanFlowActions actions;

  @override
  bool get reactive => false;

  @override
  ScanErrorViewModel viewModelBuilder(BuildContext context) =>
      ScanErrorViewModel(
        kind: kind,
        dialogs: const SheetScanCaptureDialogs(),
        actions: actions,
      );

  @override
  void onViewModelReady(ScanErrorViewModel viewModel) => viewModel.init();

  /// The badge sits 200 from the top of the board's phone (kare 1 and 3); 62
  /// of it is the safe area the status view adds itself.
  static const double _top = 138;

  @override
  Widget builder(
    BuildContext context,
    ScanErrorViewModel viewModel,
    Widget? child,
  ) {
    final l10n = AppLocalizations.of(context);
    final offline = kind == ScanErrorKind.offline;
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.bar,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) viewModel.close();
        },
        child: Material(
          color: context.appColors.bgCanvas,
          child: AppStatusView(
            title: offline
                ? l10n.scan_offlineTitle
                : l10n.scan_formNotFoundTitle,
            message: offline
                ? l10n.scan_offlineQueuedBody
                : l10n.scan_formNotFoundBody,
            tone: offline ? AppStatusTone.neutral : AppStatusTone.error,
            icon: offline
                ? PhosphorIconsRegular.wifiSlash
                : PhosphorIconsRegular.warningCircle,
            size: AppStatusSize.flow,
            topPadding: _top,
            onClose: viewModel.close,
            closeLabel: l10n.common_close,
            primary: AppStatusAction(
              label: offline ? l10n.scan_ok : l10n.scan_newPhoto,
              onPressed: offline ? viewModel.close : viewModel.newPhoto,
            ),
            secondary: AppStatusAction(
              label: offline ? l10n.scan_retryNow : l10n.scan_howToShoot,
              variant: AppButtonVariant.quiet,
              onPressed: offline ? viewModel.retryNow : viewModel.showTutorial,
            ),
          ),
        ),
      ),
    );
  }
}
