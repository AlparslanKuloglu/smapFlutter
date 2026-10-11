import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/schedule/application/program_lessons.dart';
import 'package:smap/features/schedule/data/dtos/bag_item_dto.dart';
import 'package:smap/features/schedule/data/dtos/main_subject_dto.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';

/// A topic picked in the "Konu ekle" sheet (pano 3.5 kare 3): which lesson and
/// which main subject, and for a "Çantam" item the item behind it.
///
/// Immutable; the sheet pops it, the caller puts it into a time slot with
/// [toTask].
@immutable
class TopicChoice {
  const TopicChoice({
    required this.lessonId,
    required this.lessonName,
    required this.title,
    this.mainSubjectId,
    this.subjectId,
    this.itemId,
    this.lessonColor,
    this.mapImage,
  });

  /// A "Çantam" item: the topic the student's exams left missing. Null when
  /// the item has no lesson or no topic name (nothing to plan).
  static TopicChoice? fromBag(BagItemDto item) {
    final lesson = item.lesson;
    final topic = item.data;
    final lessonId = lesson?.id;
    final title = topic?.name;
    if (lessonId == null || title == null || title.isEmpty) return null;
    return TopicChoice(
      lessonId: lessonId,
      lessonName: ProgramLessons.nameOf(
        lessonId: lessonId,
        lessonName: lesson?.name,
      ),
      title: title,
      mainSubjectId: item.mainSubject,
      subjectId: topic?.subject,
      itemId: topic?.id,
      lessonColor: lesson?.lessonColor,
      mapImage: lesson?.mapImage,
    );
  }

  /// A main subject of an exam lesson (the "Dersler" tab). Null when the
  /// subject has no name.
  static TopicChoice? fromMainSubject(
    ExamLessonSpec lesson,
    MainSubjectDto subject,
  ) {
    final name = subject.name;
    if (name == null || name.isEmpty) return null;
    final style = ProgramLessons.styleOf(lesson.id);
    return TopicChoice(
      lessonId: lesson.id,
      lessonName: lesson.name,
      title: name,
      mainSubjectId: subject.id,
      lessonColor: style?.colorHex,
      mapImage: style?.mapImage,
    );
  }

  final String lessonId;
  final String lessonName;
  final String title;
  final String? mainSubjectId;
  final String? subjectId;
  final String? itemId;
  final String? lessonColor;
  final String? mapImage;

  /// A key that tells two choices apart: a "Çantam" item by its id, a lesson
  /// topic by lesson and main subject.
  String get key => keyFor(
    itemId: itemId,
    lessonId: lessonId,
    mainSubjectId: mainSubjectId,
    title: title,
  );

  /// The [key] of a topic described by its parts (an entry already in a
  /// program has the same parts).
  static String keyFor({
    required String lessonId,
    required String title,
    String? itemId,
    String? mainSubjectId,
  }) => itemId != null && itemId.isNotEmpty
      ? 'bag:$itemId'
      : 'lesson:$lessonId:${mainSubjectId ?? title}';

  /// The task this choice becomes at [hour]:[minute] of [day].
  ProgramTaskDraft toTask({
    required DateTime day,
    required int hour,
    int minute = 0,
  }) {
    final style = ProgramLessons.styleOf(lessonId);
    return ProgramTaskDraft.create(
      day: day,
      hour: hour,
      minute: minute,
      lessonId: lessonId,
      title: title,
      lessonName: lessonName,
      mainSubjectId: mainSubjectId,
      subjectId: subjectId,
      itemId: itemId,
      lessonColor: lessonColor ?? style?.colorHex,
      mapImage: mapImage ?? style?.mapImage,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TopicChoice &&
      other.lessonId == lessonId &&
      other.lessonName == lessonName &&
      other.title == title &&
      other.mainSubjectId == mainSubjectId &&
      other.subjectId == subjectId &&
      other.itemId == itemId &&
      other.lessonColor == lessonColor &&
      other.mapImage == mapImage;

  @override
  int get hashCode => Object.hash(
    lessonId,
    lessonName,
    title,
    mainSubjectId,
    subjectId,
    itemId,
    lessonColor,
    mapImage,
  );
}
