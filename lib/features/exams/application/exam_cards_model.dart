import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/exams/domain/exam_card_counts.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';

/// The cards an exam earned in one lesson (pano 5.6 group header: the
/// subject tile and "Tarih"; the count is `getMexamItemDetail`'s).
@immutable
class ExamCardGroup {
  const ExamCardGroup({
    required this.backendLessonId,
    required this.name,
    required this.count,
    this.subject,
  });

  /// The exam lesson's id; the card deck of the lesson takes it.
  final String backendLessonId;

  /// "Tarih", "Tarih-2": the lesson's name without its exam prefix.
  final String name;

  /// Cards, items and map items together (the legacy count).
  final int count;
  final SubjectKey? subject;

  @override
  bool operator ==(Object other) =>
      other is ExamCardGroup &&
      other.backendLessonId == backendLessonId &&
      other.name == name &&
      other.count == count &&
      other.subject == subject;

  @override
  int get hashCode => Object.hash(backendLessonId, name, count, subject);
}

/// The Kartlar tab (pano 5.6): "23 bilgi kartı eklendi" and one group per
/// lesson with cards. Pure.
@immutable
class ExamCardsModel {
  const ExamCardsModel({this.total = 0, this.groups = const []});

  /// Reads the breakdown. A lesson without cards has no group ("ders başına
  /// sayı yoksa grup sayacı çizilmez"); groups follow the exam's lesson order;
  /// a lesson id the catalog does not know adds to [total] but has no group
  /// (its name would be a guess).
  factory ExamCardsModel.of(ExamCardBreakdown breakdown) {
    final groups = <ExamCardGroup>[];
    for (final tally in breakdown.lessons) {
      final spec = ExamLessonCatalog.byId(tally.lessonId);
      if (spec == null || tally.total <= 0) continue;
      groups.add(
        ExamCardGroup(
          backendLessonId: spec.id,
          name: lessonName(spec),
          count: tally.total,
          subject: spec.subject,
        ),
      );
    }
    groups.sort((a, b) => _orderOf(a).compareTo(_orderOf(b)));
    return ExamCardsModel(total: breakdown.total, groups: groups);
  }

  /// Cards the exam added.
  final int total;
  final List<ExamCardGroup> groups;

  /// "Bu denemeden kart eklenmedi."
  bool get isEmpty => total <= 0;

  static int _orderOf(ExamCardGroup group) {
    final spec = ExamLessonCatalog.byId(group.backendLessonId);
    if (spec == null) return 1 << 20;
    // TYT lessons before AYT ones, each in exam order.
    return (spec.exam.index * 100) + spec.mexamOrder;
  }

  /// The lesson's name without "TYT " or "AYT ".
  static String lessonName(ExamLessonSpec spec) {
    final prefix = '${spec.exam.label} ';
    return spec.name.startsWith(prefix)
        ? spec.name.substring(prefix.length)
        : spec.name;
  }

  @override
  bool operator ==(Object other) =>
      other is ExamCardsModel &&
      other.total == total &&
      listEquals(other.groups, groups);

  @override
  int get hashCode => Object.hash(total, Object.hashAll(groups));
}
