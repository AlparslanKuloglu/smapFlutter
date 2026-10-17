part of '../program_detail_view.dart';

/// `yyyy-MM-dd` as a calendar day; `null` for anything else.
DateTime? _parseDay(String? text) {
  if (text == null) return null;
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text.trim());
  if (match == null) return null;
  final day = DateTime(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
  return day.month == int.parse(match.group(2)!) ? day : null;
}

/// Opens the topic detail of [entry] (pano 3.4 "Bloğa ya da satıra dokununca
/// konu detayı", pano 7.3).
void _openTopic(BuildContext context, ProgramEntry entry) {
  if (getParentViewModel<ProgramDetailViewModel>(
    context,
    listen: false,
  ).isCoachView) {
    return;
  }
  final subject = entry.mainSubjectId;
  if (subject == null || subject.isEmpty || entry.lessonId.isEmpty) return;
  context.navigateTo(
    LessonsTabRoute(
      children: [
        const LessonsRoute(),
        TopicDetailRoute(lessonId: entry.lessonId, topicId: subject),
      ],
    ),
  );
}
