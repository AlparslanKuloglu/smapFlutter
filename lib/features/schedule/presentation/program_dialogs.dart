import 'package:flutter/material.dart' show TimeOfDay;

import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/topic_choice.dart';

/// A topic and the hour it was dropped on.
typedef PlacedTopic = ({int hour, TopicChoice choice});

/// The questions the program screens ask in sheets (UI guide §6 rule 15: a
/// sheet returns a typed result; the ViewModel that asked does the writing).
/// The ViewModels hold this interface, the app gives them the sheets
/// (`SheetProgramDialogs`), tests give them answers.
abstract interface class ProgramDialogs {
  /// "Cumartesi'yi sıfırlayalım mı?": [count] topics of [day] would go
  /// (pano 3.6 kare 2). `true` when the student confirmed.
  Future<bool> confirmResetDay({required DateTime day, required int count});

  /// "{name} iptal edilsin mi?" (pano 3.6 kare 4). `true` when confirmed.
  Future<bool> confirmCancelProgram({required String name});

  /// "Program kaydedilmesin mi?": leaving the new program flow with changes
  /// (pano 3.5). `true` when the student wants to leave.
  Future<bool> confirmDiscard();

  /// The time wheel on [initial] (pano 3.6 kare 1); `null` when dismissed.
  Future<TimeOfDay?> pickTime({required TimeOfDay initial});

  /// The "Konu ekle" sheet for [hour] of [day] (pano 3.5 kare 3).
  /// [placements] tells where each topic already sits in the program.
  /// `null` when dismissed.
  Future<TopicChoice?> pickTopic({
    required DateTime day,
    required int hour,
    required Map<String, ProgramEntry> placements,
  });

  /// The hour grid of [day] with its [entries] (the "Konu Ekle" button of edit
  /// mode): the student taps an empty hour, picks a topic, and both come back.
  /// `null` when dismissed.
  Future<PlacedTopic?> pickSlot({
    required DateTime day,
    required List<ProgramEntry> entries,
    required Map<String, ProgramEntry> placements,
  });
}
