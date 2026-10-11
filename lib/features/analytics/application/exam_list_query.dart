import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/domain/exam_page.dart';
import 'package:smap/features/exams/domain/exam_summary.dart';

/// The exam type segment of Denemelerim (pano 6.2: "Tümü", "TYT", "AYT").
enum ExamTypeFilter {
  all(null),
  tyt(NetExamType.tyt),
  ayt(NetExamType.ayt);

  const ExamTypeFilter(this.exam);

  /// The exam type; `null` for "Tümü".
  final NetExamType? exam;
}

/// The ready date ranges of the "Süz ve Sırala" sheet (pano 6.2 kare 2; spec
/// 4.7: no custom range). The backend's `dates` format is not confirmed, so
/// the app cuts the ranges itself: the list comes newest first, so a page
/// that reaches an exam older than the range ends the list ([ExamListQuery]).
enum ExamDatePreset {
  /// "Tüm tarihler".
  all,

  /// "Son 30 gün".
  last30Days,

  /// "Son 3 ay".
  last3Months,

  /// "Bu eğitim yılı": from 1 September (decision of spec 6.2).
  academicYear;

  /// The first day the range holds at [now]; `null` for [all].
  DateTime? startOf(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      all => null,
      last30Days => today.subtract(const Duration(days: 30)),
      last3Months => DateTime(today.year, today.month - 3, today.day),
      academicYear => DateTime(
        today.month >= 9 ? today.year : today.year - 1,
        9,
      ),
    };
  }
}

/// The filter of the Denemelerim list: the type goes to the server (`types`,
/// known to work), the date range is applied here.
@immutable
class ExamListQuery {
  const ExamListQuery({
    this.type = ExamTypeFilter.all,
    this.date = ExamDatePreset.all,
  });

  /// Every exam: what the list starts with.
  static const ExamListQuery initial = ExamListQuery();

  final ExamTypeFilter type;
  final ExamDatePreset date;

  /// Nothing is filtered.
  bool get isInitial =>
      type == ExamTypeFilter.all && date == ExamDatePreset.all;

  /// The part the server applies.
  ExamListFilter get serverFilter => ExamListFilter(types: {?type.exam});

  ExamListQuery copyWith({ExamTypeFilter? type, ExamDatePreset? date}) =>
      ExamListQuery(type: type ?? this.type, date: date ?? this.date);

  /// Whether [exam] belongs in the range at [now]. An exam without a date
  /// cannot be placed, so a date range leaves it out.
  bool accepts(ExamSummary exam, DateTime now) {
    final start = date.startOf(now);
    if (start == null) return true;
    final day = exam.date;
    return day != null && !day.isBefore(start);
  }

  /// A page (newest first) reached the end of the range: it holds a dated
  /// exam older than the range, so later pages hold nothing more.
  bool endsRange(Iterable<ExamSummary> page, DateTime now) {
    final start = date.startOf(now);
    if (start == null) return false;
    return page.any((exam) {
      final day = exam.date;
      return day != null && day.isBefore(start);
    });
  }

  @override
  bool operator ==(Object other) =>
      other is ExamListQuery && other.type == type && other.date == date;

  @override
  int get hashCode => Object.hash(type, date);
}
