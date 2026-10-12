import 'package:flutter/foundation.dart';
import 'package:smap/features/scan/domain/answer_grid.dart';

/// The answer of `opticimage`: what the optical reader found on the photo
/// (pano 4.5 kare 3 to 4.7; spec §4.C 4.5 "Veri").
///
/// The server's document is kept as it came, because `answerArray` wants it
/// back whole (`original_data`); [toLegacyJson] writes it in the legacy
/// shape, the five keys of the old `ImageResponseModel`, so that body stays
/// byte for byte what the old flow sent.
@immutable
class OpticReading {
  OpticReading({
    this.mexamFound,
    this.success,
    this.answersArray,
    this.opticImageFileName,
    this.originalImageFileName,
  }) : grid = AnswerGrid.parse(answersArray);

  /// Reads the decoded answer. Every field is optional and a field of an
  /// unexpected type reads as missing: the reader's answer must never fail a
  /// scan before the screen can say what went wrong.
  factory OpticReading.fromJson(Map<String, dynamic> json) => OpticReading(
    mexamFound: json['mexamFound'] is Map
        ? Map<String, dynamic>.from(json['mexamFound'] as Map)
        : null,
    success: json['success'] is bool ? json['success'] as bool : null,
    answersArray: json['answersArray'] is List
        ? List<dynamic>.of(json['answersArray'] as List)
        : null,
    opticImageFileName: _text(json['opticImageFileName']),
    originalImageFileName: _text(json['originalImageFileName']),
  );

  /// The exam the server already recognised, if it did.
  final Map<String, dynamic>? mexamFound;
  final bool? success;

  /// The raw `answersArray`.
  final List<dynamic>? answersArray;

  /// The file of the form image the reader drew its findings on.
  final String? opticImageFileName;

  /// The file of the photo as it was sent.
  final String? originalImageFileName;

  /// The answers as a grid; `null` when the reader found no answer area
  /// (nothing to check: the "Formu bulamadık" screen).
  final AnswerGrid? grid;

  /// Whether there is anything to check.
  bool get foundForm => grid != null;

  /// The legacy JSON of this answer (`ImageResponseModel.toJson`).
  Map<String, dynamic> toLegacyJson() => {
    'mexamFound': mexamFound,
    'success': success,
    'answersArray': answersArray,
    'opticImageFileName': opticImageFileName,
    'originalImageFileName': originalImageFileName,
  };

  static String? _text(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}

/// The answer of `answerArray`: whether the checked answers were taken and
/// which exam they belong to (pano 4.7 kare 4, 4.9).
@immutable
class AnswerReply {
  const AnswerReply({
    this.mexamFound,
    this.success,
    this.answersArray,
    this.opticImageFileName,
  });

  /// Reads the decoded answer; `mexamFound` is a document when the exam was
  /// recognised and `false` (or missing) when it was not.
  factory AnswerReply.fromJson(Map<String, dynamic> json) => AnswerReply(
    mexamFound: json['mexamFound'],
    success: json['success'] is bool ? json['success'] as bool : null,
    answersArray: json['answersArray'] is List
        ? List<dynamic>.of(json['answersArray'] as List)
        : null,
    opticImageFileName: OpticReading._text(json['opticImageFileName']),
  );

  /// The exam, as the server sent it: a document when it was recognised, and
  /// `false` or nothing when it was not (kept raw for [toLegacyJson]).
  final Object? mexamFound;
  final bool? success;
  final List<dynamic>? answersArray;
  final String? opticImageFileName;

  /// The id of the recognised exam (`mexamFound._id`); `null` when the exam
  /// is not in the system (the request screen of pano 4.9).
  String? get examId {
    final found = mexamFound;
    if (found is! Map) return null;
    final id = found['_id']?.toString().trim() ?? '';
    return id.isEmpty ? null : id;
  }

  /// Whether the exam was recognised.
  bool get examFound => examId != null;

  /// The legacy JSON of this answer plus the two image names, the
  /// `answerData` of an `examrequest` (`AnswerResponseModel.toJson` with the
  /// `images` the old flow added).
  Map<String, dynamic> toLegacyJson({
    required String? originalImageFileName,
    required String? readImageFileName,
  }) => {
    'mexamFound': mexamFound,
    'success': success,
    'answersArray': answersArray,
    'opticImageFileName': opticImageFileName,
    'images': {
      'original_image': originalImageFileName,
      'read_image': readImageFileName,
    },
  };
}
