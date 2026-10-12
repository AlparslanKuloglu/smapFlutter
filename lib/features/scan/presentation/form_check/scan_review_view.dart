import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_shadows.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/exams/presentation/widgets/question_cell.dart';
import 'package:smap/features/scan/application/form_check_model.dart';
import 'package:smap/features/scan/data/scan_repository.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';
import 'package:smap/features/scan/presentation/form_check/scan_review_dialogs.dart';
import 'package:smap/features/scan/presentation/form_check/scan_review_viewmodel.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_actions.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';
import 'package:smap/shared/ui/surfaces/app_notice_box.dart';

part 'widgets/review_actions.dart';
part 'widgets/review_columns.dart';
part 'widgets/review_grid.dart';
part 'widgets/review_header.dart';
part 'widgets/review_image.dart';
part 'widgets/review_image_states.dart';
part 'widgets/review_summary.dart';

/// Form Kontrol (pano 4.7 "Form Kontrol · 4 kare", 4.8 "Durumlar"; flow 13.4;
/// spec §4.C 4.7; `FormCheckScreen`): the student checks what the reader found
/// before the answers count.
///
/// Kapat, "Form Kontrol" with "Okunan cevapları formunla karşılaştır.", the
/// form image the reader drew on (zoomable, 1 to 5 times), "160 cevap okundu"
/// with the blanks and corrections, a column segment with its blank counts,
/// the 5-column grid of the column (blank readings dashed amber, corrected
/// cells navy with a pencil; a tap opens the fix sheet at that question) and
/// the bottom band: "Düzelt" and "Cevapları Onayla". Confirming asks nothing
/// more; a failure shows the inline alert and turns the button into "Tekrar
/// Dene" with the corrections kept. Kapat (and Back) with corrections asks
/// "Okutmadan çıkılsın mı?".
class ScanReviewView extends StackedView<ScanReviewViewModel> {
  const ScanReviewView({
    required this.reading,
    required this.actions,
    super.key,
  });

  /// What the reader found; it has an answer grid (the flow checked).
  final OpticReading reading;
  final ScanFlowActions actions;

  @override
  bool get reactive => false;

  @override
  ScanReviewViewModel viewModelBuilder(BuildContext context) =>
      ScanReviewViewModel(
        reading: reading,
        repository: locator<ScanRepository>(),
        dialogs: SheetScanReviewDialogs(l10n: AppLocalizations.of(context)),
        actions: actions,
        imageUrl: _imageUrl(locator<AppConfig>().cdnBaseUrl, reading),
      );

  /// `<cdn>/uploads/<file>`: where the old flow loaded the read image from.
  static String? _imageUrl(String cdnBaseUrl, OpticReading reading) {
    final name = reading.opticImageFileName;
    return name == null ? null : '$cdnBaseUrl/uploads/$name';
  }

  @override
  Widget builder(
    BuildContext context,
    ScanReviewViewModel viewModel,
    Widget? child,
  ) {
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.bar,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) unawaited(viewModel.exit());
        },
        child: Material(
          color: context.appColors.bgCanvas,
          child: const Column(
            children: [
              Expanded(child: _ReviewScroll()),
              _ReviewAlert(),
              _ReviewActions(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The scrolling part: header, image, summary, columns, grid.
class _ReviewScroll extends StatelessWidget {
  const _ReviewScroll();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _ReviewHeader()),
        SliverToBoxAdapter(child: _ReviewImageCard()),
        SliverToBoxAdapter(child: _ReviewSummary()),
        SliverToBoxAdapter(child: _ReviewColumns()),
        _ReviewGridSliver(),
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s24)),
      ],
    );
  }
}
