// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../lesson_answers.dart';

class GeneralLessonDtoMapper extends ClassMapperBase<GeneralLessonDto> {
  GeneralLessonDtoMapper._();

  static GeneralLessonDtoMapper? _instance;
  static GeneralLessonDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GeneralLessonDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'GeneralLessonDto';

  static String? _$id(GeneralLessonDto v) => v.id;
  static const Field<GeneralLessonDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$name(GeneralLessonDto v) => v.name;
  static const Field<GeneralLessonDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$image(GeneralLessonDto v) => v.image;
  static const Field<GeneralLessonDto, String> _f$image = Field(
    'image',
    _$image,
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$order(GeneralLessonDto v) => v.order;
  static const Field<GeneralLessonDto, int> _f$order = Field(
    'order',
    _$order,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$tytAyt(GeneralLessonDto v) => v.tytAyt;
  static const Field<GeneralLessonDto, int> _f$tytAyt = Field(
    'tytAyt',
    _$tytAyt,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$mindMap(GeneralLessonDto v) => v.mindMap;
  static const Field<GeneralLessonDto, int> _f$mindMap = Field(
    'mindMap',
    _$mindMap,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$edebiyat(GeneralLessonDto v) => v.edebiyat;
  static const Field<GeneralLessonDto, int> _f$edebiyat = Field(
    'edebiyat',
    _$edebiyat,
    opt: true,
    hook: IntOrNullHook(),
  );
  static String? _$lessonId(GeneralLessonDto v) => v.lessonId;
  static const Field<GeneralLessonDto, String> _f$lessonId = Field(
    'lessonId',
    _$lessonId,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$lessonTyt(GeneralLessonDto v) => v.lessonTyt;
  static const Field<GeneralLessonDto, String> _f$lessonTyt = Field(
    'lessonTyt',
    _$lessonTyt,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$lessonAyt(GeneralLessonDto v) => v.lessonAyt;
  static const Field<GeneralLessonDto, String> _f$lessonAyt = Field(
    'lessonAyt',
    _$lessonAyt,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$lessonSos2(GeneralLessonDto v) => v.lessonSos2;
  static const Field<GeneralLessonDto, String> _f$lessonSos2 = Field(
    'lessonSos2',
    _$lessonSos2,
    opt: true,
    hook: TextOrNullHook(),
  );

  @override
  final MappableFields<GeneralLessonDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #image: _f$image,
    #order: _f$order,
    #tytAyt: _f$tytAyt,
    #mindMap: _f$mindMap,
    #edebiyat: _f$edebiyat,
    #lessonId: _f$lessonId,
    #lessonTyt: _f$lessonTyt,
    #lessonAyt: _f$lessonAyt,
    #lessonSos2: _f$lessonSos2,
  };
  @override
  final bool ignoreNull = true;

  static GeneralLessonDto _instantiate(DecodingData data) {
    return GeneralLessonDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      image: data.dec(_f$image),
      order: data.dec(_f$order),
      tytAyt: data.dec(_f$tytAyt),
      mindMap: data.dec(_f$mindMap),
      edebiyat: data.dec(_f$edebiyat),
      lessonId: data.dec(_f$lessonId),
      lessonTyt: data.dec(_f$lessonTyt),
      lessonAyt: data.dec(_f$lessonAyt),
      lessonSos2: data.dec(_f$lessonSos2),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static GeneralLessonDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GeneralLessonDto>(map);
  }

  static GeneralLessonDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<GeneralLessonDto>(json);
  }
}

mixin GeneralLessonDtoMappable {
  String toJsonString() {
    return GeneralLessonDtoMapper.ensureInitialized()
        .encodeJson<GeneralLessonDto>(this as GeneralLessonDto);
  }

  Map<String, dynamic> toJson() {
    return GeneralLessonDtoMapper.ensureInitialized()
        .encodeMap<GeneralLessonDto>(this as GeneralLessonDto);
  }

  GeneralLessonDtoCopyWith<GeneralLessonDto, GeneralLessonDto, GeneralLessonDto>
  get copyWith =>
      _GeneralLessonDtoCopyWithImpl<GeneralLessonDto, GeneralLessonDto>(
        this as GeneralLessonDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return GeneralLessonDtoMapper.ensureInitialized().stringifyValue(
      this as GeneralLessonDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return GeneralLessonDtoMapper.ensureInitialized().equalsValue(
      this as GeneralLessonDto,
      other,
    );
  }

  @override
  int get hashCode {
    return GeneralLessonDtoMapper.ensureInitialized().hashValue(
      this as GeneralLessonDto,
    );
  }
}

extension GeneralLessonDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, GeneralLessonDto, $Out> {
  GeneralLessonDtoCopyWith<$R, GeneralLessonDto, $Out>
  get $asGeneralLessonDto =>
      $base.as((v, t, t2) => _GeneralLessonDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class GeneralLessonDtoCopyWith<$R, $In extends GeneralLessonDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? image,
    int? order,
    int? tytAyt,
    int? mindMap,
    int? edebiyat,
    String? lessonId,
    String? lessonTyt,
    String? lessonAyt,
    String? lessonSos2,
  });
  GeneralLessonDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _GeneralLessonDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GeneralLessonDto, $Out>
    implements GeneralLessonDtoCopyWith<$R, GeneralLessonDto, $Out> {
  _GeneralLessonDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GeneralLessonDto> $mapper =
      GeneralLessonDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? id = $none,
    Object? name = $none,
    Object? image = $none,
    Object? order = $none,
    Object? tytAyt = $none,
    Object? mindMap = $none,
    Object? edebiyat = $none,
    Object? lessonId = $none,
    Object? lessonTyt = $none,
    Object? lessonAyt = $none,
    Object? lessonSos2 = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (name != $none) #name: name,
      if (image != $none) #image: image,
      if (order != $none) #order: order,
      if (tytAyt != $none) #tytAyt: tytAyt,
      if (mindMap != $none) #mindMap: mindMap,
      if (edebiyat != $none) #edebiyat: edebiyat,
      if (lessonId != $none) #lessonId: lessonId,
      if (lessonTyt != $none) #lessonTyt: lessonTyt,
      if (lessonAyt != $none) #lessonAyt: lessonAyt,
      if (lessonSos2 != $none) #lessonSos2: lessonSos2,
    }),
  );
  @override
  GeneralLessonDto $make(CopyWithData data) => GeneralLessonDto(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    image: data.get(#image, or: $value.image),
    order: data.get(#order, or: $value.order),
    tytAyt: data.get(#tytAyt, or: $value.tytAyt),
    mindMap: data.get(#mindMap, or: $value.mindMap),
    edebiyat: data.get(#edebiyat, or: $value.edebiyat),
    lessonId: data.get(#lessonId, or: $value.lessonId),
    lessonTyt: data.get(#lessonTyt, or: $value.lessonTyt),
    lessonAyt: data.get(#lessonAyt, or: $value.lessonAyt),
    lessonSos2: data.get(#lessonSos2, or: $value.lessonSos2),
  );

  @override
  GeneralLessonDtoCopyWith<$R2, GeneralLessonDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _GeneralLessonDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class GeneralLessonsResponseMapper
    extends ClassMapperBase<GeneralLessonsResponse> {
  GeneralLessonsResponseMapper._();

  static GeneralLessonsResponseMapper? _instance;
  static GeneralLessonsResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GeneralLessonsResponseMapper._());
      GeneralLessonDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'GeneralLessonsResponse';

  static bool? _$success(GeneralLessonsResponse v) => v.success;
  static const Field<GeneralLessonsResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(GeneralLessonsResponse v) => v.message;
  static const Field<GeneralLessonsResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<GeneralLessonDto>? _$lessons(GeneralLessonsResponse v) =>
      v.lessons;
  static const Field<GeneralLessonsResponse, List<GeneralLessonDto>>
  _f$lessons = Field(
    'lessons',
    _$lessons,
    key: r'generalLessons',
    opt: true,
    hook: MapListHook(),
  );

  @override
  final MappableFields<GeneralLessonsResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #lessons: _f$lessons,
  };
  @override
  final bool ignoreNull = true;

  static GeneralLessonsResponse _instantiate(DecodingData data) {
    return GeneralLessonsResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      lessons: data.dec(_f$lessons),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static GeneralLessonsResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GeneralLessonsResponse>(map);
  }

  static GeneralLessonsResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<GeneralLessonsResponse>(json);
  }
}

mixin GeneralLessonsResponseMappable {
  String toJsonString() {
    return GeneralLessonsResponseMapper.ensureInitialized()
        .encodeJson<GeneralLessonsResponse>(this as GeneralLessonsResponse);
  }

  Map<String, dynamic> toJson() {
    return GeneralLessonsResponseMapper.ensureInitialized()
        .encodeMap<GeneralLessonsResponse>(this as GeneralLessonsResponse);
  }

  GeneralLessonsResponseCopyWith<
    GeneralLessonsResponse,
    GeneralLessonsResponse,
    GeneralLessonsResponse
  >
  get copyWith =>
      _GeneralLessonsResponseCopyWithImpl<
        GeneralLessonsResponse,
        GeneralLessonsResponse
      >(this as GeneralLessonsResponse, $identity, $identity);
  @override
  String toString() {
    return GeneralLessonsResponseMapper.ensureInitialized().stringifyValue(
      this as GeneralLessonsResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return GeneralLessonsResponseMapper.ensureInitialized().equalsValue(
      this as GeneralLessonsResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return GeneralLessonsResponseMapper.ensureInitialized().hashValue(
      this as GeneralLessonsResponse,
    );
  }
}

extension GeneralLessonsResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, GeneralLessonsResponse, $Out> {
  GeneralLessonsResponseCopyWith<$R, GeneralLessonsResponse, $Out>
  get $asGeneralLessonsResponse => $base.as(
    (v, t, t2) => _GeneralLessonsResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class GeneralLessonsResponseCopyWith<
  $R,
  $In extends GeneralLessonsResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    GeneralLessonDto,
    GeneralLessonDtoCopyWith<$R, GeneralLessonDto, GeneralLessonDto>
  >?
  get lessons;
  $R call({bool? success, String? message, List<GeneralLessonDto>? lessons});
  GeneralLessonsResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _GeneralLessonsResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GeneralLessonsResponse, $Out>
    implements
        GeneralLessonsResponseCopyWith<$R, GeneralLessonsResponse, $Out> {
  _GeneralLessonsResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GeneralLessonsResponse> $mapper =
      GeneralLessonsResponseMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    GeneralLessonDto,
    GeneralLessonDtoCopyWith<$R, GeneralLessonDto, GeneralLessonDto>
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
  GeneralLessonsResponse $make(CopyWithData data) => GeneralLessonsResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    lessons: data.get(#lessons, or: $value.lessons),
  );

  @override
  GeneralLessonsResponseCopyWith<$R2, GeneralLessonsResponse, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _GeneralLessonsResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class LessonMissingDtoMapper extends ClassMapperBase<LessonMissingDto> {
  LessonMissingDtoMapper._();

  static LessonMissingDtoMapper? _instance;
  static LessonMissingDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LessonMissingDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'LessonMissingDto';

  static String? _$lessonId(LessonMissingDto v) => v.lessonId;
  static const Field<LessonMissingDto, String> _f$lessonId = Field(
    'lessonId',
    _$lessonId,
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$tyt(LessonMissingDto v) => v.tyt;
  static const Field<LessonMissingDto, int> _f$tyt = Field(
    'tyt',
    _$tyt,
    key: r'1',
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$ayt(LessonMissingDto v) => v.ayt;
  static const Field<LessonMissingDto, int> _f$ayt = Field(
    'ayt',
    _$ayt,
    key: r'2',
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$sos2(LessonMissingDto v) => v.sos2;
  static const Field<LessonMissingDto, int> _f$sos2 = Field(
    'sos2',
    _$sos2,
    key: r'3',
    opt: true,
    hook: IntOrNullHook(),
  );

  @override
  final MappableFields<LessonMissingDto> fields = const {
    #lessonId: _f$lessonId,
    #tyt: _f$tyt,
    #ayt: _f$ayt,
    #sos2: _f$sos2,
  };
  @override
  final bool ignoreNull = true;

  static LessonMissingDto _instantiate(DecodingData data) {
    return LessonMissingDto(
      lessonId: data.dec(_f$lessonId),
      tyt: data.dec(_f$tyt),
      ayt: data.dec(_f$ayt),
      sos2: data.dec(_f$sos2),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LessonMissingDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LessonMissingDto>(map);
  }

  static LessonMissingDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<LessonMissingDto>(json);
  }
}

mixin LessonMissingDtoMappable {
  String toJsonString() {
    return LessonMissingDtoMapper.ensureInitialized()
        .encodeJson<LessonMissingDto>(this as LessonMissingDto);
  }

  Map<String, dynamic> toJson() {
    return LessonMissingDtoMapper.ensureInitialized()
        .encodeMap<LessonMissingDto>(this as LessonMissingDto);
  }

  LessonMissingDtoCopyWith<LessonMissingDto, LessonMissingDto, LessonMissingDto>
  get copyWith =>
      _LessonMissingDtoCopyWithImpl<LessonMissingDto, LessonMissingDto>(
        this as LessonMissingDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return LessonMissingDtoMapper.ensureInitialized().stringifyValue(
      this as LessonMissingDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return LessonMissingDtoMapper.ensureInitialized().equalsValue(
      this as LessonMissingDto,
      other,
    );
  }

  @override
  int get hashCode {
    return LessonMissingDtoMapper.ensureInitialized().hashValue(
      this as LessonMissingDto,
    );
  }
}

extension LessonMissingDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LessonMissingDto, $Out> {
  LessonMissingDtoCopyWith<$R, LessonMissingDto, $Out>
  get $asLessonMissingDto =>
      $base.as((v, t, t2) => _LessonMissingDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LessonMissingDtoCopyWith<$R, $In extends LessonMissingDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? lessonId, int? tyt, int? ayt, int? sos2});
  LessonMissingDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _LessonMissingDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LessonMissingDto, $Out>
    implements LessonMissingDtoCopyWith<$R, LessonMissingDto, $Out> {
  _LessonMissingDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LessonMissingDto> $mapper =
      LessonMissingDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? lessonId = $none,
    Object? tyt = $none,
    Object? ayt = $none,
    Object? sos2 = $none,
  }) => $apply(
    FieldCopyWithData({
      if (lessonId != $none) #lessonId: lessonId,
      if (tyt != $none) #tyt: tyt,
      if (ayt != $none) #ayt: ayt,
      if (sos2 != $none) #sos2: sos2,
    }),
  );
  @override
  LessonMissingDto $make(CopyWithData data) => LessonMissingDto(
    lessonId: data.get(#lessonId, or: $value.lessonId),
    tyt: data.get(#tyt, or: $value.tyt),
    ayt: data.get(#ayt, or: $value.ayt),
    sos2: data.get(#sos2, or: $value.sos2),
  );

  @override
  LessonMissingDtoCopyWith<$R2, LessonMissingDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LessonMissingDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class LessonsMissingResponseMapper
    extends ClassMapperBase<LessonsMissingResponse> {
  LessonsMissingResponseMapper._();

  static LessonsMissingResponseMapper? _instance;
  static LessonsMissingResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LessonsMissingResponseMapper._());
      LessonMissingDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'LessonsMissingResponse';

  static bool? _$success(LessonsMissingResponse v) => v.success;
  static const Field<LessonsMissingResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(LessonsMissingResponse v) => v.message;
  static const Field<LessonsMissingResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<LessonMissingDto>? _$lessons(LessonsMissingResponse v) =>
      v.lessons;
  static const Field<LessonsMissingResponse, List<LessonMissingDto>>
  _f$lessons = Field(
    'lessons',
    _$lessons,
    key: r'lessonObj',
    opt: true,
    hook: LessonMissingMapHook(),
  );

  @override
  final MappableFields<LessonsMissingResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #lessons: _f$lessons,
  };
  @override
  final bool ignoreNull = true;

  static LessonsMissingResponse _instantiate(DecodingData data) {
    return LessonsMissingResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      lessons: data.dec(_f$lessons),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LessonsMissingResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LessonsMissingResponse>(map);
  }

  static LessonsMissingResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<LessonsMissingResponse>(json);
  }
}

mixin LessonsMissingResponseMappable {
  String toJsonString() {
    return LessonsMissingResponseMapper.ensureInitialized()
        .encodeJson<LessonsMissingResponse>(this as LessonsMissingResponse);
  }

  Map<String, dynamic> toJson() {
    return LessonsMissingResponseMapper.ensureInitialized()
        .encodeMap<LessonsMissingResponse>(this as LessonsMissingResponse);
  }

  LessonsMissingResponseCopyWith<
    LessonsMissingResponse,
    LessonsMissingResponse,
    LessonsMissingResponse
  >
  get copyWith =>
      _LessonsMissingResponseCopyWithImpl<
        LessonsMissingResponse,
        LessonsMissingResponse
      >(this as LessonsMissingResponse, $identity, $identity);
  @override
  String toString() {
    return LessonsMissingResponseMapper.ensureInitialized().stringifyValue(
      this as LessonsMissingResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return LessonsMissingResponseMapper.ensureInitialized().equalsValue(
      this as LessonsMissingResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return LessonsMissingResponseMapper.ensureInitialized().hashValue(
      this as LessonsMissingResponse,
    );
  }
}

extension LessonsMissingResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LessonsMissingResponse, $Out> {
  LessonsMissingResponseCopyWith<$R, LessonsMissingResponse, $Out>
  get $asLessonsMissingResponse => $base.as(
    (v, t, t2) => _LessonsMissingResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class LessonsMissingResponseCopyWith<
  $R,
  $In extends LessonsMissingResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    LessonMissingDto,
    LessonMissingDtoCopyWith<$R, LessonMissingDto, LessonMissingDto>
  >?
  get lessons;
  $R call({bool? success, String? message, List<LessonMissingDto>? lessons});
  LessonsMissingResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _LessonsMissingResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LessonsMissingResponse, $Out>
    implements
        LessonsMissingResponseCopyWith<$R, LessonsMissingResponse, $Out> {
  _LessonsMissingResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LessonsMissingResponse> $mapper =
      LessonsMissingResponseMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    LessonMissingDto,
    LessonMissingDtoCopyWith<$R, LessonMissingDto, LessonMissingDto>
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
  LessonsMissingResponse $make(CopyWithData data) => LessonsMissingResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    lessons: data.get(#lessons, or: $value.lessons),
  );

  @override
  LessonsMissingResponseCopyWith<$R2, LessonsMissingResponse, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _LessonsMissingResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MainSubjectDtoMapper extends ClassMapperBase<MainSubjectDto> {
  MainSubjectDtoMapper._();

  static MainSubjectDtoMapper? _instance;
  static MainSubjectDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MainSubjectDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MainSubjectDto';

  static String? _$id(MainSubjectDto v) => v.id;
  static const Field<MainSubjectDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$name(MainSubjectDto v) => v.name;
  static const Field<MainSubjectDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$order(MainSubjectDto v) => v.order;
  static const Field<MainSubjectDto, int> _f$order = Field(
    'order',
    _$order,
    opt: true,
    hook: IntOrNullHook(),
  );
  static String? _$image(MainSubjectDto v) => v.image;
  static const Field<MainSubjectDto, String> _f$image = Field(
    'image',
    _$image,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$imageColor(MainSubjectDto v) => v.imageColor;
  static const Field<MainSubjectDto, String> _f$imageColor = Field(
    'imageColor',
    _$imageColor,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$barColor(MainSubjectDto v) => v.barColor;
  static const Field<MainSubjectDto, String> _f$barColor = Field(
    'barColor',
    _$barColor,
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$itemDataCount(MainSubjectDto v) => v.itemDataCount;
  static const Field<MainSubjectDto, int> _f$itemDataCount = Field(
    'itemDataCount',
    _$itemDataCount,
    opt: true,
    hook: IntOrNullHook(),
  );

  @override
  final MappableFields<MainSubjectDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #order: _f$order,
    #image: _f$image,
    #imageColor: _f$imageColor,
    #barColor: _f$barColor,
    #itemDataCount: _f$itemDataCount,
  };
  @override
  final bool ignoreNull = true;

  static MainSubjectDto _instantiate(DecodingData data) {
    return MainSubjectDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      order: data.dec(_f$order),
      image: data.dec(_f$image),
      imageColor: data.dec(_f$imageColor),
      barColor: data.dec(_f$barColor),
      itemDataCount: data.dec(_f$itemDataCount),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MainSubjectDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MainSubjectDto>(map);
  }

  static MainSubjectDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<MainSubjectDto>(json);
  }
}

mixin MainSubjectDtoMappable {
  String toJsonString() {
    return MainSubjectDtoMapper.ensureInitialized().encodeJson<MainSubjectDto>(
      this as MainSubjectDto,
    );
  }

  Map<String, dynamic> toJson() {
    return MainSubjectDtoMapper.ensureInitialized().encodeMap<MainSubjectDto>(
      this as MainSubjectDto,
    );
  }

  MainSubjectDtoCopyWith<MainSubjectDto, MainSubjectDto, MainSubjectDto>
  get copyWith => _MainSubjectDtoCopyWithImpl<MainSubjectDto, MainSubjectDto>(
    this as MainSubjectDto,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return MainSubjectDtoMapper.ensureInitialized().stringifyValue(
      this as MainSubjectDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return MainSubjectDtoMapper.ensureInitialized().equalsValue(
      this as MainSubjectDto,
      other,
    );
  }

  @override
  int get hashCode {
    return MainSubjectDtoMapper.ensureInitialized().hashValue(
      this as MainSubjectDto,
    );
  }
}

extension MainSubjectDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MainSubjectDto, $Out> {
  MainSubjectDtoCopyWith<$R, MainSubjectDto, $Out> get $asMainSubjectDto =>
      $base.as((v, t, t2) => _MainSubjectDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MainSubjectDtoCopyWith<$R, $In extends MainSubjectDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    int? order,
    String? image,
    String? imageColor,
    String? barColor,
    int? itemDataCount,
  });
  MainSubjectDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MainSubjectDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MainSubjectDto, $Out>
    implements MainSubjectDtoCopyWith<$R, MainSubjectDto, $Out> {
  _MainSubjectDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MainSubjectDto> $mapper =
      MainSubjectDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? id = $none,
    Object? name = $none,
    Object? order = $none,
    Object? image = $none,
    Object? imageColor = $none,
    Object? barColor = $none,
    Object? itemDataCount = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (name != $none) #name: name,
      if (order != $none) #order: order,
      if (image != $none) #image: image,
      if (imageColor != $none) #imageColor: imageColor,
      if (barColor != $none) #barColor: barColor,
      if (itemDataCount != $none) #itemDataCount: itemDataCount,
    }),
  );
  @override
  MainSubjectDto $make(CopyWithData data) => MainSubjectDto(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    order: data.get(#order, or: $value.order),
    image: data.get(#image, or: $value.image),
    imageColor: data.get(#imageColor, or: $value.imageColor),
    barColor: data.get(#barColor, or: $value.barColor),
    itemDataCount: data.get(#itemDataCount, or: $value.itemDataCount),
  );

  @override
  MainSubjectDtoCopyWith<$R2, MainSubjectDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MainSubjectDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class FilterObjDtoMapper extends ClassMapperBase<FilterObjDto> {
  FilterObjDtoMapper._();

  static FilterObjDtoMapper? _instance;
  static FilterObjDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FilterObjDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'FilterObjDto';

  static String? _$name(FilterObjDto v) => v.name;
  static const Field<FilterObjDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$value(FilterObjDto v) => v.value;
  static const Field<FilterObjDto, int> _f$value = Field(
    'value',
    _$value,
    opt: true,
    hook: IntOrNullHook(),
  );

  @override
  final MappableFields<FilterObjDto> fields = const {
    #name: _f$name,
    #value: _f$value,
  };
  @override
  final bool ignoreNull = true;

  static FilterObjDto _instantiate(DecodingData data) {
    return FilterObjDto(name: data.dec(_f$name), value: data.dec(_f$value));
  }

  @override
  final Function instantiate = _instantiate;

  static FilterObjDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FilterObjDto>(map);
  }

  static FilterObjDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<FilterObjDto>(json);
  }
}

mixin FilterObjDtoMappable {
  String toJsonString() {
    return FilterObjDtoMapper.ensureInitialized().encodeJson<FilterObjDto>(
      this as FilterObjDto,
    );
  }

  Map<String, dynamic> toJson() {
    return FilterObjDtoMapper.ensureInitialized().encodeMap<FilterObjDto>(
      this as FilterObjDto,
    );
  }

  FilterObjDtoCopyWith<FilterObjDto, FilterObjDto, FilterObjDto> get copyWith =>
      _FilterObjDtoCopyWithImpl<FilterObjDto, FilterObjDto>(
        this as FilterObjDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return FilterObjDtoMapper.ensureInitialized().stringifyValue(
      this as FilterObjDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return FilterObjDtoMapper.ensureInitialized().equalsValue(
      this as FilterObjDto,
      other,
    );
  }

  @override
  int get hashCode {
    return FilterObjDtoMapper.ensureInitialized().hashValue(
      this as FilterObjDto,
    );
  }
}

extension FilterObjDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FilterObjDto, $Out> {
  FilterObjDtoCopyWith<$R, FilterObjDto, $Out> get $asFilterObjDto =>
      $base.as((v, t, t2) => _FilterObjDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FilterObjDtoCopyWith<$R, $In extends FilterObjDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? name, int? value});
  FilterObjDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _FilterObjDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FilterObjDto, $Out>
    implements FilterObjDtoCopyWith<$R, FilterObjDto, $Out> {
  _FilterObjDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FilterObjDto> $mapper =
      FilterObjDtoMapper.ensureInitialized();
  @override
  $R call({Object? name = $none, Object? value = $none}) => $apply(
    FieldCopyWithData({
      if (name != $none) #name: name,
      if (value != $none) #value: value,
    }),
  );
  @override
  FilterObjDto $make(CopyWithData data) => FilterObjDto(
    name: data.get(#name, or: $value.name),
    value: data.get(#value, or: $value.value),
  );

  @override
  FilterObjDtoCopyWith<$R2, FilterObjDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _FilterObjDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class SubjectCountDtoMapper extends ClassMapperBase<SubjectCountDto> {
  SubjectCountDtoMapper._();

  static SubjectCountDtoMapper? _instance;
  static SubjectCountDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SubjectCountDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'SubjectCountDto';

  static String? _$id(SubjectCountDto v) => v.id;
  static const Field<SubjectCountDto, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$count(SubjectCountDto v) => v.count;
  static const Field<SubjectCountDto, int> _f$count = Field(
    'count',
    _$count,
    opt: true,
    hook: IntOrNullHook(),
  );

  @override
  final MappableFields<SubjectCountDto> fields = const {
    #id: _f$id,
    #count: _f$count,
  };
  @override
  final bool ignoreNull = true;

  static SubjectCountDto _instantiate(DecodingData data) {
    return SubjectCountDto(id: data.dec(_f$id), count: data.dec(_f$count));
  }

  @override
  final Function instantiate = _instantiate;

  static SubjectCountDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SubjectCountDto>(map);
  }

  static SubjectCountDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<SubjectCountDto>(json);
  }
}

mixin SubjectCountDtoMappable {
  String toJsonString() {
    return SubjectCountDtoMapper.ensureInitialized()
        .encodeJson<SubjectCountDto>(this as SubjectCountDto);
  }

  Map<String, dynamic> toJson() {
    return SubjectCountDtoMapper.ensureInitialized().encodeMap<SubjectCountDto>(
      this as SubjectCountDto,
    );
  }

  SubjectCountDtoCopyWith<SubjectCountDto, SubjectCountDto, SubjectCountDto>
  get copyWith =>
      _SubjectCountDtoCopyWithImpl<SubjectCountDto, SubjectCountDto>(
        this as SubjectCountDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SubjectCountDtoMapper.ensureInitialized().stringifyValue(
      this as SubjectCountDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return SubjectCountDtoMapper.ensureInitialized().equalsValue(
      this as SubjectCountDto,
      other,
    );
  }

  @override
  int get hashCode {
    return SubjectCountDtoMapper.ensureInitialized().hashValue(
      this as SubjectCountDto,
    );
  }
}

extension SubjectCountDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SubjectCountDto, $Out> {
  SubjectCountDtoCopyWith<$R, SubjectCountDto, $Out> get $asSubjectCountDto =>
      $base.as((v, t, t2) => _SubjectCountDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SubjectCountDtoCopyWith<$R, $In extends SubjectCountDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, int? count});
  SubjectCountDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SubjectCountDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SubjectCountDto, $Out>
    implements SubjectCountDtoCopyWith<$R, SubjectCountDto, $Out> {
  _SubjectCountDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SubjectCountDto> $mapper =
      SubjectCountDtoMapper.ensureInitialized();
  @override
  $R call({Object? id = $none, Object? count = $none}) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (count != $none) #count: count,
    }),
  );
  @override
  SubjectCountDto $make(CopyWithData data) => SubjectCountDto(
    id: data.get(#id, or: $value.id),
    count: data.get(#count, or: $value.count),
  );

  @override
  SubjectCountDtoCopyWith<$R2, SubjectCountDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SubjectCountDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class TypeMissingDtoMapper extends ClassMapperBase<TypeMissingDto> {
  TypeMissingDtoMapper._();

  static TypeMissingDtoMapper? _instance;
  static TypeMissingDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TypeMissingDtoMapper._());
      SubjectCountDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TypeMissingDto';

  static int? _$type(TypeMissingDto v) => v.type;
  static const Field<TypeMissingDto, int> _f$type = Field(
    'type',
    _$type,
    opt: true,
    hook: IntOrNullHook(),
  );
  static List<SubjectCountDto>? _$subjects(TypeMissingDto v) => v.subjects;
  static const Field<TypeMissingDto, List<SubjectCountDto>> _f$subjects = Field(
    'subjects',
    _$subjects,
    opt: true,
    hook: MapListHook(),
  );

  @override
  final MappableFields<TypeMissingDto> fields = const {
    #type: _f$type,
    #subjects: _f$subjects,
  };
  @override
  final bool ignoreNull = true;

  static TypeMissingDto _instantiate(DecodingData data) {
    return TypeMissingDto(
      type: data.dec(_f$type),
      subjects: data.dec(_f$subjects),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TypeMissingDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TypeMissingDto>(map);
  }

  static TypeMissingDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<TypeMissingDto>(json);
  }
}

mixin TypeMissingDtoMappable {
  String toJsonString() {
    return TypeMissingDtoMapper.ensureInitialized().encodeJson<TypeMissingDto>(
      this as TypeMissingDto,
    );
  }

  Map<String, dynamic> toJson() {
    return TypeMissingDtoMapper.ensureInitialized().encodeMap<TypeMissingDto>(
      this as TypeMissingDto,
    );
  }

  TypeMissingDtoCopyWith<TypeMissingDto, TypeMissingDto, TypeMissingDto>
  get copyWith => _TypeMissingDtoCopyWithImpl<TypeMissingDto, TypeMissingDto>(
    this as TypeMissingDto,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return TypeMissingDtoMapper.ensureInitialized().stringifyValue(
      this as TypeMissingDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return TypeMissingDtoMapper.ensureInitialized().equalsValue(
      this as TypeMissingDto,
      other,
    );
  }

  @override
  int get hashCode {
    return TypeMissingDtoMapper.ensureInitialized().hashValue(
      this as TypeMissingDto,
    );
  }
}

extension TypeMissingDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TypeMissingDto, $Out> {
  TypeMissingDtoCopyWith<$R, TypeMissingDto, $Out> get $asTypeMissingDto =>
      $base.as((v, t, t2) => _TypeMissingDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TypeMissingDtoCopyWith<$R, $In extends TypeMissingDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    SubjectCountDto,
    SubjectCountDtoCopyWith<$R, SubjectCountDto, SubjectCountDto>
  >?
  get subjects;
  $R call({int? type, List<SubjectCountDto>? subjects});
  TypeMissingDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TypeMissingDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TypeMissingDto, $Out>
    implements TypeMissingDtoCopyWith<$R, TypeMissingDto, $Out> {
  _TypeMissingDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TypeMissingDto> $mapper =
      TypeMissingDtoMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    SubjectCountDto,
    SubjectCountDtoCopyWith<$R, SubjectCountDto, SubjectCountDto>
  >?
  get subjects => $value.subjects != null
      ? ListCopyWith(
          $value.subjects!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(subjects: v),
        )
      : null;
  @override
  $R call({Object? type = $none, Object? subjects = $none}) => $apply(
    FieldCopyWithData({
      if (type != $none) #type: type,
      if (subjects != $none) #subjects: subjects,
    }),
  );
  @override
  TypeMissingDto $make(CopyWithData data) => TypeMissingDto(
    type: data.get(#type, or: $value.type),
    subjects: data.get(#subjects, or: $value.subjects),
  );

  @override
  TypeMissingDtoCopyWith<$R2, TypeMissingDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TypeMissingDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MainSubjectsResponseMapper extends ClassMapperBase<MainSubjectsResponse> {
  MainSubjectsResponseMapper._();

  static MainSubjectsResponseMapper? _instance;
  static MainSubjectsResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MainSubjectsResponseMapper._());
      MainSubjectDtoMapper.ensureInitialized();
      FilterObjDtoMapper.ensureInitialized();
      TypeMissingDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MainSubjectsResponse';

  static bool? _$success(MainSubjectsResponse v) => v.success;
  static const Field<MainSubjectsResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(MainSubjectsResponse v) => v.message;
  static const Field<MainSubjectsResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<MainSubjectDto>? _$subjects(MainSubjectsResponse v) => v.subjects;
  static const Field<MainSubjectsResponse, List<MainSubjectDto>> _f$subjects =
      Field('subjects', _$subjects, opt: true, hook: MapListHook());
  static List<FilterObjDto>? _$filters(MainSubjectsResponse v) => v.filters;
  static const Field<MainSubjectsResponse, List<FilterObjDto>> _f$filters =
      Field(
        'filters',
        _$filters,
        key: r'filterObjs',
        opt: true,
        hook: MapListHook(),
      );
  static List<TypeMissingDto>? _$missingByType(MainSubjectsResponse v) =>
      v.missingByType;
  static const Field<MainSubjectsResponse, List<TypeMissingDto>>
  _f$missingByType = Field(
    'missingByType',
    _$missingByType,
    key: r'resultByType',
    opt: true,
    hook: MissingByTypeHook(),
  );

  @override
  final MappableFields<MainSubjectsResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #subjects: _f$subjects,
    #filters: _f$filters,
    #missingByType: _f$missingByType,
  };
  @override
  final bool ignoreNull = true;

  static MainSubjectsResponse _instantiate(DecodingData data) {
    return MainSubjectsResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      subjects: data.dec(_f$subjects),
      filters: data.dec(_f$filters),
      missingByType: data.dec(_f$missingByType),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MainSubjectsResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MainSubjectsResponse>(map);
  }

  static MainSubjectsResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<MainSubjectsResponse>(json);
  }
}

mixin MainSubjectsResponseMappable {
  String toJsonString() {
    return MainSubjectsResponseMapper.ensureInitialized()
        .encodeJson<MainSubjectsResponse>(this as MainSubjectsResponse);
  }

  Map<String, dynamic> toJson() {
    return MainSubjectsResponseMapper.ensureInitialized()
        .encodeMap<MainSubjectsResponse>(this as MainSubjectsResponse);
  }

  MainSubjectsResponseCopyWith<
    MainSubjectsResponse,
    MainSubjectsResponse,
    MainSubjectsResponse
  >
  get copyWith =>
      _MainSubjectsResponseCopyWithImpl<
        MainSubjectsResponse,
        MainSubjectsResponse
      >(this as MainSubjectsResponse, $identity, $identity);
  @override
  String toString() {
    return MainSubjectsResponseMapper.ensureInitialized().stringifyValue(
      this as MainSubjectsResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return MainSubjectsResponseMapper.ensureInitialized().equalsValue(
      this as MainSubjectsResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return MainSubjectsResponseMapper.ensureInitialized().hashValue(
      this as MainSubjectsResponse,
    );
  }
}

extension MainSubjectsResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MainSubjectsResponse, $Out> {
  MainSubjectsResponseCopyWith<$R, MainSubjectsResponse, $Out>
  get $asMainSubjectsResponse => $base.as(
    (v, t, t2) => _MainSubjectsResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class MainSubjectsResponseCopyWith<
  $R,
  $In extends MainSubjectsResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    MainSubjectDto,
    MainSubjectDtoCopyWith<$R, MainSubjectDto, MainSubjectDto>
  >?
  get subjects;
  ListCopyWith<
    $R,
    FilterObjDto,
    FilterObjDtoCopyWith<$R, FilterObjDto, FilterObjDto>
  >?
  get filters;
  ListCopyWith<
    $R,
    TypeMissingDto,
    TypeMissingDtoCopyWith<$R, TypeMissingDto, TypeMissingDto>
  >?
  get missingByType;
  $R call({
    bool? success,
    String? message,
    List<MainSubjectDto>? subjects,
    List<FilterObjDto>? filters,
    List<TypeMissingDto>? missingByType,
  });
  MainSubjectsResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MainSubjectsResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MainSubjectsResponse, $Out>
    implements MainSubjectsResponseCopyWith<$R, MainSubjectsResponse, $Out> {
  _MainSubjectsResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MainSubjectsResponse> $mapper =
      MainSubjectsResponseMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    MainSubjectDto,
    MainSubjectDtoCopyWith<$R, MainSubjectDto, MainSubjectDto>
  >?
  get subjects => $value.subjects != null
      ? ListCopyWith(
          $value.subjects!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(subjects: v),
        )
      : null;
  @override
  ListCopyWith<
    $R,
    FilterObjDto,
    FilterObjDtoCopyWith<$R, FilterObjDto, FilterObjDto>
  >?
  get filters => $value.filters != null
      ? ListCopyWith(
          $value.filters!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(filters: v),
        )
      : null;
  @override
  ListCopyWith<
    $R,
    TypeMissingDto,
    TypeMissingDtoCopyWith<$R, TypeMissingDto, TypeMissingDto>
  >?
  get missingByType => $value.missingByType != null
      ? ListCopyWith(
          $value.missingByType!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(missingByType: v),
        )
      : null;
  @override
  $R call({
    Object? success = $none,
    Object? message = $none,
    Object? subjects = $none,
    Object? filters = $none,
    Object? missingByType = $none,
  }) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
      if (subjects != $none) #subjects: subjects,
      if (filters != $none) #filters: filters,
      if (missingByType != $none) #missingByType: missingByType,
    }),
  );
  @override
  MainSubjectsResponse $make(CopyWithData data) => MainSubjectsResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    subjects: data.get(#subjects, or: $value.subjects),
    filters: data.get(#filters, or: $value.filters),
    missingByType: data.get(#missingByType, or: $value.missingByType),
  );

  @override
  MainSubjectsResponseCopyWith<$R2, MainSubjectsResponse, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MainSubjectsResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class YazarMainSubjectsResponseMapper
    extends ClassMapperBase<YazarMainSubjectsResponse> {
  YazarMainSubjectsResponseMapper._();

  static YazarMainSubjectsResponseMapper? _instance;
  static YazarMainSubjectsResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = YazarMainSubjectsResponseMapper._(),
      );
      MainSubjectDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'YazarMainSubjectsResponse';

  static bool? _$success(YazarMainSubjectsResponse v) => v.success;
  static const Field<YazarMainSubjectsResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(YazarMainSubjectsResponse v) => v.message;
  static const Field<YazarMainSubjectsResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<MainSubjectDto>? _$subjects(YazarMainSubjectsResponse v) =>
      v.subjects;
  static const Field<YazarMainSubjectsResponse, List<MainSubjectDto>>
  _f$subjects = Field(
    'subjects',
    _$subjects,
    key: r'mainSubjects',
    opt: true,
    hook: MapListHook(),
  );

  @override
  final MappableFields<YazarMainSubjectsResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #subjects: _f$subjects,
  };
  @override
  final bool ignoreNull = true;

  static YazarMainSubjectsResponse _instantiate(DecodingData data) {
    return YazarMainSubjectsResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      subjects: data.dec(_f$subjects),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static YazarMainSubjectsResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<YazarMainSubjectsResponse>(map);
  }

  static YazarMainSubjectsResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<YazarMainSubjectsResponse>(json);
  }
}

mixin YazarMainSubjectsResponseMappable {
  String toJsonString() {
    return YazarMainSubjectsResponseMapper.ensureInitialized()
        .encodeJson<YazarMainSubjectsResponse>(
          this as YazarMainSubjectsResponse,
        );
  }

  Map<String, dynamic> toJson() {
    return YazarMainSubjectsResponseMapper.ensureInitialized()
        .encodeMap<YazarMainSubjectsResponse>(
          this as YazarMainSubjectsResponse,
        );
  }

  YazarMainSubjectsResponseCopyWith<
    YazarMainSubjectsResponse,
    YazarMainSubjectsResponse,
    YazarMainSubjectsResponse
  >
  get copyWith =>
      _YazarMainSubjectsResponseCopyWithImpl<
        YazarMainSubjectsResponse,
        YazarMainSubjectsResponse
      >(this as YazarMainSubjectsResponse, $identity, $identity);
  @override
  String toString() {
    return YazarMainSubjectsResponseMapper.ensureInitialized().stringifyValue(
      this as YazarMainSubjectsResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return YazarMainSubjectsResponseMapper.ensureInitialized().equalsValue(
      this as YazarMainSubjectsResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return YazarMainSubjectsResponseMapper.ensureInitialized().hashValue(
      this as YazarMainSubjectsResponse,
    );
  }
}

extension YazarMainSubjectsResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, YazarMainSubjectsResponse, $Out> {
  YazarMainSubjectsResponseCopyWith<$R, YazarMainSubjectsResponse, $Out>
  get $asYazarMainSubjectsResponse => $base.as(
    (v, t, t2) => _YazarMainSubjectsResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class YazarMainSubjectsResponseCopyWith<
  $R,
  $In extends YazarMainSubjectsResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    MainSubjectDto,
    MainSubjectDtoCopyWith<$R, MainSubjectDto, MainSubjectDto>
  >?
  get subjects;
  $R call({bool? success, String? message, List<MainSubjectDto>? subjects});
  YazarMainSubjectsResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _YazarMainSubjectsResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, YazarMainSubjectsResponse, $Out>
    implements
        YazarMainSubjectsResponseCopyWith<$R, YazarMainSubjectsResponse, $Out> {
  _YazarMainSubjectsResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<YazarMainSubjectsResponse> $mapper =
      YazarMainSubjectsResponseMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    MainSubjectDto,
    MainSubjectDtoCopyWith<$R, MainSubjectDto, MainSubjectDto>
  >?
  get subjects => $value.subjects != null
      ? ListCopyWith(
          $value.subjects!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(subjects: v),
        )
      : null;
  @override
  $R call({
    Object? success = $none,
    Object? message = $none,
    Object? subjects = $none,
  }) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
      if (subjects != $none) #subjects: subjects,
    }),
  );
  @override
  YazarMainSubjectsResponse $make(CopyWithData data) =>
      YazarMainSubjectsResponse(
        success: data.get(#success, or: $value.success),
        message: data.get(#message, or: $value.message),
        subjects: data.get(#subjects, or: $value.subjects),
      );

  @override
  YazarMainSubjectsResponseCopyWith<$R2, YazarMainSubjectsResponse, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _YazarMainSubjectsResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class SubSubjectDtoMapper extends ClassMapperBase<SubSubjectDto> {
  SubSubjectDtoMapper._();

  static SubSubjectDtoMapper? _instance;
  static SubSubjectDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SubSubjectDtoMapper._());
      ItemDataDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SubSubjectDto';

  static String? _$id(SubSubjectDto v) => v.id;
  static const Field<SubSubjectDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$name(SubSubjectDto v) => v.name;
  static const Field<SubSubjectDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$itemDataCount(SubSubjectDto v) => v.itemDataCount;
  static const Field<SubSubjectDto, int> _f$itemDataCount = Field(
    'itemDataCount',
    _$itemDataCount,
    opt: true,
    hook: IntOrNullHook(),
  );
  static List<ItemDataDto>? _$itemDatas(SubSubjectDto v) => v.itemDatas;
  static const Field<SubSubjectDto, List<ItemDataDto>> _f$itemDatas = Field(
    'itemDatas',
    _$itemDatas,
    opt: true,
    hook: MapListHook(),
  );

  @override
  final MappableFields<SubSubjectDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #itemDataCount: _f$itemDataCount,
    #itemDatas: _f$itemDatas,
  };
  @override
  final bool ignoreNull = true;

  static SubSubjectDto _instantiate(DecodingData data) {
    return SubSubjectDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      itemDataCount: data.dec(_f$itemDataCount),
      itemDatas: data.dec(_f$itemDatas),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SubSubjectDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SubSubjectDto>(map);
  }

  static SubSubjectDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<SubSubjectDto>(json);
  }
}

mixin SubSubjectDtoMappable {
  String toJsonString() {
    return SubSubjectDtoMapper.ensureInitialized().encodeJson<SubSubjectDto>(
      this as SubSubjectDto,
    );
  }

  Map<String, dynamic> toJson() {
    return SubSubjectDtoMapper.ensureInitialized().encodeMap<SubSubjectDto>(
      this as SubSubjectDto,
    );
  }

  SubSubjectDtoCopyWith<SubSubjectDto, SubSubjectDto, SubSubjectDto>
  get copyWith => _SubSubjectDtoCopyWithImpl<SubSubjectDto, SubSubjectDto>(
    this as SubSubjectDto,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return SubSubjectDtoMapper.ensureInitialized().stringifyValue(
      this as SubSubjectDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return SubSubjectDtoMapper.ensureInitialized().equalsValue(
      this as SubSubjectDto,
      other,
    );
  }

  @override
  int get hashCode {
    return SubSubjectDtoMapper.ensureInitialized().hashValue(
      this as SubSubjectDto,
    );
  }
}

extension SubSubjectDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SubSubjectDto, $Out> {
  SubSubjectDtoCopyWith<$R, SubSubjectDto, $Out> get $asSubSubjectDto =>
      $base.as((v, t, t2) => _SubSubjectDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SubSubjectDtoCopyWith<$R, $In extends SubSubjectDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    ItemDataDto,
    ItemDataDtoCopyWith<$R, ItemDataDto, ItemDataDto>
  >?
  get itemDatas;
  $R call({
    String? id,
    String? name,
    int? itemDataCount,
    List<ItemDataDto>? itemDatas,
  });
  SubSubjectDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SubSubjectDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SubSubjectDto, $Out>
    implements SubSubjectDtoCopyWith<$R, SubSubjectDto, $Out> {
  _SubSubjectDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SubSubjectDto> $mapper =
      SubSubjectDtoMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    ItemDataDto,
    ItemDataDtoCopyWith<$R, ItemDataDto, ItemDataDto>
  >?
  get itemDatas => $value.itemDatas != null
      ? ListCopyWith(
          $value.itemDatas!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(itemDatas: v),
        )
      : null;
  @override
  $R call({
    Object? id = $none,
    Object? name = $none,
    Object? itemDataCount = $none,
    Object? itemDatas = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (name != $none) #name: name,
      if (itemDataCount != $none) #itemDataCount: itemDataCount,
      if (itemDatas != $none) #itemDatas: itemDatas,
    }),
  );
  @override
  SubSubjectDto $make(CopyWithData data) => SubSubjectDto(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    itemDataCount: data.get(#itemDataCount, or: $value.itemDataCount),
    itemDatas: data.get(#itemDatas, or: $value.itemDatas),
  );

  @override
  SubSubjectDtoCopyWith<$R2, SubSubjectDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SubSubjectDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class SubSubjectsResponseMapper extends ClassMapperBase<SubSubjectsResponse> {
  SubSubjectsResponseMapper._();

  static SubSubjectsResponseMapper? _instance;
  static SubSubjectsResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SubSubjectsResponseMapper._());
      SubSubjectDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SubSubjectsResponse';

  static bool? _$success(SubSubjectsResponse v) => v.success;
  static const Field<SubSubjectsResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(SubSubjectsResponse v) => v.message;
  static const Field<SubSubjectsResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<SubSubjectDto>? _$subSubjects(SubSubjectsResponse v) =>
      v.subSubjects;
  static const Field<SubSubjectsResponse, List<SubSubjectDto>> _f$subSubjects =
      Field('subSubjects', _$subSubjects, opt: true, hook: MapListHook());

  @override
  final MappableFields<SubSubjectsResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #subSubjects: _f$subSubjects,
  };
  @override
  final bool ignoreNull = true;

  static SubSubjectsResponse _instantiate(DecodingData data) {
    return SubSubjectsResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      subSubjects: data.dec(_f$subSubjects),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SubSubjectsResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SubSubjectsResponse>(map);
  }

  static SubSubjectsResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<SubSubjectsResponse>(json);
  }
}

mixin SubSubjectsResponseMappable {
  String toJsonString() {
    return SubSubjectsResponseMapper.ensureInitialized()
        .encodeJson<SubSubjectsResponse>(this as SubSubjectsResponse);
  }

  Map<String, dynamic> toJson() {
    return SubSubjectsResponseMapper.ensureInitialized()
        .encodeMap<SubSubjectsResponse>(this as SubSubjectsResponse);
  }

  SubSubjectsResponseCopyWith<
    SubSubjectsResponse,
    SubSubjectsResponse,
    SubSubjectsResponse
  >
  get copyWith =>
      _SubSubjectsResponseCopyWithImpl<
        SubSubjectsResponse,
        SubSubjectsResponse
      >(this as SubSubjectsResponse, $identity, $identity);
  @override
  String toString() {
    return SubSubjectsResponseMapper.ensureInitialized().stringifyValue(
      this as SubSubjectsResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return SubSubjectsResponseMapper.ensureInitialized().equalsValue(
      this as SubSubjectsResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return SubSubjectsResponseMapper.ensureInitialized().hashValue(
      this as SubSubjectsResponse,
    );
  }
}

extension SubSubjectsResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SubSubjectsResponse, $Out> {
  SubSubjectsResponseCopyWith<$R, SubSubjectsResponse, $Out>
  get $asSubSubjectsResponse => $base.as(
    (v, t, t2) => _SubSubjectsResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class SubSubjectsResponseCopyWith<
  $R,
  $In extends SubSubjectsResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    SubSubjectDto,
    SubSubjectDtoCopyWith<$R, SubSubjectDto, SubSubjectDto>
  >?
  get subSubjects;
  $R call({bool? success, String? message, List<SubSubjectDto>? subSubjects});
  SubSubjectsResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SubSubjectsResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SubSubjectsResponse, $Out>
    implements SubSubjectsResponseCopyWith<$R, SubSubjectsResponse, $Out> {
  _SubSubjectsResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SubSubjectsResponse> $mapper =
      SubSubjectsResponseMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    SubSubjectDto,
    SubSubjectDtoCopyWith<$R, SubSubjectDto, SubSubjectDto>
  >?
  get subSubjects => $value.subSubjects != null
      ? ListCopyWith(
          $value.subSubjects!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(subSubjects: v),
        )
      : null;
  @override
  $R call({
    Object? success = $none,
    Object? message = $none,
    Object? subSubjects = $none,
  }) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
      if (subSubjects != $none) #subSubjects: subSubjects,
    }),
  );
  @override
  SubSubjectsResponse $make(CopyWithData data) => SubSubjectsResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    subSubjects: data.get(#subSubjects, or: $value.subSubjects),
  );

  @override
  SubSubjectsResponseCopyWith<$R2, SubSubjectsResponse, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _SubSubjectsResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ItemsResponseMapper extends ClassMapperBase<ItemsResponse> {
  ItemsResponseMapper._();

  static ItemsResponseMapper? _instance;
  static ItemsResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ItemsResponseMapper._());
      ItemListDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ItemsResponse';

  static bool? _$success(ItemsResponse v) => v.success;
  static const Field<ItemsResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(ItemsResponse v) => v.message;
  static const Field<ItemsResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<ItemListDto>? _$itemLists(ItemsResponse v) => v.itemLists;
  static const Field<ItemsResponse, List<ItemListDto>> _f$itemLists = Field(
    'itemLists',
    _$itemLists,
    key: r'itemsArray',
    opt: true,
    hook: ItemListsHook(),
  );

  @override
  final MappableFields<ItemsResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #itemLists: _f$itemLists,
  };
  @override
  final bool ignoreNull = true;

  static ItemsResponse _instantiate(DecodingData data) {
    return ItemsResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      itemLists: data.dec(_f$itemLists),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ItemsResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ItemsResponse>(map);
  }

  static ItemsResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<ItemsResponse>(json);
  }
}

mixin ItemsResponseMappable {
  String toJsonString() {
    return ItemsResponseMapper.ensureInitialized().encodeJson<ItemsResponse>(
      this as ItemsResponse,
    );
  }

  Map<String, dynamic> toJson() {
    return ItemsResponseMapper.ensureInitialized().encodeMap<ItemsResponse>(
      this as ItemsResponse,
    );
  }

  ItemsResponseCopyWith<ItemsResponse, ItemsResponse, ItemsResponse>
  get copyWith => _ItemsResponseCopyWithImpl<ItemsResponse, ItemsResponse>(
    this as ItemsResponse,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ItemsResponseMapper.ensureInitialized().stringifyValue(
      this as ItemsResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return ItemsResponseMapper.ensureInitialized().equalsValue(
      this as ItemsResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return ItemsResponseMapper.ensureInitialized().hashValue(
      this as ItemsResponse,
    );
  }
}

extension ItemsResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ItemsResponse, $Out> {
  ItemsResponseCopyWith<$R, ItemsResponse, $Out> get $asItemsResponse =>
      $base.as((v, t, t2) => _ItemsResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ItemsResponseCopyWith<$R, $In extends ItemsResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    ItemListDto,
    ItemListDtoCopyWith<$R, ItemListDto, ItemListDto>
  >?
  get itemLists;
  $R call({bool? success, String? message, List<ItemListDto>? itemLists});
  ItemsResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ItemsResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ItemsResponse, $Out>
    implements ItemsResponseCopyWith<$R, ItemsResponse, $Out> {
  _ItemsResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ItemsResponse> $mapper =
      ItemsResponseMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    ItemListDto,
    ItemListDtoCopyWith<$R, ItemListDto, ItemListDto>
  >?
  get itemLists => $value.itemLists != null
      ? ListCopyWith(
          $value.itemLists!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(itemLists: v),
        )
      : null;
  @override
  $R call({
    Object? success = $none,
    Object? message = $none,
    Object? itemLists = $none,
  }) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
      if (itemLists != $none) #itemLists: itemLists,
    }),
  );
  @override
  ItemsResponse $make(CopyWithData data) => ItemsResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    itemLists: data.get(#itemLists, or: $value.itemLists),
  );

  @override
  ItemsResponseCopyWith<$R2, ItemsResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ItemsResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class SubjectAuthorsResponseMapper
    extends ClassMapperBase<SubjectAuthorsResponse> {
  SubjectAuthorsResponseMapper._();

  static SubjectAuthorsResponseMapper? _instance;
  static SubjectAuthorsResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SubjectAuthorsResponseMapper._());
      LessonItemDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SubjectAuthorsResponse';

  static bool? _$success(SubjectAuthorsResponse v) => v.success;
  static const Field<SubjectAuthorsResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(SubjectAuthorsResponse v) => v.message;
  static const Field<SubjectAuthorsResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<LessonItemDto>? _$authors(SubjectAuthorsResponse v) => v.authors;
  static const Field<SubjectAuthorsResponse, List<LessonItemDto>> _f$authors =
      Field('authors', _$authors, opt: true, hook: MapListHook());

  @override
  final MappableFields<SubjectAuthorsResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #authors: _f$authors,
  };
  @override
  final bool ignoreNull = true;

  static SubjectAuthorsResponse _instantiate(DecodingData data) {
    return SubjectAuthorsResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      authors: data.dec(_f$authors),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SubjectAuthorsResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SubjectAuthorsResponse>(map);
  }

  static SubjectAuthorsResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<SubjectAuthorsResponse>(json);
  }
}

mixin SubjectAuthorsResponseMappable {
  String toJsonString() {
    return SubjectAuthorsResponseMapper.ensureInitialized()
        .encodeJson<SubjectAuthorsResponse>(this as SubjectAuthorsResponse);
  }

  Map<String, dynamic> toJson() {
    return SubjectAuthorsResponseMapper.ensureInitialized()
        .encodeMap<SubjectAuthorsResponse>(this as SubjectAuthorsResponse);
  }

  SubjectAuthorsResponseCopyWith<
    SubjectAuthorsResponse,
    SubjectAuthorsResponse,
    SubjectAuthorsResponse
  >
  get copyWith =>
      _SubjectAuthorsResponseCopyWithImpl<
        SubjectAuthorsResponse,
        SubjectAuthorsResponse
      >(this as SubjectAuthorsResponse, $identity, $identity);
  @override
  String toString() {
    return SubjectAuthorsResponseMapper.ensureInitialized().stringifyValue(
      this as SubjectAuthorsResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return SubjectAuthorsResponseMapper.ensureInitialized().equalsValue(
      this as SubjectAuthorsResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return SubjectAuthorsResponseMapper.ensureInitialized().hashValue(
      this as SubjectAuthorsResponse,
    );
  }
}

extension SubjectAuthorsResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SubjectAuthorsResponse, $Out> {
  SubjectAuthorsResponseCopyWith<$R, SubjectAuthorsResponse, $Out>
  get $asSubjectAuthorsResponse => $base.as(
    (v, t, t2) => _SubjectAuthorsResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class SubjectAuthorsResponseCopyWith<
  $R,
  $In extends SubjectAuthorsResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    LessonItemDto,
    LessonItemDtoCopyWith<$R, LessonItemDto, LessonItemDto>
  >?
  get authors;
  $R call({bool? success, String? message, List<LessonItemDto>? authors});
  SubjectAuthorsResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SubjectAuthorsResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SubjectAuthorsResponse, $Out>
    implements
        SubjectAuthorsResponseCopyWith<$R, SubjectAuthorsResponse, $Out> {
  _SubjectAuthorsResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SubjectAuthorsResponse> $mapper =
      SubjectAuthorsResponseMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    LessonItemDto,
    LessonItemDtoCopyWith<$R, LessonItemDto, LessonItemDto>
  >?
  get authors => $value.authors != null
      ? ListCopyWith(
          $value.authors!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(authors: v),
        )
      : null;
  @override
  $R call({
    Object? success = $none,
    Object? message = $none,
    Object? authors = $none,
  }) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
      if (authors != $none) #authors: authors,
    }),
  );
  @override
  SubjectAuthorsResponse $make(CopyWithData data) => SubjectAuthorsResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    authors: data.get(#authors, or: $value.authors),
  );

  @override
  SubjectAuthorsResponseCopyWith<$R2, SubjectAuthorsResponse, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _SubjectAuthorsResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class SuccessResponseMapper extends ClassMapperBase<SuccessResponse> {
  SuccessResponseMapper._();

  static SuccessResponseMapper? _instance;
  static SuccessResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SuccessResponseMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'SuccessResponse';

  static bool? _$success(SuccessResponse v) => v.success;
  static const Field<SuccessResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(SuccessResponse v) => v.message;
  static const Field<SuccessResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );

  @override
  final MappableFields<SuccessResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
  };
  @override
  final bool ignoreNull = true;

  static SuccessResponse _instantiate(DecodingData data) {
    return SuccessResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SuccessResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SuccessResponse>(map);
  }

  static SuccessResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<SuccessResponse>(json);
  }
}

mixin SuccessResponseMappable {
  String toJsonString() {
    return SuccessResponseMapper.ensureInitialized()
        .encodeJson<SuccessResponse>(this as SuccessResponse);
  }

  Map<String, dynamic> toJson() {
    return SuccessResponseMapper.ensureInitialized().encodeMap<SuccessResponse>(
      this as SuccessResponse,
    );
  }

  SuccessResponseCopyWith<SuccessResponse, SuccessResponse, SuccessResponse>
  get copyWith =>
      _SuccessResponseCopyWithImpl<SuccessResponse, SuccessResponse>(
        this as SuccessResponse,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SuccessResponseMapper.ensureInitialized().stringifyValue(
      this as SuccessResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return SuccessResponseMapper.ensureInitialized().equalsValue(
      this as SuccessResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return SuccessResponseMapper.ensureInitialized().hashValue(
      this as SuccessResponse,
    );
  }
}

extension SuccessResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SuccessResponse, $Out> {
  SuccessResponseCopyWith<$R, SuccessResponse, $Out> get $asSuccessResponse =>
      $base.as((v, t, t2) => _SuccessResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SuccessResponseCopyWith<$R, $In extends SuccessResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({bool? success, String? message});
  SuccessResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SuccessResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SuccessResponse, $Out>
    implements SuccessResponseCopyWith<$R, SuccessResponse, $Out> {
  _SuccessResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SuccessResponse> $mapper =
      SuccessResponseMapper.ensureInitialized();
  @override
  $R call({Object? success = $none, Object? message = $none}) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
    }),
  );
  @override
  SuccessResponse $make(CopyWithData data) => SuccessResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
  );

  @override
  SuccessResponseCopyWith<$R2, SuccessResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SuccessResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

