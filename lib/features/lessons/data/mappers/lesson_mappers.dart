import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/data/dtos/lesson_answers.dart';
import 'package:smap/features/lessons/data/dtos/lesson_item_dto.dart';
import 'package:smap/features/lessons/domain/general_lesson.dart';
import 'package:smap/features/lessons/domain/lesson_content.dart';
import 'package:smap/features/lessons/domain/main_subjects.dart';

extension GeneralLessonDtoMapping on GeneralLessonDto {
  /// The lesson as the strip shows it; `null` without an id or a name. Fields
  /// and lesson ids the server left out come from the catalog entry with the
  /// same id (the legacy screens always read the catalog).
  GeneralLesson? toDomain() {
    final generalId = id;
    final lessonName = name;
    if (generalId == null || lessonName == null) return null;
    final spec = LessonCatalog.byId(generalId);
    return GeneralLesson(
      id: generalId,
      name: lessonName,
      order: order ?? spec?.order ?? 0,
      imageFile: image,
      ids: LessonIds(
        single: lessonId ?? spec?.ids.single,
        tyt: lessonTyt ?? spec?.ids.tyt,
        ayt: lessonAyt ?? spec?.ids.ayt,
        sos2: lessonSos2 ?? spec?.ids.sos2,
      ),
      hasTrackChoice: tytAyt != null
          ? tytAyt == 1
          : spec?.hasTrackChoice ?? false,
      isWebOnly: mindMap != null ? mindMap == 1 : spec?.isWebOnly ?? false,
      isLiterature: edebiyat != null
          ? edebiyat == 1
          : spec?.isLiterature ?? false,
    );
  }
}

extension LessonsMissingResponseMapping on LessonsMissingResponse {
  LessonsMissing toDomain() => LessonsMissing({
    for (final lesson in lessons ?? const <LessonMissingDto>[])
      if (lesson.lessonId != null)
        lesson.lessonId!: LessonMissing(
          tyt: lesson.tyt,
          ayt: lesson.ayt,
          sos2: lesson.sos2,
        ),
  });
}

extension MainSubjectDtoMapping on MainSubjectDto {
  /// `null` without an id or a name.
  MainSubject? toDomain() {
    final subjectId = id;
    final subjectName = name;
    if (subjectId == null || subjectName == null) return null;
    return MainSubject(
      id: subjectId,
      name: subjectName,
      order: order,
      imageFile: image,
      imageColorHex: imageColor,
      barColorHex: barColor,
      missingCount: itemDataCount,
    );
  }
}

List<MainSubject> mainSubjectsOf(List<MainSubjectDto>? dtos) => [
  for (final dto in dtos ?? const <MainSubjectDto>[])
    if (dto.toDomain() case final MainSubject subject) subject,
];

extension MainSubjectsResponseMapping on MainSubjectsResponse {
  MainSubjects toDomain() => MainSubjects(
    subjects: mainSubjectsOf(subjects),
    filters: [
      for (final filter in filters ?? const <FilterObjDto>[])
        if (filter.name != null && filter.value != null)
          LessonTypeFilter(name: filter.name!, value: filter.value!),
    ],
    missing: MissingByType({
      for (final type in missingByType ?? const <TypeMissingDto>[])
        if (type.type != null)
          type.type!: {
            for (final subject in type.subjects ?? const <SubjectCountDto>[])
              if (subject.id != null) subject.id!: subject.count ?? 0,
          },
    }),
  );
}

extension ItemDataDtoMapping on ItemDataDto {
  ItemProgress toDomain() => ItemProgress(
    id: id,
    status: status,
    statusArray: statusArray ?? const [],
    isIndependent: itsIndependent == 1,
    subjectId: subject,
  );
}

extension LessonItemDtoMapping on LessonItemDto {
  /// The entry as the content tree shows it; `null` without a name.
  /// [progressRecords] are the records grouped under an era.
  LessonItem? toDomain({List<ItemDataDto> progressRecords = const []}) {
    final itemName = name;
    if (itemName == null) return null;
    final data = itemData;
    return LessonItem(
      id: id,
      name: itemName,
      descriptions: desc ?? const [],
      imageFile: image,
      progress: data?.toDomain(),
      prompts: [
        for (final prompt in data?.prompts ?? const <PromptDto>[])
          ItemPrompt(
            title: prompt.title,
            content: prompt.content ?? prompt.text,
            isFavorite: prompt.isFavorite ?? false,
          ),
      ],
      isAuthor: itsYazar == 1,
      authorCategoryId: yazarCategory,
      works: [
        for (final work in works ?? const <WorkDto>[])
          if (work.eser != null)
            AuthorWork(
              title: work.eser!,
              typeId: work.type,
              progress: work.itemData?.toDomain(),
            ),
      ],
      progressRecords: [
        for (final record in [
          ...(itemDatas ?? const <ItemDataDto>[]),
          ...progressRecords,
        ])
          record.toDomain(),
      ],
      isFavorite: isFavorite ?? false,
    );
  }
}

List<LessonItem> lessonItemsOf(
  List<LessonItemDto>? dtos, {
  List<ItemDataDto> eraRecords = const [],
}) {
  // An era's records are grouped by the era their author belongs to; an
  // item takes the group of its own id.
  final byEra = <String, List<ItemDataDto>>{};
  for (final record in eraRecords) {
    final era = record.item?.yazar?.yazarCategory;
    if (era != null) byEra.putIfAbsent(era, () => []).add(record);
  }
  return [
    for (final dto in dtos ?? const <LessonItemDto>[])
      if (dto.toDomain(progressRecords: byEra[dto.id] ?? const [])
          case final LessonItem item)
        item,
  ];
}

extension SubSubjectDtoMapping on SubSubjectDto {
  /// `null` without an id or a name.
  SubSubject? toDomain({List<LessonItemDto>? items}) {
    final subId = id;
    final subName = name;
    if (subId == null || subName == null) return null;
    return SubSubject(
      id: subId,
      name: subName,
      missingCount: itemDataCount,
      items: lessonItemsOf(items, eraRecords: itemDatas ?? const []),
    );
  }
}
