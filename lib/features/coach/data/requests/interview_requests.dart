import 'package:smap/core/domain/legacy_envelope.dart';
import 'package:smap/core/network/base_request.dart';
import 'package:smap/features/coach/domain/interview_filter.dart';
import 'package:smap/features/coach/domain/interview_type.dart';

/// The interview endpoints as typed requests (`NetworkService.send`), after
/// `CoachRepository`. Every call answers the backend's `{success, ...}` frame.
abstract final class InterviewRequests {
  /// `POST /coach/getInterviews?page=&limit=` with `{filter: {types, dates}}`.
  /// Answers `{interviews: [...]}`.
  static BaseRequest<LegacyEnvelope> list({
    required int page,
    required int limit,
    required InterviewFilter filter,
  }) => BaseRequest<LegacyEnvelope>(
    method: HttpMethod.post,
    path: '/coach/getInterviews',
    query: <String, dynamic>{'page': page, 'limit': limit},
    body: <String, Object>{'filter': filter.toBody()},
    decoder: LegacyEnvelope.read,
  );

  /// `POST /coach/addNewInterview` with `{dataObj: {date, type, student}}`.
  /// Answers `{newInterview}`.
  static BaseRequest<LegacyEnvelope> create({
    required String studentId,
    required InterviewType type,
    required DateTime date,
  }) => BaseRequest<LegacyEnvelope>(
    method: HttpMethod.post,
    path: '/coach/addNewInterview',
    body: <String, Object>{
      'dataObj': <String, Object>{
        // Zoneless local time, exactly as the legacy screen sent it
        // (`interviews_screen.dart:620`). Switching to UTC would shift every
        // stored interview by the device offset; waits for the backend's
        // answer (DATA2 open question 1).
        'date': date.toLocal().toIso8601String(),
        'type': type.code,
        'student': studentId,
      },
    },
    decoder: LegacyEnvelope.read,
  );

  /// `POST /coach/addNewNote` with `{dataObj: {interview, note}}`.
  static BaseRequest<LegacyEnvelope> addNote({
    required String interviewId,
    required String note,
  }) => BaseRequest<LegacyEnvelope>(
    method: HttpMethod.post,
    path: '/coach/addNewNote',
    body: <String, Object>{
      'dataObj': <String, Object>{'interview': interviewId, 'note': note},
    },
    decoder: LegacyEnvelope.read,
  );

  /// `POST /coach/editNote` with `{dataObj: {interview, note, editIndex}}`.
  static BaseRequest<LegacyEnvelope> editNote({
    required String interviewId,
    required int index,
    required String note,
  }) => BaseRequest<LegacyEnvelope>(
    method: HttpMethod.post,
    path: '/coach/editNote',
    body: <String, Object>{
      'dataObj': <String, Object>{
        'interview': interviewId,
        'note': note,
        'editIndex': index,
      },
    },
    decoder: LegacyEnvelope.read,
  );

  /// `POST /coach/deleteNote` with `{dataObj: {interview, deleteIndex}}`.
  static BaseRequest<LegacyEnvelope> deleteNote({
    required String interviewId,
    required int index,
  }) => BaseRequest<LegacyEnvelope>(
    method: HttpMethod.post,
    path: '/coach/deleteNote',
    body: <String, Object>{
      'dataObj': <String, Object>{
        'interview': interviewId,
        'deleteIndex': index,
      },
    },
    decoder: LegacyEnvelope.read,
  );
}
