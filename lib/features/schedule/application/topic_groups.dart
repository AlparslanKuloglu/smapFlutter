import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/schedule/application/topic_choice.dart';
import 'package:smap/features/schedule/data/dtos/bag_item_dto.dart';
import 'package:smap/features/schedule/data/dtos/main_subject_dto.dart';

/// A lesson heading and its topics in the "Konu ekle" sheet (pano 3.5 kare 3:
/// "Türkçe" over "Noktalama İşaretleri", "Cümlenin Öğeleri" ...).
@immutable
class TopicGroup {
  const TopicGroup({required this.lessonName, required this.choices});

  /// "TYT Türkçe".
  final String lessonName;
  final List<TopicChoice> choices;

  @override
  bool operator ==(Object other) =>
      other is TopicGroup &&
      other.lessonName == lessonName &&
      listEquals(other.choices, choices);

  @override
  int get hashCode => Object.hash(lessonName, Object.hashAll(choices));
}

/// Builds the two lists of the topic sheet.
abstract final class TopicGroups {
  /// "Çantam": the bag's topics grouped by lesson, the lessons in the order
  /// the bag first names them and each lesson's topics in the bag's order. An
  /// item the sheet cannot plan (no lesson or no name) is left out.
  static List<TopicGroup> bag(Iterable<BagItemDto> items) {
    final byLesson = <String, List<TopicChoice>>{};
    final names = <String, String>{};
    for (final item in items) {
      final choice = TopicChoice.fromBag(item);
      if (choice == null) continue;
      (byLesson[choice.lessonId] ??= []).add(choice);
      names.putIfAbsent(choice.lessonId, () => choice.lessonName);
    }
    return [
      for (final entry in byLesson.entries)
        TopicGroup(lessonName: names[entry.key]!, choices: entry.value),
    ];
  }

  /// "Dersler": every main subject of every exam lesson, the lessons in the
  /// catalog's order (TYT then AYT). A lesson with no subject is left out.
  static List<TopicGroup> lessons(Map<String, List<MainSubjectDto>> subjects) {
    final groups = <TopicGroup>[];
    for (final lesson in ExamLessonCatalog.all) {
      final list = subjects[lesson.id];
      if (list == null) continue;
      final choices = [
        for (final subject in list)
          ?TopicChoice.fromMainSubject(lesson, subject),
      ];
      if (choices.isNotEmpty) {
        groups.add(TopicGroup(lessonName: lesson.name, choices: choices));
      }
    }
    return groups;
  }
}
