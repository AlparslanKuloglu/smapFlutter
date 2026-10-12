import 'package:flutter/material.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/exams/domain/question_detail.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// The sheet of a card related to a question (pano 5.7 "Karta dokunmak → kart
/// sheet'i"; the look of the card sheet of pano 7.3 kare 3, read only).
///
/// The head: the card's main subject 13/20 · 600 `textSecondary` as the
/// subtitle and the card's title 20/28 · 700 with "Kapat"; the body: the
/// card's text 16/26, one paragraph per block, 8 apart. A card of a question
/// has no id on the wire, so it can neither be starred nor learned here; the
/// decks do that.
class QuestionCardSheet extends StatelessWidget {
  const QuestionCardSheet({required this.card, super.key});

  final QuestionTopicCard card;

  /// Opens the sheet.
  static Future<void> show({required QuestionTopicCard card}) =>
      AppSheet.show<void>(builder: (_) => QuestionCardSheet(card: card));

  /// Space between two paragraphs.
  static const double _paragraphGap = AppSpacing.s8;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final subject = card.mainSubjectName;
    return AppSheetFrame(
      title: card.title,
      subtitle: subject,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, paragraph) in card.paragraphs.indexed) ...[
            if (i > 0) const SizedBox(height: _paragraphGap),
            Text(
              paragraph,
              style: text.bodyReading.copyWith(color: colors.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}
