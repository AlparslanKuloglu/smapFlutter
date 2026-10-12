import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/smap_theme.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/scan/application/corner_geometry.dart';
import 'package:smap/features/scan/application/form_quad.dart';
import 'package:smap/features/scan/data/scan_camera.dart';
import 'package:smap/features/scan/data/scan_gallery_picker.dart';
import 'package:smap/features/scan/data/scan_vision.dart';
import 'package:smap/features/scan/presentation/capture/scan_capture_dialogs.dart';
import 'package:smap/features/scan/presentation/capture/scan_capture_viewmodel.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_actions.dart';
import 'package:smap/features/scan/presentation/widgets/camera_top_bar.dart';
import 'package:smap/features/scan/presentation/widgets/camera_tones.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/feedback/app_status_view.dart';
import 'package:smap/shared/ui/indicators/app_spinner.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';

part 'widgets/capture_guide.dart';
part 'widgets/capture_hint.dart';
part 'widgets/capture_shutter.dart';
part 'widgets/capture_states.dart';

/// Çekim (pano 4.3 "Çekim · 2 kare", 4.10 kare 4 "Kamera açılamadı"; flow
/// 13.4; spec §4.C 4.3): the camera stage of the scan.
///
/// It is dark in every theme (`SmapTheme.dark()`, status bar with light
/// icons): the preview with the dimmed guide frame (330 x 400 on the board),
/// the top bar (Kapat, "Optik Form", "?"), the hint pill, and the 76 pt
/// shutter. When the camera sees the form the corner marks fade to 35 % and
/// the orange quadrilateral with its four dots fades in, and the pill says
/// "Hazır. Telefonu sabit tut ve çek."; the shutter works either way.
///
/// The system Back closes the scan, like Kapat.
class ScanCaptureView extends StackedView<ScanCaptureViewModel> {
  const ScanCaptureView({required this.actions, super.key});

  final ScanFlowActions actions;

  @override
  bool get reactive => false;

  @override
  ScanCaptureViewModel viewModelBuilder(BuildContext context) =>
      ScanCaptureViewModel(
        camera: locator<ScanCamera>(),
        vision: locator<ScanVision>(),
        preferences: locator<DevicePreferences>(),
        dialogs: const SheetScanCaptureDialogs(),
        actions: actions,
        gallery: ScanDebug.galleryEnabled
            ? const ImagePickerGalleryPicker()
            : null,
      );

  @override
  void onViewModelReady(ScanCaptureViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    ScanCaptureViewModel viewModel,
    Widget? child,
  ) {
    return Theme(
      data: SmapTheme.dark(),
      child: Builder(
        builder: (context) => AppSystemOverlayRegion(
          kind: AppSystemOverlayKind.camera,
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) viewModel.close();
            },
            child: Material(
              color: context.appColors.cameraGround,
              child: const _CaptureStage(),
            ),
          ),
        ),
      ),
    );
  }
}

/// The stage: the page changes with the phase, over 250 ms of cross-fade
/// (150 ms under "reduce motion": it already is an opacity change).
class _CaptureStage
    extends SelectorViewModelWidget<ScanCaptureViewModel, CapturePhase> {
  const _CaptureStage();

  @override
  CapturePhase selector(ScanCaptureViewModel viewModel) => viewModel.phase;

  @override
  Widget build(BuildContext context, CapturePhase phase) {
    final fade = context.motion(AppMotion.base, reduced: AppMotion.fast);
    return AnimatedSwitcher(
      duration: fade,
      child: switch (phase) {
        CapturePhase.opening => const _CaptureOpening(key: ValueKey('open')),
        CapturePhase.ready ||
        CapturePhase.capturing => const _CapturePreview(key: ValueKey('view')),
        CapturePhase.failed => const _CaptureFailed(key: ValueKey('fail')),
      },
    );
  }
}
