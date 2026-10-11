import 'package:smap/core/utils/tr_format.dart';

/// The direction a [DeltaText] points.
enum DeltaDirection {
  up,
  down,
  flat;

  /// The direction of [value] as it will be written: a value that rounds to
  /// zero in `TrFormat.delta` is [flat], so "0" never carries an arrow and
  /// "+0,001" cannot show an up arrow beside the text "0".
  static DeltaDirection of(num value) {
    if (TrFormat.delta(value) == '0') return flat;
    return value > 0 ? up : down;
  }
}
