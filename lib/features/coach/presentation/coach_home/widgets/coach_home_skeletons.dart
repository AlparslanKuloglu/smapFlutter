part of '../coach_home_view.dart';

/// The skeleton of "Öğrencilerin" (pano 10.1 kare 4): the title 140 × 24 and
/// three tiles of the strip, each a card with a 48 pt circle and a 70 × 14 bar.
class _StudentsSkeleton extends StatelessWidget {
  const _StudentsSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: _gutter,
            child: SkeletonBox(width: 140, height: 24),
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

/// One placeholder tile of the strip: the tile's shape (108 wide, padding 14).
class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: StudentTile.widthOf(context),
      child: const AppCard(
        padding: EdgeInsets.all(StudentTile.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 48, height: 48, radius: 999),
            SizedBox(height: AppSpacing.s8),
            SkeletonBox(width: 70, height: 14),
          ],
        ),
      ),
    );
  }
}

/// The skeleton of "Dikkat gerektirenler" (pano 10.1 kare 4): the title 190 ×
/// 24 and a card of 88. Only with the attention flag open.
class _AttentionSkeleton extends StatelessWidget {
  const _AttentionSkeleton();

  @override
  Widget build(BuildContext context) =>
      const _CardSkeleton(titleWidth: 190, cardHeight: 88);
}

/// The skeleton of "Yaklaşan görüşmeler" (pano 10.1 kare 4): the title 180 ×
/// 24 and a card of 128.
class _MeetingsSkeleton extends StatelessWidget {
  const _MeetingsSkeleton();

  @override
  Widget build(BuildContext context) =>
      const _CardSkeleton(titleWidth: 180, cardHeight: 128);
}

/// A title bar over an empty card, the shape of both list sections.
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({required this.titleWidth, required this.cardHeight});

  final double titleWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _gutter,
      child: AppSkeleton(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: titleWidth, height: 24),
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              width: double.infinity,
              height: cardHeight,
              child: const AppCard(child: SizedBox.shrink()),
            ),
          ],
        ),
      ),
    );
  }
}
