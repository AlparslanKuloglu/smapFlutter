import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';
import 'package:smap/features/exams/data/api_support.dart';
import 'package:smap/features/exams/data/dtos/exam_answers.dart';
import 'package:smap/features/exams/data/dtos/exam_hooks.dart';
import 'package:smap/features/exams/data/dtos/lenient_list_hooks.dart';

part 'generated/card_answers.mapper.dart';

/// The three counters of one lesson in `getInfoCardsInfo`.
@MappableClass(ignoreNull: true)
class CardTallyDto with CardTallyDtoMappable {
  const CardTallyDto({
    this.lessonId,
    this.missCount,
    this.trueCount,
    this.favoriteCount,
  });

  factory CardTallyDto.fromJson(Map<String, dynamic> json) =>
      CardTallyDtoMapper.fromJson(json);

  @MappableField(hook: TextOrNullHook())
  final String? lessonId;

  @MappableField(hook: IntOrNullHook())
  final int? missCount;

  @MappableField(hook: IntOrNullHook())
  final int? trueCount;

  @MappableField(hook: IntOrNullHook())
  final int? favoriteCount;
}

/// The `infoData` object of `getInfoCardsInfo`: counters per lesson id under
/// `infoObj`.
@MappableClass(ignoreNull: true)
class InfoDataDto with InfoDataDtoMappable {
  const InfoDataDto({this.lessons});

  factory InfoDataDto.fromJson(Map<String, dynamic> json) =>
      InfoDataDtoMapper.fromJson(json);

  @MappableField(key: 'infoObj', hook: LessonTallyMapHook())
  final List<CardTallyDto>? lessons;
}

/// Answer of `GET /student/getInfoCardsInfo`.
@MappableClass(ignoreNull: true)
class InfoCardsInfoResponse
    with InfoCardsInfoResponseMappable
    implements ApiEnvelope {
  const InfoCardsInfoResponse({this.success, this.message, this.infoData});

  factory InfoCardsInfoResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const InfoCardsInfoResponse();
    return InfoCardsInfoResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  @MappableField(hook: ObjectHook())
  final InfoDataDto? infoData;
}

/// The `item` of a card entry: `{_id, name, desc, mainSubject}`.
@MappableClass(ignoreNull: true)
class CardItemDto with CardItemDtoMappable {
  const CardItemDto({this.id, this.name, this.desc, this.mainSubject});

  factory CardItemDto.fromJson(Map<String, dynamic> json) =>
      CardItemDtoMapper.fromJson(json);

  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  @MappableField(hook: TextOrNullHook())
  final String? name;

  @MappableField(hook: StringListHook())
  final List<String>? desc;

  /// Populated `{name}`; an id text reads as no object (the legacy screen
  /// logged "mainSubject populate edilmemiş" for that).
  @MappableField(hook: ObjectHook())
  final NamedRefDto? mainSubject;
}

/// One entry of a deck: the item and whether the student starred it
/// (`favorite`: `1` or `0`).
@MappableClass(ignoreNull: true)
class CardEntryDto with CardEntryDtoMappable {
  const CardEntryDto({this.favorite, this.item});

  factory CardEntryDto.fromJson(Map<String, dynamic> json) =>
      CardEntryDtoMapper.fromJson(json);

  @MappableField(hook: BoolOrNullHook())
  final bool? favorite;

  @MappableField(hook: ObjectHook())
  final CardItemDto? item;
}

/// The `data` object of `getLessonInfoCards`: three decks.
@MappableClass(ignoreNull: true)
class CardDecksDto with CardDecksDtoMappable {
  const CardDecksDto({this.successCards, this.favoriteCards, this.failedCards});

  factory CardDecksDto.fromJson(Map<String, dynamic> json) =>
      CardDecksDtoMapper.fromJson(json);

  @MappableField(hook: MapListHook())
  final List<CardEntryDto>? successCards;

  @MappableField(hook: MapListHook())
  final List<CardEntryDto>? favoriteCards;

  @MappableField(hook: MapListHook())
  final List<CardEntryDto>? failedCards;
}

/// Answer of `GET /student/getLessonInfoCards?lesson=`.
@MappableClass(ignoreNull: true)
class LessonInfoCardsResponse
    with LessonInfoCardsResponseMappable
    implements ApiEnvelope {
  const LessonInfoCardsResponse({this.success, this.message, this.data});

  factory LessonInfoCardsResponse.fromBody(Object? data) {
    final map = bodyMap(data);
    if (map == null) return const LessonInfoCardsResponse();
    return LessonInfoCardsResponseMapper.fromJson(map);
  }

  @override
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @override
  @MappableField(hook: TextOrNullHook())
  final String? message;

  @MappableField(hook: ObjectHook())
  final CardDecksDto? data;
}
