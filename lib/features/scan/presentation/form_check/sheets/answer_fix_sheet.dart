import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/scan/domain/answer_correction.dart';
import 'package:smap/features/scan/domain/answer_grid.dart';
import 'package:smap/features/scan/presentation/form_check/sheets/answer_fix_sheet_viewmodel.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/controls/app_chip.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

part 'widgets/answer_fix_corrections.dart';
part 'widgets/answer_fix_form.dart';
part 'widgets/answer_fix_header.dart';

/// Cevap Düzelt (pano 4.7 kare 2 "Tek sheet · boş liste", kare 3 "İki
/// düzeltme"; spec §4.C 4.7; `SmapAnswerFixSheet`): the one sheet that fixes
/// what the reader got wrong, column → question → option.
///
/// A tall sheet: the title "Cevap Düzelt" with the always-visible counter
/// ("Düzeltme yok" / "2 düzeltme") and Kapat; the form (column segment,
/// question stepper with the read value, the option chips, "Düzeltmeyi
/// Ekle", disabled until an option is picked); and the list of corrections
/// with the X of each. Tapping a cell of the grid opens it at that question,
/// so only the option is left to pick.
///
/// It completes with the corrections as they stand when it closes, however it
/// is closed (Kapat, drag, scrim, Back): nothing added is lost.
class AnswerFixSheet extends StatelessWidget {
  const AnswerFixSheet({
    required this.grid,
    required this.corrections,
    required this.start,
    super.key,
  });

  final AnswerGrid grid;
  final AnswerCorrections corrections;
  final AnswerCell start;

  /// Opens the sheet; completes with the corrections when it closes.
  static Future<AnswerCorrections?> show({
    required AnswerGrid grid,
    required AnswerCorrections corrections,
    required AnswerCell start,
    BuildContext? context,
  }) => AppSheet.show<AnswerCorrections>(
    context: context,
    size: AppSheetSize.full,
    builder: (_) =>
        AnswerFixSheet(grid: grid, corrections: corrections, start: start),
  );

  /// The body padding of the board: 12, 24, 0 (16 between its items).
  static const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(
    AppSpacing.s24,
    AppSpacing.s12,
    AppSpacing.s24,
    0,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ViewModelBuilder<AnswerFixSheetViewModel>.reactive(
      viewModelBuilder: () => AnswerFixSheetViewModel(
        grid: grid,
        corrections: corrections,
        start: start,
      ),
      builder: (context, viewModel, _) {
        void close() => Navigator.of(context).pop(viewModel.corrections);
        return AppSheetFrame(
          semanticLabel: l10n.scan_fixSheetTitle,
          onCloseAttempt: close,
          bodyPadding: _bodyPadding,
          header: _FixHeader(
            count: viewModel.corrections.count,
            onClose: close,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FixForm(viewModel: viewModel),
              const SizedBox(height: AppSpacing.s24),
              _FixCorrections(viewModel: viewModel),
            ],
          ),
        );
      },
    );
  }
}
