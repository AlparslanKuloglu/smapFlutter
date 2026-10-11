import 'package:dartz/dartz.dart';

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';

/// Null-safe accessors and side-effect hooks for dartz [Either].
///
/// Everything goes through `fold`; there is no unchecked cast. (The legacy
/// `asRight()` / `asLeft()` in `dartz_extension.dart` throw on the wrong side
/// and are retired with the legacy code.) Names differ from the legacy ones
/// on purpose so both files can be imported during the migration.
extension EitherAccessors<L, R> on Either<L, R> {
  /// The value, or `null` for a failure.
  R? get rightOrNull => fold((_) => null, (r) => r);

  /// The failure, or `null` for a value.
  L? get leftOrNull => fold((l) => l, (_) => null);

  /// The value, or [fallback] for a failure.
  R rightOr(R fallback) => fold((_) => fallback, (r) => r);

  /// Named-argument `fold`, easier to read at call sites.
  T when<T>({
    required T Function(L failure) failure,
    required T Function(R value) success,
  }) => fold(failure, success);

  /// Runs [action] for a value and returns this, so calls can be chained.
  Either<L, R> onRight(void Function(R value) action) {
    fold((_) {}, action);
    return this;
  }

  /// Runs [action] for a failure and returns this, so calls can be chained.
  Either<L, R> onLeft(void Function(L failure) action) {
    fold(action, (_) {});
    return this;
  }
}

/// Helpers for results whose failure is an [AppException].
extension AppResultAccessors<R> on Either<AppException, R> {
  /// The failure's code, or `null` for a value.
  AppErrorCode? get errorCode => fold((e) => e.code, (_) => null);

  /// `true` when the failure is the given [code].
  bool failedWith(AppErrorCode code) =>
      fold((e) => e.code == code, (_) => false);
}

/// Chaining on a future [Either], so repositories stay free of `await` ladders.
extension FutureEitherChain<L, R> on Future<Either<L, R>> {
  /// Maps the value; a failure passes through.
  Future<Either<L, T>> mapRight<T>(T Function(R value) mapper) async {
    final either = await this;
    return either.map(mapper);
  }

  /// Continues with another call when this one succeeded.
  Future<Either<L, T>> bindRight<T>(
    Future<Either<L, T>> Function(R value) next,
  ) async {
    final either = await this;
    return either.fold((l) async => Left<L, T>(l), next);
  }
}
