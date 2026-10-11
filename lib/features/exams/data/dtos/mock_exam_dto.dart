import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';
import 'package:smap/features/exams/data/dtos/exam_hooks.dart';
import 'package:smap/features/exams/data/dtos/lenient_list_hooks.dart';

part 'generated/mock_exam_dto.mapper.dart';

/// The exam a result belongs to (`mexam` inside a mock-exam result): which
/// exam it was and its cover.
///
/// Fields come from the legacy readers (`mexam.order`, `mexam.image`,
/// `mexam.type`, `mexam._id`). [raw] is the object as the server sent it, kept
/// only so `getQuestion` can post it back unchanged.
@MappableClass(ignoreNull: true, hook: KeepRawObjectHook())
class ExamDefinitionDto with ExamDefinitionDtoMappable {
  const ExamDefinitionDto({
    this.id,
    this.order,
    this.type,
    this.image,
    this.raw,
  });

  factory ExamDefinitionDto.fromJson(Map<String, dynamic> json) =>
      ExamDefinitionDtoMapper.fromJson(json);

  /// Mongo `_id` of the exam.
  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  /// "Deneme: 9": the exam's number.
  @MappableField(hook: IntOrNullHook())
  final int? order;

  /// `1` TYT, `2` AYT (the legacy `mexam.type == 1` rule).
  @MappableField(hook: IntOrNullHook())
  final int? type;

  /// Cover file name under `/uploads/`, or a full URL.
  @MappableField(hook: TextOrNullHook())
  final String? image;

  /// The object exactly as received.
  @MappableField(hook: ObjectHook())
  final Map<String, dynamic>? raw;
}

/// `{net, true, wrong, pass}`: the numbers of one test (`lessonInfo` entry) or
/// of one score type (`aytNets` entry). Every field is optional.
@MappableClass(ignoreNull: true)
class NetBreakdownDto with NetBreakdownDtoMappable {
  const NetBreakdownDto({this.net, this.correct, this.wrong, this.pass});

  factory NetBreakdownDto.fromJson(Map<String, dynamic> json) =>
      NetBreakdownDtoMapper.fromJson(json);

  @MappableField(hook: DoubleOrNullHook())
  final double? net;

  /// The server key is `true`.
  @MappableField(key: 'true', hook: IntOrNullHook())
  final int? correct;

  @MappableField(hook: IntOrNullHook())
  final int? wrong;

  /// Blank answers.
  @MappableField(hook: IntOrNullHook())
  final int? pass;
}

/// One lesson of a mock exam (`lessonmockexams` / `lessonMockExams` entry):
/// `{lesson, net, true, wrong, pass}`.
@MappableClass(ignoreNull: true)
class LessonResultDto with LessonResultDtoMappable {
  const LessonResultDto({
    this.lesson,
    this.net,
    this.correct,
    this.wrong,
    this.pass,
  });

  factory LessonResultDto.fromJson(Map<String, dynamic> json) =>
      LessonResultDtoMapper.fromJson(json);

  /// Id of the lesson (`TYT Türkçe`, ...), the catalog's lesson ids.
  @MappableField(hook: IdRefHook())
  final String? lesson;

  @MappableField(hook: DoubleOrNullHook())
  final double? net;

  @MappableField(key: 'true', hook: IntOrNullHook())
  final int? correct;

  @MappableField(hook: IntOrNullHook())
  final int? wrong;

  @MappableField(hook: IntOrNullHook())
  final int? pass;
}

/// One question cell of `questionsArrStr`: `{order, type}`. `type` is `1`
/// right, `3` wrong, anything else blank (the legacy reading).
@MappableClass(ignoreNull: true)
class QuestionCellDto with QuestionCellDtoMappable {
  const QuestionCellDto({this.order, this.type});

  factory QuestionCellDto.fromJson(Map<String, dynamic> json) =>
      QuestionCellDtoMapper.fromJson(json);

  @MappableField(hook: IntOrNullHook())
  final int? order;

  @MappableField(hook: IntOrNullHook())
  final int? type;
}

/// The questions of one test of the exam (one list of `questionsArrStr`).
@MappableClass(ignoreNull: true)
class QuestionGroupDto with QuestionGroupDtoMappable {
  const QuestionGroupDto({this.cells});

  factory QuestionGroupDto.fromJson(Map<String, dynamic> json) =>
      QuestionGroupDtoMapper.fromJson(json);

  @MappableField(hook: MapListHook())
  final List<QuestionCellDto>? cells;
}

/// A student's result of one mock exam, as `getMyMockExams` lists it and as
/// the `answerArray` answer's `mexamFound` carries it (same shape, one extra
/// spelling of the lesson list).
///
/// Everything is optional; the mapper decides what is usable. Fields read by
/// the legacy screens: `itemName`, `publisherName`, `net`, `true`, `wrong`,
/// `pass`, `mexam`, `points`, `pointsHam`, `ranks`, `ranksHam`, `aytNets`,
/// `lessonmockexams`, `lessonInfo`, `questionsArrStr`, `isStarred`; `date` is
/// in the spec's list answer.
@MappableClass(ignoreNull: true, hook: LessonResultsAliasHook())
class MockExamDto with MockExamDtoMappable {
  const MockExamDto({
    this.id,
    this.itemName,
    this.publisherName,
    this.mexam,
    this.net,
    this.correct,
    this.wrong,
    this.pass,
    this.points,
    this.pointsHam,
    this.ranks,
    this.ranksHam,
    this.aytNets,
    this.lessonResults,
    this.lessonInfo,
    this.questionGroups,
    this.date,
    this.isStarred,
  });

  factory MockExamDto.fromJson(Map<String, dynamic> json) =>
      MockExamDtoMapper.fromJson(json);

  /// Mongo `_id` of the result (what `getMexamSubjectDetail` takes).
  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  /// "TYT Genel Deneme 9".
  @MappableField(hook: TextOrNullHook())
  final String? itemName;

  @MappableField(hook: TextOrNullHook())
  final String? publisherName;

  @MappableField(hook: ObjectHook())
  final ExamDefinitionDto? mexam;

  @MappableField(hook: DoubleOrNullHook())
  final double? net;

  @MappableField(key: 'true', hook: IntOrNullHook())
  final int? correct;

  @MappableField(hook: IntOrNullHook())
  final int? wrong;

  /// Blank answers.
  @MappableField(hook: IntOrNullHook())
  final int? pass;

  /// Placement points per score type; slot 0 is TYT, AYT uses slots 2 to 4.
  @MappableField(hook: PointListHook())
  final List<double?>? points;

  /// Raw (ham) points, same slots as [points].
  @MappableField(hook: PointListHook())
  final List<double?>? pointsHam;

  @MappableField(hook: RankListHook())
  final List<int?>? ranks;

  @MappableField(hook: RankListHook())
  final List<int?>? ranksHam;

  /// AYT net per score type, keyed `"2"`, `"3"`, `"4"`.
  @MappableField(hook: AytNetsHook())
  final Map<String, NetBreakdownDto>? aytNets;

  /// Per-lesson results (`lessonmockexams`, also read from `lessonMockExams`).
  @MappableField(key: 'lessonmockexams', hook: MapListHook())
  final List<LessonResultDto>? lessonResults;

  /// Per-test D/Y/B (a JSON string on the wire).
  @MappableField(hook: JsonPositionalMapListHook())
  final List<NetBreakdownDto>? lessonInfo;

  /// The questions of every test (`questionsArrStr`, a JSON string on the
  /// wire).
  @MappableField(key: 'questionsArrStr', hook: QuestionGroupsHook())
  final List<QuestionGroupDto>? questionGroups;

  @MappableField(hook: DateOrNullHook())
  final DateTime? date;

  /// The server's star; the app keeps favourites on the device (spec §6.3 #40)
  /// and ignores this.
  @MappableField(hook: BoolOrNullHook())
  final bool? isStarred;
}
