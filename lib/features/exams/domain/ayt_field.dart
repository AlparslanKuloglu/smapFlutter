import 'package:smap/features/analytics/application/net_chart_point.dart';

/// The student's AYT field ("alan"), which decides the score type that
/// counts: Eşit Ağırlık, Sayısal or Sözel.
///
/// The wire value is the legacy `aimType` (spec §6.3 #18: the registration
/// form and the exam screens agree on 2, 3 and 4; Dil and the coach dialog's
/// value 1 are open). It also is the slot of the field's score in the
/// `points` / `ranks` arrays of an exam result.
enum AytField {
  /// Eşit Ağırlık (EA).
  equalWeight(2),

  /// Sayısal (SAY).
  numeric(3),

  /// Sözel (SÖZ).
  verbal(4);

  const AytField(this.wireValue);

  /// `aimType` on the wire; also the score slot of this field.
  final int wireValue;

  /// The field of an `aimType` value, or `null` for anything else (TYT-only
  /// students, an unknown code, no value).
  static AytField? fromWire(int? aimType) {
    for (final field in values) {
      if (field.wireValue == aimType) return field;
    }
    return null;
  }
}

/// The wire form of a [NetExamType]: the legacy `type` value (`1` TYT, `2`
/// AYT).
extension NetExamTypeWire on NetExamType {
  /// `type` on the wire.
  int get wireType => switch (this) {
    NetExamType.tyt => 1,
    NetExamType.ayt => 2,
  };

  /// The exam type of a `type` value, or `null` for an unknown one.
  static NetExamType? fromWire(int? type) => switch (type) {
    1 => NetExamType.tyt,
    2 => NetExamType.ayt,
    _ => null,
  };
}
