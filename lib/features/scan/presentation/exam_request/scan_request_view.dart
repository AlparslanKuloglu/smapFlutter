import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/scan/application/exam_request_form.dart';
import 'package:smap/features/scan/data/scan_repository.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';
import 'package:smap/features/scan/presentation/exam_request/scan_request_dialogs.dart';
import 'package:smap/features/scan/presentation/exam_request/scan_request_viewmodel.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_actions.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/feedback/app_status_view.dart';
import 'package:smap/shared/ui/inputs/app_text_field.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';

part 'widgets/request_done.dart';
part 'widgets/request_form.dart';

/// Deneme Bulunamadı (pano 4.9 "Deneme Bulunamadı · 4 kare"; flow 13.5; spec
/// §4.C 4.9; `ExamRequestScreen`): the exam the student scanned is not in the
/// system, so they ask for its analysis.
///
/// Kapat, "Bu deneme henüz sistemde yok" with "Yayınevini ve deneme adını yaz;
/// analizini en geç 72 saat içinde hazırlayalım.", the card "Cevapların
/// kaydedildi. Yeniden okutman gerekmez.", the two required fields (publisher,
/// exam name) and "Analizimi Hazırlayın" above the keyboard. Pressing it with an
/// empty field shows the error under it; with both filled the sheet "Talep
/// oluşturulsun mu?" asks once more, and then "Talebin alındı" with "Anasayfa"
/// replaces the form over 250 ms.
class ScanRequestView extends StackedView<ScanRequestViewModel> {
  const ScanRequestView({
    required this.reading,
    required this.reply,
    required this.actions,
    super.key,
  });

  /// The reading the exam request refers to.
  final OpticReading reading;

  /// The server's answer to the checked answers (the exam is unknown).
  final AnswerReply reply;
  final ScanFlowActions actions;

  @override
  bool get reactive => false;

  @override
  ScanRequestViewModel viewModelBuilder(BuildContext context) =>
      ScanRequestViewModel(
        reading: reading,
        reply: reply,
        repository: locator<ScanRepository>(),
        user: () => locator<CurrentUserService>().user?.toJson(),
        dialogs: const SheetScanRequestDialogs(),
        actions: actions,
        toast: locator<ToastService>(),
      );

  @override
  Widget builder(
    BuildContext context,
    ScanRequestViewModel viewModel,
    Widget? child,
  ) {
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.bar,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) viewModel.close();
        },
        child: Material(
          color: context.appColors.bgCanvas,
          child: const _RequestStage(),
        ),
      ),
    );
  }
}

/// The form and "Talebin alındı" swap over 250 ms of cross-fade.
class _RequestStage
    extends SelectorViewModelWidget<ScanRequestViewModel, RequestPhase> {
  const _RequestStage();

  @override
  RequestPhase selector(ScanRequestViewModel viewModel) => viewModel.phase;

  @override
  Widget build(BuildContext context, RequestPhase phase) {
    final fade = context.motion(AppMotion.base, reduced: AppMotion.fast);
    return AnimatedSwitcher(
      duration: fade,
      child: switch (phase) {
        RequestPhase.form => const _RequestFormPage(key: ValueKey('form')),
        RequestPhase.sent => const _RequestDone(key: ValueKey('done')),
      },
    );
  }
}
