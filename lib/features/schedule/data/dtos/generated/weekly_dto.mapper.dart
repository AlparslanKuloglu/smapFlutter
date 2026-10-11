// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../weekly_dto.dart';

class WeeklyDtoMapper extends ClassMapperBase<WeeklyDto> {
  WeeklyDtoMapper._();

  static WeeklyDtoMapper? _instance;
  static WeeklyDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WeeklyDtoMapper._());
      ProgramTaskDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'WeeklyDto';

  static String? _$id(WeeklyDto v) => v.id;
  static const Field<WeeklyDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$name(WeeklyDto v) => v.name;
  static const Field<WeeklyDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$motto(WeeklyDto v) => v.motto;
  static const Field<WeeklyDto, String> _f$motto = Field(
    'motto',
    _$motto,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$student(WeeklyDto v) => v.student;
  static const Field<WeeklyDto, String> _f$student = Field(
    'student',
    _$student,
    opt: true,
    hook: CoachRefHook(),
  );
  static List<ProgramTaskDto> _$tasks(WeeklyDto v) => v.tasks;
  static const Field<WeeklyDto, List<ProgramTaskDto>> _f$tasks = Field(
    'tasks',
    _$tasks,
    key: r'content',
    opt: true,
    def: const [],
    hook: ProgramTasksHook(),
  );

  @override
  final MappableFields<WeeklyDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #motto: _f$motto,
    #student: _f$student,
    #tasks: _f$tasks,
  };
  @override
  final bool ignoreNull = true;

  static WeeklyDto _instantiate(DecodingData data) {
    return WeeklyDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      motto: data.dec(_f$motto),
      student: data.dec(_f$student),
      tasks: data.dec(_f$tasks),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static WeeklyDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<WeeklyDto>(map);
  }

  static WeeklyDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<WeeklyDto>(json);
  }
}

mixin WeeklyDtoMappable {
  String toJsonString() {
    return WeeklyDtoMapper.ensureInitialized().encodeJson<WeeklyDto>(
      this as WeeklyDto,
    );
  }

  Map<String, dynamic> toJson() {
    return WeeklyDtoMapper.ensureInitialized().encodeMap<WeeklyDto>(
      this as WeeklyDto,
    );
  }

  WeeklyDtoCopyWith<WeeklyDto, WeeklyDto, WeeklyDto> get copyWith =>
      _WeeklyDtoCopyWithImpl<WeeklyDto, WeeklyDto>(
        this as WeeklyDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return WeeklyDtoMapper.ensureInitialized().stringifyValue(
      this as WeeklyDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return WeeklyDtoMapper.ensureInitialized().equalsValue(
      this as WeeklyDto,
      other,
    );
  }

  @override
  int get hashCode {
    return WeeklyDtoMapper.ensureInitialized().hashValue(this as WeeklyDto);
  }
}

extension WeeklyDtoValueCopy<$R, $Out> on ObjectCopyWith<$R, WeeklyDto, $Out> {
  WeeklyDtoCopyWith<$R, WeeklyDto, $Out> get $asWeeklyDto =>
      $base.as((v, t, t2) => _WeeklyDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class WeeklyDtoCopyWith<$R, $In extends WeeklyDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    ProgramTaskDto,
    ProgramTaskDtoCopyWith<$R, ProgramTaskDto, ProgramTaskDto>
  >
  get tasks;
  $R call({
    String? id,
    String? name,
    String? motto,
    String? student,
    List<ProgramTaskDto>? tasks,
  });
  WeeklyDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _WeeklyDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, WeeklyDto, $Out>
    implements WeeklyDtoCopyWith<$R, WeeklyDto, $Out> {
  _WeeklyDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<WeeklyDto> $mapper =
      WeeklyDtoMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    ProgramTaskDto,
    ProgramTaskDtoCopyWith<$R, ProgramTaskDto, ProgramTaskDto>
  >
  get tasks => ListCopyWith(
    $value.tasks,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(tasks: v),
  );
  @override
  $R call({
    Object? id = $none,
    Object? name = $none,
    Object? motto = $none,
    Object? student = $none,
    List<ProgramTaskDto>? tasks,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (name != $none) #name: name,
      if (motto != $none) #motto: motto,
      if (student != $none) #student: student,
      if (tasks != null) #tasks: tasks,
    }),
  );
  @override
  WeeklyDto $make(CopyWithData data) => WeeklyDto(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    motto: data.get(#motto, or: $value.motto),
    student: data.get(#student, or: $value.student),
    tasks: data.get(#tasks, or: $value.tasks),
  );

  @override
  WeeklyDtoCopyWith<$R2, WeeklyDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _WeeklyDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

