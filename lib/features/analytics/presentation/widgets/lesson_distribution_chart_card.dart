import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/features/analytics/presentation/models/analytics_general_data.dart';

class LessonDistributionChartCard extends StatelessWidget {
  const LessonDistributionChartCard({super.key, required this.items});

  final List<AnalyticsLessonDistributionData> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final barHeight = (screenWidth * 0.105).clamp(34.0, 42.0);
    final barGap = (screenWidth * 0.012).clamp(2.0, 5.0);
    final axisFontSize = (screenWidth * 0.028).clamp(10.0, 11.5);
    final legendFontSize = (screenWidth * 0.031).clamp(11.0, 12.5);
    final titleFontSize = (screenWidth * 0.046).clamp(16.0, 18.0);
    final axisHeight = (axisFontSize + 6).clamp(14.0, 18.0);

    final maxValue = items.isEmpty ? 1.0 : items.map((e) => e.value).reduce(math.max);
    final maxValueInt = maxValue.ceil();
    final axisLabels = _buildAxisLabels(maxValueInt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: LayoutBuilder(
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eksik Ders Konu Dagilimlari',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: (items.length * barHeight) + ((items.length - 1) * barGap),
              child: Stack(
                children: [
                  Column(
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final isLast = index == items.length - 1;
                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : barGap),
                        child: _HorizontalBar(
                          item: item,
                          maxValue: maxValue,
                          barHeight: barHeight,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: axisHeight,
              child: _AxisLabelsRow(
                axisLabels: axisLabels,
                maxValue: maxValue,
                fontSize: axisFontSize,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: items
                  .take(items.length)
                  .map(
                    (e) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: e.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${e.lesson} ${e.value.toInt()}',
                      style: TextStyle(
                        fontSize: legendFontSize,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<int> _buildAxisLabels(int maxValueInt) {
    if (maxValueInt <= 0) return [0];
    const step = 3;
    final labels = <int>[0];
    for (var i = step; i <= maxValueInt; i += step) {
      labels.add(i);
    }
    if (labels.last != maxValueInt) {
      labels.add(maxValueInt);
    }
    return labels;
  }
}

class _AxisLabelsRow extends StatelessWidget {
  const _AxisLabelsRow({
    required this.axisLabels,
    required this.maxValue,
    required this.fontSize,
  });

  final List<int> axisLabels;
  final double maxValue;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: axisLabels.map((label) {
            final ratio = maxValue == 0 ? 0.0 : (label / maxValue).clamp(0.0, 1.0);
            final x = ratio * constraints.maxWidth;
            final text = '$label';
            final painter = TextPainter(
              text: TextSpan(
                text: text,
                style: TextStyle(fontSize: fontSize, color: AppColors.textSecondary),
              ),
              textDirection: TextDirection.ltr,
            )..layout();
            final left = (x - (painter.width / 2)).clamp(
              0.0,
              (constraints.maxWidth - painter.width).clamp(0.0, constraints.maxWidth),
            );
            return Positioned(
              left: left,
              child: Text(
                text,
                style: TextStyle(fontSize: fontSize, color: AppColors.textSecondary),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _HorizontalBar extends StatelessWidget {
  const _HorizontalBar({
    required this.item,
    required this.maxValue,
    required this.barHeight,
  });

  final AnalyticsLessonDistributionData item;
  final double maxValue;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue == 0 ? 0.0 : (item.value / maxValue).clamp(0.0, 1.0);

    return SizedBox(
      height: barHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fullWidth = constraints.maxWidth;
          final barWidth = fullWidth * ratio;

          const textPadding = 20.0;

          final textPainter = TextPainter(
            text: TextSpan(
              text: item.lesson,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout();

          final textWidth = textPainter.width;

          final canFitInside = barWidth > (textWidth + textPadding);

          return Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: barWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
              ),

              if (canFitInside)
              // İçeri
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      item.lesson,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
              // Dışarı
                Positioned(
                  left: barWidth + 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      item.lesson,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: item.color,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}