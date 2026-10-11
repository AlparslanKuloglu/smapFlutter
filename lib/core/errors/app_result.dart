import 'package:dartz/dartz.dart';

import 'package:smap/core/errors/app_exception.dart';

/// Result of every repository call: a failure or a value.
typedef AppResult<T> = Either<AppException, T>;

/// Runs [body] and turns anything it throws into a `Left`.
///
/// Use it at the edge of code that can throw (file reads, platform calls). The
/// [NetworkService] already returns an [AppResult]; it does not need this.
Future<AppResult<T>> guardAsync<T>(Future<T> Function() body) async {
  try {
    return Right(await body());
  } on Object catch (error, stackTrace) {
    return Left(AppException.from(error, stackTrace));
  }
}

/// Synchronous twin of [guardAsync].
AppResult<T> guard<T>(T Function() body) {
  try {
    return Right(body());
  } on Object catch (error, stackTrace) {
    return Left(AppException.from(error, stackTrace));
  }
}
