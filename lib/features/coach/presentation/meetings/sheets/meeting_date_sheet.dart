import 'package:flutter/material.dart';

import 'package:smap/features/coach/application/meeting_schedule_logic.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/pickers/app_calendar.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// "Tarih" of "Yeni görüşme" (pano 10.5 kare 2: "Seçiciler çizilmemiş;
/// TimeWheel ya da Calendar kullanılabilir"; built from the kit): the month
/// calendar with one day picked and "Tamam".
///
/// The calendar opens on the month of [initial]. A tap picks that day (a
/// second tap on it keeps it). Days from [MeetingSchedule.pastDays] before
/// [today] can be picked; the orange ring is today. Completes with the day at
/// midnight, or `null` when the sheet was dismissed.
class MeetingDateSheet extends StatefulWidget {
  const MeetingDateSheet._({required this.initial, required this.today});

  final DateTime initial;
  final DateTime today;

  /// Opens the sheet on [initial].
  static Future<DateTime?> show({
    required DateTime initial,
    required DateTime today,
    BuildContext? context,
  }) => AppSheet.show<DateTime>(
    context: context,
    size: AppSheetSize.medium,
    builder: (_) => MeetingDateSheet._(initial: initial, today: today),
  );

  @override
  State<MeetingDateSheet> createState() => _MeetingDateSheetState();
}

class _MeetingDateSheetState extends State<MeetingDateSheet> {
  late DateTime _picked = DateTime(
    widget.initial.year,
    widget.initial.month,
    widget.initial.day,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppSheetFrame(
      title: l10n.coachMeetings_dateTitle,
      body: AppCalendar(
        selected: {_picked},
        today: widget.today,
        firstSelectable: MeetingSchedule.firstDay(widget.today),
        initialMonth: _picked,
        onToggle: (day) => setState(() => _picked = day),
      ),
      primary: AppSheetAction(
        label: l10n.common_ok,
        onPressed: () => Navigator.of(context).pop(_picked),
      ),
    );
  }
}
