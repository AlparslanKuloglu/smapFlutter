import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';
import 'package:smap/features/exams/data/dtos/lenient_list_hooks.dart';

/// Hooks for the mock-exam answers (`getMyMockExams`, `answerArray`'s
/// `mexamFound`, `getMexamSubjectDetail`, `getMexamItemDetail`).

/// Point arrays (`points`, `pointsHam`): one slot per score type, each a
/// number, text (`"412,63"`) or empty. Unreadable slots are `null`; the slot
/// positions are kept.
final class PointListHook extends MappingHook {
  const PointListHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is! List) return null;
    return [
      for (final slot in value) const DoubleOrNullHook().beforeDecode(slot),
    ];
  }
}

/// Rank arrays (`ranks`, `ranksHam`): one slot per score type. The backend
/// formats big ranks with a thousands separator (`"48.215"`), so dots and
/// commas are removed before reading (the legacy analytics rule). Unreadable
/// slots are `null`; positions are kept.
final class RankListHook extends MappingHook {
  const RankListHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is! List) return null;
    return [for (final slot in value) _rank(slot)];
  }

  static int? _rank(Object? slot) {
    if (slot is num) return slot.isFinite ? slot.round() : null;
    if (slot is! String) return null;
    final digits = slot.replaceAll('.', '').replaceAll(',', '').trim();
    return int.tryParse(digits);
  }
}

/// `aytNets`: an object keyed by the score type (`"2"`, `"3"`, `"4"`) whose
/// values are `{net, true, wrong, pass}`. Entries whose value is not an
/// object are dropped.
final class AytNetsHook extends MappingHook {
  const AytNetsHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is! Map) return null;
    return {
      for (final entry in value.entries)
        if (entry.value is Map)
          '${entry.key}': Map<String, dynamic>.from(entry.value as Map),
    };
  }
}

/// `lessonInfo`: the per-test D/Y/B list, stored as a JSON string. Positions
/// are kept (index 0 is the first test).
final class JsonPositionalMapListHook extends MappingHook {
  const JsonPositionalMapListHook();

  @override
  Object? beforeDecode(Object? value) =>
      const PositionalMapListHook().beforeDecode(decodeJsonText(value));
}

/// `questionsArrStr`: a JSON string holding one list of `{order, type}`
/// questions per test. Becomes `[{"cells": [...]}, ...]` so each test is one
/// object; a test that is not a list is an empty test (positions are kept).
final class QuestionGroupsHook extends MappingHook {
  const QuestionGroupsHook();

  @override
  Object? beforeDecode(Object? value) {
    final decoded = decodeJsonText(value);
    if (decoded is! List) return null;
    return [
      for (final group in decoded)
        <String, dynamic>{
          'cells': const MapListHook().beforeDecode(group) ?? const <Object>[],
        },
    ];
  }
}

/// Class hook of `MockExamDto`: the backend spells the per-lesson results
/// `lessonmockexams` in `getMyMockExams` and `lessonMockExams` in the
/// `answerArray` answer; both read into one field.
final class LessonResultsAliasHook extends MappingHook {
  const LessonResultsAliasHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is! Map) return value;
    if (value.containsKey('lessonmockexams') ||
        !value.containsKey('lessonMockExams')) {
      return value;
    }
    return <String, dynamic>{
      ...Map<String, dynamic>.from(value),
      'lessonmockexams': value['lessonMockExams'],
    };
  }
}

/// Class hook of `ExamDefinitionDto`: keeps a copy of the whole object under
/// `raw`, because `getQuestion` sends the exam object back to the server as it
/// came (the legacy screen posts `mexam` unchanged).
final class KeepRawObjectHook extends MappingHook {
  const KeepRawObjectHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is! Map) return value;
    final copy = Map<String, dynamic>.from(value);
    return <String, dynamic>{...copy, 'raw': copy};
  }
}

/// `getMexamSubjectDetail`'s `data`: an object keyed by lesson name whose
/// values are objects keyed by topic name, each holding `trueValue`,
/// `wrongValue`, `passValue` and `netRate`. Becomes an ordered list
/// `[{name, topics: [{name, ...}]}]` (the backend sorts both levels, so order
/// is part of the answer).
final class TopicAnalysisHook extends MappingHook {
  const TopicAnalysisHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is! Map) return null;
    return [
      for (final lesson in value.entries)
        <String, dynamic>{
          'name': '${lesson.key}',
          'topics': [
            if (lesson.value is Map)
              for (final topic in (lesson.value as Map).entries)
                <String, dynamic>{
                  if (topic.value is Map)
                    ...Map<String, dynamic>.from(topic.value as Map),
                  'name': '${topic.key}',
                },
          ],
        },
    ];
  }
}

/// `getMexamItemDetail`'s `data`: an object keyed by lesson id whose values
/// hold `totalCards`, `totalItems` and `totalMapItems`. Becomes
/// `[{lessonId, ...}]` in the answer's order.
final class LessonTallyMapHook extends MappingHook {
  const LessonTallyMapHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is! Map) return null;
    return [
      for (final entry in value.entries)
        <String, dynamic>{
          if (entry.value is Map)
            ...Map<String, dynamic>.from(entry.value as Map),
          'lessonId': '${entry.key}',
        },
    ];
  }
}
