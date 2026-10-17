import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/topic_choice.dart';

/// The line under a topic's name in the "Konu ekle" sheet (pano 14.2 kare 3
/// and 6): "TYT Türkçe · Programda: Pzt 10:00" in "Çanta" / "Çantam", where
/// the lesson stands under the name because the list has no group headings,
/// and "Programda: Pzt 10:00" in "Dersler". The "Programda" part is worked
/// out on the device from the program being built, never read from the bag.
///
/// The bag carries the topic's name and the lesson's name only; there is no
/// "eksik" tag and no "Son denemede 13 sorudan 9'u yanlış" line to write.
abstract final class TopicRowText {
  /// "Programda: Pzt 10:00" for the slot [placed]; [inProgramAt] is the
  /// localized template (`schedule_inProgramAt`).
  static String placedLine(
    ProgramEntry placed,
    String Function(String day, String time) inProgramAt,
  ) => inProgramAt(TrFormat.gunKisa(placed.day), placed.timeLabel);

  /// The whole line under [choice]'s name, or `null` when there is nothing to
  /// say: the lesson's name when [showLesson], then where the topic already
  /// sits in the program ([placed]), joined with " · ".
  static String? subline({
    required TopicChoice choice,
    required bool showLesson,
    required ProgramEntry? placed,
    required String Function(String day, String time) inProgramAt,
  }) {
    final parts = [
      if (showLesson && choice.lessonName.isNotEmpty) choice.lessonName,
      if (placed != null) placedLine(placed, inProgramAt),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }
}
