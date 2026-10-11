import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/features/lessons/domain/general_lesson.dart';
import 'package:smap/features/lessons/domain/lesson_content.dart';

/// Where to look for a topic: a backend lesson and the `getItems` filter value
/// of the category the topic is read under.
@immutable
class TopicTarget {
  const TopicTarget({
    required this.backendLessonId,
    required this.typeValue,
    required this.cat,
  });

  final String backendLessonId;

  /// 1 TYT, 2 or 3 AYT, 4 SOS-2, 9 "Tümü" (`GeneralLesson.filterValueFor`).
  final int typeValue;
  final LessonCat cat;

  @override
  bool operator ==(Object other) =>
      other is TopicTarget &&
      other.backendLessonId == backendLessonId &&
      other.typeValue == typeValue &&
      other.cat == cat;

  @override
  int get hashCode => Object.hash(backendLessonId, typeValue, cat);
}

/// What Konu Detayı shows once it has loaded (pano 7.3).
@immutable
class TopicContent {
  const TopicContent({
    required this.topicName,
    required this.number,
    required this.cat,
    required this.subSubjects,
  });

  /// "Sözcükte Anlam".
  final String topicName;

  /// The topic's number in its lesson's list, 1 to n ("1. konu").
  final int number;

  /// The category the topic was read under.
  final LessonCat cat;

  /// The sub-topics with their items.
  final List<SubSubject> subSubjects;
}

/// Finds a topic and reads its content (spec §4.F 7.3). The old screen was
/// opened from a list that already knew the lesson's track and the topic's
/// name; a link (Anasayfa "Bugün", Deneme Detay "Konular") carries only the
/// ids, so the loader works them out.
///
/// - A lesson **with tracks** is read under the track the link names, else the
///   device's last exam type; when the topic is not among that track's topics
///   the other tracks are tried, so a link without a category still lands.
/// - A lesson **without tracks** is read under the category the link names,
///   "Tümü" without one.
///
/// A failing request is the failure: the next track is tried only when the
/// answer arrived and did not list the topic. A topic no track lists is
/// `notFound`.
class TopicLoader {
  const TopicLoader(this._repository);

  final LessonContentRepository _repository;

  /// The places to look for a topic of [lesson], in order.
  static List<TopicTarget> targets(
    GeneralLesson lesson, {
    LessonCat? cat,
    required LessonCat saved,
  }) {
    if (!lesson.hasTrackChoice) {
      final id = lesson.ids.single;
      if (id == null) return const [];
      final chosen = cat ?? LessonCat.all;
      final track = chosen.track;
      return [
        TopicTarget(
          backendLessonId: id,
          typeValue: track == null
              ? GeneralLesson.allTracksFilter
              : lesson.filterValueFor(track),
          cat: chosen,
        ),
      ];
    }
    final tracks = lesson.tracks;
    final wanted = cat?.track ?? saved.track;
    final preferred = tracks.contains(wanted) ? wanted! : tracks.first;
    final order = [preferred, ...tracks.where((track) => track != preferred)];
    return [
      for (final track in order)
        if (lesson.ids.forTrack(track) case final String id)
          TopicTarget(
            backendLessonId: id,
            typeValue: lesson.filterValueFor(track),
            cat: LessonCat.ofTrack(track),
          ),
    ];
  }

  Future<AppResult<TopicContent>> load({
    required GeneralLesson lesson,
    required String topicId,
    required LessonCat saved,
    LessonCat? cat,
  }) async {
    final places = targets(lesson, cat: cat, saved: saved);
    for (final target in places) {
      final subjects = await _repository.getMainSubjects(
        lessonId: target.backendLessonId,
      );
      final failure = subjects.leftOrNull;
      if (failure != null) return Left(failure);
      final list = subjects.rightOrNull?.subjects ?? const [];
      final index = list.indexWhere((subject) => subject.id == topicId);
      if (index < 0) continue;
      final content = await _repository.getSubjectContent(
        mainSubjectId: topicId,
        type: target.typeValue,
      );
      return content.map(
        (subs) => TopicContent(
          topicName: list[index].name,
          number: index + 1,
          cat: target.cat,
          subSubjects: subs,
        ),
      );
    }
    return const Left(
      AppException(
        code: AppErrorCode.notFound,
        message: 'The topic is not among the lesson\'s topics',
      ),
    );
  }
}
