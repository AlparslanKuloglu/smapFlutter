import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/question_status.dart';
import 'package:smap/features/exams/data/dtos/exam_answers.dart';
import 'package:smap/features/exams/data/dtos/mock_exam_dto.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_card_counts.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/domain/exam_scores.dart';
import 'package:smap/features/exams/domain/exam_summary.dart';
import 'package:smap/features/exams/domain/question_detail.dart';
import 'package:smap/features/exams/domain/topic_result.dart';

/// D/Y/B of three counts; `null` unless all three are known. A negative count
/// (never sent in practice) reads as 0.
DybCounts? dybOf(int? correct, int? wrong, int? blank) {
  if (correct == null || wrong == null || blank == null) return null;
  return DybCounts(
    correct: correct < 0 ? 0 : correct,
    wrong: wrong < 0 ? 0 : wrong,
    blank: blank < 0 ? 0 : blank,
  );
}

extension ExamDefinitionDtoMapping on ExamDefinitionDto {
  ExamDefinition toDomain() => ExamDefinition(
    id: id,
    order: order,
    kind: NetExamTypeWire.fromWire(type),
    imageFile: image,
    serverObject: raw,
  );
}

extension NetBreakdownDtoMapping on NetBreakdownDto {
  DybCounts? get counts => dybOf(correct, wrong, pass);

  NetBreakdown toDomain() => NetBreakdown(net: net, counts: counts);
}

extension MockExamDtoMapping on MockExamDto {
  /// The row of the list; `null` for a result without an id (it cannot be
  /// opened or analysed).
  ExamSummary? toSummary() {
    final resultId = id;
    if (resultId == null) return null;
    return ExamSummary(
      id: resultId,
      definition: mexam?.toDomain() ?? const ExamDefinition(),
      name: itemName,
      publisherName: publisherName,
      date: date,
      net: net,
      counts: dybOf(correct, wrong, pass),
    );
  }

  /// The whole result; `null` for a result without an id.
  ExamDetail? toDetail() {
    final summary = toSummary();
    if (summary == null) return null;
    return ExamDetail(
      summary: summary,
      scores: ExamScores(
        points: points ?? const [],
        pointsHam: pointsHam ?? const [],
        ranks: ranks ?? const [],
        ranksHam: ranksHam ?? const [],
      ),
      aytNets: _aytNets(),
      lessons: [
        for (final lesson in lessonResults ?? const <LessonResultDto>[])
          if (lesson.lesson != null)
            LessonResult(
              lessonId: lesson.lesson!,
              net: lesson.net,
              counts: dybOf(lesson.correct, lesson.wrong, lesson.pass),
            ),
      ],
      tests: _tests(summary.kind),
    );
  }

  Map<AytField, NetBreakdown> _aytNets() {
    final out = <AytField, NetBreakdown>{};
    (aytNets ?? const <String, NetBreakdownDto>{}).forEach((key, value) {
      final field = AytField.fromWire(int.tryParse(key));
      if (field != null) out[field] = value.toDomain();
    });
    return out;
  }

  List<TestResult> _tests(NetExamType? kind) {
    final info = lessonInfo ?? const <NetBreakdownDto>[];
    final groups = questionGroups ?? const <QuestionGroupDto>[];
    final count = info.length > groups.length ? info.length : groups.length;
    return [
      for (var i = 0; i < count; i++)
        _test(
          i,
          kind: kind == null ? null : ExamTestKind.at(kind, i),
          reported: i < info.length ? info[i].counts : null,
          cells: i < groups.length ? groups[i].cells : null,
        ),
    ];
  }

  static TestResult _test(
    int index, {
    required ExamTestKind? kind,
    required DybCounts? reported,
    required List<QuestionCellDto>? cells,
  }) {
    final questions = [
      for (final (position, cell)
          in (cells ?? const <QuestionCellDto>[]).indexed)
        QuestionResult(
          order: cell.order ?? position + 1,
          outcome: switch (cell.type) {
            1 => QuestionOutcome.correct,
            3 => QuestionOutcome.wrong,
            _ => QuestionOutcome.blank,
          },
        ),
    ];
    final draft = TestResult(index: index, kind: kind, questions: questions);
    return TestResult(
      index: index,
      kind: kind,
      counts: reported ?? draft.questionCounts,
      questions: questions,
    );
  }
}

extension TopicAnalysisResponseMapping on TopicAnalysisResponse {
  ExamTopicAnalysis toDomain() => ExamTopicAnalysis([
    for (final lesson in lessons ?? const <LessonTopicsDto>[])
      if (lesson.name != null)
        LessonTopics(
          lessonName: lesson.name!,
          topics: [
            for (final topic in lesson.topics ?? const <TopicResultDto>[])
              if (topic.name != null)
                TopicResult(
                  name: topic.name!,
                  counts: dybOf(
                    topic.correct ?? 0,
                    topic.wrong ?? 0,
                    topic.pass ?? 0,
                  )!,
                  netRate: topic.netRate,
                ),
          ],
        ),
  ]);
}

extension ExamItemDetailMapping on ExamItemDetailResponse {
  ExamCardBreakdown toDomain() => ExamCardBreakdown([
    for (final lesson in lessons ?? const <LessonCardTallyDto>[])
      if (lesson.lessonId != null)
        LessonCardTally(
          lessonId: lesson.lessonId!,
          cards: lesson.totalCards ?? 0,
          items: lesson.totalItems ?? 0,
          mapItems: lesson.totalMapItems ?? 0,
        ),
  ]);
}

extension TotalInfoCardMapping on TotalInfoCardResponse {
  /// Counts one card per entry under its lesson (the legacy counting).
  ExamCardCounts toDomain() {
    final byLesson = <String, int>{};
    for (final card in cards ?? const <EarnedCardDto>[]) {
      final lesson = card.lesson;
      if (lesson == null) continue;
      byLesson[lesson] = (byLesson[lesson] ?? 0) + 1;
    }
    return ExamCardCounts(byLesson: byLesson);
  }
}

extension QuestionResponseMapping on QuestionResponse {
  /// `null` when the answer had no `question` object.
  QuestionDetail? toDomain() {
    final question = this.question;
    if (question == null) return null;
    return QuestionDetail(
      description: question.desc,
      pageInfo: question.pageInfo,
      cards: [
        for (final item in question.items ?? const <QuestionItemDto>[])
          if (item.name != null || (item.desc ?? const <String>[]).isNotEmpty)
            QuestionTopicCard(
              title: item.name ?? '',
              mainSubjectName: item.mainSubject?.name,
              paragraphs: item.desc ?? const [],
            ),
      ],
    );
  }
}
