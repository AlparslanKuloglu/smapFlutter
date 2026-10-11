import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';
import 'package:smap/features/exams/data/dtos/lenient_list_hooks.dart';
import 'package:smap/features/lessons/data/dtos/lesson_hooks.dart';

part 'generated/lesson_item_dto.mapper.dart';

/// One card of an item (`itemData.prompts[]`).
@MappableClass(ignoreNull: true)
class PromptDto with PromptDtoMappable {
  const PromptDto({this.title, this.content, this.text, this.isFavorite});

  factory PromptDto.fromJson(Map<String, dynamic> json) =>
      PromptDtoMapper.fromJson(json);

  @MappableField(hook: TextOrNullHook())
  final String? title;

  @MappableField(hook: TextOrNullHook())
  final String? content;

  /// The card text when the server names it `text` instead of `content` (the
  /// legacy screen reads `content ?? text`).
  @MappableField(hook: TextOrNullHook())
  final String? text;

  @MappableField(hook: BoolOrNullHook())
  final bool? isFavorite;
}

/// `item.yazar`: the author record an era's progress record points at.
@MappableClass(ignoreNull: true)
class YazarRefDto with YazarRefDtoMappable {
  const YazarRefDto({this.yazarCategory});

  factory YazarRefDto.fromJson(Map<String, dynamic> json) =>
      YazarRefDtoMapper.fromJson(json);

  /// Id of the era (`yazarCategory`).
  @MappableField(hook: IdRefHook())
  final String? yazarCategory;
}

/// `itemData.item`: the item a progress record belongs to; only the author
/// part is read.
@MappableClass(ignoreNull: true)
class ItemRefDto with ItemRefDtoMappable {
  const ItemRefDto({this.yazar});

  factory ItemRefDto.fromJson(Map<String, dynamic> json) =>
      ItemRefDtoMapper.fromJson(json);

  @MappableField(hook: ObjectHook())
  final YazarRefDto? yazar;
}

/// A progress record (`itemData`): the student's status of an item.
@MappableClass(ignoreNull: true)
class ItemDataDto with ItemDataDtoMappable {
  const ItemDataDto({
    this.id,
    this.status,
    this.statusArray,
    this.itsIndependent,
    this.subject,
    this.prompts,
    this.item,
  });

  factory ItemDataDto.fromJson(Map<String, dynamic> json) =>
      ItemDataDtoMapper.fromJson(json);

  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  @MappableField(hook: ItemStatusHook())
  final int? status;

  @MappableField(hook: ItemStatusListHook())
  final List<int>? statusArray;

  @MappableField(hook: IntOrNullHook())
  final int? itsIndependent;

  /// The main subject's id.
  @MappableField(hook: IdRefHook())
  final String? subject;

  @MappableField(hook: MapListHook())
  final List<PromptDto>? prompts;

  /// The item the record belongs to (present on an era's records).
  @MappableField(hook: ObjectHook())
  final ItemRefDto? item;
}

/// One work of an author (`works[]`).
@MappableClass(ignoreNull: true)
class WorkDto with WorkDtoMappable {
  const WorkDto({this.eser, this.type, this.itemData});

  factory WorkDto.fromJson(Map<String, dynamic> json) =>
      WorkDtoMapper.fromJson(json);

  /// The work's title.
  @MappableField(hook: TextOrNullHook())
  final String? eser;

  /// Id of the work type.
  @MappableField(hook: TextOrNullHook())
  final String? type;

  @MappableField(hook: ObjectHook())
  final ItemDataDto? itemData;
}

/// An item of `getItems` or an author of `getSubjectAuthors`.
///
/// Field names are the ones the legacy Yazar & Eserler and topic screens read:
/// `_id`, `name`, `desc`, `image`, `itsYazar`, `yazarCategory`, `isFavorite`,
/// `itemData`, `itemDatas`, `works`.
@MappableClass(ignoreNull: true)
class LessonItemDto with LessonItemDtoMappable {
  const LessonItemDto({
    this.id,
    this.name,
    this.desc,
    this.image,
    this.itsYazar,
    this.yazarCategory,
    this.isFavorite,
    this.itemData,
    this.itemDatas,
    this.works,
  });

  factory LessonItemDto.fromJson(Map<String, dynamic> json) =>
      LessonItemDtoMapper.fromJson(json);

  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  @MappableField(hook: TextOrNullHook())
  final String? name;

  /// Paragraphs (a text or a list of texts).
  @MappableField(hook: StringListHook())
  final List<String>? desc;

  @MappableField(hook: TextOrNullHook())
  final String? image;

  /// `1` for an author.
  @MappableField(hook: IntOrNullHook())
  final int? itsYazar;

  @MappableField(hook: IdRefHook())
  final String? yazarCategory;

  @MappableField(hook: BoolOrNullHook())
  final bool? isFavorite;

  @MappableField(hook: ObjectHook())
  final ItemDataDto? itemData;

  /// Progress records the server already grouped under the item.
  @MappableField(hook: MapListHook())
  final List<ItemDataDto>? itemDatas;

  @MappableField(hook: MapListHook())
  final List<WorkDto>? works;
}

/// The items answered for one sub-subject (one entry of `itemsArray`).
@MappableClass(ignoreNull: true)
class ItemListDto with ItemListDtoMappable {
  const ItemListDto({this.items});

  factory ItemListDto.fromJson(Map<String, dynamic> json) =>
      ItemListDtoMapper.fromJson(json);

  @MappableField(hook: MapListHook())
  final List<LessonItemDto>? items;
}
