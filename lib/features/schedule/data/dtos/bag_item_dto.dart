import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';

part 'generated/bag_item_dto.mapper.dart';

/// The topic part of a bag item (`data`): the subject to study.
@MappableClass(ignoreNull: true)
class BagTopicDto with BagTopicDtoMappable {
  const BagTopicDto({this.id, this.name, this.subject});

  factory BagTopicDto.fromJson(Map<String, dynamic> json) =>
      BagTopicDtoMapper.fromJson(json);

  /// The bag item's own id (`_id`); a task's `item`.
  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  /// The topic's name: "Tarih Biliminin Tanımı".
  @MappableField(hook: TextOrNullHook())
  final String? name;

  /// The subject ("konu") id (wire field `konu`); a task's `subject`.
  @MappableField(key: 'konu', hook: TextOrNullHook())
  final String? subject;
}

/// The lesson part of a bag item (`lesson`).
@MappableClass(ignoreNull: true)
class BagLessonDto with BagLessonDtoMappable {
  const BagLessonDto({this.id, this.name, this.lessonColor, this.mapImage});

  factory BagLessonDto.fromJson(Map<String, dynamic> json) =>
      BagLessonDtoMapper.fromJson(json);

  /// The general lesson's id.
  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  /// "TYT Tarih".
  @MappableField(hook: TextOrNullHook())
  final String? name;

  @MappableField(hook: TextOrNullHook())
  final String? lessonColor;

  @MappableField(hook: TextOrNullHook())
  final String? mapImage;
}

/// One "Çantam" entry of `getMyWeeklies` (`bagItems`): a topic waiting to be
/// planned (the design's "Çantam = eksik konular", spec §6.1 6.8).
///
/// The legacy app kept the whole list as JSON text in `SharedPreferences`
/// (`bagItemsStr`) only to hand it from the list screen to the editor. The new
/// code keeps it in `ScheduleSnapshot.bagItems` instead.
@MappableClass(ignoreNull: true)
class BagItemDto with BagItemDtoMappable {
  const BagItemDto({this.student, this.mainSubject, this.data, this.lesson});

  factory BagItemDto.fromJson(Map<String, dynamic> json) =>
      BagItemDtoMapper.fromJson(json);

  /// The student whose bag it is.
  @MappableField(hook: CoachRefHook())
  final String? student;

  /// The main subject's id.
  @MappableField(hook: TextOrNullHook())
  final String? mainSubject;

  @MappableField(hook: ObjectOrNullHook())
  final BagTopicDto? data;

  @MappableField(hook: ObjectOrNullHook())
  final BagLessonDto? lesson;
}
