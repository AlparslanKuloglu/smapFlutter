import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/config/feature_flags.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/scan/application/scan_flow_state.dart';
import 'package:smap/features/scan/presentation/capture/scan_capture_view.dart';
import 'package:smap/features/scan/presentation/corners/scan_corners_view.dart';
import 'package:smap/features/scan/presentation/exam_request/scan_request_view.dart';
import 'package:smap/features/scan/presentation/form_check/scan_review_view.dart';
import 'package:smap/features/scan/presentation/scan_error/scan_error_view.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_viewmodel.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_navigator.dart';
import 'package:smap/features/scan/presentation/upload/scan_upload_view.dart';

/// Okut (pano 4.3 to 4.10; flow 13.4 and 13.5; spec §3.6 `/scan`): the whole
/// optical scan, a full-screen route of the root stack (no bottom bar), opened
/// by `ScanEntry` after the permission and maintenance gate.
///
/// The stages are separate screens that swap over a 250 ms cross-fade (150 ms
/// under "reduce motion", it is an opacity change either way): the camera and the
/// corner screen, dark in every theme; the upload, the answer check, the exam
/// request and the errors in the theme. Each stage handles its own Back. While
/// the route is up the phone stays upright: the camera plugin and the corner
/// math assume a portrait photo.
@RoutePage()
class ScanFlowView extends StackedView<ScanFlowViewModel> {
  const ScanFlowView({super.key});

  @override
  bool get reactive => false;

  @override
  ScanFlowViewModel viewModelBuilder(BuildContext context) => ScanFlowViewModel(
    navigator: RouterScanNavigator(context.router),
    offlineQueueEnabled: FeatureFlags.offlineQueueEnabled,
  );

  @override
  Widget builder(
    BuildContext context,
    ScanFlowViewModel viewModel,
    Widget? child,
  ) => const _UprightScan(child: _ScanStages());
}

/// Keeps the phone upright while the scan is on screen and gives the
/// orientations back when it leaves (its one `State` owns that).
class _UprightScan extends StatefulWidget {
  const _UprightScan({required this.child});

  final Widget child;

  @override
  State<_UprightScan> createState() => _UprightScanState();
}

class _UprightScanState extends State<_UprightScan> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

typedef _StageKey = (ScanStage, int, ScanErrorKind?);

/// The stage that is up. It rebuilds when the stage, the camera generation or
/// the error kind changes, and the stage views read what they need from the
/// state once, when they are built.
class _ScanStages
    extends SelectorViewModelWidget<ScanFlowViewModel, _StageKey> {
  const _ScanStages();

  @override
  _StageKey selector(ScanFlowViewModel viewModel) =>
      (viewModel.state.stage, viewModel.generation, viewModel.state.errorKind);

  @override
  Widget build(BuildContext context, _StageKey key) {
    final vm = getParentViewModel<ScanFlowViewModel>(context, listen: false);
    final state = vm.state;
    final (stage, generation, errorKind) = key;
    final fade = context.motion(AppMotion.base, reduced: AppMotion.fast);
    // The canvas behind the cross-fade: the stages that follow the theme paint
    // their own page, the camera ones their dark one.
    return ColoredBox(
      color: context.appColors.bgCanvas,
      child: AnimatedSwitcher(
        duration: fade,
        child: switch (stage) {
          ScanStage.capture => ScanCaptureView(
            key: ValueKey('capture-$generation'),
            actions: vm,
          ),
          ScanStage.corners => ScanCornersView(
            key: const ValueKey('corners'),
            photo: state.photo!,
            initial: state.cornersQuad!,
            actions: vm,
          ),
          ScanStage.upload => ScanUploadView(
            key: const ValueKey('upload'),
            photo: state.flattened!,
            actions: vm,
          ),
          ScanStage.review => ScanReviewView(
            key: const ValueKey('review'),
            reading: state.reading!,
            actions: vm,
          ),
          ScanStage.request => ScanRequestView(
            key: const ValueKey('request'),
            reading: state.reading!,
            reply: state.reply!,
            actions: vm,
          ),
          ScanStage.error => ScanErrorView(
            key: ValueKey('error-${errorKind?.name}'),
            kind: errorKind ?? ScanErrorKind.formNotFound,
            actions: vm,
          ),
        },
      ),
    );
  }
}
