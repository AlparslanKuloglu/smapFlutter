import 'package:flutter/foundation.dart';

import 'package:smap/core/errors/app_result.dart';

/// The two rules of the coach's attention list (decision D-27; pano 10.1 kare
/// 2). There is no third: goals, homework and sign-in frequency are not
/// shown (D-3).
enum AttentionRule {
  /// 14 days or more without a read exam: "45 gündür deneme okutmadı".
  inactive,

  /// The net fell in the last two exams of the same type: "Son iki TYT
  /// denemesinde net düştü".
  netDrop,
}

/// One student the attention list names, with the evidence of the rule (the
/// server works the rules out each night and when an exam is read; the app
/// does not decide who needs attention).
///
/// The evidence fields are nullable: a row whose evidence is missing is drawn
/// without that line, never with a made-up value. [AttentionItem.inactive]
/// always has its day count (the sentence needs it).
@immutable
class AttentionItem {
  /// A student with no exam read for [daysSinceLastExam] days (14 or more).
  const AttentionItem.inactive({
    required this.studentId,
    required this.name,
    required int this.daysSinceLastExam,
    this.photo,
    this.lastExamAt,
    this.examType,
  }) : rule = AttentionRule.inactive,
       previousNet = null,
       latestNet = null,
       previousExamAt = null,
       latestExamAt = null;

  /// A student whose net fell between the last two exams of the same type.
  const AttentionItem.netDrop({
    required this.studentId,
    required this.name,
    this.photo,
    this.examType,
    this.previousNet,
    this.latestNet,
    this.previousExamAt,
    this.latestExamAt,
  }) : rule = AttentionRule.netDrop,
       daysSinceLastExam = null,
       lastExamAt = null;

  /// The student's id (what the profile screen is opened with).
  final String studentId;

  /// "Alparslan Kuloğlu".
  final String name;

  /// The avatar file name; the initials show without it.
  final String? photo;

  final AttentionRule rule;

  /// [AttentionRule.inactive]: whole days since the last exam was read.
  final int? daysSinceLastExam;

  /// [AttentionRule.inactive]: when it was read.
  final DateTime? lastExamAt;

  /// The exam type of the evidence ("TYT", "AYT"); in the sentence of
  /// [AttentionRule.netDrop] and after the date of [AttentionRule.inactive].
  final String? examType;

  /// [AttentionRule.netDrop]: the net of the earlier of the two exams.
  final double? previousNet;

  /// [AttentionRule.netDrop]: the net of the later one.
  final double? latestNet;

  /// [AttentionRule.netDrop]: the earlier exam's date.
  final DateTime? previousExamAt;

  /// [AttentionRule.netDrop]: the later exam's date.
  final DateTime? latestExamAt;

  @override
  bool operator ==(Object other) =>
      other is AttentionItem &&
      other.studentId == studentId &&
      other.name == name &&
      other.photo == photo &&
      other.rule == rule &&
      other.daysSinceLastExam == daysSinceLastExam &&
      other.lastExamAt == lastExamAt &&
      other.examType == examType &&
      other.previousNet == previousNet &&
      other.latestNet == latestNet &&
      other.previousExamAt == previousExamAt &&
      other.latestExamAt == latestExamAt;

  @override
  int get hashCode => Object.hash(
    studentId,
    name,
    photo,
    rule,
    daysSinceLastExam,
    lastExamAt,
    examType,
    previousNet,
    latestNet,
    previousExamAt,
    latestExamAt,
  );
}

/// Where the attention list comes from: a server endpoint that does not exist
/// yet (spec §6.3 #28, #29), so no implementation is registered and
/// `FeatureFlags.attentionListEnabled` is closed. The coach home reads it only
/// when the flag is open; the day the endpoint lands, implement this over it
/// and register it in the `session` scope.
// ignore: one_member_abstracts
abstract interface class AttentionRepository {
  /// The students that need attention now; empty when there are none.
  Future<AppResult<List<AttentionItem>>> getAttentionList();
}
