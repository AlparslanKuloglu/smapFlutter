import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/analytics/application/exam_list_query.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/controls/app_chip.dart';
import 'package:smap/shared/ui/controls/app_chip_group.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// The words of a ready date range: "Tüm tarihler", "Son 30 gün", "Son 3 ay",
/// "Bu eğitim yılı" (pano 6.2 kare 2). The summary line over the list uses
/// them too.
String examDateLabel(AppLocalizations l10n, ExamDatePreset date) =>
    switch (date) {
      ExamDatePreset.all => l10n.analytics_dateAll,
      ExamDatePreset.last30Days => l10n.analytics_dateLast30Days,
      ExamDatePreset.last3Months => l10n.analytics_dateLast3Months,
      ExamDatePreset.academicYear => l10n.analytics_dateAcademicYear,
    };

/// The draft of the sheet until "Uygula".
class ExamFilterSheetViewModel extends BaseViewModel {
  ExamFilterSheetViewModel(this._date);

  ExamDatePreset _date;

  ExamDatePreset get date => _date;

  void select(ExamDatePreset date) {
    if (date == _date) return;
    _date = date;
    notifyListeners();
  }
}

/// "Süz ve Sırala" of Denemelerim (pano 6.2 kare 2): the "Tarih" chips "Tüm
/// tarihler", "Son 30 gün", "Son 3 ay", "Bu eğitim yılı" and "Uygula". Small
/// size (it fits its one field); it returns the chosen [ExamDatePreset], or
/// `null` when dismissed.
///
/// The board's "Sıralama" radios ("En yeni önce", "En yüksek net önce") are
/// not drawn: the backend has no sort parameter (`getMyMockExams` answers
/// newest first), and an order the list cannot keep across pages would be a
/// lie. They come back with the endpoint.
class ExamFilterSheet extends StatelessWidget {
  const ExamFilterSheet({required this.initial, super.key});

  final ExamDatePreset initial;

  /// Opens the sheet on the root navigator.
  static Future<ExamDatePreset?> show(
    BuildContext context, {
    required ExamDatePreset initial,
  }) => AppSheet.show<ExamDatePreset>(
    context: context,
    size: AppSheetSize.small,
    builder: (_) => ExamFilterSheet(initial: initial),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ViewModelBuilder<ExamFilterSheetViewModel>.reactive(
      viewModelBuilder: () => ExamFilterSheetViewModel(initial),
      builder: (context, viewModel, _) => AppSheetFrame(
        title: l10n.analytics_sheetSortTitle,
        bodyPadding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.s12,
          AppSpacing.s24,
          0,
        ),
        primary: AppSheetAction(
          label: l10n.analytics_sheetApply,
          onPressed: () => Navigator.of(context).pop(viewModel.date),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s8),
              child: Semantics(
                header: true,
                child: Text(
                  l10n.analytics_sheetDate,
                  style: context.appText.labelMd.copyWith(
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
            ),
            AppChipGroup<ExamDatePreset>(
              size: AppChipSize.md40,
              selected: {viewModel.date},
              onChanged: viewModel.select,
              items: [
                for (final date in ExamDatePreset.values)
                  AppChipItem<ExamDatePreset>(
                    value: date,
                    label: examDateLabel(l10n, date),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
          ],
        ),
      ),
    );
  }
}
