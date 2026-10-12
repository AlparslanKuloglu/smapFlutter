import 'package:dartz/dartz.dart';

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';

/// Finds one result by its id (what Deneme Detay and Soru Detay open on a
/// deep link or an "Analizi Gör" link).
///
/// The backend has no id-to-result endpoint yet (the guide's "id ile tek
/// deneme ucu (S+)"): a result only comes inside the Denemelerim list, so the
/// pages are read, newest first, until the id turns up. A failed page is the
/// failure; reaching the last page without it is [AppErrorCode.notFound].
/// Screens opened from the list hand the result over and never call this.
class ExamFinder {
  const ExamFinder(this._repository, {this.maxPages = defaultMaxPages});

  final ExamRepository _repository;

  /// The pages read at most (8 results each).
  final int maxPages;

  /// 10 pages: the 80 newest results.
  static const int defaultMaxPages = 10;

  Future<AppResult<ExamDetail>> find(String examId, {String? studentId}) async {
    for (var page = 1; page <= maxPages; page++) {
      final answer = await _repository.getMyExams(
        page: page,
        studentId: studentId,
      );
      final failure = answer.leftOrNull;
      if (failure != null) return Left(failure);
      final data = answer.rightOrNull;
      if (data == null) break;
      for (final exam in data.exams) {
        if (exam.id == examId) return Right(exam);
      }
      if (!data.hasMore) break;
    }
    return const Left(
      AppException(
        code: AppErrorCode.notFound,
        message: 'The result is not among the listed exams',
      ),
    );
  }
}
