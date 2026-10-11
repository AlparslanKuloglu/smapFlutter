import 'package:flutter/material.dart' show TimeOfDay;

import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/application/topic_choice.dart';
import 'package:smap/features/schedule/presentation/program_dialogs.dart';
import 'package:smap/features/schedule/presentation/sheets/hour_grid_sheet.dart';
import 'package:smap/features/schedule/presentation/sheets/topic_picker/topic_picker_sheet.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/pickers/app_time_wheel.dart';
import 'package:smap/shared/ui/sheets/app_confirm_sheet.dart';

/// [ProgramDialogs] as the app's sheets (UI guide §6 rule 15): the confirm
/// sheets, the time wheel, the topic sheet and the hour grid.
///
/// A ViewModel has no `BuildContext`, so the sheets open on the root
/// navigator (`AppSheet.navigatorKey`); [l10n] gives the texts of the confirm
/// sheets (the app is Turkish only, so the localizations do not depend on a
/// widget).
class SheetProgramDialogs implements ProgramDialogs {
  const SheetProgramDialogs({
    required this.l10n,
    required this.schedule,
    this.studentId,
  });

  final AppLocalizations l10n;
  final ScheduleService schedule;
  final String? studentId;

  @override
  Future<bool> confirmResetDay({
    required DateTime day,
    required int count,
  }) async {
    final date = '${day.day} ${TrFormat.months[day.month - 1]}';
    final result = await AppConfirmSheet.show(
      title: l10n.schedule_resetDayTitle(
        TurkishSuffix.accusative(TrFormat.gunAdi(day)),
      ),
      message: l10n.schedule_resetDayBody(
        '${TurkishSuffix.locative(date)}ki',
        TrFormat.sira(count),
      ),
      confirmLabel: l10n.schedule_resetDay,
      cancelLabel: l10n.common_cancel,
      danger: true,
    );
    return result.confirmed;
  }

  @override
  Future<bool> confirmCancelProgram({required String name}) async {
    final result = await AppConfirmSheet.show(
      title: l10n.schedule_cancelProgramTitle(name),
      message: l10n.schedule_cancelProgramBody,
      confirmLabel: l10n.schedule_cancelProgram,
      cancelLabel: l10n.common_cancel,
      danger: true,
    );
    return result.confirmed;
  }

  @override
  Future<bool> confirmDiscard() async {
    final result = await AppConfirmSheet.show(
      title: l10n.schedule_discardTitle,
      message: l10n.schedule_discardBody,
      confirmLabel: l10n.schedule_discardConfirm,
      cancelLabel: l10n.common_cancel,
    );
    return result.confirmed;
  }

  @override
  Future<TimeOfDay?> pickTime({required TimeOfDay initial}) =>
      AppTimeWheelSheet.show(
        title: l10n.schedule_changeTimeTitle,
        saveLabel: l10n.common_save,
        initial: initial,
      );

  @override
  Future<TopicChoice?> pickTopic({
    required DateTime day,
    required int hour,
    required Map<String, ProgramEntry> placements,
  }) => TopicPickerSheet.show(
    day: day,
    hour: hour,
    schedule: schedule,
    placements: placements,
    studentId: studentId,
  );

  @override
  Future<PlacedTopic?> pickSlot({
    required DateTime day,
    required List<ProgramEntry> entries,
    required Map<String, ProgramEntry> placements,
  }) => HourGridSheet.show(
    day: day,
    entries: entries,
    pickTopic: (hour) =>
        pickTopic(day: day, hour: hour, placements: placements),
  );
}
