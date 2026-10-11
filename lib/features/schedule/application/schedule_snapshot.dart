import 'package:flutter/foundation.dart';

import 'package:smap/features/schedule/application/today_program.dart';
import 'package:smap/features/schedule/data/dtos/bag_item_dto.dart';
import 'package:smap/features/schedule/data/dtos/weekly_dto.dart';

/// What `ScheduleService` holds for one student (or the signed-in user): the
/// programs and the bag as of [loadedAt]. Immutable; the service replaces it.
@immutable
class ScheduleSnapshot {
  const ScheduleSnapshot({
    required this.weeklies,
    required this.bagItems,
    required this.loadedAt,
    this.studentId,
  });

  /// The student these programs belong to; `null` for the signed-in user's
  /// own (a student looking at their programs).
  final String? studentId;

  /// The programs, newest created first as far as the server sorts them; a
  /// program created in this session is put first.
  final List<WeeklyDto> weeklies;

  /// "Çantam": topics waiting to be planned.
  final List<BagItemDto> bagItems;

  final DateTime loadedAt;

  /// The program with [id], or `null`.
  WeeklyDto? weeklyById(String id) {
    for (final weekly in weeklies) {
      if (weekly.id == id) return weekly;
    }
    return null;
  }

  /// The "Bugün" view of [day] (see [tasksOnDay]).
  List<ScheduledTask> tasksOn(DateTime day) => tasksOnDay(weeklies, day);

  ScheduleSnapshot copyWith({
    List<WeeklyDto>? weeklies,
    List<BagItemDto>? bagItems,
    DateTime? loadedAt,
  }) => ScheduleSnapshot(
    studentId: studentId,
    weeklies: weeklies ?? this.weeklies,
    bagItems: bagItems ?? this.bagItems,
    loadedAt: loadedAt ?? this.loadedAt,
  );
}
