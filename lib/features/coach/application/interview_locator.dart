import 'package:dartz/dartz.dart';

import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/coach/data/dtos/interview_dtos.dart';
import 'package:smap/features/coach/data/interview_repository.dart';
import 'package:smap/features/coach/domain/interview_filter.dart';

/// Finds one interview by its id.
///
/// The backend has no "get interview" endpoint, only the paged list, and the
/// notes of an interview are addressed by position (`editIndex`,
/// `deleteIndex`), so the screen must read the interview again after every
/// note write and before it trusts an index. This does that with the list
/// call:
///
/// 1. With a [hint] (the day the interview was seen at), it asks for the
///    three days around it (`filter.dates`, so a server that reads the day in
///    another time zone still returns it) and pages through those.
/// 2. If that does not find it, or there is no hint (a link that carries only
///    the id), it pages through the whole list.
///
/// Both walks are bounded ([windowPages], [listPages]); an interview that is
/// not found is `Right(null)`, a failed request is a `Left` at once.
class InterviewLocator {
  InterviewLocator(
    this._repository, {
    this.windowPages = 5,
    this.listPages = 30,
  });

  final InterviewRepository _repository;

  /// The most pages walked inside the three-day window.
  final int windowPages;

  /// The most pages walked in the whole list.
  final int listPages;

  /// The interview with [id], or `null` when it is not in the list.
  Future<AppResult<InterviewDto?>> find(String id, {DateTime? hint}) async {
    if (hint != null) {
      final day = DateTime(hint.year, hint.month, hint.day);
      final filter = InterviewFilter(
        dates: [
          DateTime(day.year, day.month, day.day - 1),
          day,
          DateTime(day.year, day.month, day.day + 1),
        ],
      );
      final inWindow = await _walk(id, filter: filter, pages: windowPages);
      if (inWindow.fold((_) => true, (found) => found != null)) return inWindow;
    }
    return _walk(id, filter: const InterviewFilter(), pages: listPages);
  }

  Future<AppResult<InterviewDto?>> _walk(
    String id, {
    required InterviewFilter filter,
    required int pages,
  }) async {
    for (var page = 1; page <= pages; page++) {
      final result = await _repository.getInterviews(
        page: page,
        filter: filter,
      );
      final failure = result.leftOrNull;
      if (failure != null) return Left(failure);
      final read = result.rightOrNull!;
      for (final item in read.items) {
        if (item.id == id) return Right(item);
      }
      if (!read.hasMore) break;
    }
    return const Right(null);
  }
}
