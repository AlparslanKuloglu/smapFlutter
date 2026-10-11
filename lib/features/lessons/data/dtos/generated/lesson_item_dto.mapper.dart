// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../lesson_item_dto.dart';

class PromptDtoMapper extends ClassMapperBase<PromptDto> {
  PromptDtoMapper._();

  static PromptDtoMapper? _instance;
  static PromptDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PromptDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PromptDto';

  static String? _$title(PromptDto v) => v.title;
  static const Field<PromptDto, String> _f$title = Field(
    'title',
    _$title,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$content(PromptDto v) => v.content;
  static const Field<PromptDto, String> _f$content = Field(
    'content',
    _$content,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$text(PromptDto v) => v.text;
  static const Field<PromptDto, String> _f$text = Field(
    'text',
    _$text,
    opt: true,
    hook: TextOrNullHook(),
  );
  static bool? _$isFavorite(PromptDto v) => v.isFavorite;
  static const Field<PromptDto, bool> _f$isFavorite = Field(
    'isFavorite',
    _$isFavorite,
    opt: true,
    hook: BoolOrNullHook(),
  );

  @override
  final MappableFields<PromptDto> fields = const {
    #title: _f$title,
    #content: _f$content,
    #text: _f$text,
    #isFavorite: _f$isFavorite,
  };
  @override
  final bool ignoreNull = true;

  static PromptDto _instantiate(DecodingData data) {
    return PromptDto(
      title: data.dec(_f$title),
      content: data.dec(_f$content),
      text: data.dec(_f$text),
      isFavorite: data.dec(_f$isFavorite),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PromptDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PromptDto>(map);
  }

  static PromptDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<PromptDto>(json);
  }
}

mixin PromptDtoMappable {
  String toJsonString() {
    return PromptDtoMapper.ensureInitialized().encodeJson<PromptDto>(
      this as PromptDto,
    );
  }

  Map<String, dynamic> toJson() {
    return PromptDtoMapper.ensureInitialized().encodeMap<PromptDto>(
      this as PromptDto,
    );
  }

  PromptDtoCopyWith<PromptDto, PromptDto, PromptDto> get copyWith =>
      _PromptDtoCopyWithImpl<PromptDto, PromptDto>(
        this as PromptDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PromptDtoMapper.ensureInitialized().stringifyValue(
      this as PromptDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return PromptDtoMapper.ensureInitialized().equalsValue(
      this as PromptDto,
      other,
    );
  }

  @override
  int get hashCode {
    return PromptDtoMapper.ensureInitialized().hashValue(this as PromptDto);
  }
}

extension PromptDtoValueCopy<$R, $Out> on ObjectCopyWith<$R, PromptDto, $Out> {
  PromptDtoCopyWith<$R, PromptDto, $Out> get $asPromptDto =>
      $base.as((v, t, t2) => _PromptDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PromptDtoCopyWith<$R, $In extends PromptDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? title, String? content, String? text, bool? isFavorite});
  PromptDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PromptDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PromptDto, $Out>
    implements PromptDtoCopyWith<$R, PromptDto, $Out> {
  _PromptDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PromptDto> $mapper =
      PromptDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? title = $none,
    Object? content = $none,
    Object? text = $none,
    Object? isFavorite = $none,
  }) => $apply(
    FieldCopyWithData({
      if (title != $none) #title: title,
      if (content != $none) #content: content,
      if (text != $none) #text: text,
      if (isFavorite != $none) #isFavorite: isFavorite,
    }),
  );
  @override
  PromptDto $make(CopyWithData data) => PromptDto(
    title: data.get(#title, or: $value.title),
    content: data.get(#content, or: $value.content),
    text: data.get(#text, or: $value.text),
    isFavorite: data.get(#isFavorite, or: $value.isFavorite),
  );

  @override
  PromptDtoCopyWith<$R2, PromptDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PromptDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class YazarRefDtoMapper extends ClassMapperBase<YazarRefDto> {
  YazarRefDtoMapper._();

  static YazarRefDtoMapper? _instance;
  static YazarRefDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = YazarRefDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'YazarRefDto';

  static String? _$yazarCategory(YazarRefDto v) => v.yazarCategory;
  static const Field<YazarRefDto, String> _f$yazarCategory = Field(
    'yazarCategory',
    _$yazarCategory,
    opt: true,
    hook: IdRefHook(),
  );

  @override
  final MappableFields<YazarRefDto> fields = const {
    #yazarCategory: _f$yazarCategory,
  };
  @override
  final bool ignoreNull = true;

  static YazarRefDto _instantiate(DecodingData data) {
    return YazarRefDto(yazarCategory: data.dec(_f$yazarCategory));
  }

  @override
  final Function instantiate = _instantiate;

  static YazarRefDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<YazarRefDto>(map);
  }

  static YazarRefDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<YazarRefDto>(json);
  }
}

mixin YazarRefDtoMappable {
  String toJsonString() {
    return YazarRefDtoMapper.ensureInitialized().encodeJson<YazarRefDto>(
      this as YazarRefDto,
    );
  }

  Map<String, dynamic> toJson() {
    return YazarRefDtoMapper.ensureInitialized().encodeMap<YazarRefDto>(
      this as YazarRefDto,
    );
  }

  YazarRefDtoCopyWith<YazarRefDto, YazarRefDto, YazarRefDto> get copyWith =>
      _YazarRefDtoCopyWithImpl<YazarRefDto, YazarRefDto>(
        this as YazarRefDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return YazarRefDtoMapper.ensureInitialized().stringifyValue(
      this as YazarRefDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return YazarRefDtoMapper.ensureInitialized().equalsValue(
      this as YazarRefDto,
      other,
    );
  }

  @override
  int get hashCode {
    return YazarRefDtoMapper.ensureInitialized().hashValue(this as YazarRefDto);
  }
}

extension YazarRefDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, YazarRefDto, $Out> {
  YazarRefDtoCopyWith<$R, YazarRefDto, $Out> get $asYazarRefDto =>
      $base.as((v, t, t2) => _YazarRefDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class YazarRefDtoCopyWith<$R, $In extends YazarRefDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? yazarCategory});
  YazarRefDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _YazarRefDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, YazarRefDto, $Out>
    implements YazarRefDtoCopyWith<$R, YazarRefDto, $Out> {
  _YazarRefDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<YazarRefDto> $mapper =
      YazarRefDtoMapper.ensureInitialized();
  @override
  $R call({Object? yazarCategory = $none}) => $apply(
    FieldCopyWithData({
      if (yazarCategory != $none) #yazarCategory: yazarCategory,
    }),
  );
  @override
  YazarRefDto $make(CopyWithData data) => YazarRefDto(
    yazarCategory: data.get(#yazarCategory, or: $value.yazarCategory),
  );

  @override
  YazarRefDtoCopyWith<$R2, YazarRefDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _YazarRefDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ItemRefDtoMapper extends ClassMapperBase<ItemRefDto> {
  ItemRefDtoMapper._();

  static ItemRefDtoMapper? _instance;
  static ItemRefDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ItemRefDtoMapper._());
      YazarRefDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ItemRefDto';

  static YazarRefDto? _$yazar(ItemRefDto v) => v.yazar;
  static const Field<ItemRefDto, YazarRefDto> _f$yazar = Field(
    'yazar',
    _$yazar,
    opt: true,
    hook: ObjectHook(),
  );

  @override
  final MappableFields<ItemRefDto> fields = const {#yazar: _f$yazar};
  @override
  final bool ignoreNull = true;

  static ItemRefDto _instantiate(DecodingData data) {
    return ItemRefDto(yazar: data.dec(_f$yazar));
  }

  @override
  final Function instantiate = _instantiate;

  static ItemRefDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ItemRefDto>(map);
  }

  static ItemRefDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<ItemRefDto>(json);
  }
}

mixin ItemRefDtoMappable {
  String toJsonString() {
    return ItemRefDtoMapper.ensureInitialized().encodeJson<ItemRefDto>(
      this as ItemRefDto,
    );
  }

  Map<String, dynamic> toJson() {
    return ItemRefDtoMapper.ensureInitialized().encodeMap<ItemRefDto>(
      this as ItemRefDto,
    );
  }

  ItemRefDtoCopyWith<ItemRefDto, ItemRefDto, ItemRefDto> get copyWith =>
      _ItemRefDtoCopyWithImpl<ItemRefDto, ItemRefDto>(
        this as ItemRefDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ItemRefDtoMapper.ensureInitialized().stringifyValue(
      this as ItemRefDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ItemRefDtoMapper.ensureInitialized().equalsValue(
      this as ItemRefDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ItemRefDtoMapper.ensureInitialized().hashValue(this as ItemRefDto);
  }
}

extension ItemRefDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ItemRefDto, $Out> {
  ItemRefDtoCopyWith<$R, ItemRefDto, $Out> get $asItemRefDto =>
      $base.as((v, t, t2) => _ItemRefDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ItemRefDtoCopyWith<$R, $In extends ItemRefDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  YazarRefDtoCopyWith<$R, YazarRefDto, YazarRefDto>? get yazar;
  $R call({YazarRefDto? yazar});
  ItemRefDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ItemRefDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ItemRefDto, $Out>
    implements ItemRefDtoCopyWith<$R, ItemRefDto, $Out> {
  _ItemRefDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ItemRefDto> $mapper =
      ItemRefDtoMapper.ensureInitialized();
  @override
  YazarRefDtoCopyWith<$R, YazarRefDto, YazarRefDto>? get yazar =>
      $value.yazar?.copyWith.$chain((v) => call(yazar: v));
  @override
  $R call({Object? yazar = $none}) =>
      $apply(FieldCopyWithData({if (yazar != $none) #yazar: yazar}));
  @override
  ItemRefDto $make(CopyWithData data) =>
      ItemRefDto(yazar: data.get(#yazar, or: $value.yazar));

  @override
  ItemRefDtoCopyWith<$R2, ItemRefDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ItemRefDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ItemDataDtoMapper extends ClassMapperBase<ItemDataDto> {
  ItemDataDtoMapper._();

  static ItemDataDtoMapper? _instance;
  static ItemDataDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ItemDataDtoMapper._());
      PromptDtoMapper.ensureInitialized();
      ItemRefDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ItemDataDto';

  static String? _$id(ItemDataDto v) => v.id;
  static const Field<ItemDataDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$status(ItemDataDto v) => v.status;
  static const Field<ItemDataDto, int> _f$status = Field(
    'status',
    _$status,
    opt: true,
    hook: ItemStatusHook(),
  );
  static List<int>? _$statusArray(ItemDataDto v) => v.statusArray;
  static const Field<ItemDataDto, List<int>> _f$statusArray = Field(
    'statusArray',
    _$statusArray,
    opt: true,
    hook: ItemStatusListHook(),
  );
  static int? _$itsIndependent(ItemDataDto v) => v.itsIndependent;
  static const Field<ItemDataDto, int> _f$itsIndependent = Field(
    'itsIndependent',
    _$itsIndependent,
    opt: true,
    hook: IntOrNullHook(),
  );
  static String? _$subject(ItemDataDto v) => v.subject;
  static const Field<ItemDataDto, String> _f$subject = Field(
    'subject',
    _$subject,
    opt: true,
    hook: IdRefHook(),
  );
  static List<PromptDto>? _$prompts(ItemDataDto v) => v.prompts;
  static const Field<ItemDataDto, List<PromptDto>> _f$prompts = Field(
    'prompts',
    _$prompts,
    opt: true,
    hook: MapListHook(),
  );
  static ItemRefDto? _$item(ItemDataDto v) => v.item;
  static const Field<ItemDataDto, ItemRefDto> _f$item = Field(
    'item',
    _$item,
    opt: true,
    hook: ObjectHook(),
  );

  @override
  final MappableFields<ItemDataDto> fields = const {
    #id: _f$id,
    #status: _f$status,
    #statusArray: _f$statusArray,
    #itsIndependent: _f$itsIndependent,
    #subject: _f$subject,
    #prompts: _f$prompts,
    #item: _f$item,
  };
  @override
  final bool ignoreNull = true;

  static ItemDataDto _instantiate(DecodingData data) {
    return ItemDataDto(
      id: data.dec(_f$id),
      status: data.dec(_f$status),
      statusArray: data.dec(_f$statusArray),
      itsIndependent: data.dec(_f$itsIndependent),
      subject: data.dec(_f$subject),
      prompts: data.dec(_f$prompts),
      item: data.dec(_f$item),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ItemDataDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ItemDataDto>(map);
  }

  static ItemDataDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<ItemDataDto>(json);
  }
}

mixin ItemDataDtoMappable {
  String toJsonString() {
    return ItemDataDtoMapper.ensureInitialized().encodeJson<ItemDataDto>(
      this as ItemDataDto,
    );
  }

  Map<String, dynamic> toJson() {
    return ItemDataDtoMapper.ensureInitialized().encodeMap<ItemDataDto>(
      this as ItemDataDto,
    );
  }

  ItemDataDtoCopyWith<ItemDataDto, ItemDataDto, ItemDataDto> get copyWith =>
      _ItemDataDtoCopyWithImpl<ItemDataDto, ItemDataDto>(
        this as ItemDataDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ItemDataDtoMapper.ensureInitialized().stringifyValue(
      this as ItemDataDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ItemDataDtoMapper.ensureInitialized().equalsValue(
      this as ItemDataDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ItemDataDtoMapper.ensureInitialized().hashValue(this as ItemDataDto);
  }
}

extension ItemDataDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ItemDataDto, $Out> {
  ItemDataDtoCopyWith<$R, ItemDataDto, $Out> get $asItemDataDto =>
      $base.as((v, t, t2) => _ItemDataDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ItemDataDtoCopyWith<$R, $In extends ItemDataDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>>? get statusArray;
  ListCopyWith<$R, PromptDto, PromptDtoCopyWith<$R, PromptDto, PromptDto>>?
  get prompts;
  ItemRefDtoCopyWith<$R, ItemRefDto, ItemRefDto>? get item;
  $R call({
    String? id,
    int? status,
    List<int>? statusArray,
    int? itsIndependent,
    String? subject,
    List<PromptDto>? prompts,
    ItemRefDto? item,
  });
  ItemDataDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ItemDataDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ItemDataDto, $Out>
    implements ItemDataDtoCopyWith<$R, ItemDataDto, $Out> {
  _ItemDataDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ItemDataDto> $mapper =
      ItemDataDtoMapper.ensureInitialized();
  @override
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>>? get statusArray =>
      $value.statusArray != null
      ? ListCopyWith(
          $value.statusArray!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(statusArray: v),
        )
      : null;
  @override
  ListCopyWith<$R, PromptDto, PromptDtoCopyWith<$R, PromptDto, PromptDto>>?
  get prompts => $value.prompts != null
      ? ListCopyWith(
          $value.prompts!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(prompts: v),
        )
      : null;
  @override
  ItemRefDtoCopyWith<$R, ItemRefDto, ItemRefDto>? get item =>
      $value.item?.copyWith.$chain((v) => call(item: v));
  @override
  $R call({
    Object? id = $none,
    Object? status = $none,
    Object? statusArray = $none,
    Object? itsIndependent = $none,
    Object? subject = $none,
    Object? prompts = $none,
    Object? item = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (status != $none) #status: status,
      if (statusArray != $none) #statusArray: statusArray,
      if (itsIndependent != $none) #itsIndependent: itsIndependent,
      if (subject != $none) #subject: subject,
      if (prompts != $none) #prompts: prompts,
      if (item != $none) #item: item,
    }),
  );
  @override
  ItemDataDto $make(CopyWithData data) => ItemDataDto(
    id: data.get(#id, or: $value.id),
    status: data.get(#status, or: $value.status),
    statusArray: data.get(#statusArray, or: $value.statusArray),
    itsIndependent: data.get(#itsIndependent, or: $value.itsIndependent),
    subject: data.get(#subject, or: $value.subject),
    prompts: data.get(#prompts, or: $value.prompts),
    item: data.get(#item, or: $value.item),
  );

  @override
  ItemDataDtoCopyWith<$R2, ItemDataDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ItemDataDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class WorkDtoMapper extends ClassMapperBase<WorkDto> {
  WorkDtoMapper._();

  static WorkDtoMapper? _instance;
  static WorkDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WorkDtoMapper._());
      ItemDataDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'WorkDto';

  static String? _$eser(WorkDto v) => v.eser;
  static const Field<WorkDto, String> _f$eser = Field(
    'eser',
    _$eser,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$type(WorkDto v) => v.type;
  static const Field<WorkDto, String> _f$type = Field(
    'type',
    _$type,
    opt: true,
    hook: TextOrNullHook(),
  );
  static ItemDataDto? _$itemData(WorkDto v) => v.itemData;
  static const Field<WorkDto, ItemDataDto> _f$itemData = Field(
    'itemData',
    _$itemData,
    opt: true,
    hook: ObjectHook(),
  );

  @override
  final MappableFields<WorkDto> fields = const {
    #eser: _f$eser,
    #type: _f$type,
    #itemData: _f$itemData,
  };
  @override
  final bool ignoreNull = true;

  static WorkDto _instantiate(DecodingData data) {
    return WorkDto(
      eser: data.dec(_f$eser),
      type: data.dec(_f$type),
      itemData: data.dec(_f$itemData),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static WorkDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<WorkDto>(map);
  }

  static WorkDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<WorkDto>(json);
  }
}

mixin WorkDtoMappable {
  String toJsonString() {
    return WorkDtoMapper.ensureInitialized().encodeJson<WorkDto>(
      this as WorkDto,
    );
  }

  Map<String, dynamic> toJson() {
    return WorkDtoMapper.ensureInitialized().encodeMap<WorkDto>(
      this as WorkDto,
    );
  }

  WorkDtoCopyWith<WorkDto, WorkDto, WorkDto> get copyWith =>
      _WorkDtoCopyWithImpl<WorkDto, WorkDto>(
        this as WorkDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return WorkDtoMapper.ensureInitialized().stringifyValue(this as WorkDto);
  }

  @override
  bool operator ==(Object other) {
    return WorkDtoMapper.ensureInitialized().equalsValue(
      this as WorkDto,
      other,
    );
  }

  @override
  int get hashCode {
    return WorkDtoMapper.ensureInitialized().hashValue(this as WorkDto);
  }
}

extension WorkDtoValueCopy<$R, $Out> on ObjectCopyWith<$R, WorkDto, $Out> {
  WorkDtoCopyWith<$R, WorkDto, $Out> get $asWorkDto =>
      $base.as((v, t, t2) => _WorkDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class WorkDtoCopyWith<$R, $In extends WorkDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ItemDataDtoCopyWith<$R, ItemDataDto, ItemDataDto>? get itemData;
  $R call({String? eser, String? type, ItemDataDto? itemData});
  WorkDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _WorkDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, WorkDto, $Out>
    implements WorkDtoCopyWith<$R, WorkDto, $Out> {
  _WorkDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<WorkDto> $mapper =
      WorkDtoMapper.ensureInitialized();
  @override
  ItemDataDtoCopyWith<$R, ItemDataDto, ItemDataDto>? get itemData =>
      $value.itemData?.copyWith.$chain((v) => call(itemData: v));
  @override
  $R call({
    Object? eser = $none,
    Object? type = $none,
    Object? itemData = $none,
  }) => $apply(
    FieldCopyWithData({
      if (eser != $none) #eser: eser,
      if (type != $none) #type: type,
      if (itemData != $none) #itemData: itemData,
    }),
  );
  @override
  WorkDto $make(CopyWithData data) => WorkDto(
    eser: data.get(#eser, or: $value.eser),
    type: data.get(#type, or: $value.type),
    itemData: data.get(#itemData, or: $value.itemData),
  );

  @override
  WorkDtoCopyWith<$R2, WorkDto, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _WorkDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class LessonItemDtoMapper extends ClassMapperBase<LessonItemDto> {
  LessonItemDtoMapper._();

  static LessonItemDtoMapper? _instance;
  static LessonItemDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LessonItemDtoMapper._());
      ItemDataDtoMapper.ensureInitialized();
      WorkDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'LessonItemDto';

  static String? _$id(LessonItemDto v) => v.id;
  static const Field<LessonItemDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$name(LessonItemDto v) => v.name;
  static const Field<LessonItemDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<String>? _$desc(LessonItemDto v) => v.desc;
  static const Field<LessonItemDto, List<String>> _f$desc = Field(
    'desc',
    _$desc,
    opt: true,
    hook: StringListHook(),
  );
  static String? _$image(LessonItemDto v) => v.image;
  static const Field<LessonItemDto, String> _f$image = Field(
    'image',
    _$image,
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$itsYazar(LessonItemDto v) => v.itsYazar;
  static const Field<LessonItemDto, int> _f$itsYazar = Field(
    'itsYazar',
    _$itsYazar,
    opt: true,
    hook: IntOrNullHook(),
  );
  static String? _$yazarCategory(LessonItemDto v) => v.yazarCategory;
  static const Field<LessonItemDto, String> _f$yazarCategory = Field(
    'yazarCategory',
    _$yazarCategory,
    opt: true,
    hook: IdRefHook(),
  );
  static bool? _$isFavorite(LessonItemDto v) => v.isFavorite;
  static const Field<LessonItemDto, bool> _f$isFavorite = Field(
    'isFavorite',
    _$isFavorite,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static ItemDataDto? _$itemData(LessonItemDto v) => v.itemData;
  static const Field<LessonItemDto, ItemDataDto> _f$itemData = Field(
    'itemData',
    _$itemData,
    opt: true,
    hook: ObjectHook(),
  );
  static List<ItemDataDto>? _$itemDatas(LessonItemDto v) => v.itemDatas;
  static const Field<LessonItemDto, List<ItemDataDto>> _f$itemDatas = Field(
    'itemDatas',
    _$itemDatas,
    opt: true,
    hook: MapListHook(),
  );
  static List<WorkDto>? _$works(LessonItemDto v) => v.works;
  static const Field<LessonItemDto, List<WorkDto>> _f$works = Field(
    'works',
    _$works,
    opt: true,
    hook: MapListHook(),
  );

  @override
  final MappableFields<LessonItemDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #desc: _f$desc,
    #image: _f$image,
    #itsYazar: _f$itsYazar,
    #yazarCategory: _f$yazarCategory,
    #isFavorite: _f$isFavorite,
    #itemData: _f$itemData,
    #itemDatas: _f$itemDatas,
    #works: _f$works,
  };
  @override
  final bool ignoreNull = true;

  static LessonItemDto _instantiate(DecodingData data) {
    return LessonItemDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      desc: data.dec(_f$desc),
      image: data.dec(_f$image),
      itsYazar: data.dec(_f$itsYazar),
      yazarCategory: data.dec(_f$yazarCategory),
      isFavorite: data.dec(_f$isFavorite),
      itemData: data.dec(_f$itemData),
      itemDatas: data.dec(_f$itemDatas),
      works: data.dec(_f$works),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LessonItemDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LessonItemDto>(map);
  }

  static LessonItemDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<LessonItemDto>(json);
  }
}

mixin LessonItemDtoMappable {
  String toJsonString() {
    return LessonItemDtoMapper.ensureInitialized().encodeJson<LessonItemDto>(
      this as LessonItemDto,
    );
  }

  Map<String, dynamic> toJson() {
    return LessonItemDtoMapper.ensureInitialized().encodeMap<LessonItemDto>(
      this as LessonItemDto,
    );
  }

  LessonItemDtoCopyWith<LessonItemDto, LessonItemDto, LessonItemDto>
  get copyWith => _LessonItemDtoCopyWithImpl<LessonItemDto, LessonItemDto>(
    this as LessonItemDto,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return LessonItemDtoMapper.ensureInitialized().stringifyValue(
      this as LessonItemDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return LessonItemDtoMapper.ensureInitialized().equalsValue(
      this as LessonItemDto,
      other,
    );
  }

  @override
  int get hashCode {
    return LessonItemDtoMapper.ensureInitialized().hashValue(
      this as LessonItemDto,
    );
  }
}

extension LessonItemDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LessonItemDto, $Out> {
  LessonItemDtoCopyWith<$R, LessonItemDto, $Out> get $asLessonItemDto =>
      $base.as((v, t, t2) => _LessonItemDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LessonItemDtoCopyWith<$R, $In extends LessonItemDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get desc;
  ItemDataDtoCopyWith<$R, ItemDataDto, ItemDataDto>? get itemData;
  ListCopyWith<
    $R,
    ItemDataDto,
    ItemDataDtoCopyWith<$R, ItemDataDto, ItemDataDto>
  >?
  get itemDatas;
  ListCopyWith<$R, WorkDto, WorkDtoCopyWith<$R, WorkDto, WorkDto>>? get works;
  $R call({
    String? id,
    String? name,
    List<String>? desc,
    String? image,
    int? itsYazar,
    String? yazarCategory,
    bool? isFavorite,
    ItemDataDto? itemData,
    List<ItemDataDto>? itemDatas,
    List<WorkDto>? works,
  });
  LessonItemDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _LessonItemDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LessonItemDto, $Out>
    implements LessonItemDtoCopyWith<$R, LessonItemDto, $Out> {
  _LessonItemDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LessonItemDto> $mapper =
      LessonItemDtoMapper.ensureInitialized();
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
  ItemDataDtoCopyWith<$R, ItemDataDto, ItemDataDto>? get itemData =>
      $value.itemData?.copyWith.$chain((v) => call(itemData: v));
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
  ListCopyWith<$R, WorkDto, WorkDtoCopyWith<$R, WorkDto, WorkDto>>? get works =>
      $value.works != null
      ? ListCopyWith(
          $value.works!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(works: v),
        )
      : null;
  @override
  $R call({
    Object? id = $none,
    Object? name = $none,
    Object? desc = $none,
    Object? image = $none,
    Object? itsYazar = $none,
    Object? yazarCategory = $none,
    Object? isFavorite = $none,
    Object? itemData = $none,
    Object? itemDatas = $none,
    Object? works = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (name != $none) #name: name,
      if (desc != $none) #desc: desc,
      if (image != $none) #image: image,
      if (itsYazar != $none) #itsYazar: itsYazar,
      if (yazarCategory != $none) #yazarCategory: yazarCategory,
      if (isFavorite != $none) #isFavorite: isFavorite,
      if (itemData != $none) #itemData: itemData,
      if (itemDatas != $none) #itemDatas: itemDatas,
      if (works != $none) #works: works,
    }),
  );
  @override
  LessonItemDto $make(CopyWithData data) => LessonItemDto(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    desc: data.get(#desc, or: $value.desc),
    image: data.get(#image, or: $value.image),
    itsYazar: data.get(#itsYazar, or: $value.itsYazar),
    yazarCategory: data.get(#yazarCategory, or: $value.yazarCategory),
    isFavorite: data.get(#isFavorite, or: $value.isFavorite),
    itemData: data.get(#itemData, or: $value.itemData),
    itemDatas: data.get(#itemDatas, or: $value.itemDatas),
    works: data.get(#works, or: $value.works),
  );

  @override
  LessonItemDtoCopyWith<$R2, LessonItemDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LessonItemDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ItemListDtoMapper extends ClassMapperBase<ItemListDto> {
  ItemListDtoMapper._();

  static ItemListDtoMapper? _instance;
  static ItemListDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ItemListDtoMapper._());
      LessonItemDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ItemListDto';

  static List<LessonItemDto>? _$items(ItemListDto v) => v.items;
  static const Field<ItemListDto, List<LessonItemDto>> _f$items = Field(
    'items',
    _$items,
    opt: true,
    hook: MapListHook(),
  );

  @override
  final MappableFields<ItemListDto> fields = const {#items: _f$items};
  @override
  final bool ignoreNull = true;

  static ItemListDto _instantiate(DecodingData data) {
    return ItemListDto(items: data.dec(_f$items));
  }

  @override
  final Function instantiate = _instantiate;

  static ItemListDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ItemListDto>(map);
  }

  static ItemListDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<ItemListDto>(json);
  }
}

mixin ItemListDtoMappable {
  String toJsonString() {
    return ItemListDtoMapper.ensureInitialized().encodeJson<ItemListDto>(
      this as ItemListDto,
    );
  }

  Map<String, dynamic> toJson() {
    return ItemListDtoMapper.ensureInitialized().encodeMap<ItemListDto>(
      this as ItemListDto,
    );
  }

  ItemListDtoCopyWith<ItemListDto, ItemListDto, ItemListDto> get copyWith =>
      _ItemListDtoCopyWithImpl<ItemListDto, ItemListDto>(
        this as ItemListDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ItemListDtoMapper.ensureInitialized().stringifyValue(
      this as ItemListDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ItemListDtoMapper.ensureInitialized().equalsValue(
      this as ItemListDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ItemListDtoMapper.ensureInitialized().hashValue(this as ItemListDto);
  }
}

extension ItemListDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ItemListDto, $Out> {
  ItemListDtoCopyWith<$R, ItemListDto, $Out> get $asItemListDto =>
      $base.as((v, t, t2) => _ItemListDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ItemListDtoCopyWith<$R, $In extends ItemListDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    LessonItemDto,
    LessonItemDtoCopyWith<$R, LessonItemDto, LessonItemDto>
  >?
  get items;
  $R call({List<LessonItemDto>? items});
  ItemListDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ItemListDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ItemListDto, $Out>
    implements ItemListDtoCopyWith<$R, ItemListDto, $Out> {
  _ItemListDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ItemListDto> $mapper =
      ItemListDtoMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    LessonItemDto,
    LessonItemDtoCopyWith<$R, LessonItemDto, LessonItemDto>
  >?
  get items => $value.items != null
      ? ListCopyWith(
          $value.items!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(items: v),
        )
      : null;
  @override
  $R call({Object? items = $none}) =>
      $apply(FieldCopyWithData({if (items != $none) #items: items}));
  @override
  ItemListDto $make(CopyWithData data) =>
      ItemListDto(items: data.get(#items, or: $value.items));

  @override
  ItemListDtoCopyWith<$R2, ItemListDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ItemListDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

