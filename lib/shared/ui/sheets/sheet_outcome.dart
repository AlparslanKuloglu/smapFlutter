import 'package:flutter/foundation.dart';

/// What a sheet returned, typed (UI guide §6 rule 15: "sheet tipli sonuç
/// döndürür").
///
/// `AppSheet.show<T>` completes with `T?`: a value, or `null` when the user
/// dismissed it (drag, scrim, back, "Vazgeç"). That is enough for most
/// callers; [SheetOutcome] is for the ones that must tell "chose nothing"
/// from "chose a value", or hold a nullable result. Wrap with
/// [SheetOutcomeOf.outcome]:
///
/// ```dart
/// final outcome = (await AppSheet.show<Grade>(...)).outcome;
/// switch (outcome) {
///   case SheetSubmitted(:final value): save(value);
///   case SheetDismissed(): break;
/// }
/// ```
@immutable
sealed class SheetOutcome<T> {
  const SheetOutcome();

  /// [SheetSubmitted] for a popped value, [SheetDismissed] for `null`.
  static SheetOutcome<T> of<T extends Object>(T? popped) =>
      popped == null ? SheetDismissed<T>() : SheetSubmitted<T>(popped);

  /// The result, or [fallback] when the sheet was dismissed.
  T valueOr(T fallback) => switch (this) {
    SheetSubmitted<T>(:final value) => value,
    SheetDismissed<T>() => fallback,
  };

  /// The result, or `null` when the sheet was dismissed.
  T? get valueOrNull => switch (this) {
    SheetSubmitted<T>(:final value) => value,
    SheetDismissed<T>() => null,
  };

  /// True when the user left without a result.
  bool get isDismissed => this is SheetDismissed<T>;

  /// Runs [onSubmitted] with the value, or [onDismissed].
  R when<R>({
    required R Function(T value) onSubmitted,
    required R Function() onDismissed,
  }) => switch (this) {
    SheetSubmitted<T>(:final value) => onSubmitted(value),
    SheetDismissed<T>() => onDismissed(),
  };
}

/// The sheet closed with [value].
final class SheetSubmitted<T> extends SheetOutcome<T> {
  const SheetSubmitted(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      other is SheetSubmitted<T> && other.value == value;

  @override
  int get hashCode => Object.hash(SheetSubmitted, value);

  @override
  String toString() => 'SheetSubmitted($value)';
}

/// The sheet closed without a result.
final class SheetDismissed<T> extends SheetOutcome<T> {
  const SheetDismissed();

  @override
  bool operator ==(Object other) => other is SheetDismissed<T>;

  @override
  int get hashCode => (SheetDismissed).hashCode;

  @override
  String toString() => 'SheetDismissed()';
}

/// `Future<T?>` of `AppSheet.show` as a [SheetOutcome].
extension SheetOutcomeOf<T extends Object> on Future<T?> {
  /// Completes with [SheetSubmitted] for a value, [SheetDismissed] for null.
  Future<SheetOutcome<T>> get outcome async {
    final value = await this;
    return SheetOutcome.of<T>(value);
  }
}
