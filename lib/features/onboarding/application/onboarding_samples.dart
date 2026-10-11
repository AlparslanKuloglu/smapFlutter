import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';

/// The example numbers of the intro visuals (pano 2.1 kare 3 and 4, "Ek C
/// verisiyle"). They illustrate the screens and belong to no user; the
/// texts that go with them are in `onboarding_tr.arb`.
abstract final class OnboardingSamples {
  /// The example exam's net: 86 doğru, 74 yanlış → 86 − 74 ÷ 4.
  static const double net = 67.5;

  /// The change against the example exam before it.
  static const double delta = 8.25;

  /// "86 doğru · 74 yanlış · 0 boş".
  static const DybCounts counts = DybCounts(correct: 86, wrong: 74, blank: 0);

  /// The four points of the example net chart, oldest first: 8 Mayıs 48,5 to
  /// 5 Ekim 67,5 (the board draws the first and the last date only; the two
  /// between are evenly spaced).
  static final List<NetChartPoint> chart = [
    NetChartPoint(date: DateTime(2026, 5, 8), net: 48.5),
    NetChartPoint(date: DateTime(2026, 6, 27), net: 55),
    NetChartPoint(date: DateTime(2026, 8, 16), net: net - delta),
    NetChartPoint(date: DateTime(2026, 10, 5), net: net),
  ];

  /// The y axis of the example chart: the board labels 40, 55 and 70.
  static const double chartMin = 40;
  static const double chartMax = 70;
  static const double chartStep = 15;

  /// Missing counts of the three example topics, in the order of the board:
  /// "Fiilde Çatı", "Noktalama İşaretleri", "Cümlenin Öğeleri".
  static const List<int> topicMissing = [3, 3, 2];

  /// The subject of the example topic rows (Türkçe) and of the example card
  /// (Tarih).
  static const SubjectKey topicSubject = SubjectKey.turkce;
  static const SubjectKey cardSubject = SubjectKey.tarih;
}
