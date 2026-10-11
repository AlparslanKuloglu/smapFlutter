part of '../home_view.dart';

/// The skeleton of "Bugün" (pano 3.2 kare 1): the title 80 × 24 and the sub
/// line 170 × 14, then three rows of 64 with the blocks of the real row (the
/// time 44 × 18, the glyph 36 × 36 radius 12, the subject 60 × 12 and the
/// topic 90 / 180 / 110 × 16).
class _TodaySkeleton extends StatelessWidget {
  const _TodaySkeleton();

  static const List<double> _topicWidths = [90, 180, 110];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _gutter,
      child: AppSkeleton(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 80, height: 24),
            const SizedBox(height: AppSpacing.s4),
            const SkeletonBox(width: 170, height: 14),
            const SizedBox(height: AppSpacing.s12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final width in _topicWidths)
                    _SkeletonRow(topicWidth: width),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One placeholder row of the "Bugün" skeleton.
class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.topicWidth});

  final double topicWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ProgramItemRow.minHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        child: Row(
          children: [
            const SkeletonBox(width: 44, height: 18),
            const SizedBox(width: AppSpacing.s12),
            const SkeletonBox(width: 36, height: 36, radius: 12),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 60, height: 12),
                  const SizedBox(height: AppSpacing.s4),
                  SkeletonBox(width: topicWidth, height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The skeleton of "Son denemen" (pano 3.2 kare 1): the title 140 × 24, then
/// a card with padding 16 and 10 between the blocks (200 × 18, 120 × 14,
/// 130 × 36, 220 × 16 and the button 100 % × 48 radius 12).
class _LastExamSkeleton extends StatelessWidget {
  const _LastExamSkeleton();

  /// The gap between the blocks of the card.
  static const double _gap = 10;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: _gutter,
      child: AppSkeleton(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 140, height: 24),
            SizedBox(height: AppSpacing.s12),
            SizedBox(
              width: double.infinity,
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 200, height: 18),
                    SizedBox(height: _gap),
                    SkeletonBox(width: 120, height: 14),
                    SizedBox(height: _gap),
                    SkeletonBox(width: 130, height: 36),
                    SizedBox(height: _gap),
                    SkeletonBox(width: 220, height: 16),
                    SizedBox(height: _gap),
                    SkeletonBox(width: double.infinity, height: 48, radius: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The skeleton of "Derslerin": the title and three tiles of the strip (the
/// boards draw none, the shape follows the tile: 132 wide, glyph 40, the name
/// and the tag).
class _SubjectsSkeleton extends StatelessWidget {
  const _SubjectsSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: _gutter,
            child: SkeletonBox(width: 100, height: 24),
          ),
          const SizedBox(height: AppSpacing.s12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: _gutter,
            child: Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.s8),
                  const _SkeletonTile(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One placeholder tile of the "Derslerin" skeleton.
class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: SubjectTile.width,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 40, height: 40, radius: 12),
            SizedBox(height: AppSpacing.s12),
            SkeletonBox(width: 70, height: 16),
            SizedBox(height: AppSpacing.s8),
            SkeletonBox(width: 60, height: 24),
          ],
        ),
      ),
    );
  }
}
