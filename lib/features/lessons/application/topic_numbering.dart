import 'package:flutter/foundation.dart' show immutable;

/// A topic with the number it wears in the full list.
@immutable
class NumberedTopic<T> {
  const NumberedTopic(this.number, this.topic);

  /// 1-based, continuous.
  final int number;
  final T topic;

  @override
  bool operator ==(Object other) =>
      other is NumberedTopic<T> &&
      other.number == number &&
      other.topic == topic;

  @override
  int get hashCode => Object.hash(number, topic);
}

/// The topic numbers (C22 `TopicRow`; pano 1.16 "Konu satırı", 7.2).
///
/// The number is made on the device, 1 to n without a gap, in the order the
/// server sends the topics ("Numara kesintisiz ve sola sabit"; the old app
/// showed 3, 4, 4, 5, 5, 6). A filtered or searched list keeps the numbers of
/// the full list. Pure and unit-tested.
abstract final class TopicNumbering {
  /// Every topic of [all] with its number.
  static List<NumberedTopic<T>> number<T>(List<T> all) => [
    for (final (i, topic) in all.indexed) NumberedTopic(i + 1, topic),
  ];

  /// The topics of [all] that pass [keep], with the numbers they have in
  /// [all].
  static List<NumberedTopic<T>> filter<T>(
    List<T> all,
    bool Function(T topic) keep,
  ) => [
    for (final numbered in number(all))
      if (keep(numbered.topic)) numbered,
  ];
}
