// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../analytics_answers.dart';

class TotalDtoMapper extends ClassMapperBase<TotalDto> {
  TotalDtoMapper._();

  static TotalDtoMapper? _instance;
  static TotalDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TotalDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TotalDto';

  static int? _$count(TotalDto v) => v.count;
  static const Field<TotalDto, int> _f$count = Field(
    'count',
    _$count,
    opt: true,
    hook: IntOrNullHook(),
  );
  static double? _$averageNet(TotalDto v) => v.averageNet;
  static const Field<TotalDto, double> _f$averageNet = Field(
    'averageNet',
    _$averageNet,
    key: r'ortNet',
    opt: true,
    hook: DoubleOrNullHook(),
  );
  static List<String?>? _$labels(TotalDto v) => v.labels;
  static const Field<TotalDto, List<String?>> _f$labels = Field(
    'labels',
    _$labels,
    key: r'lessOrSubjects',
    opt: true,
    hook: TextSlotsHook(),
  );
  static List<double?>? _$values(TotalDto v) => v.values;
  static const Field<TotalDto, List<double?>> _f$values = Field(
    'values',
    _$values,
    key: r'data',
    opt: true,
    hook: PointListHook(),
  );

  @override
  final MappableFields<TotalDto> fields = const {
    #count: _f$count,
    #averageNet: _f$averageNet,
    #labels: _f$labels,
    #values: _f$values,
  };
  @override
  final bool ignoreNull = true;

  static TotalDto _instantiate(DecodingData data) {
    return TotalDto(
      count: data.dec(_f$count),
      averageNet: data.dec(_f$averageNet),
      labels: data.dec(_f$labels),
      values: data.dec(_f$values),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TotalDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TotalDto>(map);
  }

  static TotalDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<TotalDto>(json);
  }
}

mixin TotalDtoMappable {
  String toJsonString() {
    return TotalDtoMapper.ensureInitialized().encodeJson<TotalDto>(
      this as TotalDto,
    );
  }

  Map<String, dynamic> toJson() {
    return TotalDtoMapper.ensureInitialized().encodeMap<TotalDto>(
      this as TotalDto,
    );
  }

  TotalDtoCopyWith<TotalDto, TotalDto, TotalDto> get copyWith =>
      _TotalDtoCopyWithImpl<TotalDto, TotalDto>(
        this as TotalDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TotalDtoMapper.ensureInitialized().stringifyValue(this as TotalDto);
  }

  @override
  bool operator ==(Object other) {
    return TotalDtoMapper.ensureInitialized().equalsValue(
      this as TotalDto,
      other,
    );
  }

  @override
  int get hashCode {
    return TotalDtoMapper.ensureInitialized().hashValue(this as TotalDto);
  }
}

extension TotalDtoValueCopy<$R, $Out> on ObjectCopyWith<$R, TotalDto, $Out> {
  TotalDtoCopyWith<$R, TotalDto, $Out> get $asTotalDto =>
      $base.as((v, t, t2) => _TotalDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TotalDtoCopyWith<$R, $In extends TotalDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String?, ObjectCopyWith<$R, String?, String?>?>? get labels;
  ListCopyWith<$R, double?, ObjectCopyWith<$R, double?, double?>?>? get values;
  $R call({
    int? count,
    double? averageNet,
    List<String?>? labels,
    List<double?>? values,
  });
  TotalDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TotalDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TotalDto, $Out>
    implements TotalDtoCopyWith<$R, TotalDto, $Out> {
  _TotalDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TotalDto> $mapper =
      TotalDtoMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String?, ObjectCopyWith<$R, String?, String?>?>?
  get labels => $value.labels != null
      ? ListCopyWith(
          $value.labels!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(labels: v),
        )
      : null;
  @override
  ListCopyWith<$R, double?, ObjectCopyWith<$R, double?, double?>?>?
  get values => $value.values != null
      ? ListCopyWith(
          $value.values!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(values: v),
        )
      : null;
  @override
  $R call({
    Object? count = $none,
    Object? averageNet = $none,
    Object? labels = $none,
    Object? values = $none,
  }) => $apply(
    FieldCopyWithData({
      if (count != $none) #count: count,
      if (averageNet != $none) #averageNet: averageNet,
      if (labels != $none) #labels: labels,
      if (values != $none) #values: values,
    }),
  );
  @override
  TotalDto $make(CopyWithData data) => TotalDto(
    count: data.get(#count, or: $value.count),
    averageNet: data.get(#averageNet, or: $value.averageNet),
    labels: data.get(#labels, or: $value.labels),
    values: data.get(#values, or: $value.values),
  );

  @override
  TotalDtoCopyWith<$R2, TotalDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TotalDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TotalItemDtoMapper extends ClassMapperBase<TotalItemDto> {
  TotalItemDtoMapper._();

  static TotalItemDtoMapper? _instance;
  static TotalItemDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TotalItemDtoMapper._());
      NamedRefDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TotalItemDto';

  static NamedRefDto? _$subject(TotalItemDto v) => v.subject;
  static const Field<TotalItemDto, NamedRefDto> _f$subject = Field(
    'subject',
    _$subject,
    opt: true,
    hook: ObjectHook(),
  );
  static int? _$count(TotalItemDto v) => v.count;
  static const Field<TotalItemDto, int> _f$count = Field(
    'count',
    _$count,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$trueValue(TotalItemDto v) => v.trueValue;
  static const Field<TotalItemDto, int> _f$trueValue = Field(
    'trueValue',
    _$trueValue,
    opt: true,
    hook: IntOrNullHook(),
  );

  @override
  final MappableFields<TotalItemDto> fields = const {
    #subject: _f$subject,
    #count: _f$count,
    #trueValue: _f$trueValue,
  };
  @override
  final bool ignoreNull = true;

  static TotalItemDto _instantiate(DecodingData data) {
    return TotalItemDto(
      subject: data.dec(_f$subject),
      count: data.dec(_f$count),
      trueValue: data.dec(_f$trueValue),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TotalItemDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TotalItemDto>(map);
  }

  static TotalItemDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<TotalItemDto>(json);
  }
}

mixin TotalItemDtoMappable {
  String toJsonString() {
    return TotalItemDtoMapper.ensureInitialized().encodeJson<TotalItemDto>(
      this as TotalItemDto,
    );
  }

  Map<String, dynamic> toJson() {
    return TotalItemDtoMapper.ensureInitialized().encodeMap<TotalItemDto>(
      this as TotalItemDto,
    );
  }

  TotalItemDtoCopyWith<TotalItemDto, TotalItemDto, TotalItemDto> get copyWith =>
      _TotalItemDtoCopyWithImpl<TotalItemDto, TotalItemDto>(
        this as TotalItemDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TotalItemDtoMapper.ensureInitialized().stringifyValue(
      this as TotalItemDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return TotalItemDtoMapper.ensureInitialized().equalsValue(
      this as TotalItemDto,
      other,
    );
  }

  @override
  int get hashCode {
    return TotalItemDtoMapper.ensureInitialized().hashValue(
      this as TotalItemDto,
    );
  }
}

extension TotalItemDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TotalItemDto, $Out> {
  TotalItemDtoCopyWith<$R, TotalItemDto, $Out> get $asTotalItemDto =>
      $base.as((v, t, t2) => _TotalItemDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TotalItemDtoCopyWith<$R, $In extends TotalItemDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  NamedRefDtoCopyWith<$R, NamedRefDto, NamedRefDto>? get subject;
  $R call({NamedRefDto? subject, int? count, int? trueValue});
  TotalItemDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TotalItemDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TotalItemDto, $Out>
    implements TotalItemDtoCopyWith<$R, TotalItemDto, $Out> {
  _TotalItemDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TotalItemDto> $mapper =
      TotalItemDtoMapper.ensureInitialized();
  @override
  NamedRefDtoCopyWith<$R, NamedRefDto, NamedRefDto>? get subject =>
      $value.subject?.copyWith.$chain((v) => call(subject: v));
  @override
  $R call({
    Object? subject = $none,
    Object? count = $none,
    Object? trueValue = $none,
  }) => $apply(
    FieldCopyWithData({
      if (subject != $none) #subject: subject,
      if (count != $none) #count: count,
      if (trueValue != $none) #trueValue: trueValue,
    }),
  );
  @override
  TotalItemDto $make(CopyWithData data) => TotalItemDto(
    subject: data.get(#subject, or: $value.subject),
    count: data.get(#count, or: $value.count),
    trueValue: data.get(#trueValue, or: $value.trueValue),
  );

  @override
  TotalItemDtoCopyWith<$R2, TotalItemDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TotalItemDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TotalResponseMapper extends ClassMapperBase<TotalResponse> {
  TotalResponseMapper._();

  static TotalResponseMapper? _instance;
  static TotalResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TotalResponseMapper._());
      TotalDtoMapper.ensureInitialized();
      TotalItemDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TotalResponse';

  static bool? _$success(TotalResponse v) => v.success;
  static const Field<TotalResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(TotalResponse v) => v.message;
  static const Field<TotalResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static TotalDto? _$total(TotalResponse v) => v.total;
  static const Field<TotalResponse, TotalDto> _f$total = Field(
    'total',
    _$total,
    opt: true,
    hook: ObjectHook(),
  );
  static List<TotalItemDto>? _$items(TotalResponse v) => v.items;
  static const Field<TotalResponse, List<TotalItemDto>> _f$items = Field(
    'items',
    _$items,
    opt: true,
    hook: MapListHook(),
  );

  @override
  final MappableFields<TotalResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #total: _f$total,
    #items: _f$items,
  };
  @override
  final bool ignoreNull = true;

  static TotalResponse _instantiate(DecodingData data) {
    return TotalResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      total: data.dec(_f$total),
      items: data.dec(_f$items),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TotalResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TotalResponse>(map);
  }

  static TotalResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<TotalResponse>(json);
  }
}

mixin TotalResponseMappable {
  String toJsonString() {
    return TotalResponseMapper.ensureInitialized().encodeJson<TotalResponse>(
      this as TotalResponse,
    );
  }

  Map<String, dynamic> toJson() {
    return TotalResponseMapper.ensureInitialized().encodeMap<TotalResponse>(
      this as TotalResponse,
    );
  }

  TotalResponseCopyWith<TotalResponse, TotalResponse, TotalResponse>
  get copyWith => _TotalResponseCopyWithImpl<TotalResponse, TotalResponse>(
    this as TotalResponse,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return TotalResponseMapper.ensureInitialized().stringifyValue(
      this as TotalResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return TotalResponseMapper.ensureInitialized().equalsValue(
      this as TotalResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return TotalResponseMapper.ensureInitialized().hashValue(
      this as TotalResponse,
    );
  }
}

extension TotalResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TotalResponse, $Out> {
  TotalResponseCopyWith<$R, TotalResponse, $Out> get $asTotalResponse =>
      $base.as((v, t, t2) => _TotalResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TotalResponseCopyWith<$R, $In extends TotalResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  TotalDtoCopyWith<$R, TotalDto, TotalDto>? get total;
  ListCopyWith<
    $R,
    TotalItemDto,
    TotalItemDtoCopyWith<$R, TotalItemDto, TotalItemDto>
  >?
  get items;
  $R call({
    bool? success,
    String? message,
    TotalDto? total,
    List<TotalItemDto>? items,
  });
  TotalResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TotalResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TotalResponse, $Out>
    implements TotalResponseCopyWith<$R, TotalResponse, $Out> {
  _TotalResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TotalResponse> $mapper =
      TotalResponseMapper.ensureInitialized();
  @override
  TotalDtoCopyWith<$R, TotalDto, TotalDto>? get total =>
      $value.total?.copyWith.$chain((v) => call(total: v));
  @override
  ListCopyWith<
    $R,
    TotalItemDto,
    TotalItemDtoCopyWith<$R, TotalItemDto, TotalItemDto>
  >?
  get items => $value.items != null
      ? ListCopyWith(
          $value.items!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(items: v),
        )
      : null;
  @override
  $R call({
    Object? success = $none,
    Object? message = $none,
    Object? total = $none,
    Object? items = $none,
  }) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
      if (total != $none) #total: total,
      if (items != $none) #items: items,
    }),
  );
  @override
  TotalResponse $make(CopyWithData data) => TotalResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    total: data.get(#total, or: $value.total),
    items: data.get(#items, or: $value.items),
  );

  @override
  TotalResponseCopyWith<$R2, TotalResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TotalResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ChartUserDtoMapper extends ClassMapperBase<ChartUserDto> {
  ChartUserDtoMapper._();

  static ChartUserDtoMapper? _instance;
  static ChartUserDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChartUserDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ChartUserDto';

  static int? _$aimType(ChartUserDto v) => v.aimType;
  static const Field<ChartUserDto, int> _f$aimType = Field(
    'aimType',
    _$aimType,
    opt: true,
    hook: IntOrNullHook(),
  );

  @override
  final MappableFields<ChartUserDto> fields = const {#aimType: _f$aimType};
  @override
  final bool ignoreNull = true;

  static ChartUserDto _instantiate(DecodingData data) {
    return ChartUserDto(aimType: data.dec(_f$aimType));
  }

  @override
  final Function instantiate = _instantiate;

  static ChartUserDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ChartUserDto>(map);
  }

  static ChartUserDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<ChartUserDto>(json);
  }
}

mixin ChartUserDtoMappable {
  String toJsonString() {
    return ChartUserDtoMapper.ensureInitialized().encodeJson<ChartUserDto>(
      this as ChartUserDto,
    );
  }

  Map<String, dynamic> toJson() {
    return ChartUserDtoMapper.ensureInitialized().encodeMap<ChartUserDto>(
      this as ChartUserDto,
    );
  }

  ChartUserDtoCopyWith<ChartUserDto, ChartUserDto, ChartUserDto> get copyWith =>
      _ChartUserDtoCopyWithImpl<ChartUserDto, ChartUserDto>(
        this as ChartUserDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ChartUserDtoMapper.ensureInitialized().stringifyValue(
      this as ChartUserDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ChartUserDtoMapper.ensureInitialized().equalsValue(
      this as ChartUserDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ChartUserDtoMapper.ensureInitialized().hashValue(
      this as ChartUserDto,
    );
  }
}

extension ChartUserDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ChartUserDto, $Out> {
  ChartUserDtoCopyWith<$R, ChartUserDto, $Out> get $asChartUserDto =>
      $base.as((v, t, t2) => _ChartUserDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ChartUserDtoCopyWith<$R, $In extends ChartUserDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? aimType});
  ChartUserDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ChartUserDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ChartUserDto, $Out>
    implements ChartUserDtoCopyWith<$R, ChartUserDto, $Out> {
  _ChartUserDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ChartUserDto> $mapper =
      ChartUserDtoMapper.ensureInitialized();
  @override
  $R call({Object? aimType = $none}) =>
      $apply(FieldCopyWithData({if (aimType != $none) #aimType: aimType}));
  @override
  ChartUserDto $make(CopyWithData data) =>
      ChartUserDto(aimType: data.get(#aimType, or: $value.aimType));

  @override
  ChartUserDtoCopyWith<$R2, ChartUserDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ChartUserDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class LineChartResponseMapper extends ClassMapperBase<LineChartResponse> {
  LineChartResponseMapper._();

  static LineChartResponseMapper? _instance;
  static LineChartResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LineChartResponseMapper._());
      ChartUserDtoMapper.ensureInitialized();
      MockExamDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'LineChartResponse';

  static bool? _$success(LineChartResponse v) => v.success;
  static const Field<LineChartResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(LineChartResponse v) => v.message;
  static const Field<LineChartResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static ChartUserDto? _$user(LineChartResponse v) => v.user;
  static const Field<LineChartResponse, ChartUserDto> _f$user = Field(
    'user',
    _$user,
    opt: true,
    hook: ObjectHook(),
  );
  static List<MockExamDto>? _$exams(LineChartResponse v) => v.exams;
  static const Field<LineChartResponse, List<MockExamDto>> _f$exams = Field(
    'exams',
    _$exams,
    key: r'mockexams',
    opt: true,
    hook: MapListHook(),
  );
  static int? _$totalQuestion(LineChartResponse v) => v.totalQuestion;
  static const Field<LineChartResponse, int> _f$totalQuestion = Field(
    'totalQuestion',
    _$totalQuestion,
    opt: true,
    hook: IntOrNullHook(),
  );

  @override
  final MappableFields<LineChartResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #user: _f$user,
    #exams: _f$exams,
    #totalQuestion: _f$totalQuestion,
  };
  @override
  final bool ignoreNull = true;

  static LineChartResponse _instantiate(DecodingData data) {
    return LineChartResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      user: data.dec(_f$user),
      exams: data.dec(_f$exams),
      totalQuestion: data.dec(_f$totalQuestion),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LineChartResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LineChartResponse>(map);
  }

  static LineChartResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<LineChartResponse>(json);
  }
}

mixin LineChartResponseMappable {
  String toJsonString() {
    return LineChartResponseMapper.ensureInitialized()
        .encodeJson<LineChartResponse>(this as LineChartResponse);
  }

  Map<String, dynamic> toJson() {
    return LineChartResponseMapper.ensureInitialized()
        .encodeMap<LineChartResponse>(this as LineChartResponse);
  }

  LineChartResponseCopyWith<
    LineChartResponse,
    LineChartResponse,
    LineChartResponse
  >
  get copyWith =>
      _LineChartResponseCopyWithImpl<LineChartResponse, LineChartResponse>(
        this as LineChartResponse,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return LineChartResponseMapper.ensureInitialized().stringifyValue(
      this as LineChartResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return LineChartResponseMapper.ensureInitialized().equalsValue(
      this as LineChartResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return LineChartResponseMapper.ensureInitialized().hashValue(
      this as LineChartResponse,
    );
  }
}

extension LineChartResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LineChartResponse, $Out> {
  LineChartResponseCopyWith<$R, LineChartResponse, $Out>
  get $asLineChartResponse => $base.as(
    (v, t, t2) => _LineChartResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class LineChartResponseCopyWith<
  $R,
  $In extends LineChartResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ChartUserDtoCopyWith<$R, ChartUserDto, ChartUserDto>? get user;
  ListCopyWith<
    $R,
    MockExamDto,
    MockExamDtoCopyWith<$R, MockExamDto, MockExamDto>
  >?
  get exams;
  $R call({
    bool? success,
    String? message,
    ChartUserDto? user,
    List<MockExamDto>? exams,
    int? totalQuestion,
  });
  LineChartResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _LineChartResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LineChartResponse, $Out>
    implements LineChartResponseCopyWith<$R, LineChartResponse, $Out> {
  _LineChartResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LineChartResponse> $mapper =
      LineChartResponseMapper.ensureInitialized();
  @override
  ChartUserDtoCopyWith<$R, ChartUserDto, ChartUserDto>? get user =>
      $value.user?.copyWith.$chain((v) => call(user: v));
  @override
  ListCopyWith<
    $R,
    MockExamDto,
    MockExamDtoCopyWith<$R, MockExamDto, MockExamDto>
  >?
  get exams => $value.exams != null
      ? ListCopyWith(
          $value.exams!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(exams: v),
        )
      : null;
  @override
  $R call({
    Object? success = $none,
    Object? message = $none,
    Object? user = $none,
    Object? exams = $none,
    Object? totalQuestion = $none,
  }) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
      if (user != $none) #user: user,
      if (exams != $none) #exams: exams,
      if (totalQuestion != $none) #totalQuestion: totalQuestion,
    }),
  );
  @override
  LineChartResponse $make(CopyWithData data) => LineChartResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    user: data.get(#user, or: $value.user),
    exams: data.get(#exams, or: $value.exams),
    totalQuestion: data.get(#totalQuestion, or: $value.totalQuestion),
  );

  @override
  LineChartResponseCopyWith<$R2, LineChartResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LineChartResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

