// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../bag_item_dto.dart';

class BagTopicDtoMapper extends ClassMapperBase<BagTopicDto> {
  BagTopicDtoMapper._();

  static BagTopicDtoMapper? _instance;
  static BagTopicDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BagTopicDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'BagTopicDto';

  static String? _$id(BagTopicDto v) => v.id;
  static const Field<BagTopicDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$name(BagTopicDto v) => v.name;
  static const Field<BagTopicDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$subject(BagTopicDto v) => v.subject;
  static const Field<BagTopicDto, String> _f$subject = Field(
    'subject',
    _$subject,
    key: r'konu',
    opt: true,
    hook: TextOrNullHook(),
  );

  @override
  final MappableFields<BagTopicDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #subject: _f$subject,
  };
  @override
  final bool ignoreNull = true;

  static BagTopicDto _instantiate(DecodingData data) {
    return BagTopicDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      subject: data.dec(_f$subject),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static BagTopicDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BagTopicDto>(map);
  }

  static BagTopicDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<BagTopicDto>(json);
  }
}

mixin BagTopicDtoMappable {
  String toJsonString() {
    return BagTopicDtoMapper.ensureInitialized().encodeJson<BagTopicDto>(
      this as BagTopicDto,
    );
  }

  Map<String, dynamic> toJson() {
    return BagTopicDtoMapper.ensureInitialized().encodeMap<BagTopicDto>(
      this as BagTopicDto,
    );
  }

  BagTopicDtoCopyWith<BagTopicDto, BagTopicDto, BagTopicDto> get copyWith =>
      _BagTopicDtoCopyWithImpl<BagTopicDto, BagTopicDto>(
        this as BagTopicDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return BagTopicDtoMapper.ensureInitialized().stringifyValue(
      this as BagTopicDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return BagTopicDtoMapper.ensureInitialized().equalsValue(
      this as BagTopicDto,
      other,
    );
  }

  @override
  int get hashCode {
    return BagTopicDtoMapper.ensureInitialized().hashValue(this as BagTopicDto);
  }
}

extension BagTopicDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BagTopicDto, $Out> {
  BagTopicDtoCopyWith<$R, BagTopicDto, $Out> get $asBagTopicDto =>
      $base.as((v, t, t2) => _BagTopicDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BagTopicDtoCopyWith<$R, $In extends BagTopicDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? name, String? subject});
  BagTopicDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BagTopicDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BagTopicDto, $Out>
    implements BagTopicDtoCopyWith<$R, BagTopicDto, $Out> {
  _BagTopicDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BagTopicDto> $mapper =
      BagTopicDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? id = $none,
    Object? name = $none,
    Object? subject = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (name != $none) #name: name,
      if (subject != $none) #subject: subject,
    }),
  );
  @override
  BagTopicDto $make(CopyWithData data) => BagTopicDto(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    subject: data.get(#subject, or: $value.subject),
  );

  @override
  BagTopicDtoCopyWith<$R2, BagTopicDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BagTopicDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class BagLessonDtoMapper extends ClassMapperBase<BagLessonDto> {
  BagLessonDtoMapper._();

  static BagLessonDtoMapper? _instance;
  static BagLessonDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BagLessonDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'BagLessonDto';

  static String? _$id(BagLessonDto v) => v.id;
  static const Field<BagLessonDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$name(BagLessonDto v) => v.name;
  static const Field<BagLessonDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$lessonColor(BagLessonDto v) => v.lessonColor;
  static const Field<BagLessonDto, String> _f$lessonColor = Field(
    'lessonColor',
    _$lessonColor,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$mapImage(BagLessonDto v) => v.mapImage;
  static const Field<BagLessonDto, String> _f$mapImage = Field(
    'mapImage',
    _$mapImage,
    opt: true,
    hook: TextOrNullHook(),
  );

  @override
  final MappableFields<BagLessonDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #lessonColor: _f$lessonColor,
    #mapImage: _f$mapImage,
  };
  @override
  final bool ignoreNull = true;

  static BagLessonDto _instantiate(DecodingData data) {
    return BagLessonDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      lessonColor: data.dec(_f$lessonColor),
      mapImage: data.dec(_f$mapImage),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static BagLessonDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BagLessonDto>(map);
  }

  static BagLessonDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<BagLessonDto>(json);
  }
}

mixin BagLessonDtoMappable {
  String toJsonString() {
    return BagLessonDtoMapper.ensureInitialized().encodeJson<BagLessonDto>(
      this as BagLessonDto,
    );
  }

  Map<String, dynamic> toJson() {
    return BagLessonDtoMapper.ensureInitialized().encodeMap<BagLessonDto>(
      this as BagLessonDto,
    );
  }

  BagLessonDtoCopyWith<BagLessonDto, BagLessonDto, BagLessonDto> get copyWith =>
      _BagLessonDtoCopyWithImpl<BagLessonDto, BagLessonDto>(
        this as BagLessonDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return BagLessonDtoMapper.ensureInitialized().stringifyValue(
      this as BagLessonDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return BagLessonDtoMapper.ensureInitialized().equalsValue(
      this as BagLessonDto,
      other,
    );
  }

  @override
  int get hashCode {
    return BagLessonDtoMapper.ensureInitialized().hashValue(
      this as BagLessonDto,
    );
  }
}

extension BagLessonDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BagLessonDto, $Out> {
  BagLessonDtoCopyWith<$R, BagLessonDto, $Out> get $asBagLessonDto =>
      $base.as((v, t, t2) => _BagLessonDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BagLessonDtoCopyWith<$R, $In extends BagLessonDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? id, String? name, String? lessonColor, String? mapImage});
  BagLessonDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BagLessonDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BagLessonDto, $Out>
    implements BagLessonDtoCopyWith<$R, BagLessonDto, $Out> {
  _BagLessonDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BagLessonDto> $mapper =
      BagLessonDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? id = $none,
    Object? name = $none,
    Object? lessonColor = $none,
    Object? mapImage = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (name != $none) #name: name,
      if (lessonColor != $none) #lessonColor: lessonColor,
      if (mapImage != $none) #mapImage: mapImage,
    }),
  );
  @override
  BagLessonDto $make(CopyWithData data) => BagLessonDto(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    lessonColor: data.get(#lessonColor, or: $value.lessonColor),
    mapImage: data.get(#mapImage, or: $value.mapImage),
  );

  @override
  BagLessonDtoCopyWith<$R2, BagLessonDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BagLessonDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class BagItemDtoMapper extends ClassMapperBase<BagItemDto> {
  BagItemDtoMapper._();

  static BagItemDtoMapper? _instance;
  static BagItemDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BagItemDtoMapper._());
      BagTopicDtoMapper.ensureInitialized();
      BagLessonDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'BagItemDto';

  static String? _$student(BagItemDto v) => v.student;
  static const Field<BagItemDto, String> _f$student = Field(
    'student',
    _$student,
    opt: true,
    hook: CoachRefHook(),
  );
  static String? _$mainSubject(BagItemDto v) => v.mainSubject;
  static const Field<BagItemDto, String> _f$mainSubject = Field(
    'mainSubject',
    _$mainSubject,
    opt: true,
    hook: TextOrNullHook(),
  );
  static BagTopicDto? _$data(BagItemDto v) => v.data;
  static const Field<BagItemDto, BagTopicDto> _f$data = Field(
    'data',
    _$data,
    opt: true,
    hook: ObjectOrNullHook(),
  );
  static BagLessonDto? _$lesson(BagItemDto v) => v.lesson;
  static const Field<BagItemDto, BagLessonDto> _f$lesson = Field(
    'lesson',
    _$lesson,
    opt: true,
    hook: ObjectOrNullHook(),
  );

  @override
  final MappableFields<BagItemDto> fields = const {
    #student: _f$student,
    #mainSubject: _f$mainSubject,
    #data: _f$data,
    #lesson: _f$lesson,
  };
  @override
  final bool ignoreNull = true;

  static BagItemDto _instantiate(DecodingData data) {
    return BagItemDto(
      student: data.dec(_f$student),
      mainSubject: data.dec(_f$mainSubject),
      data: data.dec(_f$data),
      lesson: data.dec(_f$lesson),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static BagItemDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BagItemDto>(map);
  }

  static BagItemDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<BagItemDto>(json);
  }
}

mixin BagItemDtoMappable {
  String toJsonString() {
    return BagItemDtoMapper.ensureInitialized().encodeJson<BagItemDto>(
      this as BagItemDto,
    );
  }

  Map<String, dynamic> toJson() {
    return BagItemDtoMapper.ensureInitialized().encodeMap<BagItemDto>(
      this as BagItemDto,
    );
  }

  BagItemDtoCopyWith<BagItemDto, BagItemDto, BagItemDto> get copyWith =>
      _BagItemDtoCopyWithImpl<BagItemDto, BagItemDto>(
        this as BagItemDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return BagItemDtoMapper.ensureInitialized().stringifyValue(
      this as BagItemDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return BagItemDtoMapper.ensureInitialized().equalsValue(
      this as BagItemDto,
      other,
    );
  }

  @override
  int get hashCode {
    return BagItemDtoMapper.ensureInitialized().hashValue(this as BagItemDto);
  }
}

extension BagItemDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BagItemDto, $Out> {
  BagItemDtoCopyWith<$R, BagItemDto, $Out> get $asBagItemDto =>
      $base.as((v, t, t2) => _BagItemDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BagItemDtoCopyWith<$R, $In extends BagItemDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  BagTopicDtoCopyWith<$R, BagTopicDto, BagTopicDto>? get data;
  BagLessonDtoCopyWith<$R, BagLessonDto, BagLessonDto>? get lesson;
  $R call({
    String? student,
    String? mainSubject,
    BagTopicDto? data,
    BagLessonDto? lesson,
  });
  BagItemDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BagItemDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BagItemDto, $Out>
    implements BagItemDtoCopyWith<$R, BagItemDto, $Out> {
  _BagItemDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BagItemDto> $mapper =
      BagItemDtoMapper.ensureInitialized();
  @override
  BagTopicDtoCopyWith<$R, BagTopicDto, BagTopicDto>? get data =>
      $value.data?.copyWith.$chain((v) => call(data: v));
  @override
  BagLessonDtoCopyWith<$R, BagLessonDto, BagLessonDto>? get lesson =>
      $value.lesson?.copyWith.$chain((v) => call(lesson: v));
  @override
  $R call({
    Object? student = $none,
    Object? mainSubject = $none,
    Object? data = $none,
    Object? lesson = $none,
  }) => $apply(
    FieldCopyWithData({
      if (student != $none) #student: student,
      if (mainSubject != $none) #mainSubject: mainSubject,
      if (data != $none) #data: data,
      if (lesson != $none) #lesson: lesson,
    }),
  );
  @override
  BagItemDto $make(CopyWithData data) => BagItemDto(
    student: data.get(#student, or: $value.student),
    mainSubject: data.get(#mainSubject, or: $value.mainSubject),
    data: data.get(#data, or: $value.data),
    lesson: data.get(#lesson, or: $value.lesson),
  );

  @override
  BagItemDtoCopyWith<$R2, BagItemDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BagItemDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

