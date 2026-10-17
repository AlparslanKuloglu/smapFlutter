import 'dart:math' as math;

import 'package:dartz/dartz.dart';

import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/lessons/application/literature_authors.dart';
import 'package:smap/features/lessons/application/literature_tree.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/features/lessons/domain/lesson_content.dart';

/// Reads the Yazar ve Eserler tree one level at a time, as the screens open
/// it (spec §4.F 7.4, pano 14.5): the eras for the list, an era's
/// sub-subjects for the era detail, and the authors of one sub-subject when
/// its accordion opens.
///
/// Nothing is read ahead: the old loader walked the whole curriculum before
/// showing a row; the sections now load on their own, so a failure stays in
/// its own section (pano 14.7 kare 2).
class LiteratureLoader {
  const LiteratureLoader(this._repository, {this.batch = 6});

  final LessonContentRepository _repository;

  /// Requests for the authors of groups that run at the same time.
  final int batch;

  /// `yazarEserMainSubjects`: the eras, in the server's order.
  Future<AppResult<List<LiteratureEra>>> eras() async {
    final answer = await _repository.getAuthorMainSubjects();
    return answer.map(
      (subjects) => [
        for (final subject in subjects)
          LiteratureEra(
            id: subject.id,
            name: subject.name,
            order: subject.order,
            missing: subject.missingCount,
          ),
      ],
    );
  }

  /// `getSubSubjects` and `getItems` of the era [eraId]: its sub-subjects
  /// with what is listed under them.
  Future<AppResult<List<LiteratureSub>>> subs(String eraId) async {
    final answer = await _repository.getSubjectContent(
      mainSubjectId: eraId,
      authorMode: true,
    );
    return answer.map(
      (subs) => [
        for (final sub in subs)
          LiteratureSub(
            id: sub.id,
            name: sub.name,
            missing: sub.missingCount,
            items: sub.items,
          ),
      ],
    );
  }

  /// The authors of [sub], in the server's order. An item that is an author
  /// itself (`itsYazar`, `yazarCategory`) joins the list as it is; any other
  /// item is a group, and `getSubjectAuthors` lists its authors. If one
  /// request fails the whole list fails: a list with an author group missing
  /// would pass for the whole list.
  Future<AppResult<List<AuthorView>>> authors(LiteratureSub sub) async {
    final slots = [
      for (final item in sub.items)
        if (item.isAuthor || item.authorCategoryId != null)
          _Slot.direct(item)
        else if ((item.id ?? '').isNotEmpty)
          _Slot.group(item),
    ];
    final groups = [
      for (final slot in slots)
        if (slot.group != null) slot,
    ];
    for (var start = 0; start < groups.length; start += batch) {
      final chunk = groups.sublist(
        start,
        math.min(start + batch, groups.length),
      );
      final answers = await Future.wait([
        for (final slot in chunk)
          _repository.getSubjectAuthors(itemId: slot.group!.id!),
      ]);
      for (final (index, answer) in answers.indexed) {
        final failure = answer.leftOrNull;
        if (failure != null) return Left(failure);
        chunk[index].found = answer.rightOrNull ?? const [];
      }
    }
    final authors = <AuthorView>[];
    final seen = <String>{};
    for (final slot in slots) {
      final items = slot.direct != null ? [slot.direct!] : slot.found;
      for (final item in items) {
        final view = AuthorViews.of(item, index: authors.length);
        if (seen.add(view.key)) authors.add(view);
      }
    }
    return Right(authors);
  }
}

class _Slot {
  _Slot.direct(LessonItem item) : direct = item, group = null;

  _Slot.group(LessonItem item) : group = item, direct = null;

  final LessonItem? direct;
  final LessonItem? group;
  List<LessonItem> found = const [];
}
