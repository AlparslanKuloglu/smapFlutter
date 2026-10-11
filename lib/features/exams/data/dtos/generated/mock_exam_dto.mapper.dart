// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../mock_exam_dto.dart';

class ExamDefinitionDtoMapper extends ClassMapperBase<ExamDefinitionDto> {
  ExamDefinitionDtoMapper._();

  static ExamDefinitionDtoMapper? _instance;
  static ExamDefinitionDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ExamDefinitionDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ExamDefinitionDto';

  static String? _$id(ExamDefinitionDto v) => v.id;
  static const Field<ExamDefinitionDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$order(ExamDefinitionDto v) => v.order;
  static const Field<ExamDefinitionDto, int> _f$order = Field(
    'order',
    _$order,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$type(ExamDefinitionDto v) => v.type;
  static const Field<ExamDefinitionDto, int> _f$type = Field(
    'type',
    _$type,
    opt: true,
    hook: IntOrNullHook(),
  );
  static String? _$image(ExamDefinitionDto v) => v.image;
  static const Field<ExamDefinitionDto, String> _f$image = Field(
    'image',
    _$image,
    opt: true,
    hook: TextOrNullHook(),
  );
  static Map<String, dynamic>? _$raw(ExamDefinitionDto v) => v.raw;
  static const Field<ExamDefinitionDto, Map<String, dynamic>> _f$raw = Field(
    'raw',
    _$raw,
    opt: true,
    hook: ObjectHook(),
  );

  @override
  final MappableFields<ExamDefinitionDto> fields = const {
    #id: _f$id,
    #order: _f$order,
    #type: _f$type,
    #image: _f$image,
    #raw: _f$raw,
  };
  @override
  final bool ignoreNull = true;

  @override
  final MappingHook hook = const KeepRawObjectHook();
  static ExamDefinitionDto _instantiate(DecodingData data) {
    return ExamDefinitionDto(
      id: data.dec(_f$id),
      order: data.dec(_f$order),
      type: data.dec(_f$type),
      image: data.dec(_f$image),
      raw: data.dec(_f$raw),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ExamDefinitionDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ExamDefinitionDto>(map);
  }

  static ExamDefinitionDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<ExamDefinitionDto>(json);
  }
}

mixin ExamDefinitionDtoMappable {
  String toJsonString() {
    return ExamDefinitionDtoMapper.ensureInitialized()
        .encodeJson<ExamDefinitionDto>(this as ExamDefinitionDto);
  }

  Map<String, dynamic> toJson() {
    return ExamDefinitionDtoMapper.ensureInitialized()
        .encodeMap<ExamDefinitionDto>(this as ExamDefinitionDto);
  }

  ExamDefinitionDtoCopyWith<
    ExamDefinitionDto,
    ExamDefinitionDto,
    ExamDefinitionDto
  >
  get copyWith =>
      _ExamDefinitionDtoCopyWithImpl<ExamDefinitionDto, ExamDefinitionDto>(
        this as ExamDefinitionDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ExamDefinitionDtoMapper.ensureInitialized().stringifyValue(
      this as ExamDefinitionDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ExamDefinitionDtoMapper.ensureInitialized().equalsValue(
      this as ExamDefinitionDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ExamDefinitionDtoMapper.ensureInitialized().hashValue(
      this as ExamDefinitionDto,
    );
  }
}

extension ExamDefinitionDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ExamDefinitionDto, $Out> {
  ExamDefinitionDtoCopyWith<$R, ExamDefinitionDto, $Out>
  get $asExamDefinitionDto => $base.as(
    (v, t, t2) => _ExamDefinitionDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ExamDefinitionDtoCopyWith<
  $R,
  $In extends ExamDefinitionDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>?>?
  get raw;
  $R call({
    String? id,
    int? order,
    int? type,
    String? image,
    Map<String, dynamic>? raw,
  });
  ExamDefinitionDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ExamDefinitionDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ExamDefinitionDto, $Out>
    implements ExamDefinitionDtoCopyWith<$R, ExamDefinitionDto, $Out> {
  _ExamDefinitionDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ExamDefinitionDto> $mapper =
      ExamDefinitionDtoMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>?>?
  get raw => $value.raw != null
      ? MapCopyWith(
          $value.raw!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(raw: v),
        )
      : null;
  @override
  $R call({
    Object? id = $none,
    Object? order = $none,
    Object? type = $none,
    Object? image = $none,
    Object? raw = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (order != $none) #order: order,
      if (type != $none) #type: type,
      if (image != $none) #image: image,
      if (raw != $none) #raw: raw,
    }),
  );
  @override
  ExamDefinitionDto $make(CopyWithData data) => ExamDefinitionDto(
    id: data.get(#id, or: $value.id),
    order: data.get(#order, or: $value.order),
    type: data.get(#type, or: $value.type),
    image: data.get(#image, or: $value.image),
    raw: data.get(#raw, or: $value.raw),
  );

  @override
  ExamDefinitionDtoCopyWith<$R2, ExamDefinitionDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ExamDefinitionDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class NetBreakdownDtoMapper extends ClassMapperBase<NetBreakdownDto> {
  NetBreakdownDtoMapper._();

  static NetBreakdownDtoMapper? _instance;
  static NetBreakdownDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = NetBreakdownDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'NetBreakdownDto';

  static double? _$net(NetBreakdownDto v) => v.net;
  static const Field<NetBreakdownDto, double> _f$net = Field(
    'net',
    _$net,
    opt: true,
    hook: DoubleOrNullHook(),
  );
  static int? _$correct(NetBreakdownDto v) => v.correct;
  static const Field<NetBreakdownDto, int> _f$correct = Field(
    'correct',
    _$correct,
    key: r'true',
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$wrong(NetBreakdownDto v) => v.wrong;
  static const Field<NetBreakdownDto, int> _f$wrong = Field(
    'wrong',
    _$wrong,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$pass(NetBreakdownDto v) => v.pass;
  static const Field<NetBreakdownDto, int> _f$pass = Field(
    'pass',
    _$pass,
    opt: true,
    hook: IntOrNullHook(),
  );

  @override
  final MappableFields<NetBreakdownDto> fields = const {
    #net: _f$net,
    #correct: _f$correct,
    #wrong: _f$wrong,
    #pass: _f$pass,
  };
  @override
  final bool ignoreNull = true;

  static NetBreakdownDto _instantiate(DecodingData data) {
    return NetBreakdownDto(
      net: data.dec(_f$net),
      correct: data.dec(_f$correct),
      wrong: data.dec(_f$wrong),
      pass: data.dec(_f$pass),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static NetBreakdownDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<NetBreakdownDto>(map);
  }

  static NetBreakdownDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<NetBreakdownDto>(json);
  }
}

mixin NetBreakdownDtoMappable {
  String toJsonString() {
    return NetBreakdownDtoMapper.ensureInitialized()
        .encodeJson<NetBreakdownDto>(this as NetBreakdownDto);
  }

  Map<String, dynamic> toJson() {
    return NetBreakdownDtoMapper.ensureInitialized().encodeMap<NetBreakdownDto>(
      this as NetBreakdownDto,
    );
  }

  NetBreakdownDtoCopyWith<NetBreakdownDto, NetBreakdownDto, NetBreakdownDto>
  get copyWith =>
      _NetBreakdownDtoCopyWithImpl<NetBreakdownDto, NetBreakdownDto>(
        this as NetBreakdownDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return NetBreakdownDtoMapper.ensureInitialized().stringifyValue(
      this as NetBreakdownDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return NetBreakdownDtoMapper.ensureInitialized().equalsValue(
      this as NetBreakdownDto,
      other,
    );
  }

  @override
  int get hashCode {
    return NetBreakdownDtoMapper.ensureInitialized().hashValue(
      this as NetBreakdownDto,
    );
  }
}

extension NetBreakdownDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, NetBreakdownDto, $Out> {
  NetBreakdownDtoCopyWith<$R, NetBreakdownDto, $Out> get $asNetBreakdownDto =>
      $base.as((v, t, t2) => _NetBreakdownDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class NetBreakdownDtoCopyWith<$R, $In extends NetBreakdownDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({double? net, int? correct, int? wrong, int? pass});
  NetBreakdownDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _NetBreakdownDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, NetBreakdownDto, $Out>
    implements NetBreakdownDtoCopyWith<$R, NetBreakdownDto, $Out> {
  _NetBreakdownDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<NetBreakdownDto> $mapper =
      NetBreakdownDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? net = $none,
    Object? correct = $none,
    Object? wrong = $none,
    Object? pass = $none,
  }) => $apply(
    FieldCopyWithData({
      if (net != $none) #net: net,
      if (correct != $none) #correct: correct,
      if (wrong != $none) #wrong: wrong,
      if (pass != $none) #pass: pass,
    }),
  );
  @override
  NetBreakdownDto $make(CopyWithData data) => NetBreakdownDto(
    net: data.get(#net, or: $value.net),
    correct: data.get(#correct, or: $value.correct),
    wrong: data.get(#wrong, or: $value.wrong),
    pass: data.get(#pass, or: $value.pass),
  );

  @override
  NetBreakdownDtoCopyWith<$R2, NetBreakdownDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _NetBreakdownDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class LessonResultDtoMapper extends ClassMapperBase<LessonResultDto> {
  LessonResultDtoMapper._();

  static LessonResultDtoMapper? _instance;
  static LessonResultDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LessonResultDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'LessonResultDto';

  static String? _$lesson(LessonResultDto v) => v.lesson;
  static const Field<LessonResultDto, String> _f$lesson = Field(
    'lesson',
    _$lesson,
    opt: true,
    hook: IdRefHook(),
  );
  static double? _$net(LessonResultDto v) => v.net;
  static const Field<LessonResultDto, double> _f$net = Field(
    'net',
    _$net,
    opt: true,
    hook: DoubleOrNullHook(),
  );
  static int? _$correct(LessonResultDto v) => v.correct;
  static const Field<LessonResultDto, int> _f$correct = Field(
    'correct',
    _$correct,
    key: r'true',
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$wrong(LessonResultDto v) => v.wrong;
  static const Field<LessonResultDto, int> _f$wrong = Field(
    'wrong',
    _$wrong,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$pass(LessonResultDto v) => v.pass;
  static const Field<LessonResultDto, int> _f$pass = Field(
    'pass',
    _$pass,
    opt: true,
    hook: IntOrNullHook(),
  );

  @override
  final MappableFields<LessonResultDto> fields = const {
    #lesson: _f$lesson,
    #net: _f$net,
    #correct: _f$correct,
    #wrong: _f$wrong,
    #pass: _f$pass,
  };
  @override
  final bool ignoreNull = true;

  static LessonResultDto _instantiate(DecodingData data) {
    return LessonResultDto(
      lesson: data.dec(_f$lesson),
      net: data.dec(_f$net),
      correct: data.dec(_f$correct),
      wrong: data.dec(_f$wrong),
      pass: data.dec(_f$pass),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LessonResultDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LessonResultDto>(map);
  }

  static LessonResultDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<LessonResultDto>(json);
  }
}

mixin LessonResultDtoMappable {
  String toJsonString() {
    return LessonResultDtoMapper.ensureInitialized()
        .encodeJson<LessonResultDto>(this as LessonResultDto);
  }

  Map<String, dynamic> toJson() {
    return LessonResultDtoMapper.ensureInitialized().encodeMap<LessonResultDto>(
      this as LessonResultDto,
    );
  }

  LessonResultDtoCopyWith<LessonResultDto, LessonResultDto, LessonResultDto>
  get copyWith =>
      _LessonResultDtoCopyWithImpl<LessonResultDto, LessonResultDto>(
        this as LessonResultDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return LessonResultDtoMapper.ensureInitialized().stringifyValue(
      this as LessonResultDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return LessonResultDtoMapper.ensureInitialized().equalsValue(
      this as LessonResultDto,
      other,
    );
  }

  @override
  int get hashCode {
    return LessonResultDtoMapper.ensureInitialized().hashValue(
      this as LessonResultDto,
    );
  }
}

extension LessonResultDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LessonResultDto, $Out> {
  LessonResultDtoCopyWith<$R, LessonResultDto, $Out> get $asLessonResultDto =>
      $base.as((v, t, t2) => _LessonResultDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LessonResultDtoCopyWith<$R, $In extends LessonResultDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? lesson, double? net, int? correct, int? wrong, int? pass});
  LessonResultDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _LessonResultDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LessonResultDto, $Out>
    implements LessonResultDtoCopyWith<$R, LessonResultDto, $Out> {
  _LessonResultDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LessonResultDto> $mapper =
      LessonResultDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? lesson = $none,
    Object? net = $none,
    Object? correct = $none,
    Object? wrong = $none,
    Object? pass = $none,
  }) => $apply(
    FieldCopyWithData({
      if (lesson != $none) #lesson: lesson,
      if (net != $none) #net: net,
      if (correct != $none) #correct: correct,
      if (wrong != $none) #wrong: wrong,
      if (pass != $none) #pass: pass,
    }),
  );
  @override
  LessonResultDto $make(CopyWithData data) => LessonResultDto(
    lesson: data.get(#lesson, or: $value.lesson),
    net: data.get(#net, or: $value.net),
    correct: data.get(#correct, or: $value.correct),
    wrong: data.get(#wrong, or: $value.wrong),
    pass: data.get(#pass, or: $value.pass),
  );

  @override
  LessonResultDtoCopyWith<$R2, LessonResultDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LessonResultDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class QuestionCellDtoMapper extends ClassMapperBase<QuestionCellDto> {
  QuestionCellDtoMapper._();

  static QuestionCellDtoMapper? _instance;
  static QuestionCellDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = QuestionCellDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'QuestionCellDto';

  static int? _$order(QuestionCellDto v) => v.order;
  static const Field<QuestionCellDto, int> _f$order = Field(
    'order',
    _$order,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$type(QuestionCellDto v) => v.type;
  static const Field<QuestionCellDto, int> _f$type = Field(
    'type',
    _$type,
    opt: true,
    hook: IntOrNullHook(),
  );

  @override
  final MappableFields<QuestionCellDto> fields = const {
    #order: _f$order,
    #type: _f$type,
  };
  @override
  final bool ignoreNull = true;

  static QuestionCellDto _instantiate(DecodingData data) {
    return QuestionCellDto(order: data.dec(_f$order), type: data.dec(_f$type));
  }

  @override
  final Function instantiate = _instantiate;

  static QuestionCellDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<QuestionCellDto>(map);
  }

  static QuestionCellDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<QuestionCellDto>(json);
  }
}

mixin QuestionCellDtoMappable {
  String toJsonString() {
    return QuestionCellDtoMapper.ensureInitialized()
        .encodeJson<QuestionCellDto>(this as QuestionCellDto);
  }

  Map<String, dynamic> toJson() {
    return QuestionCellDtoMapper.ensureInitialized().encodeMap<QuestionCellDto>(
      this as QuestionCellDto,
    );
  }

  QuestionCellDtoCopyWith<QuestionCellDto, QuestionCellDto, QuestionCellDto>
  get copyWith =>
      _QuestionCellDtoCopyWithImpl<QuestionCellDto, QuestionCellDto>(
        this as QuestionCellDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return QuestionCellDtoMapper.ensureInitialized().stringifyValue(
      this as QuestionCellDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return QuestionCellDtoMapper.ensureInitialized().equalsValue(
      this as QuestionCellDto,
      other,
    );
  }

  @override
  int get hashCode {
    return QuestionCellDtoMapper.ensureInitialized().hashValue(
      this as QuestionCellDto,
    );
  }
}

extension QuestionCellDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, QuestionCellDto, $Out> {
  QuestionCellDtoCopyWith<$R, QuestionCellDto, $Out> get $asQuestionCellDto =>
      $base.as((v, t, t2) => _QuestionCellDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class QuestionCellDtoCopyWith<$R, $In extends QuestionCellDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? order, int? type});
  QuestionCellDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _QuestionCellDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, QuestionCellDto, $Out>
    implements QuestionCellDtoCopyWith<$R, QuestionCellDto, $Out> {
  _QuestionCellDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<QuestionCellDto> $mapper =
      QuestionCellDtoMapper.ensureInitialized();
  @override
  $R call({Object? order = $none, Object? type = $none}) => $apply(
    FieldCopyWithData({
      if (order != $none) #order: order,
      if (type != $none) #type: type,
    }),
  );
  @override
  QuestionCellDto $make(CopyWithData data) => QuestionCellDto(
    order: data.get(#order, or: $value.order),
    type: data.get(#type, or: $value.type),
  );

  @override
  QuestionCellDtoCopyWith<$R2, QuestionCellDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _QuestionCellDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class QuestionGroupDtoMapper extends ClassMapperBase<QuestionGroupDto> {
  QuestionGroupDtoMapper._();

  static QuestionGroupDtoMapper? _instance;
  static QuestionGroupDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = QuestionGroupDtoMapper._());
      QuestionCellDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'QuestionGroupDto';

  static List<QuestionCellDto>? _$cells(QuestionGroupDto v) => v.cells;
  static const Field<QuestionGroupDto, List<QuestionCellDto>> _f$cells = Field(
    'cells',
    _$cells,
    opt: true,
    hook: MapListHook(),
  );

  @override
  final MappableFields<QuestionGroupDto> fields = const {#cells: _f$cells};
  @override
  final bool ignoreNull = true;

  static QuestionGroupDto _instantiate(DecodingData data) {
    return QuestionGroupDto(cells: data.dec(_f$cells));
  }

  @override
  final Function instantiate = _instantiate;

  static QuestionGroupDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<QuestionGroupDto>(map);
  }

  static QuestionGroupDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<QuestionGroupDto>(json);
  }
}

mixin QuestionGroupDtoMappable {
  String toJsonString() {
    return QuestionGroupDtoMapper.ensureInitialized()
        .encodeJson<QuestionGroupDto>(this as QuestionGroupDto);
  }

  Map<String, dynamic> toJson() {
    return QuestionGroupDtoMapper.ensureInitialized()
        .encodeMap<QuestionGroupDto>(this as QuestionGroupDto);
  }

  QuestionGroupDtoCopyWith<QuestionGroupDto, QuestionGroupDto, QuestionGroupDto>
  get copyWith =>
      _QuestionGroupDtoCopyWithImpl<QuestionGroupDto, QuestionGroupDto>(
        this as QuestionGroupDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return QuestionGroupDtoMapper.ensureInitialized().stringifyValue(
      this as QuestionGroupDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return QuestionGroupDtoMapper.ensureInitialized().equalsValue(
      this as QuestionGroupDto,
      other,
    );
  }

  @override
  int get hashCode {
    return QuestionGroupDtoMapper.ensureInitialized().hashValue(
      this as QuestionGroupDto,
    );
  }
}

extension QuestionGroupDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, QuestionGroupDto, $Out> {
  QuestionGroupDtoCopyWith<$R, QuestionGroupDto, $Out>
  get $asQuestionGroupDto =>
      $base.as((v, t, t2) => _QuestionGroupDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class QuestionGroupDtoCopyWith<$R, $In extends QuestionGroupDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    QuestionCellDto,
    QuestionCellDtoCopyWith<$R, QuestionCellDto, QuestionCellDto>
  >?
  get cells;
  $R call({List<QuestionCellDto>? cells});
  QuestionGroupDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _QuestionGroupDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, QuestionGroupDto, $Out>
    implements QuestionGroupDtoCopyWith<$R, QuestionGroupDto, $Out> {
  _QuestionGroupDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<QuestionGroupDto> $mapper =
      QuestionGroupDtoMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    QuestionCellDto,
    QuestionCellDtoCopyWith<$R, QuestionCellDto, QuestionCellDto>
  >?
  get cells => $value.cells != null
      ? ListCopyWith(
          $value.cells!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(cells: v),
        )
      : null;
  @override
  $R call({Object? cells = $none}) =>
      $apply(FieldCopyWithData({if (cells != $none) #cells: cells}));
  @override
  QuestionGroupDto $make(CopyWithData data) =>
      QuestionGroupDto(cells: data.get(#cells, or: $value.cells));

  @override
  QuestionGroupDtoCopyWith<$R2, QuestionGroupDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _QuestionGroupDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MockExamDtoMapper extends ClassMapperBase<MockExamDto> {
  MockExamDtoMapper._();

  static MockExamDtoMapper? _instance;
  static MockExamDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MockExamDtoMapper._());
      ExamDefinitionDtoMapper.ensureInitialized();
      NetBreakdownDtoMapper.ensureInitialized();
      LessonResultDtoMapper.ensureInitialized();
      QuestionGroupDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MockExamDto';

  static String? _$id(MockExamDto v) => v.id;
  static const Field<MockExamDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$itemName(MockExamDto v) => v.itemName;
  static const Field<MockExamDto, String> _f$itemName = Field(
    'itemName',
    _$itemName,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$publisherName(MockExamDto v) => v.publisherName;
  static const Field<MockExamDto, String> _f$publisherName = Field(
    'publisherName',
    _$publisherName,
    opt: true,
    hook: TextOrNullHook(),
  );
  static ExamDefinitionDto? _$mexam(MockExamDto v) => v.mexam;
  static const Field<MockExamDto, ExamDefinitionDto> _f$mexam = Field(
    'mexam',
    _$mexam,
    opt: true,
    hook: ObjectHook(),
  );
  static double? _$net(MockExamDto v) => v.net;
  static const Field<MockExamDto, double> _f$net = Field(
    'net',
    _$net,
    opt: true,
    hook: DoubleOrNullHook(),
  );
  static int? _$correct(MockExamDto v) => v.correct;
  static const Field<MockExamDto, int> _f$correct = Field(
    'correct',
    _$correct,
    key: r'true',
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$wrong(MockExamDto v) => v.wrong;
  static const Field<MockExamDto, int> _f$wrong = Field(
    'wrong',
    _$wrong,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$pass(MockExamDto v) => v.pass;
  static const Field<MockExamDto, int> _f$pass = Field(
    'pass',
    _$pass,
    opt: true,
    hook: IntOrNullHook(),
  );
  static List<double?>? _$points(MockExamDto v) => v.points;
  static const Field<MockExamDto, List<double?>> _f$points = Field(
    'points',
    _$points,
    opt: true,
    hook: PointListHook(),
  );
  static List<double?>? _$pointsHam(MockExamDto v) => v.pointsHam;
  static const Field<MockExamDto, List<double?>> _f$pointsHam = Field(
    'pointsHam',
    _$pointsHam,
    opt: true,
    hook: PointListHook(),
  );
  static List<int?>? _$ranks(MockExamDto v) => v.ranks;
  static const Field<MockExamDto, List<int?>> _f$ranks = Field(
    'ranks',
    _$ranks,
    opt: true,
    hook: RankListHook(),
  );
  static List<int?>? _$ranksHam(MockExamDto v) => v.ranksHam;
  static const Field<MockExamDto, List<int?>> _f$ranksHam = Field(
    'ranksHam',
    _$ranksHam,
    opt: true,
    hook: RankListHook(),
  );
  static Map<String, NetBreakdownDto>? _$aytNets(MockExamDto v) => v.aytNets;
  static const Field<MockExamDto, Map<String, NetBreakdownDto>> _f$aytNets =
      Field('aytNets', _$aytNets, opt: true, hook: AytNetsHook());
  static List<LessonResultDto>? _$lessonResults(MockExamDto v) =>
      v.lessonResults;
  static const Field<MockExamDto, List<LessonResultDto>> _f$lessonResults =
      Field(
        'lessonResults',
        _$lessonResults,
        key: r'lessonmockexams',
        opt: true,
        hook: MapListHook(),
      );
  static List<NetBreakdownDto>? _$lessonInfo(MockExamDto v) => v.lessonInfo;
  static const Field<MockExamDto, List<NetBreakdownDto>> _f$lessonInfo = Field(
    'lessonInfo',
    _$lessonInfo,
    opt: true,
    hook: JsonPositionalMapListHook(),
  );
  static List<QuestionGroupDto>? _$questionGroups(MockExamDto v) =>
      v.questionGroups;
  static const Field<MockExamDto, List<QuestionGroupDto>> _f$questionGroups =
      Field(
        'questionGroups',
        _$questionGroups,
        key: r'questionsArrStr',
        opt: true,
        hook: QuestionGroupsHook(),
      );
  static DateTime? _$date(MockExamDto v) => v.date;
  static const Field<MockExamDto, DateTime> _f$date = Field(
    'date',
    _$date,
    opt: true,
    hook: DateOrNullHook(),
  );
  static bool? _$isStarred(MockExamDto v) => v.isStarred;
  static const Field<MockExamDto, bool> _f$isStarred = Field(
    'isStarred',
    _$isStarred,
    opt: true,
    hook: BoolOrNullHook(),
  );

  @override
  final MappableFields<MockExamDto> fields = const {
    #id: _f$id,
    #itemName: _f$itemName,
    #publisherName: _f$publisherName,
    #mexam: _f$mexam,
    #net: _f$net,
    #correct: _f$correct,
    #wrong: _f$wrong,
    #pass: _f$pass,
    #points: _f$points,
    #pointsHam: _f$pointsHam,
    #ranks: _f$ranks,
    #ranksHam: _f$ranksHam,
    #aytNets: _f$aytNets,
    #lessonResults: _f$lessonResults,
    #lessonInfo: _f$lessonInfo,
    #questionGroups: _f$questionGroups,
    #date: _f$date,
    #isStarred: _f$isStarred,
  };
  @override
  final bool ignoreNull = true;

  @override
  final MappingHook hook = const LessonResultsAliasHook();
  static MockExamDto _instantiate(DecodingData data) {
    return MockExamDto(
      id: data.dec(_f$id),
      itemName: data.dec(_f$itemName),
      publisherName: data.dec(_f$publisherName),
      mexam: data.dec(_f$mexam),
      net: data.dec(_f$net),
      correct: data.dec(_f$correct),
      wrong: data.dec(_f$wrong),
      pass: data.dec(_f$pass),
      points: data.dec(_f$points),
      pointsHam: data.dec(_f$pointsHam),
      ranks: data.dec(_f$ranks),
      ranksHam: data.dec(_f$ranksHam),
      aytNets: data.dec(_f$aytNets),
      lessonResults: data.dec(_f$lessonResults),
      lessonInfo: data.dec(_f$lessonInfo),
      questionGroups: data.dec(_f$questionGroups),
      date: data.dec(_f$date),
      isStarred: data.dec(_f$isStarred),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MockExamDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MockExamDto>(map);
  }

  static MockExamDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<MockExamDto>(json);
  }
}

mixin MockExamDtoMappable {
  String toJsonString() {
    return MockExamDtoMapper.ensureInitialized().encodeJson<MockExamDto>(
      this as MockExamDto,
    );
  }

  Map<String, dynamic> toJson() {
    return MockExamDtoMapper.ensureInitialized().encodeMap<MockExamDto>(
      this as MockExamDto,
    );
  }

  MockExamDtoCopyWith<MockExamDto, MockExamDto, MockExamDto> get copyWith =>
      _MockExamDtoCopyWithImpl<MockExamDto, MockExamDto>(
        this as MockExamDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MockExamDtoMapper.ensureInitialized().stringifyValue(
      this as MockExamDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return MockExamDtoMapper.ensureInitialized().equalsValue(
      this as MockExamDto,
      other,
    );
  }

  @override
  int get hashCode {
    return MockExamDtoMapper.ensureInitialized().hashValue(this as MockExamDto);
  }
}

extension MockExamDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MockExamDto, $Out> {
  MockExamDtoCopyWith<$R, MockExamDto, $Out> get $asMockExamDto =>
      $base.as((v, t, t2) => _MockExamDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MockExamDtoCopyWith<$R, $In extends MockExamDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ExamDefinitionDtoCopyWith<$R, ExamDefinitionDto, ExamDefinitionDto>?
  get mexam;
  ListCopyWith<$R, double?, ObjectCopyWith<$R, double?, double?>?>? get points;
  ListCopyWith<$R, double?, ObjectCopyWith<$R, double?, double?>?>?
  get pointsHam;
  ListCopyWith<$R, int?, ObjectCopyWith<$R, int?, int?>?>? get ranks;
  ListCopyWith<$R, int?, ObjectCopyWith<$R, int?, int?>?>? get ranksHam;
  MapCopyWith<
    $R,
    String,
    NetBreakdownDto,
    NetBreakdownDtoCopyWith<$R, NetBreakdownDto, NetBreakdownDto>
  >?
  get aytNets;
  ListCopyWith<
    $R,
    LessonResultDto,
    LessonResultDtoCopyWith<$R, LessonResultDto, LessonResultDto>
  >?
  get lessonResults;
  ListCopyWith<
    $R,
    NetBreakdownDto,
    NetBreakdownDtoCopyWith<$R, NetBreakdownDto, NetBreakdownDto>
  >?
  get lessonInfo;
  ListCopyWith<
    $R,
    QuestionGroupDto,
    QuestionGroupDtoCopyWith<$R, QuestionGroupDto, QuestionGroupDto>
  >?
  get questionGroups;
  $R call({
    String? id,
    String? itemName,
    String? publisherName,
    ExamDefinitionDto? mexam,
    double? net,
    int? correct,
    int? wrong,
    int? pass,
    List<double?>? points,
    List<double?>? pointsHam,
    List<int?>? ranks,
    List<int?>? ranksHam,
    Map<String, NetBreakdownDto>? aytNets,
    List<LessonResultDto>? lessonResults,
    List<NetBreakdownDto>? lessonInfo,
    List<QuestionGroupDto>? questionGroups,
    DateTime? date,
    bool? isStarred,
  });
  MockExamDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MockExamDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MockExamDto, $Out>
    implements MockExamDtoCopyWith<$R, MockExamDto, $Out> {
  _MockExamDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MockExamDto> $mapper =
      MockExamDtoMapper.ensureInitialized();
  @override
  ExamDefinitionDtoCopyWith<$R, ExamDefinitionDto, ExamDefinitionDto>?
  get mexam => $value.mexam?.copyWith.$chain((v) => call(mexam: v));
  @override
  ListCopyWith<$R, double?, ObjectCopyWith<$R, double?, double?>?>?
  get points => $value.points != null
      ? ListCopyWith(
          $value.points!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(points: v),
        )
      : null;
  @override
  ListCopyWith<$R, double?, ObjectCopyWith<$R, double?, double?>?>?
  get pointsHam => $value.pointsHam != null
      ? ListCopyWith(
          $value.pointsHam!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(pointsHam: v),
        )
      : null;
  @override
  ListCopyWith<$R, int?, ObjectCopyWith<$R, int?, int?>?>? get ranks =>
      $value.ranks != null
      ? ListCopyWith(
          $value.ranks!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(ranks: v),
        )
      : null;
  @override
  ListCopyWith<$R, int?, ObjectCopyWith<$R, int?, int?>?>? get ranksHam =>
      $value.ranksHam != null
      ? ListCopyWith(
          $value.ranksHam!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(ranksHam: v),
        )
      : null;
  @override
  MapCopyWith<
    $R,
    String,
    NetBreakdownDto,
    NetBreakdownDtoCopyWith<$R, NetBreakdownDto, NetBreakdownDto>
  >?
  get aytNets => $value.aytNets != null
      ? MapCopyWith(
          $value.aytNets!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(aytNets: v),
        )
      : null;
  @override
  ListCopyWith<
    $R,
    LessonResultDto,
    LessonResultDtoCopyWith<$R, LessonResultDto, LessonResultDto>
  >?
  get lessonResults => $value.lessonResults != null
      ? ListCopyWith(
          $value.lessonResults!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(lessonResults: v),
        )
      : null;
  @override
  ListCopyWith<
    $R,
    NetBreakdownDto,
    NetBreakdownDtoCopyWith<$R, NetBreakdownDto, NetBreakdownDto>
  >?
  get lessonInfo => $value.lessonInfo != null
      ? ListCopyWith(
          $value.lessonInfo!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(lessonInfo: v),
        )
      : null;
  @override
  ListCopyWith<
    $R,
    QuestionGroupDto,
    QuestionGroupDtoCopyWith<$R, QuestionGroupDto, QuestionGroupDto>
  >?
  get questionGroups => $value.questionGroups != null
      ? ListCopyWith(
          $value.questionGroups!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(questionGroups: v),
        )
      : null;
  @override
  $R call({
    Object? id = $none,
    Object? itemName = $none,
    Object? publisherName = $none,
    Object? mexam = $none,
    Object? net = $none,
    Object? correct = $none,
    Object? wrong = $none,
    Object? pass = $none,
    Object? points = $none,
    Object? pointsHam = $none,
    Object? ranks = $none,
    Object? ranksHam = $none,
    Object? aytNets = $none,
    Object? lessonResults = $none,
    Object? lessonInfo = $none,
    Object? questionGroups = $none,
    Object? date = $none,
    Object? isStarred = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (itemName != $none) #itemName: itemName,
      if (publisherName != $none) #publisherName: publisherName,
      if (mexam != $none) #mexam: mexam,
      if (net != $none) #net: net,
      if (correct != $none) #correct: correct,
      if (wrong != $none) #wrong: wrong,
      if (pass != $none) #pass: pass,
      if (points != $none) #points: points,
      if (pointsHam != $none) #pointsHam: pointsHam,
      if (ranks != $none) #ranks: ranks,
      if (ranksHam != $none) #ranksHam: ranksHam,
      if (aytNets != $none) #aytNets: aytNets,
      if (lessonResults != $none) #lessonResults: lessonResults,
      if (lessonInfo != $none) #lessonInfo: lessonInfo,
      if (questionGroups != $none) #questionGroups: questionGroups,
      if (date != $none) #date: date,
      if (isStarred != $none) #isStarred: isStarred,
    }),
  );
  @override
  MockExamDto $make(CopyWithData data) => MockExamDto(
    id: data.get(#id, or: $value.id),
    itemName: data.get(#itemName, or: $value.itemName),
    publisherName: data.get(#publisherName, or: $value.publisherName),
    mexam: data.get(#mexam, or: $value.mexam),
    net: data.get(#net, or: $value.net),
    correct: data.get(#correct, or: $value.correct),
    wrong: data.get(#wrong, or: $value.wrong),
    pass: data.get(#pass, or: $value.pass),
    points: data.get(#points, or: $value.points),
    pointsHam: data.get(#pointsHam, or: $value.pointsHam),
    ranks: data.get(#ranks, or: $value.ranks),
    ranksHam: data.get(#ranksHam, or: $value.ranksHam),
    aytNets: data.get(#aytNets, or: $value.aytNets),
    lessonResults: data.get(#lessonResults, or: $value.lessonResults),
    lessonInfo: data.get(#lessonInfo, or: $value.lessonInfo),
    questionGroups: data.get(#questionGroups, or: $value.questionGroups),
    date: data.get(#date, or: $value.date),
    isStarred: data.get(#isStarred, or: $value.isStarred),
  );

  @override
  MockExamDtoCopyWith<$R2, MockExamDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MockExamDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

