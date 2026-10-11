import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/lessons/presentation/widgets/eksik_tag.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/application/topic_choice.dart';
import 'package:smap/features/schedule/application/topic_groups.dart';
import 'package:smap/features/schedule/presentation/sheets/topic_picker/topic_picker_viewmodel.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/controls/app_radio.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

part 'widgets/topic_picker_list.dart';
part 'widgets/topic_picker_states.dart';

/// "Konu ekle" (pano 3.5 kare 3; 11.14 "BottomSheet, Radio, SegmentedControl").
///
/// A full sheet titled with the slot, "Pazartesi 12 Ekim · 16:00", and
/// "Kapat". A segment "Çantam" | "Dersler" with "Çantam: denemelerinden çıkan
/// eksik konuların." under it; radio rows of at least 56, padding 8 / 24, 12
/// between the parts, the lesson as a 13/20 · 700 group heading (padding 12 /
/// 24 / 0). A "Çantam" row ends with the amber "Eksik" tag; a topic already in
/// the program says "Programda: Pzt 10:00" under its name. "Ekle" (primary)
/// returns the picked [TopicChoice]; it is off until one is picked.
///
/// Open it with [show]; the sheet owns a [TopicPickerViewModel].
class TopicPickerSheet extends StatelessWidget {
  const TopicPickerSheet._({
    required this.day,
    required this.hour,
    required this.schedule,
    required this.placements,
    required this.studentId,
  });

  /// The day and hour of the slot the topic is for.
  final DateTime day;
  final int hour;
  final ScheduleService schedule;
  final Map<String, ProgramEntry> placements;
  final String? studentId;

  /// Opens the sheet; completes with the picked topic or `null` when it was
  /// dismissed.
  static Future<TopicChoice?> show({
    required DateTime day,
    required int hour,
    required ScheduleService schedule,
    Map<String, ProgramEntry> placements = const {},
    String? studentId,
    BuildContext? context,
  }) => AppSheet.show<TopicChoice>(
    context: context,
    size: AppSheetSize.full,
    builder: (_) => TopicPickerSheet._(
      day: day,
      hour: hour,
      schedule: schedule,
      placements: placements,
      studentId: studentId,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n.schedule_topicSheetTitle(
      TrFormat.gunAdi(day),
      '${day.day}',
      TrFormat.months[day.month - 1],
      TrFormat.saatParcali(hour),
    );
    return ViewModelBuilder<TopicPickerViewModel>.nonReactive(
      viewModelBuilder: () => TopicPickerViewModel(
        schedule: schedule,
        placements: placements,
        studentId: studentId,
      ),
      onViewModelReady: (viewModel) => viewModel.init(),
      builder: (context, viewModel, _) => _TopicPickerFrame(title: title),
    );
  }
}

/// The sheet frame: the title, the body and "Ekle", which follows the pick.
class _TopicPickerFrame
    extends SelectorViewModelWidget<TopicPickerViewModel, TopicChoice?> {
  const _TopicPickerFrame({required this.title});

  final String title;

  @override
  TopicChoice? selector(TopicPickerViewModel viewModel) => viewModel.selected;

  @override
  Widget build(BuildContext context, TopicChoice? selected) {
    final l10n = AppLocalizations.of(context);
    return AppSheetFrame(
      title: title,
      semanticLabel: l10n.schedule_topicSheetA11y,
      bodyPadding: EdgeInsets.zero,
      body: const _TopicPickerBody(),
      primary: AppSheetAction(
        label: l10n.schedule_add,
        onPressed: selected == null
            ? null
            : () => Navigator.of(context).pop(selected),
      ),
    );
  }
}

/// The segment, its help line and the list.
class _TopicPickerBody extends StatelessWidget {
  const _TopicPickerBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SourceSegment(),
        _SourceHelp(),
        _TopicListSection(),
        SizedBox(height: AppSpacing.s16),
      ],
    );
  }
}

class _SourceSegment
    extends SelectorViewModelWidget<TopicPickerViewModel, TopicSource> {
  const _SourceSegment();

  @override
  TopicSource selector(TopicPickerViewModel viewModel) => viewModel.source;

  @override
  Widget build(BuildContext context, TopicSource source) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<TopicPickerViewModel>(
      context,
      listen: false,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s8,
        AppSpacing.s24,
        0,
      ),
      child: AppSegmented<TopicSource>(
        segments: [
          AppSegment(value: TopicSource.bag, label: l10n.schedule_srcBag),
          AppSegment(
            value: TopicSource.lessons,
            label: l10n.schedule_srcLessons,
          ),
        ],
        value: source,
        onChanged: viewModel.setSource,
      ),
    );
  }
}

class _SourceHelp
    extends SelectorViewModelWidget<TopicPickerViewModel, TopicSource> {
  const _SourceHelp();

  @override
  TopicSource selector(TopicPickerViewModel viewModel) => viewModel.source;

  @override
  Widget build(BuildContext context, TopicSource source) {
    if (source != TopicSource.bag) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s8,
        AppSpacing.s24,
        0,
      ),
      child: Text(
        AppLocalizations.of(context).schedule_bagHelp,
        style: context.appText.caption.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
    );
  }
}
