part of '../login_view.dart';

/// The SMAP lockup under the bar (pano 2.3 kare 1 to 4: top 110, left 24; the
/// mark 36 high with "SMAP" 24 beside it). The logo shows only on the launch
/// and sign-in screens (board 1.26).
///
/// The title follows 20 below (its own 8 top padding makes the board's 28).
class _LoginBrand extends StatelessWidget {
  const _LoginBrand();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutterAuth,
          0,
          AppSpacing.gutterAuth,
          _formGap,
        ),
        child: Align(alignment: Alignment.centerLeft, child: AppLockup()),
      ),
    );
  }
}
