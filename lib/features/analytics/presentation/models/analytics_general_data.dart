import 'package:flutter/material.dart';

/// API'den gelecek "Genel" sekme verileri için ana model.
class AnalyticsGeneralData {
  const AnalyticsGeneralData({
    required this.chart,
    required this.cards,
    required this.lessonDistributions,
  });

  final AnalyticsChartData chart;
  final List<AnalyticsMetricCardData> cards;
  final List<AnalyticsLessonDistributionData> lessonDistributions;

  /// Veriler yüklenirken veya hata durumunda kullanılacak boş nesne
  factory AnalyticsGeneralData.empty() {
    return AnalyticsGeneralData(
      chart: AnalyticsChartData.empty(),
      cards: [],
      lessonDistributions: [],
    );
  }

  factory AnalyticsGeneralData.mock() {
    return const AnalyticsGeneralData(
      chart: AnalyticsChartData(
        title: 'Deneme Net Grafigi 2',
        subtitle: 'TYT Denemeleri',
        primaryColor: Color(0xFF1E344A),
        yLabels: ['120 Net', '100 Net', '80 Net', '60 Net', '40 Net'],
        xLabels: ['12 Oct', '16 Oct', '18 Oct', '20 Oct', '22 Oct', '24 Oct'],
        primarySeries: [
          NetGraphPoint(value: 74),
          NetGraphPoint(value: 76),
          NetGraphPoint(value: 73),
          NetGraphPoint(value: 79),
          NetGraphPoint(value: 84),
          NetGraphPoint(value: 82),
          NetGraphPoint(value: 83),
          NetGraphPoint(value: 89),
          NetGraphPoint(value: 95),
          NetGraphPoint(value: 92),
          NetGraphPoint(value: 74),
          NetGraphPoint(value: 70),
          NetGraphPoint(value: 90),
          NetGraphPoint(value: 81),
          NetGraphPoint(value: 76),
        ],
      ),
      cards: [
        AnalyticsMetricCardData(
          value: '78',
          label: 'Ortalama Net',
          iconPath: 'assets/icons/tag.svg',
        ),
        AnalyticsMetricCardData(
          value: '105',
          label: 'Ortalama Puan',
          iconPath: 'assets/icons/trophy.svg',
        ),
        AnalyticsMetricCardData(
          value: '158',
          label: 'Ort. Siralama',
          iconPath: 'assets/icons/chart.svg',
        ),
        AnalyticsMetricCardData(
          value: '121',
          label: 'Toplam Dogru',
          iconPath: 'assets/icons/check_all.svg',
        ),
      ],
      lessonDistributions: [
        AnalyticsLessonDistributionData(
          lesson: 'TYT Turkce',
          value: 17,
          color: Color(0xFF3E516A),
        ),
        AnalyticsLessonDistributionData(
          lesson: 'TYT Tarih',
          value: 4,
          color: Color(0xFFF7B889),
        ),
        AnalyticsLessonDistributionData(
          lesson: 'TYT Cografya',
          value: 2,
          color: Color(0xFF98A4B2),
        ),
        AnalyticsLessonDistributionData(
          lesson: 'TYT Matematik',
          value: 18,
          color: Color(0xFFF68A3F),
        ),
      ],
    );
  }
}

class AnalyticsChartData {
  const AnalyticsChartData({
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.yLabels,
    required this.xLabels,
    required this.primarySeries,
  });

  final String title;
  final String subtitle;
  final Color primaryColor;
  final List<String> yLabels;
  final List<String> xLabels;
  final List<NetGraphPoint> primarySeries;

  factory AnalyticsChartData.empty() {
    return const AnalyticsChartData(
      title: '',
      subtitle: '',
      primaryColor: Colors.transparent,
      yLabels: [],
      xLabels: [],
      primarySeries: [],
    );
  }
}

class NetGraphPoint {
  const NetGraphPoint({required this.value});

  final double value;
}

class AnalyticsMetricCardData {
  const AnalyticsMetricCardData({
    required this.value,
    required this.label,
    required this.iconPath,
    this.changeText = '+18.2%',
    this.periodText = 'gecen ay',
  });

  final String value;
  final String label;
  final String iconPath;
  final String changeText;
  final String periodText;

  /// İhtiyaç duyulursa boş kart verisi
  factory AnalyticsMetricCardData.empty() {
    return const AnalyticsMetricCardData(
      value: '-',
      label: '',
      iconPath: '',
      changeText: '',
      periodText: '',
    );
  }
}

class AnalyticsLessonDistributionData {
  const AnalyticsLessonDistributionData({
    required this.lesson,
    required this.value,
    required this.color,
  });

  final String lesson;
  final double value;
  final Color color;

  factory AnalyticsLessonDistributionData.empty() {
    return const AnalyticsLessonDistributionData(
      lesson: '',
      value: 0,
      color: Colors.transparent,
    );
  }
}
