import 'package:flutter/foundation.dart';

import 'package:smap/features/coach/domain/interview_type.dart';

/// The interview list's server-side filter (`filter {types, dates}` of
/// `POST /coach/getInterviews`).
///
/// There is no text-search parameter and no "with whom" parameter on the
/// server (spec §6.3 #31); a name search has to run on the loaded pages.
@immutable
class InterviewFilter {
  const InterviewFilter({this.types = const [], this.dates = const []});

  /// Kinds to keep; empty keeps all.
  final List<InterviewType> types;

  /// Days to keep (the time of day is ignored); empty keeps all. The server's
  /// reading of a day (its time zone) is not confirmed.
  final List<DateTime> dates;

  /// `true` when nothing is filtered.
  bool get isEmpty => types.isEmpty && dates.isEmpty;

  /// The `filter` object of the request body: `types` as numbers and `dates`
  /// as `yyyy-MM-dd` text, both always present (the legacy call sent empty
  /// lists for "no filter").
  Map<String, Object> toBody() => <String, Object>{
    'types': [for (final type in types) type.code],
    'dates': [for (final date in dates) _day(date)],
  };

  static String _day(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }

  @override
  bool operator ==(Object other) =>
      other is InterviewFilter &&
      listEquals(other.types, types) &&
      listEquals(other.dates, dates);

  @override
  int get hashCode => Object.hash(Object.hashAll(types), Object.hashAll(dates));
}
