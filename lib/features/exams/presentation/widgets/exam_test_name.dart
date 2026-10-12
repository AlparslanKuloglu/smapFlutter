import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/exams/application/exam_detail_model.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The full name of a test (pano 5.3, 5.7: "Türk Dili ve Edebiyatı–Sosyal
/// Bilimler 1", "Sosyal Bilimler 2", "Temel Matematik"); a test the app has no
/// name for is "5. Test" ([index] is 0-based).
String examTestName(AppLocalizations l10n, ExamTestLabel? label, int index) =>
    switch (label) {
      ExamTestLabel.turkish => l10n.examDetail_testTurkish,
      ExamTestLabel.socialSciences => l10n.examDetail_testSocial,
      ExamTestLabel.socialSciencesLiterature =>
        l10n.examDetail_testSocialLiterature,
      ExamTestLabel.socialSciences2 => l10n.examDetail_testSocial2,
      ExamTestLabel.basicMathematics => l10n.examDetail_testBasicMath,
      ExamTestLabel.mathematics => l10n.examDetail_testMath,
      ExamTestLabel.sciences => l10n.examDetail_testSciences,
      null => l10n.examDetail_testNumbered(TrFormat.sira(index + 1)),
    };
