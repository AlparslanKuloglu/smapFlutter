// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../main_subject_dto.dart';

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

  @override
  final MappableFields<MainSubjectDto> fields = const {
    #id: _f$id,
    #name: _f$name,
  };
  @override
  final bool ignoreNull = true;

  static MainSubjectDto _instantiate(DecodingData data) {
    return MainSubjectDto(id: data.dec(_f$id), name: data.dec(_f$name));
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
  $R call({String? id, String? name});
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
  $R call({Object? id = $none, Object? name = $none}) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (name != $none) #name: name,
    }),
  );
  @override
  MainSubjectDto $make(CopyWithData data) => MainSubjectDto(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
  );

  @override
  MainSubjectDtoCopyWith<$R2, MainSubjectDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MainSubjectDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

