/// Who an interview is with, as the backend's `type` number.
///
/// The legacy screens read `1` as "Öğrenci Görüşmesi" and everything else as
/// "Veli Görüşmesi", and wrote 1 for a student and 2 for a parent.
enum InterviewType {
  /// "Öğrenci Görüşmesi".
  student(1),

  /// "Veli Görüşmesi".
  parent(2);

  const InterviewType(this.code);

  /// The `type` value on the wire (and in the list filter's `types`).
  final int code;

  /// Reads a `type`; `null` for a missing or unknown number.
  static InterviewType? fromCode(int? code) {
    for (final type in values) {
      if (type.code == code) return type;
    }
    return null;
  }
}
