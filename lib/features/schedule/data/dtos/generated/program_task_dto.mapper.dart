// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../program_task_dto.dart';

class ProgramTaskDtoMapper extends ClassMapperBase<ProgramTaskDto> {
  ProgramTaskDtoMapper._();

  static ProgramTaskDtoMapper? _instance;
  static ProgramTaskDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProgramTaskDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ProgramTaskDto';

  static String? _$id(ProgramTaskDto v) => v.id;
  static const Field<ProgramTaskDto, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$day(ProgramTaskDto v) => v.day;
  static const Field<ProgramTaskDto, String> _f$day = Field(
    'day',
    _$day,
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$hour(ProgramTaskDto v) => v.hour;
  static const Field<ProgramTaskDto, int> _f$hour = Field(
    'hour',
    _$hour,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$minute(ProgramTaskDto v) => v.minute;
  static const Field<ProgramTaskDto, int> _f$minute = Field(
    'minute',
    _$minute,
    opt: true,
    hook: IntOrNullHook(),
  );
  static String? _$lesson(ProgramTaskDto v) => v.lesson;
  static const Field<ProgramTaskDto, String> _f$lesson = Field(
    'lesson',
    _$lesson,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$lessonName(ProgramTaskDto v) => v.lessonName;
  static const Field<ProgramTaskDto, String> _f$lessonName = Field(
    'lessonName',
    _$lessonName,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$mainSubject(ProgramTaskDto v) => v.mainSubject;
  static const Field<ProgramTaskDto, String> _f$mainSubject = Field(
    'mainSubject',
    _$mainSubject,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$subject(ProgramTaskDto v) => v.subject;
  static const Field<ProgramTaskDto, String> _f$subject = Field(
    'subject',
    _$subject,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$item(ProgramTaskDto v) => v.item;
  static const Field<ProgramTaskDto, String> _f$item = Field(
    'item',
    _$item,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$title(ProgramTaskDto v) => v.title;
  static const Field<ProgramTaskDto, String> _f$title = Field(
    'title',
    _$title,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$category(ProgramTaskDto v) => v.category;
  static const Field<ProgramTaskDto, String> _f$category = Field(
    'category',
    _$category,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$lessonColor(ProgramTaskDto v) => v.lessonColor;
  static const Field<ProgramTaskDto, String> _f$lessonColor = Field(
    'lessonColor',
    _$lessonColor,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$mapImage(ProgramTaskDto v) => v.mapImage;
  static const Field<ProgramTaskDto, String> _f$mapImage = Field(
    'mapImage',
    _$mapImage,
    opt: true,
    hook: TextOrNullHook(),
  );

  @override
  final MappableFields<ProgramTaskDto> fields = const {
    #id: _f$id,
    #day: _f$day,
    #hour: _f$hour,
    #minute: _f$minute,
    #lesson: _f$lesson,
    #lessonName: _f$lessonName,
    #mainSubject: _f$mainSubject,
    #subject: _f$subject,
    #item: _f$item,
    #title: _f$title,
    #category: _f$category,
    #lessonColor: _f$lessonColor,
    #mapImage: _f$mapImage,
  };
  @override
  final bool ignoreNull = true;

  static ProgramTaskDto _instantiate(DecodingData data) {
    return ProgramTaskDto(
      id: data.dec(_f$id),
      day: data.dec(_f$day),
      hour: data.dec(_f$hour),
      minute: data.dec(_f$minute),
      lesson: data.dec(_f$lesson),
      lessonName: data.dec(_f$lessonName),
      mainSubject: data.dec(_f$mainSubject),
      subject: data.dec(_f$subject),
      item: data.dec(_f$item),
      title: data.dec(_f$title),
      category: data.dec(_f$category),
      lessonColor: data.dec(_f$lessonColor),
      mapImage: data.dec(_f$mapImage),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ProgramTaskDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProgramTaskDto>(map);
  }

  static ProgramTaskDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<ProgramTaskDto>(json);
  }
}

mixin ProgramTaskDtoMappable {
  String toJsonString() {
    return ProgramTaskDtoMapper.ensureInitialized().encodeJson<ProgramTaskDto>(
      this as ProgramTaskDto,
    );
  }

  Map<String, dynamic> toJson() {
    return ProgramTaskDtoMapper.ensureInitialized().encodeMap<ProgramTaskDto>(
      this as ProgramTaskDto,
    );
  }

  ProgramTaskDtoCopyWith<ProgramTaskDto, ProgramTaskDto, ProgramTaskDto>
  get copyWith => _ProgramTaskDtoCopyWithImpl<ProgramTaskDto, ProgramTaskDto>(
    this as ProgramTaskDto,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ProgramTaskDtoMapper.ensureInitialized().stringifyValue(
      this as ProgramTaskDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProgramTaskDtoMapper.ensureInitialized().equalsValue(
      this as ProgramTaskDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ProgramTaskDtoMapper.ensureInitialized().hashValue(
      this as ProgramTaskDto,
    );
  }
}

extension ProgramTaskDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ProgramTaskDto, $Out> {
  ProgramTaskDtoCopyWith<$R, ProgramTaskDto, $Out> get $asProgramTaskDto =>
      $base.as((v, t, t2) => _ProgramTaskDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProgramTaskDtoCopyWith<$R, $In extends ProgramTaskDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? day,
    int? hour,
    int? minute,
    String? lesson,
    String? lessonName,
    String? mainSubject,
    String? subject,
    String? item,
    String? title,
    String? category,
    String? lessonColor,
    String? mapImage,
  });
  ProgramTaskDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ProgramTaskDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ProgramTaskDto, $Out>
    implements ProgramTaskDtoCopyWith<$R, ProgramTaskDto, $Out> {
  _ProgramTaskDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProgramTaskDto> $mapper =
      ProgramTaskDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? id = $none,
    Object? day = $none,
    Object? hour = $none,
    Object? minute = $none,
    Object? lesson = $none,
    Object? lessonName = $none,
    Object? mainSubject = $none,
    Object? subject = $none,
    Object? item = $none,
    Object? title = $none,
    Object? category = $none,
    Object? lessonColor = $none,
    Object? mapImage = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (day != $none) #day: day,
      if (hour != $none) #hour: hour,
      if (minute != $none) #minute: minute,
      if (lesson != $none) #lesson: lesson,
      if (lessonName != $none) #lessonName: lessonName,
      if (mainSubject != $none) #mainSubject: mainSubject,
      if (subject != $none) #subject: subject,
      if (item != $none) #item: item,
      if (title != $none) #title: title,
      if (category != $none) #category: category,
      if (lessonColor != $none) #lessonColor: lessonColor,
      if (mapImage != $none) #mapImage: mapImage,
    }),
  );
  @override
  ProgramTaskDto $make(CopyWithData data) => ProgramTaskDto(
    id: data.get(#id, or: $value.id),
    day: data.get(#day, or: $value.day),
    hour: data.get(#hour, or: $value.hour),
    minute: data.get(#minute, or: $value.minute),
    lesson: data.get(#lesson, or: $value.lesson),
    lessonName: data.get(#lessonName, or: $value.lessonName),
    mainSubject: data.get(#mainSubject, or: $value.mainSubject),
    subject: data.get(#subject, or: $value.subject),
    item: data.get(#item, or: $value.item),
    title: data.get(#title, or: $value.title),
    category: data.get(#category, or: $value.category),
    lessonColor: data.get(#lessonColor, or: $value.lessonColor),
    mapImage: data.get(#mapImage, or: $value.mapImage),
  );

  @override
  ProgramTaskDtoCopyWith<$R2, ProgramTaskDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ProgramTaskDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

