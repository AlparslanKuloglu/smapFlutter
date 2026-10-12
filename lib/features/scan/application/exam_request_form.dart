import 'package:flutter/foundation.dart';

/// Why a field of the exam request cannot be sent (pano 4.9 kare 2).
enum ExamRequestError {
  /// "Yayınevini yaz."
  publisherRequired,

  /// "Deneme adını yaz."
  examNameRequired,
}

/// The two fields of the exam request (pano 4.9): the publisher and the name
/// of the exam the system does not know. Both are required; a field of only
/// blanks is empty.
@immutable
class ExamRequestForm {
  const ExamRequestForm({this.publisher = '', this.examName = ''});

  final String publisher;
  final String examName;

  /// The publisher without the blanks around it.
  String get publisherTrimmed => publisher.trim();

  /// The exam name without the blanks around it.
  String get examNameTrimmed => examName.trim();

  ExamRequestForm withPublisher(String value) =>
      ExamRequestForm(publisher: value, examName: examName);

  ExamRequestForm withExamName(String value) =>
      ExamRequestForm(publisher: publisher, examName: value);

  /// The error of the publisher field, or `null`.
  ExamRequestError? get publisherError =>
      publisherTrimmed.isEmpty ? ExamRequestError.publisherRequired : null;

  /// The error of the exam name field, or `null`.
  ExamRequestError? get examNameError =>
      examNameTrimmed.isEmpty ? ExamRequestError.examNameRequired : null;

  /// Whether the request can be sent.
  bool get isValid => publisherError == null && examNameError == null;

  /// The first field with an error, where the focus goes (pano 4.9 kare 2:
  /// "Odak ilk hatalı alana gider").
  ExamRequestError? get firstError => publisherError ?? examNameError;

  @override
  bool operator ==(Object other) =>
      other is ExamRequestForm &&
      other.publisher == publisher &&
      other.examName == examName;

  @override
  int get hashCode => Object.hash(publisher, examName);
}
