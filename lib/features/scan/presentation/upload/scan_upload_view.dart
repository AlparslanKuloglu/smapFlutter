import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart';

import 'dart:typed_data';

import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_shadows.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/scan/application/scan_job_service.dart';
import 'package:smap/features/scan/domain/scan_failure.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_actions.dart';
import 'package:smap/features/scan/presentation/upload/scan_upload_viewmodel.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/indicators/app_linear_progress.dart';
import 'package:smap/shared/ui/indicators/app_spinner.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';

part 'widgets/upload_actions.dart';
part 'widgets/upload_header.dart';
part 'widgets/upload_photo.dart';
part 'widgets/upload_steps.dart';

/// Gönderim (pano 4.5 "Gönderim · 4 kare", 4.6 koyu; flow 13.4; spec §4.C
/// 4.5): the photo goes up and the answers are read.
///
/// "Formun okunuyor" with "Birkaç saniye sürebilir.", the straightened photo
/// on a card, and the three real steps ("Fotoğraf hazırlanıyor", "Gönderiliyor
/// %64", "Cevapların okunuyor"); "Vazgeç" under them. A failure turns the
/// title into "Formun gönderilemedi" with its reason, marks the second step
/// "Gönderilemedi" and swaps "Vazgeç" for "Tekrar Dene" and "Yeni Fotoğraf":
/// the screen stays and the photo is kept. It follows the theme (the dark one
/// is board 4.6: no white flash right after the camera).
///
/// The system Back is "Vazgeç".
class ScanUploadView extends StackedView<ScanUploadViewModel> {
  const ScanUploadView({required this.photo, required this.actions, super.key});

  /// The straightened photo that is sent.
  final Uint8List photo;
  final ScanFlowActions actions;

  @override
  bool get reactive => false;

  @override
  ScanUploadViewModel viewModelBuilder(BuildContext context) =>
      ScanUploadViewModel(
        photo: photo,
        jobs: locator<ScanJobService>(),
        actions: actions,
      );

  @override
  void onViewModelReady(ScanUploadViewModel viewModel) => viewModel.start();

  @override
  Widget builder(
    BuildContext context,
    ScanUploadViewModel viewModel,
    Widget? child,
  ) {
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.bar,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) viewModel.cancel();
        },
        child: Material(
          color: context.appColors.bgCanvas,
          child: const _UploadPage(),
        ),
      ),
    );
  }
}

/// The page: the scrolling content (header, photo, steps) and the buttons
/// pinned at the bottom.
class _UploadPage extends StatelessWidget {
  const _UploadPage();

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.paddingOf(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s16,
              safe.top + AppSpacing.s16,
              AppSpacing.s16,
              AppSpacing.s24,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _UploadHeader(),
                SizedBox(height: AppSpacing.s16),
                _UploadPhoto(),
                SizedBox(height: AppSpacing.s24),
                _UploadSteps(),
              ],
            ),
          ),
        ),
        const _UploadActions(),
      ],
    );
  }
}
