import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';
import 'package:smap/features/exams/data/api_support.dart';
import 'package:smap/features/exams/data/dtos/exam_answers.dart';
import 'package:smap/features/exams/data/dtos/exam_hooks.dart';
import 'package:smap/features/exams/data/dtos/lenient_list_hooks.dart';
import 'package:smap/features/exams/data/dtos/mock_exam_dto.dart';

part 'generated/analytics_answers.mapper.dart';

/// The `total` object of `getTotal`.
@MappableClass(ignoreNull: true)
class TotalDto with TotalDtoMappable {
  const TotalDto({this.count, this.averageNet, this.labels, this.values});

  factory TotalDto.fromJson(Map<String, dynamic> json) =>
      TotalDtoMapper.fromJson(json);

  /// Exams solved.
  @MappableField(hook: IntOrNullHook())
  final int? count;

  /// Average net (`ortNet`).
  @MappableField(key: 'ortNet', hook: DoubleOrNullHook())
  final double? averageNet;

  /// Bar labels (`lessOrSubjects`), position-aligned with [values].
  @MappableField(key: 'lessOrSubjects', hook: TextSlotsHook())
  final List<String?>? labels;

  /// Bar values (`data`), position-aligned with [labels].
  @MappableField(key: 'data', hook: PointListHook())
  final List<double?>? values;
}

/// One subject tally of `getTotal`'s `items`.
@MappableClass(ignoreNull: true)
class TotalItemDto with TotalItemDtoMappable {
  const TotalItemDto({this.subject, this.count, this.trueValue});

  factory TotalItemDto.fromJson(Map<String, dynamic> json) =>
      TotalItemDtoMapper.fromJson(json);

  @MappableField(hook: ObjectHook())
  final NamedRefDto? subject;

  @MappableField(hook: IntOrNullHook())
  final int? count;

  /// Questions answered right.
  @MappableField(hook: IntOrNullHook())
  final int? trueValue;
}

/// Answer of `GET /student/getTotal`.
@MappableClass(ignoreNull: true)
class TotalResponse with TotalResponseMappable implements ApiEnvelope {
  const TotalResponse({this.success, this.message, this.total, this.items});

  factory TotalResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const TotalResponse();
    return TotalResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  @MappableField(hook: ObjectHook())
  final TotalDto? total;

  @MappableField(hook: MapListHook())
  final List<TotalItemDto>? items;
}

/// The `user` object of `getLineChartData`: only the AYT field is read.
@MappableClass(ignoreNull: true)
class ChartUserDto with ChartUserDtoMappable {
  const ChartUserDto({this.aimType});

  factory ChartUserDto.fromJson(Map<String, dynamic> json) =>
      ChartUserDtoMapper.fromJson(json);

  @MappableField(hook: IntOrNullHook())
  final int? aimType;
}

/// Answer of `GET /student/getLineChartData`: the exams of the scope
/// (`mockexams`, the same documents `getMyMockExams` lists), the question
/// count and the user.
@MappableClass(ignoreNull: true)
class LineChartResponse with LineChartResponseMappable implements ApiEnvelope {
  const LineChartResponse({
    this.success,
    this.message,
    this.user,
    this.exams,
    this.totalQuestion,
  });

  factory LineChartResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const LineChartResponse();
    return LineChartResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  @MappableField(hook: ObjectHook())
  final ChartUserDto? user;

  @MappableField(key: 'mockexams', hook: MapListHook())
  final List<MockExamDto>? exams;

  @MappableField(hook: IntOrNullHook())
  final int? totalQuestion;
}
