import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';

/// What the Genel tab shows the numbers of: the exam type, the student's AYT
/// field and one lesson (pano 6.1 kare 3 "Süzgeç": "Sınav", "Alan", "Ders";
/// the pill reads "TYT · Genel").
///
/// [field] only matters for AYT: it picks the score type whose points and
/// ranks the boxes average and the lessons the sheet offers (spec 6.1: "alan
/// yalnız ders listesini değiştirir"). A TYT filter never carries one. A
/// `null` [lesson] is "Genel": the whole exam.
@immutable
class AnalyticsFilter {
  const AnalyticsFilter({required this.exam, this.field, this.lesson});

  /// The screen's first filter: all of TYT.
  static const AnalyticsFilter tyt = AnalyticsFilter(exam: NetExamType.tyt);

  final NetExamType exam;

  /// The AYT field; always `null` for TYT.
  final AytField? field;

  /// One exam lesson; `null` is "Genel".
  final ExamLessonSpec? lesson;

  /// The whole exam is selected.
  bool get isGeneral => lesson == null;

  /// The lesson id the requests take; `null` for "Genel".
  String? get lessonId => lesson?.id;

  /// A filter for [exam]: a TYT filter drops the field, any change of exam or
  /// field drops the lesson (the lessons differ).
  AnalyticsFilter switchTo(NetExamType exam, {AytField? field}) =>
      AnalyticsFilter(
        exam: exam,
        field: exam == NetExamType.ayt ? field : null,
      );

  /// The same exam and field with [lesson] (`null` for "Genel").
  AnalyticsFilter withLesson(ExamLessonSpec? lesson) =>
      AnalyticsFilter(exam: exam, field: field, lesson: lesson);

  @override
  bool operator ==(Object other) =>
      other is AnalyticsFilter &&
      other.exam == exam &&
      other.field == field &&
      other.lesson?.id == lesson?.id;

  @override
  int get hashCode => Object.hash(exam, field, lesson?.id);
}

/// The lessons the filter sheet offers per exam and AYT field (pano 6.1 kare
/// 3: "Ders listesi alanına göre değişir"; Eşit Ağırlık lists Matematik too).
abstract final class AnalyticsLessons {
  /// Which AYT test lessons belong to a field, by their `mexamOrder`: 1 Türk
  /// Dili ve Edebiyatı, 2 Tarih, 3 Coğrafya, 4 Tarih-2, 5 Coğrafya-2, 8
  /// Matematik, 9 Geometri, 10 Fizik, 11 Kimya, 12 Biyoloji.
  static const Map<AytField, Set<int>> _aytOrders = {
    AytField.equalWeight: {1, 2, 3, 8},
    AytField.numeric: {8, 9, 10, 11, 12},
    AytField.verbal: {1, 2, 3, 4, 5},
  };

  /// The lessons of [exam]: all eight of TYT; for AYT those of [field], or
  /// every AYT lesson while the field is unknown.
  static List<ExamLessonSpec> of(NetExamType exam, AytField? field) {
    final all = ExamLessonCatalog.of(exam);
    if (exam == NetExamType.tyt) return all;
    final orders = field == null ? null : _aytOrders[field];
    if (orders == null) return all;
    return [
      for (final lesson in all)
        if (orders.contains(lesson.mexamOrder)) lesson,
    ];
  }

  /// The lesson without its exam prefix: "TYT Türkçe" is "Türkçe", "AYT Türk
  /// Dili ve Edebiyatı" is "Türk Dili ve Edebiyatı". The catalog names are
  /// content labels of the backend's lessons.
  static String shortName(ExamLessonSpec lesson) {
    final prefix = '${lesson.exam.label} ';
    return lesson.name.startsWith(prefix)
        ? lesson.name.substring(prefix.length)
        : lesson.name;
  }
}
