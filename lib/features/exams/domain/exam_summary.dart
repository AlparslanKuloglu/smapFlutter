import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';

/// Which exam a result belongs to: its number, type and cover.
@immutable
class ExamDefinition {
  const ExamDefinition({
    this.id,
    this.order,
    this.kind,
    this.imageFile,
    this.serverObject,
  });

  /// Mongo `_id` of the exam.
  final String? id;

  /// "Deneme: 9".
  final int? order;

  /// TYT or AYT; `null` for a type this build does not know.
  final NetExamType? kind;

  /// Cover file name (or a full URL) the server sent; see [imageUrl].
  final String? imageFile;

  /// The exam object exactly as the server sent it. Screens never read it:
  /// `ExamRepository.getQuestion` posts it back to the server unchanged (as the
  /// legacy screen did). Not part of equality.
  final Map<String, dynamic>? serverObject;

  /// The cover's full URL: a file name goes under `<cdnBaseUrl>/uploads/`
  /// (`AppConfig.cdnBaseUrl`), a full URL stays as it is, no cover is `null`.
  String? imageUrl(String cdnBaseUrl) {
    final file = imageFile?.trim();
    if (file == null || file.isEmpty) return null;
    if (file.startsWith('http://') || file.startsWith('https://')) return file;
    final base = cdnBaseUrl.endsWith('/')
        ? cdnBaseUrl.substring(0, cdnBaseUrl.length - 1)
        : cdnBaseUrl;
    return '$base/uploads/$file';
  }

  @override
  bool operator ==(Object other) =>
      other is ExamDefinition &&
      other.id == id &&
      other.order == order &&
      other.kind == kind &&
      other.imageFile == imageFile;

  @override
  int get hashCode => Object.hash(id, order, kind, imageFile);
}

/// What an exam row shows (C24 `ExamRow`, `ExamCard`; board 6.2): the exam,
/// its date, its net and D/Y/B. A field the server did not send is `null` and
/// is not drawn (never a made-up zero).
@immutable
class ExamSummary {
  const ExamSummary({
    required this.id,
    required this.definition,
    this.name,
    this.publisherName,
    this.date,
    this.net,
    this.counts,
  });

  /// Id of the student's result (what the topic analysis takes).
  final String id;

  final ExamDefinition definition;

  /// "TYT Genel Deneme 9"; when missing the screen writes "tür + denemesi"
  /// (board 6.2).
  final String? name;

  /// Publisher; absent on TYT results (spec 2.12).
  final String? publisherName;

  /// When the exam was solved.
  final DateTime? date;

  /// The net the server calculated.
  final double? net;

  /// Doğru / Yanlış / Boş; `null` unless all three came.
  final DybCounts? counts;

  /// TYT or AYT.
  NetExamType? get kind => definition.kind;

  @override
  bool operator ==(Object other) =>
      other is ExamSummary &&
      other.id == id &&
      other.definition == definition &&
      other.name == name &&
      other.publisherName == publisherName &&
      other.date == date &&
      other.net == net &&
      other.counts == counts;

  @override
  int get hashCode =>
      Object.hash(id, definition, name, publisherName, date, net, counts);
}
