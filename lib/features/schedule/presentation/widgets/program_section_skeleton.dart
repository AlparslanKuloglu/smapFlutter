import 'package:flutter/material.dart';

import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

/// The program as a skeleton inside a tab (pano 14.3 kare 1; the rows are the
/// ones of pano 3.7 kare 2): the title and its line, the "Gün | Hafta"
/// segment, seven day chips and a card of three rows (time, 36 pt tile, two
/// lines). The strip, the header and the tabs of the screen around it are
/// already there. At 15 s without an answer the owner turns it into the
/// section error.
class ProgramSectionSkeleton extends StatelessWidget {
  const ProgramSectionSkeleton({super.key});

  static const double _chipWidth = 48;
  static const double _chipHeight = 64;
  static const double _tile = 36;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      child: AppSkeleton(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 150, height: 20),
            SizedBox(height: AppSpacing.s8),
            SkeletonBox(width: 220, height: 14),
            SizedBox(height: AppSpacing.s16),
            SkeletonBox(
              width: double.infinity,
              height: 44,
              radius: AppRadius.md,
            ),
            SizedBox(height: AppSpacing.s16),
            _ChipStrip(),
            SizedBox(height: AppSpacing.s16),
            AppCard(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
              child: Column(
                children: [
                  _RowSkeleton(wide: 110),
                  _RowSkeleton(wide: 150),
                  _RowSkeleton(wide: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipStrip extends StatelessWidget {
  const _ChipStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < 7; i++)
          const SkeletonBox(
            width: ProgramSectionSkeleton._chipWidth,
            height: ProgramSectionSkeleton._chipHeight,
            radius: AppRadius.md,
          ),
      ],
    );
  }
}

/// One row: the time, the tile and the two lines.
class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton({required this.wide});

  final double wide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 48, height: 16),
          const SizedBox(width: AppSpacing.s12),
          const SkeletonBox(
            width: ProgramSectionSkeleton._tile,
            height: ProgramSectionSkeleton._tile,
            radius: AppRadius.md,
          ),
          const SizedBox(width: AppSpacing.s12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox(width: 60, height: 10),
              const SizedBox(height: AppSpacing.s8),
              SkeletonBox(width: wide, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}
