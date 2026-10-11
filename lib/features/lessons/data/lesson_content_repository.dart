import 'package:dartz/dartz.dart';

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/exams/data/api_support.dart';
import 'package:smap/features/lessons/data/dtos/lesson_answers.dart';
import 'package:smap/features/lessons/data/dtos/lesson_item_dto.dart';
import 'package:smap/features/lessons/data/mappers/lesson_mappers.dart';
import 'package:smap/features/lessons/data/requests/lesson_requests.dart';
import 'package:smap/features/lessons/domain/general_lesson.dart';
import 'package:smap/features/lessons/domain/lesson_content.dart';
import 'package:smap/features/lessons/domain/main_subjects.dart';

/// Reads the lesson content: the nine lessons and their missing counts, a
/// lesson's main subjects, sub-subjects and items, the Edebiyat Yazar & Eserler
/// tree, and marks an item learned. Replaces the lesson half of the legacy
/// `AnalysisRepository` and the lesson calls of `HomeRepository` (spec §6.3
/// #21, #24, #33).
///
/// Every method answers `Either<AppException, T>` and never throws. Every
/// read takes an optional `studentId` for a coach looking at a student; it is
/// sent as the `studentId` query parameter, as the legacy repository did for
/// the analysis calls (the home calls never sent it, so whether
/// `getLessonsTotalMissing` honours it is an open question).
class LessonContentRepository {
  LessonContentRepository(this._network);

  final NetworkService _network;

  /// `getGeneralLessons`: the lessons of the "Derslerin" strip, in the order
  /// the server lists them.
  ///
  /// The legacy reader did not look for a `success` flag, so an answer with
  /// the list is enough; an explicit `success: false` or an answer without
  /// the list is a failure. Entries without an id or a name are left out.
  Future<AppResult<List<GeneralLesson>>> getGeneralLessons() async {
    const path = '/ajax/getGeneralLessons';
    final result = await _network.send(LessonRequests.generalLessons());
    return result.flatMap((response) {
      if (response.success == false) {
        return Left(
          AppException(
            code: AppErrorCode.validation,
            message: 'The server answered success: false',
            path: path,
            serverMessage: response.message,
          ),
        );
      }
      final lessons = response.lessons;
      if (lessons == null) {
        return const Left(
          AppException(
            code: AppErrorCode.server,
            message: 'The answer had no generalLessons list',
            path: path,
          ),
        );
      }
      return Right([
        for (final dto in lessons)
          if (dto.toDomain() case final GeneralLesson lesson) lesson,
      ]);
    });
  }

  /// `getLessonsTotalMissing`: missing items per lesson and track. A lesson
  /// the answer does not list has no entry in the result.
  Future<AppResult<LessonsMissing>> getLessonsMissing({
    String? studentId,
  }) async {
    final result = await _network.send(
      LessonRequests.lessonsTotalMissing(studentId: studentId),
    );
    return result
        .requireSuccess('/student/getLessonsTotalMissing')
        .map((response) => response.toDomain());
  }

  /// `mainSubjects`: the main subjects of the backend lesson [lessonId] (use
  /// `LessonIds.forTrack`), the lesson's type filter and the missing counts.
  Future<AppResult<MainSubjects>> getMainSubjects({
    required String lessonId,
    String? studentId,
  }) async {
    final result = await _network.send(
      LessonRequests.mainSubjects(lessonId: lessonId, studentId: studentId),
    );
    return result
        .requireSuccess('/student/mainSubjects')
        .map((response) => response.toDomain());
  }

  /// `yazarEserMainSubjects`: the eras of the Yazar & Eserler tab, with the
  /// missing count of each (`MainSubject.missingCount`).
  Future<AppResult<List<MainSubject>>> getAuthorMainSubjects({
    String? studentId,
  }) async {
    final result = await _network.send(
      LessonRequests.yazarEserMainSubjects(studentId: studentId),
    );
    return result
        .requireSuccess('/student/yazarEserMainSubjects')
        .map((response) => mainSubjectsOf(response.subjects));
  }

  /// `getSubSubjects`: the sub-subjects of a main subject, without items.
  /// For Yazar & Eserler the era's progress records are not kept here; use
  /// [getSubjectContent].
  Future<AppResult<List<SubSubject>>> getSubSubjects({
    required String mainSubjectId,
    String? studentId,
  }) async {
    final result = await _network.send(
      LessonRequests.subSubjects(
        mainSubjectId: mainSubjectId,
        studentId: studentId,
      ),
    );
    return result
        .requireSuccess('/student/getSubSubjects')
        .map(
          (response) => [
            for (final dto in response.subSubjects ?? const <SubSubjectDto>[])
              if (dto.toDomain() case final SubSubject sub) sub,
          ],
        );
  }

  /// `getSubSubjects` then `getItems`: a main subject's sub-subjects with
  /// their items, as the topic screens read them (the legacy
  /// `getSubSubjectsAndItems`).
  ///
  /// [type] is the lesson's filter value (`LessonTypeFilter.value`, 9 for
  /// "Tümü"); [authorMode] asks for the Yazar & Eserler tree (eras with
  /// their progress records). A main subject without sub-subjects is an
  /// empty list (the second call is skipped). If either call fails the
  /// failure is returned.
  Future<AppResult<List<SubSubject>>> getSubjectContent({
    required String mainSubjectId,
    int? type,
    bool authorMode = false,
    String? studentId,
  }) async {
    final subResult = await _network.send(
      LessonRequests.subSubjects(
        mainSubjectId: mainSubjectId,
        studentId: studentId,
      ),
    );
    final subs = subResult.requireSuccess('/student/getSubSubjects');
    final readable = subs.map(
      (response) => [
        for (final dto in response.subSubjects ?? const <SubSubjectDto>[])
          if (dto.id != null && dto.name != null) dto,
      ],
    );
    return readable.fold<Future<AppResult<List<SubSubject>>>>(
      (failure) async => Left(failure),
      (dtos) async {
        if (dtos.isEmpty) return const Right(<SubSubject>[]);
        final itemsResult = await _network.send(
          LessonRequests.items(
            subjectIds: [for (final dto in dtos) dto.id!],
            type: type,
            authorMode: authorMode,
            studentId: studentId,
          ),
        );
        return itemsResult.requireSuccess('/student/getItems').map((response) {
          final lists = response.itemLists ?? const <ItemListDto>[];
          return [
            for (final (index, dto) in dtos.indexed)
              if (dto.toDomain(
                    items: index < lists.length ? lists[index].items : null,
                  )
                  case final SubSubject sub)
                sub,
          ];
        });
      },
    );
  }

  /// `getSubjectAuthors`: the authors of the era [itemId] (a
  /// `LessonItem.id`), each with its works and progress.
  Future<AppResult<List<LessonItem>>> getSubjectAuthors({
    required String itemId,
    String? studentId,
  }) async {
    final result = await _network.send(
      LessonRequests.subjectAuthors(itemId: itemId, studentId: studentId),
    );
    return result
        .requireSuccess('/student/getSubjectAuthors')
        .map((response) => lessonItemsOf(response.authors));
  }

  /// `learnedItem`: marks the item with progress id [itemId]
  /// (`ItemProgress.id`) learned. Fire-and-confirm: the answer carries
  /// nothing but the flag. There is no way to undo it on the server (spec
  /// §6.3 #24).
  Future<AppResult<Unit>> markItemLearned({required String itemId}) async {
    final result = await _network.send(
      LessonRequests.learnedItem(itemId: itemId),
    );
    return result.requireSuccess('/student/learnedItem').map((_) => unit);
  }
}
