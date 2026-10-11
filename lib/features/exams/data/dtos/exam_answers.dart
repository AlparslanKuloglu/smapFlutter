import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';
import 'package:smap/features/exams/data/api_support.dart';
import 'package:smap/features/exams/data/dtos/exam_hooks.dart';
import 'package:smap/features/exams/data/dtos/lenient_list_hooks.dart';
import 'package:smap/features/exams/data/dtos/mock_exam_dto.dart';

part 'generated/exam_answers.mapper.dart';

/// Answer of `POST /student/getMyMockExams`.
@MappableClass(ignoreNull: true)
class MyMockExamsResponse
    with MyMockExamsResponseMappable
    implements ApiEnvelope {
  const MyMockExamsResponse({this.success, this.message, this.exams});

  /// A body that is not a JSON object reads as an empty answer (no flag).
  factory MyMockExamsResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const MyMockExamsResponse();
    return MyMockExamsResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  /// The page's exams (`enrichedMockExams`).
  @MappableField(key: 'enrichedMockExams', hook: MapListHook())
  final List<MockExamDto>? exams;
}

/// One topic of the topic analysis: `{trueValue, wrongValue, passValue,
/// netRate}` under its name.
@MappableClass(ignoreNull: true)
class TopicResultDto with TopicResultDtoMappable {
  const TopicResultDto({
    this.name,
    this.correct,
    this.wrong,
    this.pass,
    this.netRate,
  });

  factory TopicResultDto.fromJson(Map<String, dynamic> json) =>
      TopicResultDtoMapper.fromJson(json);

  @MappableField(hook: TextOrNullHook())
  final String? name;

  @MappableField(key: 'trueValue', hook: IntOrNullHook())
  final int? correct;

  @MappableField(key: 'wrongValue', hook: IntOrNullHook())
  final int? wrong;

  @MappableField(key: 'passValue', hook: IntOrNullHook())
  final int? pass;

  /// The server's own rate for the topic (meaning not documented; the app
  /// computes the percentage from D/Y/B).
  @MappableField(hook: DoubleOrNullHook())
  final double? netRate;
}

/// One lesson of the topic analysis: its name and its topics in the order the
/// server sorted them.
@MappableClass(ignoreNull: true)
class LessonTopicsDto with LessonTopicsDtoMappable {
  const LessonTopicsDto({this.name, this.topics});

  factory LessonTopicsDto.fromJson(Map<String, dynamic> json) =>
      LessonTopicsDtoMapper.fromJson(json);

  @MappableField(hook: TextOrNullHook())
  final String? name;

  @MappableField(hook: MapListHook())
  final List<TopicResultDto>? topics;
}

/// Answer of `GET /student/getMexamSubjectDetail`.
@MappableClass(ignoreNull: true)
class TopicAnalysisResponse
    with TopicAnalysisResponseMappable
    implements ApiEnvelope {
  const TopicAnalysisResponse({this.success, this.message, this.lessons});

  factory TopicAnalysisResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const TopicAnalysisResponse();
    return TopicAnalysisResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  /// The answer's `data`, lesson by lesson.
  @MappableField(key: 'data', hook: TopicAnalysisHook())
  final List<LessonTopicsDto>? lessons;
}

/// Card counts of one lesson in `getMexamItemDetail`.
@MappableClass(ignoreNull: true)
class LessonCardTallyDto with LessonCardTallyDtoMappable {
  const LessonCardTallyDto({
    this.lessonId,
    this.totalCards,
    this.totalItems,
    this.totalMapItems,
  });

  factory LessonCardTallyDto.fromJson(Map<String, dynamic> json) =>
      LessonCardTallyDtoMapper.fromJson(json);

  @MappableField(hook: TextOrNullHook())
  final String? lessonId;

  @MappableField(hook: IntOrNullHook())
  final int? totalCards;

  @MappableField(hook: IntOrNullHook())
  final int? totalItems;

  @MappableField(hook: IntOrNullHook())
  final int? totalMapItems;
}

/// Answer of `GET /student/getMexamItemDetail`.
@MappableClass(ignoreNull: true)
class ExamItemDetailResponse
    with ExamItemDetailResponseMappable
    implements ApiEnvelope {
  const ExamItemDetailResponse({this.success, this.message, this.lessons});

  factory ExamItemDetailResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const ExamItemDetailResponse();
    return ExamItemDetailResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  @MappableField(key: 'data', hook: LessonTallyMapHook())
  final List<LessonCardTallyDto>? lessons;
}

/// One card earned by an exam in `getTotalInfoCard`: its lesson and, when the
/// entry names it, the card's item (an id or a populated object; the card
/// deck of an exam keeps those cards only).
@MappableClass(ignoreNull: true)
class EarnedCardDto with EarnedCardDtoMappable {
  const EarnedCardDto({this.lesson, this.item});

  factory EarnedCardDto.fromJson(Map<String, dynamic> json) =>
      EarnedCardDtoMapper.fromJson(json);

  @MappableField(hook: IdRefHook())
  final String? lesson;

  @MappableField(hook: IdRefHook())
  final String? item;
}

/// Answer of `GET /student/getTotalInfoCard?mexamId=`: one entry per card the
/// exam earned.
@MappableClass(ignoreNull: true)
class TotalInfoCardResponse
    with TotalInfoCardResponseMappable
    implements ApiEnvelope {
  const TotalInfoCardResponse({this.success, this.message, this.cards});

  factory TotalInfoCardResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const TotalInfoCardResponse();
    return TotalInfoCardResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  @MappableField(key: 'data', hook: MapListHook())
  final List<EarnedCardDto>? cards;
}

/// One topic card attached to a question in `getQuestion`.
@MappableClass(ignoreNull: true)
class QuestionItemDto with QuestionItemDtoMappable {
  const QuestionItemDto({this.name, this.desc, this.mainSubject});

  factory QuestionItemDto.fromJson(Map<String, dynamic> json) =>
      QuestionItemDtoMapper.fromJson(json);

  /// The card's title (`item.name`).
  @MappableField(hook: TextOrNullHook())
  final String? name;

  /// The card text; the server sends a list of paragraphs or a text.
  @MappableField(hook: StringListHook())
  final List<String>? desc;

  /// The populated main subject (`{name}`); an id text reads as no object.
  @MappableField(hook: ObjectHook())
  final NamedRefDto? mainSubject;
}

/// A populated reference with a `name` (`mainSubject`).
@MappableClass(ignoreNull: true)
class NamedRefDto with NamedRefDtoMappable {
  const NamedRefDto({this.name});

  factory NamedRefDto.fromJson(Map<String, dynamic> json) =>
      NamedRefDtoMapper.fromJson(json);

  @MappableField(hook: TextOrNullHook())
  final String? name;
}

/// The `question` object of `getQuestion`.
@MappableClass(ignoreNull: true)
class QuestionDto with QuestionDtoMappable {
  const QuestionDto({this.desc, this.pageInfo, this.items});

  factory QuestionDto.fromJson(Map<String, dynamic> json) =>
      QuestionDtoMapper.fromJson(json);

  /// What the question asks about.
  @MappableField(hook: TextOrNullHook())
  final String? desc;

  /// Where the question sits on the optical form (`page_info`).
  @MappableField(key: 'page_info', hook: TextOrNullHook())
  final String? pageInfo;

  @MappableField(hook: MapListHook())
  final List<QuestionItemDto>? items;
}

/// Answer of `POST /student/getQuestion`.
@MappableClass(ignoreNull: true)
class QuestionResponse with QuestionResponseMappable implements ApiEnvelope {
  const QuestionResponse({this.success, this.message, this.question});

  factory QuestionResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const QuestionResponse();
    return QuestionResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  @MappableField(hook: ObjectHook())
  final QuestionDto? question;
}
