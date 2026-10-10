import 'package:dartz/dartz.dart' as dartz;

extension EitherX<L, R> on dartz.Either<L, R> {
  R asRight() => (this as dartz.Right).value as R;
  L asLeft() => (this as dartz.Left).value as L;
}
