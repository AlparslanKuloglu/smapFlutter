import 'package:flutter/material.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/schedule/application/hour_range.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/topic_choice.dart';
import 'package:smap/features/schedule/presentation/program_dialogs.dart';
import 'package:smap/features/schedule/presentation/widgets/hour_slot.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

/// The hour grid of a day as a sheet: the "Konu Ekle" of edit mode (pano 3.6
/// kare 1: "Konu Ekle ızgara sheet'ini açar"; the slots are those of pano 3.5
/// kare 2).
///
/// Titled with the day ("Cumartesi, 10 Ekim") and "Boş bir saate dokun, konu
/// seç. Izgara 06:00–23:00." One [HourSlot] per hour, 06:00 to 23:00 (wider
/// when the day holds a topic outside); a filled hour shows its topic with no
/// remove button, an empty one asks [pickTopic] for a topic. The sheet
/// returns the hour and the topic together ([PlacedTopic]); the screen that
/// opened it places the topic and saves.
class HourGridSheet extends StatelessWidget {
  const HourGridSheet._({
    required this.day,
    required this.entries,
    required this.pickTopic,
  });

  final DateTime day;

  /// The topics the day already holds.
  final List<ProgramEntry> entries;

  /// Opens the topic sheet for an hour.
  final Future<TopicChoice?> Function(int hour) pickTopic;

  /// Opens the sheet; completes with the placed topic or `null`.
  static Future<PlacedTopic?> show({
    required DateTime day,
    required List<ProgramEntry> entries,
    required Future<TopicChoice?> Function(int hour) pickTopic,
    BuildContext? context,
  }) => AppSheet.show<PlacedTopic>(
    context: context,
    size: AppSheetSize.full,
    builder: (_) =>
        HourGridSheet._(day: day, entries: entries, pickTopic: pickTopic),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final range = HourRange.of(entries);
    return AppSheetFrame(
      title: l10n.schedule_dayTitle(
        TrFormat.gunAdi(day),
        '${day.day}',
        TrFormat.months[day.month - 1],
      ),
      subtitle: l10n.schedule_gridBody,
      bodyPadding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
      ),
      body: AppCard(
        padding: EdgeInsets.zero,
        clip: true,
        child: Column(
          children: [
            for (final hour in range.hours)
              HourSlot(
                hour: hour,
                showRule: hour != range.last,
                entries: [
                  for (final entry in entries)
                    if (entry.hour == hour) entry,
                ],
                onAdd: () async {
                  final choice = await pickTopic(hour);
                  if (choice != null && context.mounted) {
                    Navigator.of(context).pop((hour: hour, choice: choice));
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
