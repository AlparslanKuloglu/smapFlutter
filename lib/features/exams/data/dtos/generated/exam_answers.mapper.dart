// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../exam_answers.dart';

class MyMockExamsResponseMapper extends ClassMapperBase<MyMockExamsResponse> {
  MyMockExamsResponseMapper._();

  static MyMockExamsResponseMapper? _instance;
  static MyMockExamsResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MyMockExamsResponseMapper._());
      MockExamDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MyMockExamsResponse';

  static bool? _$success(MyMockExamsResponse v) => v.success;
  static const Field<MyMockExamsResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(MyMockExamsResponse v) => v.message;
  static const Field<MyMockExamsResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<MockExamDto>? _$exams(MyMockExamsResponse v) => v.exams;
  static const Field<MyMockExamsResponse, List<MockExamDto>> _f$exams = Field(
    'exams',
    _$exams,
    key: r'enrichedMockExams',
    opt: true,
    hook: MapListHook(),
  );

  @override
  final MappableFields<MyMockExamsResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #exams: _f$exams,
  };
  @override
  final bool ignoreNull = true;

  static MyMockExamsResponse _instantiate(DecodingData data) {
    return MyMockExamsResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      exams: data.dec(_f$exams),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MyMockExamsResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MyMockExamsResponse>(map);
  }

  static MyMockExamsResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<MyMockExamsResponse>(json);
  }
}

mixin MyMockExamsResponseMappable {
  String toJsonString() {
    return MyMockExamsResponseMapper.ensureInitialized()
        .encodeJson<MyMockExamsResponse>(this as MyMockExamsResponse);
  }

  Map<String, dynamic> toJson() {
    return MyMockExamsResponseMapper.ensureInitialized()
        .encodeMap<MyMockExamsResponse>(this as MyMockExamsResponse);
  }

  MyMockExamsResponseCopyWith<
    MyMockExamsResponse,
    MyMockExamsResponse,
    MyMockExamsResponse
  >
  get copyWith =>
      _MyMockExamsResponseCopyWithImpl<
        MyMockExamsResponse,
        MyMockExamsResponse
      >(this as MyMockExamsResponse, $identity, $identity);
  @override
  String toString() {
    return MyMockExamsResponseMapper.ensureInitialized().stringifyValue(
      this as MyMockExamsResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return MyMockExamsResponseMapper.ensureInitialized().equalsValue(
      this as MyMockExamsResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return MyMockExamsResponseMapper.ensureInitialized().hashValue(
      this as MyMockExamsResponse,
    );
  }
}

extension MyMockExamsResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MyMockExamsResponse, $Out> {
  MyMockExamsResponseCopyWith<$R, MyMockExamsResponse, $Out>
  get $asMyMockExamsResponse => $base.as(
    (v, t, t2) => _MyMockExamsResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class MyMockExamsResponseCopyWith<
  $R,
  $In extends MyMockExamsResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    MockExamDto,
    MockExamDtoCopyWith<$R, MockExamDto, MockExamDto>
  >?
  get exams;
  $R call({bool? success, String? message, List<MockExamDto>? exams});
  MyMockExamsResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MyMockExamsResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MyMockExamsResponse, $Out>
    implements MyMockExamsResponseCopyWith<$R, MyMockExamsResponse, $Out> {
  _MyMockExamsResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MyMockExamsResponse> $mapper =
      MyMockExamsResponseMapper.ensureInitialized();
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
    Object? exams = $none,
  }) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
      if (exams != $none) #exams: exams,
    }),
  );
  @override
  MyMockExamsResponse $make(CopyWithData data) => MyMockExamsResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    exams: data.get(#exams, or: $value.exams),
  );

  @override
  MyMockExamsResponseCopyWith<$R2, MyMockExamsResponse, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MyMockExamsResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TopicResultDtoMapper extends ClassMapperBase<TopicResultDto> {
  TopicResultDtoMapper._();

  static TopicResultDtoMapper? _instance;
  static TopicResultDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TopicResultDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TopicResultDto';

  static String? _$name(TopicResultDto v) => v.name;
  static const Field<TopicResultDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$correct(TopicResultDto v) => v.correct;
  static const Field<TopicResultDto, int> _f$correct = Field(
    'correct',
    _$correct,
    key: r'trueValue',
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$wrong(TopicResultDto v) => v.wrong;
  static const Field<TopicResultDto, int> _f$wrong = Field(
    'wrong',
    _$wrong,
    key: r'wrongValue',
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$pass(TopicResultDto v) => v.pass;
  static const Field<TopicResultDto, int> _f$pass = Field(
    'pass',
    _$pass,
    key: r'passValue',
    opt: true,
    hook: IntOrNullHook(),
  );
  static double? _$netRate(TopicResultDto v) => v.netRate;
  static const Field<TopicResultDto, double> _f$netRate = Field(
    'netRate',
    _$netRate,
    opt: true,
    hook: DoubleOrNullHook(),
  );

  @override
  final MappableFields<TopicResultDto> fields = const {
    #name: _f$name,
    #correct: _f$correct,
    #wrong: _f$wrong,
    #pass: _f$pass,
    #netRate: _f$netRate,
  };
  @override
  final bool ignoreNull = true;

  static TopicResultDto _instantiate(DecodingData data) {
    return TopicResultDto(
      name: data.dec(_f$name),
      correct: data.dec(_f$correct),
      wrong: data.dec(_f$wrong),
      pass: data.dec(_f$pass),
      netRate: data.dec(_f$netRate),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TopicResultDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TopicResultDto>(map);
  }

  static TopicResultDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<TopicResultDto>(json);
  }
}

mixin TopicResultDtoMappable {
  String toJsonString() {
    return TopicResultDtoMapper.ensureInitialized().encodeJson<TopicResultDto>(
      this as TopicResultDto,
    );
  }

  Map<String, dynamic> toJson() {
    return TopicResultDtoMapper.ensureInitialized().encodeMap<TopicResultDto>(
      this as TopicResultDto,
    );
  }

  TopicResultDtoCopyWith<TopicResultDto, TopicResultDto, TopicResultDto>
  get copyWith => _TopicResultDtoCopyWithImpl<TopicResultDto, TopicResultDto>(
    this as TopicResultDto,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return TopicResultDtoMapper.ensureInitialized().stringifyValue(
      this as TopicResultDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return TopicResultDtoMapper.ensureInitialized().equalsValue(
      this as TopicResultDto,
      other,
    );
  }

  @override
  int get hashCode {
    return TopicResultDtoMapper.ensureInitialized().hashValue(
      this as TopicResultDto,
    );
  }
}

extension TopicResultDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TopicResultDto, $Out> {
  TopicResultDtoCopyWith<$R, TopicResultDto, $Out> get $asTopicResultDto =>
      $base.as((v, t, t2) => _TopicResultDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TopicResultDtoCopyWith<$R, $In extends TopicResultDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? name, int? correct, int? wrong, int? pass, double? netRate});
  TopicResultDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TopicResultDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TopicResultDto, $Out>
    implements TopicResultDtoCopyWith<$R, TopicResultDto, $Out> {
  _TopicResultDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TopicResultDto> $mapper =
      TopicResultDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? name = $none,
    Object? correct = $none,
    Object? wrong = $none,
    Object? pass = $none,
    Object? netRate = $none,
  }) => $apply(
    FieldCopyWithData({
      if (name != $none) #name: name,
      if (correct != $none) #correct: correct,
      if (wrong != $none) #wrong: wrong,
      if (pass != $none) #pass: pass,
      if (netRate != $none) #netRate: netRate,
    }),
  );
  @override
  TopicResultDto $make(CopyWithData data) => TopicResultDto(
    name: data.get(#name, or: $value.name),
    correct: data.get(#correct, or: $value.correct),
    wrong: data.get(#wrong, or: $value.wrong),
    pass: data.get(#pass, or: $value.pass),
    netRate: data.get(#netRate, or: $value.netRate),
  );

  @override
  TopicResultDtoCopyWith<$R2, TopicResultDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TopicResultDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class LessonTopicsDtoMapper extends ClassMapperBase<LessonTopicsDto> {
  LessonTopicsDtoMapper._();

  static LessonTopicsDtoMapper? _instance;
  static LessonTopicsDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LessonTopicsDtoMapper._());
      TopicResultDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'LessonTopicsDto';

  static String? _$name(LessonTopicsDto v) => v.name;
  static const Field<LessonTopicsDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<TopicResultDto>? _$topics(LessonTopicsDto v) => v.topics;
  static const Field<LessonTopicsDto, List<TopicResultDto>> _f$topics = Field(
    'topics',
    _$topics,
    opt: true,
    hook: MapListHook(),
  );

  @override
  final MappableFields<LessonTopicsDto> fields = const {
    #name: _f$name,
    #topics: _f$topics,
  };
  @override
  final bool ignoreNull = true;

  static LessonTopicsDto _instantiate(DecodingData data) {
    return LessonTopicsDto(
      name: data.dec(_f$name),
      topics: data.dec(_f$topics),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LessonTopicsDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LessonTopicsDto>(map);
  }

  static LessonTopicsDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<LessonTopicsDto>(json);
  }
}

mixin LessonTopicsDtoMappable {
  String toJsonString() {
    return LessonTopicsDtoMapper.ensureInitialized()
        .encodeJson<LessonTopicsDto>(this as LessonTopicsDto);
  }

  Map<String, dynamic> toJson() {
    return LessonTopicsDtoMapper.ensureInitialized().encodeMap<LessonTopicsDto>(
      this as LessonTopicsDto,
    );
  }

  LessonTopicsDtoCopyWith<LessonTopicsDto, LessonTopicsDto, LessonTopicsDto>
  get copyWith =>
      _LessonTopicsDtoCopyWithImpl<LessonTopicsDto, LessonTopicsDto>(
        this as LessonTopicsDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return LessonTopicsDtoMapper.ensureInitialized().stringifyValue(
      this as LessonTopicsDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return LessonTopicsDtoMapper.ensureInitialized().equalsValue(
      this as LessonTopicsDto,
      other,
    );
  }

  @override
  int get hashCode {
    return LessonTopicsDtoMapper.ensureInitialized().hashValue(
      this as LessonTopicsDto,
    );
  }
}

extension LessonTopicsDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LessonTopicsDto, $Out> {
  LessonTopicsDtoCopyWith<$R, LessonTopicsDto, $Out> get $asLessonTopicsDto =>
      $base.as((v, t, t2) => _LessonTopicsDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LessonTopicsDtoCopyWith<$R, $In extends LessonTopicsDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    TopicResultDto,
    TopicResultDtoCopyWith<$R, TopicResultDto, TopicResultDto>
  >?
  get topics;
  $R call({String? name, List<TopicResultDto>? topics});
  LessonTopicsDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _LessonTopicsDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LessonTopicsDto, $Out>
    implements LessonTopicsDtoCopyWith<$R, LessonTopicsDto, $Out> {
  _LessonTopicsDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LessonTopicsDto> $mapper =
      LessonTopicsDtoMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    TopicResultDto,
    TopicResultDtoCopyWith<$R, TopicResultDto, TopicResultDto>
  >?
  get topics => $value.topics != null
      ? ListCopyWith(
          $value.topics!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(topics: v),
        )
      : null;
  @override
  $R call({Object? name = $none, Object? topics = $none}) => $apply(
    FieldCopyWithData({
      if (name != $none) #name: name,
      if (topics != $none) #topics: topics,
    }),
  );
  @override
  LessonTopicsDto $make(CopyWithData data) => LessonTopicsDto(
    name: data.get(#name, or: $value.name),
    topics: data.get(#topics, or: $value.topics),
  );

  @override
  LessonTopicsDtoCopyWith<$R2, LessonTopicsDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LessonTopicsDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TopicAnalysisResponseMapper
    extends ClassMapperBase<TopicAnalysisResponse> {
  TopicAnalysisResponseMapper._();

  static TopicAnalysisResponseMapper? _instance;
  static TopicAnalysisResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TopicAnalysisResponseMapper._());
      LessonTopicsDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TopicAnalysisResponse';

  static bool? _$success(TopicAnalysisResponse v) => v.success;
  static const Field<TopicAnalysisResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(TopicAnalysisResponse v) => v.message;
  static const Field<TopicAnalysisResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<LessonTopicsDto>? _$lessons(TopicAnalysisResponse v) => v.lessons;
  static const Field<TopicAnalysisResponse, List<LessonTopicsDto>> _f$lessons =
      Field(
        'lessons',
        _$lessons,
        key: r'data',
        opt: true,
        hook: TopicAnalysisHook(),
      );

  @override
  final MappableFields<TopicAnalysisResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #lessons: _f$lessons,
  };
  @override
  final bool ignoreNull = true;

  static TopicAnalysisResponse _instantiate(DecodingData data) {
    return TopicAnalysisResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      lessons: data.dec(_f$lessons),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TopicAnalysisResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TopicAnalysisResponse>(map);
  }

  static TopicAnalysisResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<TopicAnalysisResponse>(json);
  }
}

mixin TopicAnalysisResponseMappable {
  String toJsonString() {
    return TopicAnalysisResponseMapper.ensureInitialized()
        .encodeJson<TopicAnalysisResponse>(this as TopicAnalysisResponse);
  }

  Map<String, dynamic> toJson() {
    return TopicAnalysisResponseMapper.ensureInitialized()
        .encodeMap<TopicAnalysisResponse>(this as TopicAnalysisResponse);
  }

  TopicAnalysisResponseCopyWith<
    TopicAnalysisResponse,
    TopicAnalysisResponse,
    TopicAnalysisResponse
  >
  get copyWith =>
      _TopicAnalysisResponseCopyWithImpl<
        TopicAnalysisResponse,
        TopicAnalysisResponse
      >(this as TopicAnalysisResponse, $identity, $identity);
  @override
  String toString() {
    return TopicAnalysisResponseMapper.ensureInitialized().stringifyValue(
      this as TopicAnalysisResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return TopicAnalysisResponseMapper.ensureInitialized().equalsValue(
      this as TopicAnalysisResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return TopicAnalysisResponseMapper.ensureInitialized().hashValue(
      this as TopicAnalysisResponse,
    );
  }
}

extension TopicAnalysisResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TopicAnalysisResponse, $Out> {
  TopicAnalysisResponseCopyWith<$R, TopicAnalysisResponse, $Out>
  get $asTopicAnalysisResponse => $base.as(
    (v, t, t2) => _TopicAnalysisResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class TopicAnalysisResponseCopyWith<
  $R,
  $In extends TopicAnalysisResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    LessonTopicsDto,
    LessonTopicsDtoCopyWith<$R, LessonTopicsDto, LessonTopicsDto>
  >?
  get lessons;
  $R call({bool? success, String? message, List<LessonTopicsDto>? lessons});
  TopicAnalysisResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TopicAnalysisResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TopicAnalysisResponse, $Out>
    implements TopicAnalysisResponseCopyWith<$R, TopicAnalysisResponse, $Out> {
  _TopicAnalysisResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TopicAnalysisResponse> $mapper =
      TopicAnalysisResponseMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    LessonTopicsDto,
    LessonTopicsDtoCopyWith<$R, LessonTopicsDto, LessonTopicsDto>
  >?
  get lessons => $value.lessons != null
      ? ListCopyWith(
          $value.lessons!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(lessons: v),
        )
      : null;
  @override
  $R call({
    Object? success = $none,
    Object? message = $none,
    Object? lessons = $none,
  }) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
      if (lessons != $none) #lessons: lessons,
    }),
  );
  @override
  TopicAnalysisResponse $make(CopyWithData data) => TopicAnalysisResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    lessons: data.get(#lessons, or: $value.lessons),
  );

  @override
  TopicAnalysisResponseCopyWith<$R2, TopicAnalysisResponse, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _TopicAnalysisResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class LessonCardTallyDtoMapper extends ClassMapperBase<LessonCardTallyDto> {
  LessonCardTallyDtoMapper._();

  static LessonCardTallyDtoMapper? _instance;
  static LessonCardTallyDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LessonCardTallyDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'LessonCardTallyDto';

  static String? _$lessonId(LessonCardTallyDto v) => v.lessonId;
  static const Field<LessonCardTallyDto, String> _f$lessonId = Field(
    'lessonId',
    _$lessonId,
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$totalCards(LessonCardTallyDto v) => v.totalCards;
  static const Field<LessonCardTallyDto, int> _f$totalCards = Field(
    'totalCards',
    _$totalCards,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$totalItems(LessonCardTallyDto v) => v.totalItems;
  static const Field<LessonCardTallyDto, int> _f$totalItems = Field(
    'totalItems',
    _$totalItems,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$totalMapItems(LessonCardTallyDto v) => v.totalMapItems;
  static const Field<LessonCardTallyDto, int> _f$totalMapItems = Field(
    'totalMapItems',
    _$totalMapItems,
    opt: true,
    hook: IntOrNullHook(),
  );

  @override
  final MappableFields<LessonCardTallyDto> fields = const {
    #lessonId: _f$lessonId,
    #totalCards: _f$totalCards,
    #totalItems: _f$totalItems,
    #totalMapItems: _f$totalMapItems,
  };
  @override
  final bool ignoreNull = true;

  static LessonCardTallyDto _instantiate(DecodingData data) {
    return LessonCardTallyDto(
      lessonId: data.dec(_f$lessonId),
      totalCards: data.dec(_f$totalCards),
      totalItems: data.dec(_f$totalItems),
      totalMapItems: data.dec(_f$totalMapItems),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LessonCardTallyDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LessonCardTallyDto>(map);
  }

  static LessonCardTallyDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<LessonCardTallyDto>(json);
  }
}

mixin LessonCardTallyDtoMappable {
  String toJsonString() {
    return LessonCardTallyDtoMapper.ensureInitialized()
        .encodeJson<LessonCardTallyDto>(this as LessonCardTallyDto);
  }

  Map<String, dynamic> toJson() {
    return LessonCardTallyDtoMapper.ensureInitialized()
        .encodeMap<LessonCardTallyDto>(this as LessonCardTallyDto);
  }

  LessonCardTallyDtoCopyWith<
    LessonCardTallyDto,
    LessonCardTallyDto,
    LessonCardTallyDto
  >
  get copyWith =>
      _LessonCardTallyDtoCopyWithImpl<LessonCardTallyDto, LessonCardTallyDto>(
        this as LessonCardTallyDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return LessonCardTallyDtoMapper.ensureInitialized().stringifyValue(
      this as LessonCardTallyDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return LessonCardTallyDtoMapper.ensureInitialized().equalsValue(
      this as LessonCardTallyDto,
      other,
    );
  }

  @override
  int get hashCode {
    return LessonCardTallyDtoMapper.ensureInitialized().hashValue(
      this as LessonCardTallyDto,
    );
  }
}

extension LessonCardTallyDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LessonCardTallyDto, $Out> {
  LessonCardTallyDtoCopyWith<$R, LessonCardTallyDto, $Out>
  get $asLessonCardTallyDto => $base.as(
    (v, t, t2) => _LessonCardTallyDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class LessonCardTallyDtoCopyWith<
  $R,
  $In extends LessonCardTallyDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? lessonId,
    int? totalCards,
    int? totalItems,
    int? totalMapItems,
  });
  LessonCardTallyDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _LessonCardTallyDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LessonCardTallyDto, $Out>
    implements LessonCardTallyDtoCopyWith<$R, LessonCardTallyDto, $Out> {
  _LessonCardTallyDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LessonCardTallyDto> $mapper =
      LessonCardTallyDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? lessonId = $none,
    Object? totalCards = $none,
    Object? totalItems = $none,
    Object? totalMapItems = $none,
  }) => $apply(
    FieldCopyWithData({
      if (lessonId != $none) #lessonId: lessonId,
      if (totalCards != $none) #totalCards: totalCards,
      if (totalItems != $none) #totalItems: totalItems,
      if (totalMapItems != $none) #totalMapItems: totalMapItems,
    }),
  );
  @override
  LessonCardTallyDto $make(CopyWithData data) => LessonCardTallyDto(
    lessonId: data.get(#lessonId, or: $value.lessonId),
    totalCards: data.get(#totalCards, or: $value.totalCards),
    totalItems: data.get(#totalItems, or: $value.totalItems),
    totalMapItems: data.get(#totalMapItems, or: $value.totalMapItems),
  );

  @override
  LessonCardTallyDtoCopyWith<$R2, LessonCardTallyDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LessonCardTallyDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ExamItemDetailResponseMapper
    extends ClassMapperBase<ExamItemDetailResponse> {
  ExamItemDetailResponseMapper._();

  static ExamItemDetailResponseMapper? _instance;
  static ExamItemDetailResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ExamItemDetailResponseMapper._());
      LessonCardTallyDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ExamItemDetailResponse';

  static bool? _$success(ExamItemDetailResponse v) => v.success;
  static const Field<ExamItemDetailResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(ExamItemDetailResponse v) => v.message;
  static const Field<ExamItemDetailResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<LessonCardTallyDto>? _$lessons(ExamItemDetailResponse v) =>
      v.lessons;
  static const Field<ExamItemDetailResponse, List<LessonCardTallyDto>>
  _f$lessons = Field(
    'lessons',
    _$lessons,
    key: r'data',
    opt: true,
    hook: LessonTallyMapHook(),
  );

  @override
  final MappableFields<ExamItemDetailResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #lessons: _f$lessons,
  };
  @override
  final bool ignoreNull = true;

  static ExamItemDetailResponse _instantiate(DecodingData data) {
    return ExamItemDetailResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      lessons: data.dec(_f$lessons),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ExamItemDetailResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ExamItemDetailResponse>(map);
  }

  static ExamItemDetailResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<ExamItemDetailResponse>(json);
  }
}

mixin ExamItemDetailResponseMappable {
  String toJsonString() {
    return ExamItemDetailResponseMapper.ensureInitialized()
        .encodeJson<ExamItemDetailResponse>(this as ExamItemDetailResponse);
  }

  Map<String, dynamic> toJson() {
    return ExamItemDetailResponseMapper.ensureInitialized()
        .encodeMap<ExamItemDetailResponse>(this as ExamItemDetailResponse);
  }

  ExamItemDetailResponseCopyWith<
    ExamItemDetailResponse,
    ExamItemDetailResponse,
    ExamItemDetailResponse
  >
  get copyWith =>
      _ExamItemDetailResponseCopyWithImpl<
        ExamItemDetailResponse,
        ExamItemDetailResponse
      >(this as ExamItemDetailResponse, $identity, $identity);
  @override
  String toString() {
    return ExamItemDetailResponseMapper.ensureInitialized().stringifyValue(
      this as ExamItemDetailResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return ExamItemDetailResponseMapper.ensureInitialized().equalsValue(
      this as ExamItemDetailResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return ExamItemDetailResponseMapper.ensureInitialized().hashValue(
      this as ExamItemDetailResponse,
    );
  }
}

extension ExamItemDetailResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ExamItemDetailResponse, $Out> {
  ExamItemDetailResponseCopyWith<$R, ExamItemDetailResponse, $Out>
  get $asExamItemDetailResponse => $base.as(
    (v, t, t2) => _ExamItemDetailResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ExamItemDetailResponseCopyWith<
  $R,
  $In extends ExamItemDetailResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    LessonCardTallyDto,
    LessonCardTallyDtoCopyWith<$R, LessonCardTallyDto, LessonCardTallyDto>
  >?
  get lessons;
  $R call({bool? success, String? message, List<LessonCardTallyDto>? lessons});
  ExamItemDetailResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ExamItemDetailResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ExamItemDetailResponse, $Out>
    implements
        ExamItemDetailResponseCopyWith<$R, ExamItemDetailResponse, $Out> {
  _ExamItemDetailResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ExamItemDetailResponse> $mapper =
      ExamItemDetailResponseMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    LessonCardTallyDto,
    LessonCardTallyDtoCopyWith<$R, LessonCardTallyDto, LessonCardTallyDto>
  >?
  get lessons => $value.lessons != null
      ? ListCopyWith(
          $value.lessons!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(lessons: v),
        )
      : null;
  @override
  $R call({
    Object? success = $none,
    Object? message = $none,
    Object? lessons = $none,
  }) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
      if (lessons != $none) #lessons: lessons,
    }),
  );
  @override
  ExamItemDetailResponse $make(CopyWithData data) => ExamItemDetailResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    lessons: data.get(#lessons, or: $value.lessons),
  );

  @override
  ExamItemDetailResponseCopyWith<$R2, ExamItemDetailResponse, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ExamItemDetailResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class EarnedCardDtoMapper extends ClassMapperBase<EarnedCardDto> {
  EarnedCardDtoMapper._();

  static EarnedCardDtoMapper? _instance;
  static EarnedCardDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = EarnedCardDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'EarnedCardDto';

  static String? _$lesson(EarnedCardDto v) => v.lesson;
  static const Field<EarnedCardDto, String> _f$lesson = Field(
    'lesson',
    _$lesson,
    opt: true,
    hook: IdRefHook(),
  );

  @override
  final MappableFields<EarnedCardDto> fields = const {#lesson: _f$lesson};
  @override
  final bool ignoreNull = true;

  static EarnedCardDto _instantiate(DecodingData data) {
    return EarnedCardDto(lesson: data.dec(_f$lesson));
  }

  @override
  final Function instantiate = _instantiate;

  static EarnedCardDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<EarnedCardDto>(map);
  }

  static EarnedCardDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<EarnedCardDto>(json);
  }
}

mixin EarnedCardDtoMappable {
  String toJsonString() {
    return EarnedCardDtoMapper.ensureInitialized().encodeJson<EarnedCardDto>(
      this as EarnedCardDto,
    );
  }

  Map<String, dynamic> toJson() {
    return EarnedCardDtoMapper.ensureInitialized().encodeMap<EarnedCardDto>(
      this as EarnedCardDto,
    );
  }

  EarnedCardDtoCopyWith<EarnedCardDto, EarnedCardDto, EarnedCardDto>
  get copyWith => _EarnedCardDtoCopyWithImpl<EarnedCardDto, EarnedCardDto>(
    this as EarnedCardDto,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return EarnedCardDtoMapper.ensureInitialized().stringifyValue(
      this as EarnedCardDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return EarnedCardDtoMapper.ensureInitialized().equalsValue(
      this as EarnedCardDto,
      other,
    );
  }

  @override
  int get hashCode {
    return EarnedCardDtoMapper.ensureInitialized().hashValue(
      this as EarnedCardDto,
    );
  }
}

extension EarnedCardDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, EarnedCardDto, $Out> {
  EarnedCardDtoCopyWith<$R, EarnedCardDto, $Out> get $asEarnedCardDto =>
      $base.as((v, t, t2) => _EarnedCardDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class EarnedCardDtoCopyWith<$R, $In extends EarnedCardDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? lesson});
  EarnedCardDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _EarnedCardDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, EarnedCardDto, $Out>
    implements EarnedCardDtoCopyWith<$R, EarnedCardDto, $Out> {
  _EarnedCardDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<EarnedCardDto> $mapper =
      EarnedCardDtoMapper.ensureInitialized();
  @override
  $R call({Object? lesson = $none}) =>
      $apply(FieldCopyWithData({if (lesson != $none) #lesson: lesson}));
  @override
  EarnedCardDto $make(CopyWithData data) =>
      EarnedCardDto(lesson: data.get(#lesson, or: $value.lesson));

  @override
  EarnedCardDtoCopyWith<$R2, EarnedCardDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _EarnedCardDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TotalInfoCardResponseMapper
    extends ClassMapperBase<TotalInfoCardResponse> {
  TotalInfoCardResponseMapper._();

  static TotalInfoCardResponseMapper? _instance;
  static TotalInfoCardResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TotalInfoCardResponseMapper._());
      EarnedCardDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TotalInfoCardResponse';

  static bool? _$success(TotalInfoCardResponse v) => v.success;
  static const Field<TotalInfoCardResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(TotalInfoCardResponse v) => v.message;
  static const Field<TotalInfoCardResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<EarnedCardDto>? _$cards(TotalInfoCardResponse v) => v.cards;
  static const Field<TotalInfoCardResponse, List<EarnedCardDto>> _f$cards =
      Field('cards', _$cards, key: r'data', opt: true, hook: MapListHook());

  @override
  final MappableFields<TotalInfoCardResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #cards: _f$cards,
  };
  @override
  final bool ignoreNull = true;

  static TotalInfoCardResponse _instantiate(DecodingData data) {
    return TotalInfoCardResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      cards: data.dec(_f$cards),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TotalInfoCardResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TotalInfoCardResponse>(map);
  }

  static TotalInfoCardResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<TotalInfoCardResponse>(json);
  }
}

mixin TotalInfoCardResponseMappable {
  String toJsonString() {
    return TotalInfoCardResponseMapper.ensureInitialized()
        .encodeJson<TotalInfoCardResponse>(this as TotalInfoCardResponse);
  }

  Map<String, dynamic> toJson() {
    return TotalInfoCardResponseMapper.ensureInitialized()
        .encodeMap<TotalInfoCardResponse>(this as TotalInfoCardResponse);
  }

  TotalInfoCardResponseCopyWith<
    TotalInfoCardResponse,
    TotalInfoCardResponse,
    TotalInfoCardResponse
  >
  get copyWith =>
      _TotalInfoCardResponseCopyWithImpl<
        TotalInfoCardResponse,
        TotalInfoCardResponse
      >(this as TotalInfoCardResponse, $identity, $identity);
  @override
  String toString() {
    return TotalInfoCardResponseMapper.ensureInitialized().stringifyValue(
      this as TotalInfoCardResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return TotalInfoCardResponseMapper.ensureInitialized().equalsValue(
      this as TotalInfoCardResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return TotalInfoCardResponseMapper.ensureInitialized().hashValue(
      this as TotalInfoCardResponse,
    );
  }
}

extension TotalInfoCardResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TotalInfoCardResponse, $Out> {
  TotalInfoCardResponseCopyWith<$R, TotalInfoCardResponse, $Out>
  get $asTotalInfoCardResponse => $base.as(
    (v, t, t2) => _TotalInfoCardResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class TotalInfoCardResponseCopyWith<
  $R,
  $In extends TotalInfoCardResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    EarnedCardDto,
    EarnedCardDtoCopyWith<$R, EarnedCardDto, EarnedCardDto>
  >?
  get cards;
  $R call({bool? success, String? message, List<EarnedCardDto>? cards});
  TotalInfoCardResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TotalInfoCardResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TotalInfoCardResponse, $Out>
    implements TotalInfoCardResponseCopyWith<$R, TotalInfoCardResponse, $Out> {
  _TotalInfoCardResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TotalInfoCardResponse> $mapper =
      TotalInfoCardResponseMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    EarnedCardDto,
    EarnedCardDtoCopyWith<$R, EarnedCardDto, EarnedCardDto>
  >?
  get cards => $value.cards != null
      ? ListCopyWith(
          $value.cards!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(cards: v),
        )
      : null;
  @override
  $R call({
    Object? success = $none,
    Object? message = $none,
    Object? cards = $none,
  }) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
      if (cards != $none) #cards: cards,
    }),
  );
  @override
  TotalInfoCardResponse $make(CopyWithData data) => TotalInfoCardResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    cards: data.get(#cards, or: $value.cards),
  );

  @override
  TotalInfoCardResponseCopyWith<$R2, TotalInfoCardResponse, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _TotalInfoCardResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class QuestionItemDtoMapper extends ClassMapperBase<QuestionItemDto> {
  QuestionItemDtoMapper._();

  static QuestionItemDtoMapper? _instance;
  static QuestionItemDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = QuestionItemDtoMapper._());
      NamedRefDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'QuestionItemDto';

  static String? _$name(QuestionItemDto v) => v.name;
  static const Field<QuestionItemDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<String>? _$desc(QuestionItemDto v) => v.desc;
  static const Field<QuestionItemDto, List<String>> _f$desc = Field(
    'desc',
    _$desc,
    opt: true,
    hook: StringListHook(),
  );
  static NamedRefDto? _$mainSubject(QuestionItemDto v) => v.mainSubject;
  static const Field<QuestionItemDto, NamedRefDto> _f$mainSubject = Field(
    'mainSubject',
    _$mainSubject,
    opt: true,
    hook: ObjectHook(),
  );

  @override
  final MappableFields<QuestionItemDto> fields = const {
    #name: _f$name,
    #desc: _f$desc,
    #mainSubject: _f$mainSubject,
  };
  @override
  final bool ignoreNull = true;

  static QuestionItemDto _instantiate(DecodingData data) {
    return QuestionItemDto(
      name: data.dec(_f$name),
      desc: data.dec(_f$desc),
      mainSubject: data.dec(_f$mainSubject),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static QuestionItemDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<QuestionItemDto>(map);
  }

  static QuestionItemDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<QuestionItemDto>(json);
  }
}

mixin QuestionItemDtoMappable {
  String toJsonString() {
    return QuestionItemDtoMapper.ensureInitialized()
        .encodeJson<QuestionItemDto>(this as QuestionItemDto);
  }

  Map<String, dynamic> toJson() {
    return QuestionItemDtoMapper.ensureInitialized().encodeMap<QuestionItemDto>(
      this as QuestionItemDto,
    );
  }

  QuestionItemDtoCopyWith<QuestionItemDto, QuestionItemDto, QuestionItemDto>
  get copyWith =>
      _QuestionItemDtoCopyWithImpl<QuestionItemDto, QuestionItemDto>(
        this as QuestionItemDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return QuestionItemDtoMapper.ensureInitialized().stringifyValue(
      this as QuestionItemDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return QuestionItemDtoMapper.ensureInitialized().equalsValue(
      this as QuestionItemDto,
      other,
    );
  }

  @override
  int get hashCode {
    return QuestionItemDtoMapper.ensureInitialized().hashValue(
      this as QuestionItemDto,
    );
  }
}

extension QuestionItemDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, QuestionItemDto, $Out> {
  QuestionItemDtoCopyWith<$R, QuestionItemDto, $Out> get $asQuestionItemDto =>
      $base.as((v, t, t2) => _QuestionItemDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class QuestionItemDtoCopyWith<$R, $In extends QuestionItemDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get desc;
  NamedRefDtoCopyWith<$R, NamedRefDto, NamedRefDto>? get mainSubject;
  $R call({String? name, List<String>? desc, NamedRefDto? mainSubject});
  QuestionItemDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _QuestionItemDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, QuestionItemDto, $Out>
    implements QuestionItemDtoCopyWith<$R, QuestionItemDto, $Out> {
  _QuestionItemDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<QuestionItemDto> $mapper =
      QuestionItemDtoMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get desc =>
      $value.desc != null
      ? ListCopyWith(
          $value.desc!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(desc: v),
        )
      : null;
  @override
  NamedRefDtoCopyWith<$R, NamedRefDto, NamedRefDto>? get mainSubject =>
      $value.mainSubject?.copyWith.$chain((v) => call(mainSubject: v));
  @override
  $R call({
    Object? name = $none,
    Object? desc = $none,
    Object? mainSubject = $none,
  }) => $apply(
    FieldCopyWithData({
      if (name != $none) #name: name,
      if (desc != $none) #desc: desc,
      if (mainSubject != $none) #mainSubject: mainSubject,
    }),
  );
  @override
  QuestionItemDto $make(CopyWithData data) => QuestionItemDto(
    name: data.get(#name, or: $value.name),
    desc: data.get(#desc, or: $value.desc),
    mainSubject: data.get(#mainSubject, or: $value.mainSubject),
  );

  @override
  QuestionItemDtoCopyWith<$R2, QuestionItemDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _QuestionItemDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class NamedRefDtoMapper extends ClassMapperBase<NamedRefDto> {
  NamedRefDtoMapper._();

  static NamedRefDtoMapper? _instance;
  static NamedRefDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = NamedRefDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'NamedRefDto';

  static String? _$name(NamedRefDto v) => v.name;
  static const Field<NamedRefDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );

  @override
  final MappableFields<NamedRefDto> fields = const {#name: _f$name};
  @override
  final bool ignoreNull = true;

  static NamedRefDto _instantiate(DecodingData data) {
    return NamedRefDto(name: data.dec(_f$name));
  }

  @override
  final Function instantiate = _instantiate;

  static NamedRefDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<NamedRefDto>(map);
  }

  static NamedRefDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<NamedRefDto>(json);
  }
}

mixin NamedRefDtoMappable {
  String toJsonString() {
    return NamedRefDtoMapper.ensureInitialized().encodeJson<NamedRefDto>(
      this as NamedRefDto,
    );
  }

  Map<String, dynamic> toJson() {
    return NamedRefDtoMapper.ensureInitialized().encodeMap<NamedRefDto>(
      this as NamedRefDto,
    );
  }

  NamedRefDtoCopyWith<NamedRefDto, NamedRefDto, NamedRefDto> get copyWith =>
      _NamedRefDtoCopyWithImpl<NamedRefDto, NamedRefDto>(
        this as NamedRefDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return NamedRefDtoMapper.ensureInitialized().stringifyValue(
      this as NamedRefDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return NamedRefDtoMapper.ensureInitialized().equalsValue(
      this as NamedRefDto,
      other,
    );
  }

  @override
  int get hashCode {
    return NamedRefDtoMapper.ensureInitialized().hashValue(this as NamedRefDto);
  }
}

extension NamedRefDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, NamedRefDto, $Out> {
  NamedRefDtoCopyWith<$R, NamedRefDto, $Out> get $asNamedRefDto =>
      $base.as((v, t, t2) => _NamedRefDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class NamedRefDtoCopyWith<$R, $In extends NamedRefDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? name});
  NamedRefDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _NamedRefDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, NamedRefDto, $Out>
    implements NamedRefDtoCopyWith<$R, NamedRefDto, $Out> {
  _NamedRefDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<NamedRefDto> $mapper =
      NamedRefDtoMapper.ensureInitialized();
  @override
  $R call({Object? name = $none}) =>
      $apply(FieldCopyWithData({if (name != $none) #name: name}));
  @override
  NamedRefDto $make(CopyWithData data) =>
      NamedRefDto(name: data.get(#name, or: $value.name));

  @override
  NamedRefDtoCopyWith<$R2, NamedRefDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _NamedRefDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class QuestionDtoMapper extends ClassMapperBase<QuestionDto> {
  QuestionDtoMapper._();

  static QuestionDtoMapper? _instance;
  static QuestionDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = QuestionDtoMapper._());
      QuestionItemDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'QuestionDto';

  static String? _$desc(QuestionDto v) => v.desc;
  static const Field<QuestionDto, String> _f$desc = Field(
    'desc',
    _$desc,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$pageInfo(QuestionDto v) => v.pageInfo;
  static const Field<QuestionDto, String> _f$pageInfo = Field(
    'pageInfo',
    _$pageInfo,
    key: r'page_info',
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<QuestionItemDto>? _$items(QuestionDto v) => v.items;
  static const Field<QuestionDto, List<QuestionItemDto>> _f$items = Field(
    'items',
    _$items,
    opt: true,
    hook: MapListHook(),
  );

  @override
  final MappableFields<QuestionDto> fields = const {
    #desc: _f$desc,
    #pageInfo: _f$pageInfo,
    #items: _f$items,
  };
  @override
  final bool ignoreNull = true;

  static QuestionDto _instantiate(DecodingData data) {
    return QuestionDto(
      desc: data.dec(_f$desc),
      pageInfo: data.dec(_f$pageInfo),
      items: data.dec(_f$items),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static QuestionDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<QuestionDto>(map);
  }

  static QuestionDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<QuestionDto>(json);
  }
}

mixin QuestionDtoMappable {
  String toJsonString() {
    return QuestionDtoMapper.ensureInitialized().encodeJson<QuestionDto>(
      this as QuestionDto,
    );
  }

  Map<String, dynamic> toJson() {
    return QuestionDtoMapper.ensureInitialized().encodeMap<QuestionDto>(
      this as QuestionDto,
    );
  }

  QuestionDtoCopyWith<QuestionDto, QuestionDto, QuestionDto> get copyWith =>
      _QuestionDtoCopyWithImpl<QuestionDto, QuestionDto>(
        this as QuestionDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return QuestionDtoMapper.ensureInitialized().stringifyValue(
      this as QuestionDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return QuestionDtoMapper.ensureInitialized().equalsValue(
      this as QuestionDto,
      other,
    );
  }

  @override
  int get hashCode {
    return QuestionDtoMapper.ensureInitialized().hashValue(this as QuestionDto);
  }
}

extension QuestionDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, QuestionDto, $Out> {
  QuestionDtoCopyWith<$R, QuestionDto, $Out> get $asQuestionDto =>
      $base.as((v, t, t2) => _QuestionDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class QuestionDtoCopyWith<$R, $In extends QuestionDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    QuestionItemDto,
    QuestionItemDtoCopyWith<$R, QuestionItemDto, QuestionItemDto>
  >?
  get items;
  $R call({String? desc, String? pageInfo, List<QuestionItemDto>? items});
  QuestionDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _QuestionDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, QuestionDto, $Out>
    implements QuestionDtoCopyWith<$R, QuestionDto, $Out> {
  _QuestionDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<QuestionDto> $mapper =
      QuestionDtoMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    QuestionItemDto,
    QuestionItemDtoCopyWith<$R, QuestionItemDto, QuestionItemDto>
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
    Object? desc = $none,
    Object? pageInfo = $none,
    Object? items = $none,
  }) => $apply(
    FieldCopyWithData({
      if (desc != $none) #desc: desc,
      if (pageInfo != $none) #pageInfo: pageInfo,
      if (items != $none) #items: items,
    }),
  );
  @override
  QuestionDto $make(CopyWithData data) => QuestionDto(
    desc: data.get(#desc, or: $value.desc),
    pageInfo: data.get(#pageInfo, or: $value.pageInfo),
    items: data.get(#items, or: $value.items),
  );

  @override
  QuestionDtoCopyWith<$R2, QuestionDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _QuestionDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class QuestionResponseMapper extends ClassMapperBase<QuestionResponse> {
  QuestionResponseMapper._();

  static QuestionResponseMapper? _instance;
  static QuestionResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = QuestionResponseMapper._());
      QuestionDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'QuestionResponse';

  static bool? _$success(QuestionResponse v) => v.success;
  static const Field<QuestionResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(QuestionResponse v) => v.message;
  static const Field<QuestionResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static QuestionDto? _$question(QuestionResponse v) => v.question;
  static const Field<QuestionResponse, QuestionDto> _f$question = Field(
    'question',
    _$question,
    opt: true,
    hook: ObjectHook(),
  );

  @override
  final MappableFields<QuestionResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #question: _f$question,
  };
  @override
  final bool ignoreNull = true;

  static QuestionResponse _instantiate(DecodingData data) {
    return QuestionResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      question: data.dec(_f$question),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static QuestionResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<QuestionResponse>(map);
  }

  static QuestionResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<QuestionResponse>(json);
  }
}

mixin QuestionResponseMappable {
  String toJsonString() {
    return QuestionResponseMapper.ensureInitialized()
        .encodeJson<QuestionResponse>(this as QuestionResponse);
  }

  Map<String, dynamic> toJson() {
    return QuestionResponseMapper.ensureInitialized()
        .encodeMap<QuestionResponse>(this as QuestionResponse);
  }

  QuestionResponseCopyWith<QuestionResponse, QuestionResponse, QuestionResponse>
  get copyWith =>
      _QuestionResponseCopyWithImpl<QuestionResponse, QuestionResponse>(
        this as QuestionResponse,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return QuestionResponseMapper.ensureInitialized().stringifyValue(
      this as QuestionResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return QuestionResponseMapper.ensureInitialized().equalsValue(
      this as QuestionResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return QuestionResponseMapper.ensureInitialized().hashValue(
      this as QuestionResponse,
    );
  }
}

extension QuestionResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, QuestionResponse, $Out> {
  QuestionResponseCopyWith<$R, QuestionResponse, $Out>
  get $asQuestionResponse =>
      $base.as((v, t, t2) => _QuestionResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class QuestionResponseCopyWith<$R, $In extends QuestionResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  QuestionDtoCopyWith<$R, QuestionDto, QuestionDto>? get question;
  $R call({bool? success, String? message, QuestionDto? question});
  QuestionResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _QuestionResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, QuestionResponse, $Out>
    implements QuestionResponseCopyWith<$R, QuestionResponse, $Out> {
  _QuestionResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<QuestionResponse> $mapper =
      QuestionResponseMapper.ensureInitialized();
  @override
  QuestionDtoCopyWith<$R, QuestionDto, QuestionDto>? get question =>
      $value.question?.copyWith.$chain((v) => call(question: v));
  @override
  $R call({
    Object? success = $none,
    Object? message = $none,
    Object? question = $none,
  }) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
      if (question != $none) #question: question,
    }),
  );
  @override
  QuestionResponse $make(CopyWithData data) => QuestionResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    question: data.get(#question, or: $value.question),
  );

  @override
  QuestionResponseCopyWith<$R2, QuestionResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _QuestionResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

