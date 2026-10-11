import 'package:dartz/dartz.dart';

import 'package:smap/core/domain/legacy_envelope.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/account/data/dtos/legal_document_dto.dart';
import 'package:smap/features/account/data/requests/account_requests.dart';
import 'package:smap/features/account/domain/profile_update.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';

/// The account endpoints: profile update, legal texts, account deletion and
/// the student's coach link. Answers `Either<AppException, T>`; nothing throws.
///
/// A `success: false` answer is a failure with
/// `AppErrorCode.validation` and the server's own text in
/// `AppException.serverMessage`; an answer that is not the backend's JSON
/// frame is an `AppErrorCode.server` failure.
///
/// Not here, because the backend has no endpoint yet: changing the password
/// (the legacy screen only showed a success message), verifying a new e-mail,
/// notification preferences.
class AccountRepository {
  AccountRepository(this._network);

  final NetworkService _network;

  /// `POST /student/updateStudent`: saves the fields of [update] (the others
  /// are not sent, which assumes the server merges them; spec §6.3 #11).
  ///
  /// Succeeds with the updated account when the answer carries it (`student`),
  /// and with `null` when the server accepted the change without echoing the
  /// user; reload it with `CurrentUserService.refresh()` then.
  Future<AppResult<UserDto?>> updateProfile(ProfileUpdate update) async {
    const path = '/student/updateStudent';
    final result = await _network.send(AccountRequests.updateStudent(update));
    return result.fold(Left.new, (envelope) {
      final failure = _failureOf(envelope, path);
      if (failure != null) return Left(failure);
      final student = envelope.object('student');
      if (student == null) return const Right(null);
      return _decode(path, () => UserDto.fromJson(student));
    });
  }

  /// `GET /ajax/getLegalDocuments`: every legal text, active or not (see
  /// `LegalDocumentDto.active`). An empty list is a valid answer; an empty
  /// body is not.
  Future<AppResult<List<LegalDocumentDto>>> getLegalDocuments() async {
    const path = '/ajax/getLegalDocuments';
    final result = await _network.send(AccountRequests.getLegalDocuments());
    return result.fold(Left.new, (body) {
      final envelope = LegacyEnvelope.read(body);
      final items = body is List ? _documentsOf(body) : _wrapped(envelope);
      if (items != null) return Right(items);
      if (envelope.isRejected) return Left(envelope.rejection(path));
      return Left(envelope.unusable(path, 'no list of documents'));
    });
  }

  /// `GET /ajax/deleteAccount`: deletes the signed-in account for good. The
  /// caller ends the session afterwards.
  Future<AppResult<Unit>> deleteAccount() async {
    const path = '/ajax/deleteAccount';
    final result = await _network.send(AccountRequests.deleteAccount());
    return result.fold(Left.new, (envelope) {
      final failure = _failureOf(envelope, path);
      return failure == null ? const Right(unit) : Left(failure);
    });
  }

  /// `GET /student/getStudentsCoach`: the student's coach, or `null` when the
  /// student has none.
  ///
  /// A `success: false` answer also reads as "no coach": the legacy screen
  /// treated every non-success answer of this call as the unlinked state. That
  /// is an assumption about the server (see the task report).
  Future<AppResult<UserDto?>> getMyCoach() async {
    const path = '/student/getStudentsCoach';
    final result = await _network.send(AccountRequests.getStudentsCoach());
    return result.fold(Left.new, (envelope) {
      if (envelope.isRejected) return const Right(null);
      if (!envelope.isSuccess) {
        return Left(envelope.unusable(path, 'no success flag'));
      }
      final coach = envelope.object('coach');
      if (coach == null) return const Right(null);
      return _decode(path, () => UserDto.fromJson(coach));
    });
  }

  /// `GET /student/addCoach?code=`: links the student to the coach who owns
  /// [refCode]. The code goes out as given (trimmed); see `CoachCode` for the
  /// `AAAA-0000` shape and the open question about the dash.
  ///
  /// An unknown code is a `validation` failure with the server's message.
  Future<AppResult<UserDto>> addCoach(String refCode) async {
    const path = '/student/addCoach';
    final result = await _network.send(
      AccountRequests.addCoach(refCode.trim()),
    );
    return result.fold(Left.new, (envelope) {
      final coach = envelope.object('coach');
      if (envelope.isRejected || (envelope.isSuccess && coach == null)) {
        return Left(envelope.rejection(path));
      }
      if (coach == null) {
        return Left(envelope.unusable(path, 'no coach in the answer'));
      }
      return _decode(path, () => UserDto.fromJson(coach));
    });
  }

  /// `GET /student/deleteCoach?coach=<coachId>`: unlinks the student from the
  /// coach. [coachId] is sent (the legacy call dropped it).
  Future<AppResult<Unit>> removeCoach(String coachId) async {
    const path = '/student/deleteCoach';
    final result = await _network.send(AccountRequests.deleteCoach(coachId));
    return result.fold(Left.new, (envelope) {
      final failure = _failureOf(envelope, path);
      return failure == null ? const Right(unit) : Left(failure);
    });
  }

  /// `null` for `success: true`; otherwise the failure the answer stands for.
  AppException? _failureOf(LegacyEnvelope envelope, String path) {
    if (envelope.isSuccess) return null;
    if (envelope.isRejected) return envelope.rejection(path);
    return envelope.unusable(path, 'no success flag');
  }

  AppResult<T> _decode<T>(String path, T Function() read) {
    try {
      return Right(read());
    } on Object catch (error, stackTrace) {
      return Left(AppException.parse(error, stackTrace, path));
    }
  }

  List<LegalDocumentDto>? _wrapped(LegacyEnvelope envelope) {
    final data = envelope['data'];
    return data is List ? _documentsOf(data) : null;
  }

  List<LegalDocumentDto> _documentsOf(List<Object?> items) {
    final documents = <LegalDocumentDto>[];
    for (final item in items) {
      if (item is! Map) continue;
      try {
        documents.add(
          LegalDocumentDto.fromJson(Map<String, dynamic>.from(item)),
        );
      } on Object {
        continue;
      }
    }
    return documents;
  }
}
