import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';

/// A result and the net of the exam before it.
@immutable
class MomentSource {
  const MomentSource({required this.exam, this.previousNet});

  final ExamDetail exam;

  /// The net of the previous exam of the same type; `null` when there is none
  /// (no change is drawn then).
  final double? previousNet;

  @override
  bool operator ==(Object other) =>
      other is MomentSource &&
      other.exam == exam &&
      other.previousNet == previousNet;

  @override
  int get hashCode => Object.hash(exam, previousNet);
}

/// Reads the result the camera flow just created and the exam before it (pano
/// 5.1: "Fark yalnız bir önceki AYT'ye göre"; spec §6.3 #20: the change comes
/// from the list, as the home screen's does).
///
/// The backend has no id-to-result endpoint, so the Denemelerim list is read
/// newest first until the id turns up (a fresh result is on the first page:
/// one request). The previous exam is the next exam of the same type further
/// down the list; if it is not on the page that held the result, the next
/// pages are read, [maxPages] at most. A page that fails after the result was
/// found only costs the change (it is not drawn); a failure before that is
/// the failure of the screen. A result that is not among the listed ones is
/// [AppErrorCode.notFound].
class ResultMomentLoader {
  const ResultMomentLoader(this._repository, {this.maxPages = defaultMaxPages});

  final ExamRepository _repository;

  /// The pages read at most (8 results each).
  final int maxPages;

  /// 10 pages: the 80 newest results.
  static const int defaultMaxPages = 10;

  Future<AppResult<MomentSource>> load(String examId) async {
    ExamDetail? found;
    for (var page = 1; page <= maxPages; page++) {
      final answer = await _repository.getMyExams(page: page);
      final failure = answer.leftOrNull;
      final data = answer.rightOrNull;
      if (failure != null || data == null) {
        // After the result was found a failed page only loses the change.
        if (found != null) return Right(MomentSource(exam: found));
        return Left(
          failure ??
              const AppException(
                code: AppErrorCode.unknown,
                message: 'The exam list answered nothing',
              ),
        );
      }
      final list = data.exams;
      var start = 0;
      if (found == null) {
        final index = list.indexWhere((exam) => exam.id == examId);
        if (index >= 0) {
          found = list[index];
          start = index + 1;
        } else {
          start = list.length;
        }
      }
      final reference = found;
      if (reference != null) {
        final previous = _previousNet(reference, list.skip(start));
        if (previous != null) {
          return Right(MomentSource(exam: reference, previousNet: previous));
        }
      }
      if (!data.hasMore) break;
    }
    final result = found;
    if (result != null) return Right(MomentSource(exam: result));
    return const Left(
      AppException(
        code: AppErrorCode.notFound,
        message: 'The result is not among the listed exams',
      ),
    );
  }

  /// The net of the first exam of [later] with the same type as [exam] and a
  /// net; `null` for none (or an [exam] of unknown type).
  static double? _previousNet(ExamDetail exam, Iterable<ExamDetail> later) {
    final kind = exam.kind;
    if (kind == null) return null;
    for (final earlier in later) {
      if (earlier.kind != kind) continue;
      final net = earlier.summary.net ?? earlier.summary.counts?.net;
      if (net != null) return net;
    }
    return null;
  }
}
