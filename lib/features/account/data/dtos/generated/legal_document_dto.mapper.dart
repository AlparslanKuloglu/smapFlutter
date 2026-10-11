// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../legal_document_dto.dart';

class LegalDocumentDtoMapper extends ClassMapperBase<LegalDocumentDto> {
  LegalDocumentDtoMapper._();

  static LegalDocumentDtoMapper? _instance;
  static LegalDocumentDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LegalDocumentDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'LegalDocumentDto';

  static String? _$id(LegalDocumentDto v) => v.id;
  static const Field<LegalDocumentDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$name(LegalDocumentDto v) => v.name;
  static const Field<LegalDocumentDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$title(LegalDocumentDto v) => v.title;
  static const Field<LegalDocumentDto, String> _f$title = Field(
    'title',
    _$title,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$version(LegalDocumentDto v) => v.version;
  static const Field<LegalDocumentDto, String> _f$version = Field(
    'version',
    _$version,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$content(LegalDocumentDto v) => v.content;
  static const Field<LegalDocumentDto, String> _f$content = Field(
    'content',
    _$content,
    opt: true,
    hook: TextOrNullHook(),
  );
  static bool? _$isActive(LegalDocumentDto v) => v.isActive;
  static const Field<LegalDocumentDto, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    hook: BoolOrNullHook(),
  );

  @override
  final MappableFields<LegalDocumentDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #title: _f$title,
    #version: _f$version,
    #content: _f$content,
    #isActive: _f$isActive,
  };
  @override
  final bool ignoreNull = true;

  static LegalDocumentDto _instantiate(DecodingData data) {
    return LegalDocumentDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      title: data.dec(_f$title),
      version: data.dec(_f$version),
      content: data.dec(_f$content),
      isActive: data.dec(_f$isActive),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LegalDocumentDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LegalDocumentDto>(map);
  }

  static LegalDocumentDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<LegalDocumentDto>(json);
  }
}

mixin LegalDocumentDtoMappable {
  String toJsonString() {
    return LegalDocumentDtoMapper.ensureInitialized()
        .encodeJson<LegalDocumentDto>(this as LegalDocumentDto);
  }

  Map<String, dynamic> toJson() {
    return LegalDocumentDtoMapper.ensureInitialized()
        .encodeMap<LegalDocumentDto>(this as LegalDocumentDto);
  }

  LegalDocumentDtoCopyWith<LegalDocumentDto, LegalDocumentDto, LegalDocumentDto>
  get copyWith =>
      _LegalDocumentDtoCopyWithImpl<LegalDocumentDto, LegalDocumentDto>(
        this as LegalDocumentDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return LegalDocumentDtoMapper.ensureInitialized().stringifyValue(
      this as LegalDocumentDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return LegalDocumentDtoMapper.ensureInitialized().equalsValue(
      this as LegalDocumentDto,
      other,
    );
  }

  @override
  int get hashCode {
    return LegalDocumentDtoMapper.ensureInitialized().hashValue(
      this as LegalDocumentDto,
    );
  }
}

extension LegalDocumentDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LegalDocumentDto, $Out> {
  LegalDocumentDtoCopyWith<$R, LegalDocumentDto, $Out>
  get $asLegalDocumentDto =>
      $base.as((v, t, t2) => _LegalDocumentDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LegalDocumentDtoCopyWith<$R, $In extends LegalDocumentDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? title,
    String? version,
    String? content,
    bool? isActive,
  });
  LegalDocumentDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _LegalDocumentDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LegalDocumentDto, $Out>
    implements LegalDocumentDtoCopyWith<$R, LegalDocumentDto, $Out> {
  _LegalDocumentDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LegalDocumentDto> $mapper =
      LegalDocumentDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? id = $none,
    Object? name = $none,
    Object? title = $none,
    Object? version = $none,
    Object? content = $none,
    Object? isActive = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (name != $none) #name: name,
      if (title != $none) #title: title,
      if (version != $none) #version: version,
      if (content != $none) #content: content,
      if (isActive != $none) #isActive: isActive,
    }),
  );
  @override
  LegalDocumentDto $make(CopyWithData data) => LegalDocumentDto(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    title: data.get(#title, or: $value.title),
    version: data.get(#version, or: $value.version),
    content: data.get(#content, or: $value.content),
    isActive: data.get(#isActive, or: $value.isActive),
  );

  @override
  LegalDocumentDtoCopyWith<$R2, LegalDocumentDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LegalDocumentDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

