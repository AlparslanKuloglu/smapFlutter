import 'package:dartz/dartz.dart';

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/exams/data/api_support.dart';
import 'package:smap/features/exams/data/dtos/mock_exam_dto.dart';
import 'package:smap/features/exams/data/mappers/exam_mappers.dart';
import 'package:smap/features/exams/data/requests/exam_requests.dart';
import 'package:smap/features/exams/domain/exam_card_counts.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/domain/exam_page.dart';
import 'package:smap/features/exams/domain/exam_summary.dart';
import 'package:smap/features/exams/domain/question_detail.dart';
import 'package:smap/features/exams/domain/topic_result.dart';

/// Reads a student's mock exams: the list, one result's topic analysis and
/// card counts, a question's detail. Replaces the exam half of the legacy
/// `AnalysisRepository` (spec §6.3 #20, #23, #27, #33).
///
/// Every method answers `Either<AppException, T>` and never throws. Every read
/// takes an optional `studentId`: a coach opening a student's exams passes the
/// student's id, which goes out as the `studentId` query parameter, the way
/// the legacy repository injected it. Whether every endpoint honours it is
/// still an open backend question (spec §6.3 #33).
class ExamRepository {
  ExamRepository(this._network);

  final NetworkService _network;

  /// `getMyMockExams`: one page of the Denemelerim list, [pageSize] exams
  /// (8) per page, newest-first as the server orders them.
  ///
  /// An empty page is a normal answer (`hasMore: false`); an answer without
  /// the `success: true` flag is a failure. Results without an id are left
  /// out.
  Future<AppResult<ExamPage>> getMyExams({
    int page = 1,
    int pageSize = ExamRequests.pageSize,
    ExamListFilter filter = ExamListFilter.none,
    String? studentId,
  }) async {
    const path = '/student/getMyMockExams';
    final result = await _network.send(
      ExamRequests.myMockExams(
        page: page,
        perPage: pageSize,
        filter: filter,
        studentId: studentId,
      ),
    );
    return result.requireSuccess(path).map((response) {
      final raw = response.exams ?? const <MockExamDto>[];
      return ExamPage(
        page: page,
        exams: [
          for (final exam in raw)
            if (exam.toDetail() case final ExamDetail detail) detail,
        ],
        hasMore: raw.length >= pageSize,
      );
    });
  }

  /// `getMexamSubjectDetail`: the Konu Analizi of the result [examId].
  Future<AppResult<ExamTopicAnalysis>> getTopicAnalysis({
    required String examId,
    String? studentId,
  }) async {
    final result = await _network.send(
      ExamRequests.subjectDetail(mexamId: examId, studentId: studentId),
    );
    return result
        .requireSuccess('/student/getMexamSubjectDetail')
        .map((response) => response.toDomain());
  }

  /// `getMexamItemDetail`: info-card counts per lesson of the result
  /// [examId] (the Bilgi Kartları tab).
  Future<AppResult<ExamCardBreakdown>> getCardBreakdown({
    required String examId,
    String? studentId,
  }) async {
    final result = await _network.send(
      ExamRequests.itemDetail(mexamId: examId, studentId: studentId),
    );
    return result
        .requireSuccess('/student/getMexamItemDetail')
        .map((response) => response.toDomain());
  }

  /// `getTotalInfoCard`: how many info cards the result [examId] earned, per
  /// lesson (the result moment's "Toplam N bilgi kartı kazandın"). Goes
  /// through the shared client, so the session cookie is the app's own (the
  /// legacy screen attached a cookie by hand).
  Future<AppResult<ExamCardCounts>> getEarnedCardCounts({
    required String examId,
    String? studentId,
  }) async {
    final result = await _network.send(
      ExamRequests.totalInfoCard(mexamId: examId, studentId: studentId),
    );
    return result
        .requireSuccess('/student/getTotalInfoCard')
        .map((response) => response.toDomain());
  }

  /// `getQuestion`: the detail of question [questionOrder] of test
  /// [lessonOrder] (0-based, `TestResult.index`) of [exam].
  ///
  /// An answer with `success: true` but no `question` object is
  /// [AppErrorCode.notFound].
  Future<AppResult<QuestionDetail>> getQuestion({
    required ExamDefinition exam,
    required int questionOrder,
    required int lessonOrder,
    String? studentId,
  }) async {
    const path = '/student/getQuestion';
    final result = await _network.send(
      ExamRequests.question(
        exam: exam,
        questionOrder: questionOrder,
        lessonOrder: lessonOrder,
        studentId: studentId,
      ),
    );
    return result.requireSuccess(path).flatMap((response) {
      final detail = response.toDomain();
      if (detail != null) return Right(detail);
      return const Left(
        AppException(
          code: AppErrorCode.notFound,
          message: 'The answer had no question object',
          path: path,
        ),
      );
    });
  }
}
