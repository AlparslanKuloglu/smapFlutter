import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/smap_theme.dart';
import 'package:smap/features/exams/presentation/widgets/exam_score_card.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The loading skeleton of the exam detail draws the score card's block
/// [ExamScoreCard.fullHeight] tall (pano 14.4 kare 4: 163 pt); the real card
/// with both rows must be exactly as tall, or the tabs jump when it loads.
void main() {
  testWidgets('both rows at text scale 1 are fullHeight tall', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SmapTheme.light(),
        locale: const Locale('tr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        // In a scroll view, as on the exam detail screen: the card takes
        // its own height.
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const [
              ExamScoreCard(
                fieldName: 'Eşit Ağırlık',
                score: 412.63,
                rank: 48215,
                scoreHam: 398.12,
                rankHam: 52904,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final size = tester.getSize(find.byType(ExamScoreCard));
    expect(size.height, ExamScoreCard.fullHeight);
  });
}
