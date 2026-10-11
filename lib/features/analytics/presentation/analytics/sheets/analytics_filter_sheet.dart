import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/analytics/application/analytics_filter.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/controls/app_chip.dart';
import 'package:smap/shared/ui/controls/app_chip_group.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// The draft of the filter sheet: the choices until "Uygula". The sheet
/// returns it; the screen's ViewModel applies it.
class AnalyticsFilterSheetViewModel extends BaseViewModel {
  AnalyticsFilterSheetViewModel({
    required AnalyticsFilter initial,
    required this.userField,
  }) : _filter = initial;

  /// The student's own AYT field: selected when the sheet switches to AYT
  /// ("Profildeki alanın seçili gelir").
  final AytField? userField;

  AnalyticsFilter _filter;

  /// The draft.
  AnalyticsFilter get filter => _filter;

  /// The lessons of the draft's exam and field.
  List<ExamLessonOption> get lessons => [
    for (final lesson in AnalyticsLessons.of(_filter.exam, _filter.field))
      ExamLessonOption(lesson.id, AnalyticsLessons.shortName(lesson)),
  ];

  /// Chooses TYT or AYT; AYT starts on the student's field.
  void selectExam(NetExamType exam) {
    if (exam == _filter.exam) return;
    _filter = _filter.switchTo(exam, field: _filter.field ?? userField);
    notifyListeners();
  }

  /// Chooses the AYT field; the lessons change with it.
  void selectField(AytField? field) {
    if (field == _filter.field) return;
    _filter = _filter.switchTo(NetExamType.ayt, field: field);
    notifyListeners();
  }

  /// Chooses a lesson by id; `null` is "Genel".
  void selectLesson(String? id) {
    final lesson = id == null
        ? null
        : AnalyticsLessons.of(
            _filter.exam,
            _filter.field,
          ).firstWhere((candidate) => candidate.id == id);
    _filter = _filter.withLesson(lesson);
    notifyListeners();
  }
}

/// A lesson chip: the catalog id and its short name.
class ExamLessonOption {
  const ExamLessonOption(this.id, this.label);

  final String id;
  final String label;
}

/// The filter sheet of the Genel tab (pano 6.1 kare 3 "Süzgeç"; flow 13.7
/// "TYT · Genel çipi"): "Sınav" (TYT, AYT), for AYT "Alan" (Eşit Ağırlık,
/// Sayısal, Sözel) with "Ders listesi alanına göre değişir. Profildeki alanın
/// seçili gelir.", "Ders" chips (Genel and the lessons of the exam and field)
/// and the primary "Uygula". Medium size. It returns the chosen
/// [AnalyticsFilter], or `null` when dismissed.
///
/// The board also lists "Dil"; no confirmed `aimType` exists for it yet
/// (`StudyTrack.dil`), so it is not offered.
class AnalyticsFilterSheet extends StatelessWidget {
  const AnalyticsFilterSheet({
    required this.initial,
    required this.userField,
    super.key,
  });

  final AnalyticsFilter initial;
  final AytField? userField;

  /// Opens the sheet on the root navigator.
  static Future<AnalyticsFilter?> show(
    BuildContext context, {
    required AnalyticsFilter initial,
    AytField? userField,
  }) => AppSheet.show<AnalyticsFilter>(
    context: context,
    size: AppSheetSize.medium,
    builder: (_) =>
        AnalyticsFilterSheet(initial: initial, userField: userField),
  );

  /// Gap between the sheet's fields (pano 6.1 kare 3: 20).
  static const double _fieldGap = 20;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ViewModelBuilder<AnalyticsFilterSheetViewModel>.reactive(
      viewModelBuilder: () =>
          AnalyticsFilterSheetViewModel(initial: initial, userField: userField),
      builder: (context, viewModel, _) => AppSheetFrame(
        title: l10n.analytics_sheetFilterTitle,
        bodyPadding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.s12,
          AppSpacing.s24,
          0,
        ),
        primary: AppSheetAction(
          label: l10n.analytics_sheetApply,
          onPressed: () => Navigator.of(context).pop(viewModel.filter),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FieldLabel(l10n.analytics_sheetExam),
            Semantics(
              container: true,
              label: l10n.analytics_sheetExamA11y,
              child: AppSegmented<NetExamType>(
                value: viewModel.filter.exam,
                onChanged: viewModel.selectExam,
                segments: [
                  for (final exam in NetExamType.values)
                    AppSegment(value: exam, label: exam.label),
                ],
              ),
            ),
            if (viewModel.filter.exam == NetExamType.ayt) ...[
              const SizedBox(height: _fieldGap),
              _FieldLabel(l10n.analytics_sheetField),
              Semantics(
                container: true,
                label: l10n.analytics_sheetFieldA11y,
                child: AppSegmented<AytField?>(
                  value: viewModel.filter.field,
                  onChanged: viewModel.selectField,
                  segments: [
                    AppSegment(
                      value: AytField.equalWeight,
                      label: l10n.analytics_fieldEqualWeight,
                    ),
                    AppSegment(
                      value: AytField.numeric,
                      label: l10n.analytics_fieldNumeric,
                    ),
                    AppSegment(
                      value: AytField.verbal,
                      label: l10n.analytics_fieldVerbal,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                l10n.analytics_sheetFieldHelp,
                style: context.appText.caption.copyWith(
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: _fieldGap),
            _FieldLabel(l10n.analytics_sheetLesson),
            AppChipGroup<String?>(
              size: AppChipSize.md40,
              selected: {viewModel.filter.lessonId},
              onChanged: viewModel.selectLesson,
              items: [
                AppChipItem<String?>(
                  value: null,
                  label: l10n.analytics_filterGeneral,
                ),
                for (final lesson in viewModel.lessons)
                  AppChipItem<String?>(value: lesson.id, label: lesson.label),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
          ],
        ),
      ),
    );
  }
}

/// A field label of the sheet: 14/20 · 600, 8 above its control (pano 0.3
/// "Alan etiketi").
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.s8),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: context.appText.labelMd.copyWith(
          color: context.appColors.textPrimary,
        ),
      ),
    ),
  );
}
