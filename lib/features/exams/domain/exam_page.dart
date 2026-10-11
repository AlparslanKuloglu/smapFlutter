import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/domain/exam_summary.dart';

/// The filter of the Denemelerim list (`filter{types, nets, dates}` of
/// `getMyMockExams`; board 6.2 "Süz ve Sırala").
///
/// The legacy app always sent all three empty, so the value formats of
/// [nets] and [dates] are **not confirmed** (open question, spec §6.3 #27);
/// they are passed through as text. A `sort` parameter does not exist yet.
@immutable
class ExamListFilter {
  const ExamListFilter({
    this.types = const {},
    this.nets = const [],
    this.dates = const [],
  });

  /// No filter: every exam.
  static const ExamListFilter none = ExamListFilter();

  /// Only these exam types; empty means all.
  final Set<NetExamType> types;

  /// Net ranges, as the server expects them (format unconfirmed).
  final List<String> nets;

  /// Date ranges, as the server expects them (format unconfirmed).
  final List<String> dates;

  bool get isEmpty => types.isEmpty && nets.isEmpty && dates.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is ExamListFilter &&
      other.types.length == types.length &&
      other.types.containsAll(types) &&
      listEquals(other.nets, nets) &&
      listEquals(other.dates, dates);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(types),
    Object.hashAll(nets),
    Object.hashAll(dates),
  );
}

/// One page of the Denemelerim list. The list answer already carries
/// everything a detail screen needs, so every entry is a full [ExamDetail].
@immutable
class ExamPage {
  const ExamPage({
    required this.page,
    required this.exams,
    required this.hasMore,
  });

  /// The page number that was asked for (1-based).
  final int page;

  final List<ExamDetail> exams;

  /// Another page may exist: this one came back full (the legacy rule, the
  /// answer has no page count).
  final bool hasMore;

  /// The list rows.
  List<ExamSummary> get summaries => [for (final exam in exams) exam.summary];

  @override
  bool operator ==(Object other) =>
      other is ExamPage &&
      other.page == page &&
      other.hasMore == hasMore &&
      listEquals(other.exams, exams);

  @override
  int get hashCode => Object.hash(page, hasMore, Object.hashAll(exams));
}
