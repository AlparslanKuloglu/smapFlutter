import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/smap_theme.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/scan/application/corner_geometry.dart';
import 'package:smap/features/scan/application/form_quad.dart';
import 'package:smap/features/scan/application/scan_flow_state.dart';
import 'package:smap/features/scan/data/scan_vision.dart';
import 'package:smap/features/scan/presentation/corners/scan_corners_viewmodel.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_actions.dart';
import 'package:smap/features/scan/presentation/widgets/camera_tones.dart';
import 'package:smap/features/scan/presentation/widgets/camera_top_bar.dart';
import 'package:smap/features/scan/presentation/widgets/omr_form_art.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';

part 'widgets/corners_actions.dart';
part 'widgets/corners_canvas.dart';
part 'widgets/corners_hint.dart';
part 'widgets/corners_loupe.dart';
part 'widgets/corners_painter.dart';

/// Köşe Düzenleme (pano 4.4 "Köşe Düzenleme · 2 kare"; flow 13.4; spec §4.C
/// 4.4): the second camera stage, dark in every theme.
///
/// The photo fills the room between the top bar ("Köşeleri Ayarla") and the
/// bottom band; the answer area is the orange quadrilateral with a handle on
/// each corner (18 pt, 28 while dragged, 48 pt to touch). A drag opens the 2,6
/// times loupe 70 right and 150 above the finger, with an orange crosshair at
/// the handle's exact place, and hides the hint card. The band holds "Tekrar
/// Çek" and "Devam"; cropping and straightening are this one step.
///
/// The system Back is "Tekrar Çek".
class ScanCornersView extends StackedView<ScanCornersViewModel> {
  const ScanCornersView({
    required this.photo,
    required this.initial,
    required this.actions,
    super.key,
  });

  final ScanPhoto photo;
  final FormQuad initial;
  final ScanFlowActions actions;

  @override
  bool get reactive => false;

  @override
  ScanCornersViewModel viewModelBuilder(BuildContext context) =>
      ScanCornersViewModel(
        photo: photo,
        initial: initial,
        vision: locator<ScanVision>(),
        preferences: locator<DevicePreferences>(),
        actions: actions,
      );

  @override
  Widget builder(
    BuildContext context,
    ScanCornersViewModel viewModel,
    Widget? child,
  ) {
    return Theme(
      data: SmapTheme.dark(),
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return AppSystemOverlayRegion(
            kind: AppSystemOverlayKind.camera,
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) viewModel.retake();
              },
              child: Material(
                color: context.appColors.cameraGround,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const _CornersCanvas(),
                    const _CornersHint(),
                    CameraTopBar(
                      title: l10n.scan_cornersTitle,
                      onClose: viewModel.close,
                    ),
                    const _CornersBand(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
