import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/features/analytics/presentation/models/analytics_general_data.dart';

class NetChartCard extends StatelessWidget {
  const NetChartCard({
    super.key,
    required this.data,
    this.maxDisplayedLabels = 6,
    this.yLabelSpace =
        12.0, // Yazı ile çizgi arasındaki mesafe (Aralığı büyütmek için artırın)
    this.yAxisReservedSize = 48.0, // Sol eksenin toplam genisliği
  });

  final AnalyticsChartData data;

  /// Toplam gösterilecek metin etiket sayısı (İlk ve Son dahil)
  final int maxDisplayedLabels;

  /// Y ekseni etiketleri ile chart çizgisi arasındaki boşluk
  final double yLabelSpace;

  /// Y ekseni etiketleri için ayrılan toplam sol genişlik
  final double yAxisReservedSize;

  // Dikey çizgi ayarları (Çok silik görünmesi için şeffaf renk ve ince genişlik)
  static const Color _verticalLineColor = Color(
    0x26D0D5DD,
  ); // %15 şeffaflık (0x40 yerine 0x26)
  static const double _verticalLineWidth = 1.0;

  static final _numRegExp = RegExp(r'[\d.]+');

  static const List<String> _monthsTr = [
    'Oca',
    'Şub',
    'Mar',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Ağu',
    'Eyl',
    'Eki',
    'Kas',
    'Ara',
  ];

  double _parseLabel(String label) =>
      double.tryParse(_numRegExp.firstMatch(label)?.group(0) ?? '') ?? 0.0;

  /// Tarih stringini "12 Ara." formatına çevirir
  String _formatDateLabel(String rawLabel) {
    final parsedDate = DateTime.tryParse(rawLabel);
    if (parsedDate != null) {
      final day = parsedDate.day;
      final month = _monthsTr[parsedDate.month - 1];
      return '$day $month.';
    }

    final dateParts = RegExp(r'(\d{1,2})[./-](\d{1,2})').firstMatch(rawLabel);
    if (dateParts != null) {
      final day = int.tryParse(dateParts.group(1) ?? '');
      final month = int.tryParse(dateParts.group(2) ?? '');
      if (day != null && month != null && month >= 1 && month <= 12) {
        return '$day ${_monthsTr[month - 1]}.';
      }
    }

    return rawLabel;
  }

  /// Eşit aralıklarla gösterilecek indeksleri hesaplar (1. ve sonuncu dahil)
  Set<int> _calculateVisibleIndices(int totalCount, int targetCount) {
    if (totalCount <= targetCount) {
      return List.generate(totalCount, (i) => i).toSet();
    }

    final Set<int> indices = {0, totalCount - 1};
    if (targetCount <= 2) return indices;

    final double step = (totalCount - 1) / (targetCount - 1);
    for (int i = 1; i < targetCount - 1; i++) {
      indices.add((i * step).round());
    }

    return indices;
  }

  @override
  Widget build(BuildContext context) {
    final yValues = data.yLabels.isEmpty
        ? [0.0, 100.0]
        : data.yLabels.map(_parseLabel).toList();
    final yMin = yValues.reduce(min);
    final yMax = yValues.reduce(max);

    final spotCount = max(1, data.primarySeries.length);
    final spots = data.primarySeries.isEmpty
        ? const [FlSpot(0, 0)]
        : List.generate(
            spotCount,
            (i) => FlSpot(
              i.toDouble(),
              data.primarySeries[i].value.clamp(yMin, yMax),
            ),
          );

    final xInterval = max(
      1.0,
      data.xLabels.length > 1
          ? (spotCount - 1) / (data.xLabels.length - 1)
          : 1.0,
    );
    final yInterval = max(
      1.0,
      data.yLabels.length > 1 ? (yMax - yMin) / (data.yLabels.length - 1) : 1.0,
    );

    const labelStyle = TextStyle(fontSize: 11, color: Color(0xFF9AA1AA));
    const hideTitle = AxisTitles(sideTitles: SideTitles(showTitles: false));

    // Metin olarak gösterilecek indeksler
    final visibleTextIndices = _calculateVisibleIndices(
      data.xLabels.length,
      maxDisplayedLabels,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 69, 69, 71),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.subtitle,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 260,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (spotCount - 1).toDouble(),
                minY: yMin,
                maxY: yMax,
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: false,
                  drawVerticalLine: true,
                  verticalInterval: 1.0,
                  getDrawingVerticalLine: (value) {
                    final int stepIndex = value.round();
                    final isExactStep = (value - stepIndex).abs() < 0.001;

                    final isEdge =
                        stepIndex == 0 || stepIndex == (spotCount - 1);

                    if (isExactStep &&
                        (visibleTextIndices.contains(stepIndex) || isEdge)) {
                      return const FlLine(
                        color: _verticalLineColor,
                        strokeWidth: _verticalLineWidth,
                      );
                    }
                    return const FlLine(
                      color: Colors.transparent,
                      strokeWidth: 0,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    top: BorderSide(color: Color(0xFFEAECEF)),
                    bottom: BorderSide.none,
                    left: BorderSide(
                      color: _verticalLineColor,
                      width: _verticalLineWidth,
                    ),
                    right: BorderSide(
                      color: _verticalLineColor,
                      width: _verticalLineWidth,
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: hideTitle,
                  topTitles: hideTitle,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: xInterval,
                      getTitlesWidget: (value, meta) {
                        if (data.xLabels.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final index = (value / xInterval).round();
                        if (index < 0 || index >= data.xLabels.length) {
                          return const SizedBox.shrink();
                        }
                        final showText = visibleTextIndices.contains(index);

                        Widget childWidget;
                        if (showText) {
                          final formattedDate = _formatDateLabel(
                            data.xLabels[index],
                          );
                          // Sadece tarihlere top padding eklemek için Text'i Padding ile sarıyoruz:
                          childWidget = Padding(
                            padding: const EdgeInsets.only(
                              top: 4.0,
                            ), // <-- Değeri ihtiyacınıza göre ayarlayabilirsiniz
                            child: Text(formattedDate, style: labelStyle),
                          );
                        } else {
                          childWidget = Container(
                            width: 1.5,
                            height: 1.5,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          );
                        }

                        return SideTitleWidget(meta: meta, child: childWidget);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize:
                          yAxisReservedSize, // Parametre ile kontrol ediliyor
                      interval: yInterval,
                      getTitlesWidget: (value, meta) {
                        final steps = ((value - yMin) / yInterval).round();
                        if (steps >= data.yLabels.length) {
                          return const SizedBox.shrink();
                        }

                        final index = (data.yLabels.length - 1) - steps;
                        final rawLabel = data.yLabels[index];
                        final formattedY = rawLabel.contains('Net')
                            ? rawLabel
                            : '$rawLabel Net';

                        return SideTitleWidget(
                          meta: meta,
                          space:
                              yLabelSpace, // Çizgi ile yazı arasındaki boşluk parametresi
                          child: Text(
                            formattedY,
                            style: labelStyle,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: data.primaryColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                        data.primaryColor.withValues(alpha: 0.85),
                    getTooltipItems: (spots) => spots
                        .map(
                          (s) => LineTooltipItem(
                            '${s.y.toStringAsFixed(1)} Net',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
