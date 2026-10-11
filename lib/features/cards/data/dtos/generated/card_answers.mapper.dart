// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../card_answers.dart';

class CardTallyDtoMapper extends ClassMapperBase<CardTallyDto> {
  CardTallyDtoMapper._();

  static CardTallyDtoMapper? _instance;
  static CardTallyDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CardTallyDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CardTallyDto';

  static String? _$lessonId(CardTallyDto v) => v.lessonId;
  static const Field<CardTallyDto, String> _f$lessonId = Field(
    'lessonId',
    _$lessonId,
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$missCount(CardTallyDto v) => v.missCount;
  static const Field<CardTallyDto, int> _f$missCount = Field(
    'missCount',
    _$missCount,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$trueCount(CardTallyDto v) => v.trueCount;
  static const Field<CardTallyDto, int> _f$trueCount = Field(
    'trueCount',
    _$trueCount,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$favoriteCount(CardTallyDto v) => v.favoriteCount;
  static const Field<CardTallyDto, int> _f$favoriteCount = Field(
    'favoriteCount',
    _$favoriteCount,
    opt: true,
    hook: IntOrNullHook(),
  );

  @override
  final MappableFields<CardTallyDto> fields = const {
    #lessonId: _f$lessonId,
    #missCount: _f$missCount,
    #trueCount: _f$trueCount,
    #favoriteCount: _f$favoriteCount,
  };
  @override
  final bool ignoreNull = true;

  static CardTallyDto _instantiate(DecodingData data) {
    return CardTallyDto(
      lessonId: data.dec(_f$lessonId),
      missCount: data.dec(_f$missCount),
      trueCount: data.dec(_f$trueCount),
      favoriteCount: data.dec(_f$favoriteCount),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CardTallyDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CardTallyDto>(map);
  }

  static CardTallyDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<CardTallyDto>(json);
  }
}

mixin CardTallyDtoMappable {
  String toJsonString() {
    return CardTallyDtoMapper.ensureInitialized().encodeJson<CardTallyDto>(
      this as CardTallyDto,
    );
  }

  Map<String, dynamic> toJson() {
    return CardTallyDtoMapper.ensureInitialized().encodeMap<CardTallyDto>(
      this as CardTallyDto,
    );
  }

  CardTallyDtoCopyWith<CardTallyDto, CardTallyDto, CardTallyDto> get copyWith =>
      _CardTallyDtoCopyWithImpl<CardTallyDto, CardTallyDto>(
        this as CardTallyDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CardTallyDtoMapper.ensureInitialized().stringifyValue(
      this as CardTallyDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return CardTallyDtoMapper.ensureInitialized().equalsValue(
      this as CardTallyDto,
      other,
    );
  }

  @override
  int get hashCode {
    return CardTallyDtoMapper.ensureInitialized().hashValue(
      this as CardTallyDto,
    );
  }
}

extension CardTallyDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CardTallyDto, $Out> {
  CardTallyDtoCopyWith<$R, CardTallyDto, $Out> get $asCardTallyDto =>
      $base.as((v, t, t2) => _CardTallyDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CardTallyDtoCopyWith<$R, $In extends CardTallyDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? lessonId,
    int? missCount,
    int? trueCount,
    int? favoriteCount,
  });
  CardTallyDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CardTallyDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CardTallyDto, $Out>
    implements CardTallyDtoCopyWith<$R, CardTallyDto, $Out> {
  _CardTallyDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CardTallyDto> $mapper =
      CardTallyDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? lessonId = $none,
    Object? missCount = $none,
    Object? trueCount = $none,
    Object? favoriteCount = $none,
  }) => $apply(
    FieldCopyWithData({
      if (lessonId != $none) #lessonId: lessonId,
      if (missCount != $none) #missCount: missCount,
      if (trueCount != $none) #trueCount: trueCount,
      if (favoriteCount != $none) #favoriteCount: favoriteCount,
    }),
  );
  @override
  CardTallyDto $make(CopyWithData data) => CardTallyDto(
    lessonId: data.get(#lessonId, or: $value.lessonId),
    missCount: data.get(#missCount, or: $value.missCount),
    trueCount: data.get(#trueCount, or: $value.trueCount),
    favoriteCount: data.get(#favoriteCount, or: $value.favoriteCount),
  );

  @override
  CardTallyDtoCopyWith<$R2, CardTallyDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CardTallyDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class InfoDataDtoMapper extends ClassMapperBase<InfoDataDto> {
  InfoDataDtoMapper._();

  static InfoDataDtoMapper? _instance;
  static InfoDataDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InfoDataDtoMapper._());
      CardTallyDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'InfoDataDto';

  static List<CardTallyDto>? _$lessons(InfoDataDto v) => v.lessons;
  static const Field<InfoDataDto, List<CardTallyDto>> _f$lessons = Field(
    'lessons',
    _$lessons,
    key: r'infoObj',
    opt: true,
    hook: LessonTallyMapHook(),
  );

  @override
  final MappableFields<InfoDataDto> fields = const {#lessons: _f$lessons};
  @override
  final bool ignoreNull = true;

  static InfoDataDto _instantiate(DecodingData data) {
    return InfoDataDto(lessons: data.dec(_f$lessons));
  }

  @override
  final Function instantiate = _instantiate;

  static InfoDataDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<InfoDataDto>(map);
  }

  static InfoDataDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<InfoDataDto>(json);
  }
}

mixin InfoDataDtoMappable {
  String toJsonString() {
    return InfoDataDtoMapper.ensureInitialized().encodeJson<InfoDataDto>(
      this as InfoDataDto,
    );
  }

  Map<String, dynamic> toJson() {
    return InfoDataDtoMapper.ensureInitialized().encodeMap<InfoDataDto>(
      this as InfoDataDto,
    );
  }

  InfoDataDtoCopyWith<InfoDataDto, InfoDataDto, InfoDataDto> get copyWith =>
      _InfoDataDtoCopyWithImpl<InfoDataDto, InfoDataDto>(
        this as InfoDataDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return InfoDataDtoMapper.ensureInitialized().stringifyValue(
      this as InfoDataDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return InfoDataDtoMapper.ensureInitialized().equalsValue(
      this as InfoDataDto,
      other,
    );
  }

  @override
  int get hashCode {
    return InfoDataDtoMapper.ensureInitialized().hashValue(this as InfoDataDto);
  }
}

extension InfoDataDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, InfoDataDto, $Out> {
  InfoDataDtoCopyWith<$R, InfoDataDto, $Out> get $asInfoDataDto =>
      $base.as((v, t, t2) => _InfoDataDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class InfoDataDtoCopyWith<$R, $In extends InfoDataDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    CardTallyDto,
    CardTallyDtoCopyWith<$R, CardTallyDto, CardTallyDto>
  >?
  get lessons;
  $R call({List<CardTallyDto>? lessons});
  InfoDataDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _InfoDataDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, InfoDataDto, $Out>
    implements InfoDataDtoCopyWith<$R, InfoDataDto, $Out> {
  _InfoDataDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<InfoDataDto> $mapper =
      InfoDataDtoMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    CardTallyDto,
    CardTallyDtoCopyWith<$R, CardTallyDto, CardTallyDto>
  >?
  get lessons => $value.lessons != null
      ? ListCopyWith(
          $value.lessons!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(lessons: v),
        )
      : null;
  @override
  $R call({Object? lessons = $none}) =>
      $apply(FieldCopyWithData({if (lessons != $none) #lessons: lessons}));
  @override
  InfoDataDto $make(CopyWithData data) =>
      InfoDataDto(lessons: data.get(#lessons, or: $value.lessons));

  @override
  InfoDataDtoCopyWith<$R2, InfoDataDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _InfoDataDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class InfoCardsInfoResponseMapper
    extends ClassMapperBase<InfoCardsInfoResponse> {
  InfoCardsInfoResponseMapper._();

  static InfoCardsInfoResponseMapper? _instance;
  static InfoCardsInfoResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InfoCardsInfoResponseMapper._());
      InfoDataDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'InfoCardsInfoResponse';

  static bool? _$success(InfoCardsInfoResponse v) => v.success;
  static const Field<InfoCardsInfoResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(InfoCardsInfoResponse v) => v.message;
  static const Field<InfoCardsInfoResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static InfoDataDto? _$infoData(InfoCardsInfoResponse v) => v.infoData;
  static const Field<InfoCardsInfoResponse, InfoDataDto> _f$infoData = Field(
    'infoData',
    _$infoData,
    opt: true,
    hook: ObjectHook(),
  );

  @override
  final MappableFields<InfoCardsInfoResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #infoData: _f$infoData,
  };
  @override
  final bool ignoreNull = true;

  static InfoCardsInfoResponse _instantiate(DecodingData data) {
    return InfoCardsInfoResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      infoData: data.dec(_f$infoData),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static InfoCardsInfoResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<InfoCardsInfoResponse>(map);
  }

  static InfoCardsInfoResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<InfoCardsInfoResponse>(json);
  }
}

mixin InfoCardsInfoResponseMappable {
  String toJsonString() {
    return InfoCardsInfoResponseMapper.ensureInitialized()
        .encodeJson<InfoCardsInfoResponse>(this as InfoCardsInfoResponse);
  }

  Map<String, dynamic> toJson() {
    return InfoCardsInfoResponseMapper.ensureInitialized()
        .encodeMap<InfoCardsInfoResponse>(this as InfoCardsInfoResponse);
  }

  InfoCardsInfoResponseCopyWith<
    InfoCardsInfoResponse,
    InfoCardsInfoResponse,
    InfoCardsInfoResponse
  >
  get copyWith =>
      _InfoCardsInfoResponseCopyWithImpl<
        InfoCardsInfoResponse,
        InfoCardsInfoResponse
      >(this as InfoCardsInfoResponse, $identity, $identity);
  @override
  String toString() {
    return InfoCardsInfoResponseMapper.ensureInitialized().stringifyValue(
      this as InfoCardsInfoResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return InfoCardsInfoResponseMapper.ensureInitialized().equalsValue(
      this as InfoCardsInfoResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return InfoCardsInfoResponseMapper.ensureInitialized().hashValue(
      this as InfoCardsInfoResponse,
    );
  }
}

extension InfoCardsInfoResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, InfoCardsInfoResponse, $Out> {
  InfoCardsInfoResponseCopyWith<$R, InfoCardsInfoResponse, $Out>
  get $asInfoCardsInfoResponse => $base.as(
    (v, t, t2) => _InfoCardsInfoResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class InfoCardsInfoResponseCopyWith<
  $R,
  $In extends InfoCardsInfoResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  InfoDataDtoCopyWith<$R, InfoDataDto, InfoDataDto>? get infoData;
  $R call({bool? success, String? message, InfoDataDto? infoData});
  InfoCardsInfoResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _InfoCardsInfoResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, InfoCardsInfoResponse, $Out>
    implements InfoCardsInfoResponseCopyWith<$R, InfoCardsInfoResponse, $Out> {
  _InfoCardsInfoResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<InfoCardsInfoResponse> $mapper =
      InfoCardsInfoResponseMapper.ensureInitialized();
  @override
  InfoDataDtoCopyWith<$R, InfoDataDto, InfoDataDto>? get infoData =>
      $value.infoData?.copyWith.$chain((v) => call(infoData: v));
  @override
  $R call({
    Object? success = $none,
    Object? message = $none,
    Object? infoData = $none,
  }) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
      if (infoData != $none) #infoData: infoData,
    }),
  );
  @override
  InfoCardsInfoResponse $make(CopyWithData data) => InfoCardsInfoResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    infoData: data.get(#infoData, or: $value.infoData),
  );

  @override
  InfoCardsInfoResponseCopyWith<$R2, InfoCardsInfoResponse, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _InfoCardsInfoResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CardItemDtoMapper extends ClassMapperBase<CardItemDto> {
  CardItemDtoMapper._();

  static CardItemDtoMapper? _instance;
  static CardItemDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CardItemDtoMapper._());
      NamedRefDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CardItemDto';

  static String? _$id(CardItemDto v) => v.id;
  static const Field<CardItemDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$name(CardItemDto v) => v.name;
  static const Field<CardItemDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static List<String>? _$desc(CardItemDto v) => v.desc;
  static const Field<CardItemDto, List<String>> _f$desc = Field(
    'desc',
    _$desc,
    opt: true,
    hook: StringListHook(),
  );
  static NamedRefDto? _$mainSubject(CardItemDto v) => v.mainSubject;
  static const Field<CardItemDto, NamedRefDto> _f$mainSubject = Field(
    'mainSubject',
    _$mainSubject,
    opt: true,
    hook: ObjectHook(),
  );

  @override
  final MappableFields<CardItemDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #desc: _f$desc,
    #mainSubject: _f$mainSubject,
  };
  @override
  final bool ignoreNull = true;

  static CardItemDto _instantiate(DecodingData data) {
    return CardItemDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      desc: data.dec(_f$desc),
      mainSubject: data.dec(_f$mainSubject),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CardItemDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CardItemDto>(map);
  }

  static CardItemDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<CardItemDto>(json);
  }
}

mixin CardItemDtoMappable {
  String toJsonString() {
    return CardItemDtoMapper.ensureInitialized().encodeJson<CardItemDto>(
      this as CardItemDto,
    );
  }

  Map<String, dynamic> toJson() {
    return CardItemDtoMapper.ensureInitialized().encodeMap<CardItemDto>(
      this as CardItemDto,
    );
  }

  CardItemDtoCopyWith<CardItemDto, CardItemDto, CardItemDto> get copyWith =>
      _CardItemDtoCopyWithImpl<CardItemDto, CardItemDto>(
        this as CardItemDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CardItemDtoMapper.ensureInitialized().stringifyValue(
      this as CardItemDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return CardItemDtoMapper.ensureInitialized().equalsValue(
      this as CardItemDto,
      other,
    );
  }

  @override
  int get hashCode {
    return CardItemDtoMapper.ensureInitialized().hashValue(this as CardItemDto);
  }
}

extension CardItemDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CardItemDto, $Out> {
  CardItemDtoCopyWith<$R, CardItemDto, $Out> get $asCardItemDto =>
      $base.as((v, t, t2) => _CardItemDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CardItemDtoCopyWith<$R, $In extends CardItemDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>? get desc;
  NamedRefDtoCopyWith<$R, NamedRefDto, NamedRefDto>? get mainSubject;
  $R call({
    String? id,
    String? name,
    List<String>? desc,
    NamedRefDto? mainSubject,
  });
  CardItemDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CardItemDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CardItemDto, $Out>
    implements CardItemDtoCopyWith<$R, CardItemDto, $Out> {
  _CardItemDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CardItemDto> $mapper =
      CardItemDtoMapper.ensureInitialized();
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
    Object? id = $none,
    Object? name = $none,
    Object? desc = $none,
    Object? mainSubject = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (name != $none) #name: name,
      if (desc != $none) #desc: desc,
      if (mainSubject != $none) #mainSubject: mainSubject,
    }),
  );
  @override
  CardItemDto $make(CopyWithData data) => CardItemDto(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    desc: data.get(#desc, or: $value.desc),
    mainSubject: data.get(#mainSubject, or: $value.mainSubject),
  );

  @override
  CardItemDtoCopyWith<$R2, CardItemDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CardItemDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CardEntryDtoMapper extends ClassMapperBase<CardEntryDto> {
  CardEntryDtoMapper._();

  static CardEntryDtoMapper? _instance;
  static CardEntryDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CardEntryDtoMapper._());
      CardItemDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CardEntryDto';

  static bool? _$favorite(CardEntryDto v) => v.favorite;
  static const Field<CardEntryDto, bool> _f$favorite = Field(
    'favorite',
    _$favorite,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static CardItemDto? _$item(CardEntryDto v) => v.item;
  static const Field<CardEntryDto, CardItemDto> _f$item = Field(
    'item',
    _$item,
    opt: true,
    hook: ObjectHook(),
  );

  @override
  final MappableFields<CardEntryDto> fields = const {
    #favorite: _f$favorite,
    #item: _f$item,
  };
  @override
  final bool ignoreNull = true;

  static CardEntryDto _instantiate(DecodingData data) {
    return CardEntryDto(
      favorite: data.dec(_f$favorite),
      item: data.dec(_f$item),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CardEntryDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CardEntryDto>(map);
  }

  static CardEntryDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<CardEntryDto>(json);
  }
}

mixin CardEntryDtoMappable {
  String toJsonString() {
    return CardEntryDtoMapper.ensureInitialized().encodeJson<CardEntryDto>(
      this as CardEntryDto,
    );
  }

  Map<String, dynamic> toJson() {
    return CardEntryDtoMapper.ensureInitialized().encodeMap<CardEntryDto>(
      this as CardEntryDto,
    );
  }

  CardEntryDtoCopyWith<CardEntryDto, CardEntryDto, CardEntryDto> get copyWith =>
      _CardEntryDtoCopyWithImpl<CardEntryDto, CardEntryDto>(
        this as CardEntryDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CardEntryDtoMapper.ensureInitialized().stringifyValue(
      this as CardEntryDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return CardEntryDtoMapper.ensureInitialized().equalsValue(
      this as CardEntryDto,
      other,
    );
  }

  @override
  int get hashCode {
    return CardEntryDtoMapper.ensureInitialized().hashValue(
      this as CardEntryDto,
    );
  }
}

extension CardEntryDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CardEntryDto, $Out> {
  CardEntryDtoCopyWith<$R, CardEntryDto, $Out> get $asCardEntryDto =>
      $base.as((v, t, t2) => _CardEntryDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CardEntryDtoCopyWith<$R, $In extends CardEntryDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  CardItemDtoCopyWith<$R, CardItemDto, CardItemDto>? get item;
  $R call({bool? favorite, CardItemDto? item});
  CardEntryDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CardEntryDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CardEntryDto, $Out>
    implements CardEntryDtoCopyWith<$R, CardEntryDto, $Out> {
  _CardEntryDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CardEntryDto> $mapper =
      CardEntryDtoMapper.ensureInitialized();
  @override
  CardItemDtoCopyWith<$R, CardItemDto, CardItemDto>? get item =>
      $value.item?.copyWith.$chain((v) => call(item: v));
  @override
  $R call({Object? favorite = $none, Object? item = $none}) => $apply(
    FieldCopyWithData({
      if (favorite != $none) #favorite: favorite,
      if (item != $none) #item: item,
    }),
  );
  @override
  CardEntryDto $make(CopyWithData data) => CardEntryDto(
    favorite: data.get(#favorite, or: $value.favorite),
    item: data.get(#item, or: $value.item),
  );

  @override
  CardEntryDtoCopyWith<$R2, CardEntryDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CardEntryDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CardDecksDtoMapper extends ClassMapperBase<CardDecksDto> {
  CardDecksDtoMapper._();

  static CardDecksDtoMapper? _instance;
  static CardDecksDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CardDecksDtoMapper._());
      CardEntryDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CardDecksDto';

  static List<CardEntryDto>? _$successCards(CardDecksDto v) => v.successCards;
  static const Field<CardDecksDto, List<CardEntryDto>> _f$successCards = Field(
    'successCards',
    _$successCards,
    opt: true,
    hook: MapListHook(),
  );
  static List<CardEntryDto>? _$favoriteCards(CardDecksDto v) => v.favoriteCards;
  static const Field<CardDecksDto, List<CardEntryDto>> _f$favoriteCards = Field(
    'favoriteCards',
    _$favoriteCards,
    opt: true,
    hook: MapListHook(),
  );
  static List<CardEntryDto>? _$failedCards(CardDecksDto v) => v.failedCards;
  static const Field<CardDecksDto, List<CardEntryDto>> _f$failedCards = Field(
    'failedCards',
    _$failedCards,
    opt: true,
    hook: MapListHook(),
  );

  @override
  final MappableFields<CardDecksDto> fields = const {
    #successCards: _f$successCards,
    #favoriteCards: _f$favoriteCards,
    #failedCards: _f$failedCards,
  };
  @override
  final bool ignoreNull = true;

  static CardDecksDto _instantiate(DecodingData data) {
    return CardDecksDto(
      successCards: data.dec(_f$successCards),
      favoriteCards: data.dec(_f$favoriteCards),
      failedCards: data.dec(_f$failedCards),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CardDecksDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CardDecksDto>(map);
  }

  static CardDecksDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<CardDecksDto>(json);
  }
}

mixin CardDecksDtoMappable {
  String toJsonString() {
    return CardDecksDtoMapper.ensureInitialized().encodeJson<CardDecksDto>(
      this as CardDecksDto,
    );
  }

  Map<String, dynamic> toJson() {
    return CardDecksDtoMapper.ensureInitialized().encodeMap<CardDecksDto>(
      this as CardDecksDto,
    );
  }

  CardDecksDtoCopyWith<CardDecksDto, CardDecksDto, CardDecksDto> get copyWith =>
      _CardDecksDtoCopyWithImpl<CardDecksDto, CardDecksDto>(
        this as CardDecksDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CardDecksDtoMapper.ensureInitialized().stringifyValue(
      this as CardDecksDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return CardDecksDtoMapper.ensureInitialized().equalsValue(
      this as CardDecksDto,
      other,
    );
  }

  @override
  int get hashCode {
    return CardDecksDtoMapper.ensureInitialized().hashValue(
      this as CardDecksDto,
    );
  }
}

extension CardDecksDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CardDecksDto, $Out> {
  CardDecksDtoCopyWith<$R, CardDecksDto, $Out> get $asCardDecksDto =>
      $base.as((v, t, t2) => _CardDecksDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CardDecksDtoCopyWith<$R, $In extends CardDecksDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    CardEntryDto,
    CardEntryDtoCopyWith<$R, CardEntryDto, CardEntryDto>
  >?
  get successCards;
  ListCopyWith<
    $R,
    CardEntryDto,
    CardEntryDtoCopyWith<$R, CardEntryDto, CardEntryDto>
  >?
  get favoriteCards;
  ListCopyWith<
    $R,
    CardEntryDto,
    CardEntryDtoCopyWith<$R, CardEntryDto, CardEntryDto>
  >?
  get failedCards;
  $R call({
    List<CardEntryDto>? successCards,
    List<CardEntryDto>? favoriteCards,
    List<CardEntryDto>? failedCards,
  });
  CardDecksDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CardDecksDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CardDecksDto, $Out>
    implements CardDecksDtoCopyWith<$R, CardDecksDto, $Out> {
  _CardDecksDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CardDecksDto> $mapper =
      CardDecksDtoMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    CardEntryDto,
    CardEntryDtoCopyWith<$R, CardEntryDto, CardEntryDto>
  >?
  get successCards => $value.successCards != null
      ? ListCopyWith(
          $value.successCards!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(successCards: v),
        )
      : null;
  @override
  ListCopyWith<
    $R,
    CardEntryDto,
    CardEntryDtoCopyWith<$R, CardEntryDto, CardEntryDto>
  >?
  get favoriteCards => $value.favoriteCards != null
      ? ListCopyWith(
          $value.favoriteCards!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(favoriteCards: v),
        )
      : null;
  @override
  ListCopyWith<
    $R,
    CardEntryDto,
    CardEntryDtoCopyWith<$R, CardEntryDto, CardEntryDto>
  >?
  get failedCards => $value.failedCards != null
      ? ListCopyWith(
          $value.failedCards!,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(failedCards: v),
        )
      : null;
  @override
  $R call({
    Object? successCards = $none,
    Object? favoriteCards = $none,
    Object? failedCards = $none,
  }) => $apply(
    FieldCopyWithData({
      if (successCards != $none) #successCards: successCards,
      if (favoriteCards != $none) #favoriteCards: favoriteCards,
      if (failedCards != $none) #failedCards: failedCards,
    }),
  );
  @override
  CardDecksDto $make(CopyWithData data) => CardDecksDto(
    successCards: data.get(#successCards, or: $value.successCards),
    favoriteCards: data.get(#favoriteCards, or: $value.favoriteCards),
    failedCards: data.get(#failedCards, or: $value.failedCards),
  );

  @override
  CardDecksDtoCopyWith<$R2, CardDecksDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CardDecksDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class LessonInfoCardsResponseMapper
    extends ClassMapperBase<LessonInfoCardsResponse> {
  LessonInfoCardsResponseMapper._();

  static LessonInfoCardsResponseMapper? _instance;
  static LessonInfoCardsResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = LessonInfoCardsResponseMapper._(),
      );
      CardDecksDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'LessonInfoCardsResponse';

  static bool? _$success(LessonInfoCardsResponse v) => v.success;
  static const Field<LessonInfoCardsResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(LessonInfoCardsResponse v) => v.message;
  static const Field<LessonInfoCardsResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static CardDecksDto? _$data(LessonInfoCardsResponse v) => v.data;
  static const Field<LessonInfoCardsResponse, CardDecksDto> _f$data = Field(
    'data',
    _$data,
    opt: true,
    hook: ObjectHook(),
  );

  @override
  final MappableFields<LessonInfoCardsResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #data: _f$data,
  };
  @override
  final bool ignoreNull = true;

  static LessonInfoCardsResponse _instantiate(DecodingData data) {
    return LessonInfoCardsResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      data: data.dec(_f$data),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LessonInfoCardsResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LessonInfoCardsResponse>(map);
  }

  static LessonInfoCardsResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<LessonInfoCardsResponse>(json);
  }
}

mixin LessonInfoCardsResponseMappable {
  String toJsonString() {
    return LessonInfoCardsResponseMapper.ensureInitialized()
        .encodeJson<LessonInfoCardsResponse>(this as LessonInfoCardsResponse);
  }

  Map<String, dynamic> toJson() {
    return LessonInfoCardsResponseMapper.ensureInitialized()
        .encodeMap<LessonInfoCardsResponse>(this as LessonInfoCardsResponse);
  }

  LessonInfoCardsResponseCopyWith<
    LessonInfoCardsResponse,
    LessonInfoCardsResponse,
    LessonInfoCardsResponse
  >
  get copyWith =>
      _LessonInfoCardsResponseCopyWithImpl<
        LessonInfoCardsResponse,
        LessonInfoCardsResponse
      >(this as LessonInfoCardsResponse, $identity, $identity);
  @override
  String toString() {
    return LessonInfoCardsResponseMapper.ensureInitialized().stringifyValue(
      this as LessonInfoCardsResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return LessonInfoCardsResponseMapper.ensureInitialized().equalsValue(
      this as LessonInfoCardsResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return LessonInfoCardsResponseMapper.ensureInitialized().hashValue(
      this as LessonInfoCardsResponse,
    );
  }
}

extension LessonInfoCardsResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LessonInfoCardsResponse, $Out> {
  LessonInfoCardsResponseCopyWith<$R, LessonInfoCardsResponse, $Out>
  get $asLessonInfoCardsResponse => $base.as(
    (v, t, t2) => _LessonInfoCardsResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class LessonInfoCardsResponseCopyWith<
  $R,
  $In extends LessonInfoCardsResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  CardDecksDtoCopyWith<$R, CardDecksDto, CardDecksDto>? get data;
  $R call({bool? success, String? message, CardDecksDto? data});
  LessonInfoCardsResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _LessonInfoCardsResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LessonInfoCardsResponse, $Out>
    implements
        LessonInfoCardsResponseCopyWith<$R, LessonInfoCardsResponse, $Out> {
  _LessonInfoCardsResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LessonInfoCardsResponse> $mapper =
      LessonInfoCardsResponseMapper.ensureInitialized();
  @override
  CardDecksDtoCopyWith<$R, CardDecksDto, CardDecksDto>? get data =>
      $value.data?.copyWith.$chain((v) => call(data: v));
  @override
  $R call({
    Object? success = $none,
    Object? message = $none,
    Object? data = $none,
  }) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
      if (data != $none) #data: data,
    }),
  );
  @override
  LessonInfoCardsResponse $make(CopyWithData data) => LessonInfoCardsResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    data: data.get(#data, or: $value.data),
  );

  @override
  LessonInfoCardsResponseCopyWith<$R2, LessonInfoCardsResponse, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _LessonInfoCardsResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

