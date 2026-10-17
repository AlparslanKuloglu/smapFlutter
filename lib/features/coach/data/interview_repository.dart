import 'package:dartz/dartz.dart';

import 'package:smap/core/domain/legacy_envelope.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/network/base_request.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/coach/data/dtos/interview_dtos.dart';
import 'package:smap/features/coach/data/interview_page.dart';
import 'package:smap/features/coach/data/requests/interview_requests.dart';
import 'package:smap/features/coach/domain/interview_filter.dart';
import 'package:smap/features/coach/domain/interview_type.dart';

/// The coach's interviews and their notes. Answers
/// `Either<AppException, T>`; nothing throws.
///
/// There is no endpoint to edit or delete an interview itself, nor a text
/// search or a "with whom" filter (spec §6.3 #31); those are missing on the
/// server, not here. Notes are addressed by their position in the interview's
/// list.
class InterviewRepository {
  InterviewRepository(this._network);

  final NetworkService _network;

  /// The page size of the legacy list and of the design (`perPage: 8`).
  static const int defaultPageSize = 8;

  /// `POST /coach/getInterviews`: one page, [page] counted from 1.
  Future<AppResult<InterviewPage>> getInterviews({
    int page = 1,
    int limit = defaultPageSize,
    InterviewFilter filter = const InterviewFilter(),
  }) async {
    const path = '/coach/getInterviews';
    final result = await _network.send(
      InterviewRequests.list(page: page, limit: limit, filter: filter),
    );
    return result.fold(Left.new, (envelope) {
      if (envelope.isRejected) return Left(envelope.rejection(path));
      final items = envelope.readList('interviews', InterviewDto.fromJson);
      if (items == null) return Left(envelope.unusable(path, 'no interviews'));
      return Right(InterviewPage(items: items, page: page, limit: limit));
    });
  }

  /// `POST /coach/addNewInterview`: schedules an interview with [studentId].
  ///
  /// [date] is sent as the local wall-clock time without a zone
  /// (`2026-10-14T16:00:00.000`), as the legacy dialog sent it: the stored
  /// interviews are in that form, and a UTC instant would shift every new one
  /// by the device's offset. The screens read it back the same way
  /// (`MeetingMoment.wallClock`). How the server stores it is an open backend
  /// question (`docs/Backend_Sorulari_Ek.md`, G1).
  ///
  /// Succeeds with the created interview (`newInterview`), or with `null`
  /// when the server accepted it without echoing it; reload the first page
  /// then.
  Future<AppResult<InterviewDto?>> createInterview({
    required String studentId,
    required InterviewType type,
    required DateTime date,
  }) async {
    const path = '/coach/addNewInterview';
    final result = await _network.send(
      InterviewRequests.create(studentId: studentId, type: type, date: date),
    );
    return result.fold(Left.new, (envelope) {
      final failure = _failureOf(envelope, path);
      if (failure != null) return Left(failure);
      final created = envelope.object('newInterview');
      if (created == null) return const Right(null);
      try {
        return Right(InterviewDto.fromJson(created));
      } on Object catch (error, stackTrace) {
        return Left(AppException.parse(error, stackTrace, path));
      }
    });
  }

  /// `POST /coach/addNewNote`: adds [note] to the interview. The server does
  /// not say where it put it; reload the interview before using positions.
  Future<AppResult<Unit>> addNote({
    required String interviewId,
    required String note,
  }) => _unit(
    '/coach/addNewNote',
    InterviewRequests.addNote(interviewId: interviewId, note: note),
  );

  /// `POST /coach/editNote`: replaces the text of the note at [index].
  Future<AppResult<Unit>> editNote({
    required String interviewId,
    required int index,
    required String note,
  }) => _unit(
    '/coach/editNote',
    InterviewRequests.editNote(
      interviewId: interviewId,
      index: index,
      note: note,
    ),
  );

  /// `POST /coach/deleteNote`: removes the note at [index].
  Future<AppResult<Unit>> deleteNote({
    required String interviewId,
    required int index,
  }) => _unit(
    '/coach/deleteNote',
    InterviewRequests.deleteNote(interviewId: interviewId, index: index),
  );

  Future<AppResult<Unit>> _unit(
    String path,
    BaseRequest<LegacyEnvelope> request,
  ) async {
    final result = await _network.send(request);
    return result.fold(Left.new, (envelope) {
      final failure = _failureOf(envelope, path);
      return failure == null ? const Right(unit) : Left(failure);
    });
  }

  AppException? _failureOf(LegacyEnvelope envelope, String path) {
    if (envelope.isSuccess) return null;
    if (envelope.isRejected) return envelope.rejection(path);
    return envelope.unusable(path, 'no success flag');
  }
}
