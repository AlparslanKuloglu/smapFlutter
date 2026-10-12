part of '../account_view.dart';

/// The band of Hesap (C80 root band + C37 profile summary; pano 9.1 kare 1
/// and 2): "Hesap" and under it the avatar, the name and up to two lines of
/// the account, as one touch target that opens Profil.
///
/// A pinned sliver that is 206 high open and shrinks to 110 with the scroll
/// (the title 24 to 17, the corners flat), the summary fading out before it
/// is half shrunk. It rebuilds only when the summary's facts change; it
/// comes at once with the account on the device and never waits for a
/// request (the coach's name joins it when it arrives).
class _AccountBand
    extends SelectorViewModelWidget<AccountViewModel, AccountHeader?> {
  const _AccountBand();

  @override
  AccountHeader? selector(AccountViewModel viewModel) => viewModel.header;

  @override
  Widget build(BuildContext context, AccountHeader? header) {
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final texts = header == null ? null : accountSummaryTexts(l10n, header);
    final metrics = AccountBandMetrics(
      safeTop: media.padding.top,
      summaryLines: texts?.lines.length ?? 0,
      hasSummary: header != null,
      textScaler: media.textScaler,
    );
    final viewModel = getParentViewModel<AccountViewModel>(
      context,
      listen: false,
    );
    return SliverPersistentHeader(
      pinned: true,
      delegate: _AccountBandDelegate(
        metrics: metrics,
        title: l10n.account_title,
        name: header?.name ?? '',
        avatar: _avatarOf(header?.photo),
        texts: texts,
        hint: l10n.account_a11yOpensProfile,
        onProfile: viewModel.openProfile,
      ),
    );
  }

  static ImageProvider? _avatarOf(String? photo) {
    final asset = AvatarAsset.pathOf(photo);
    return asset == null ? null : AssetImage(asset);
  }
}

class _AccountBandDelegate extends SliverPersistentHeaderDelegate {
  _AccountBandDelegate({
    required this.metrics,
    required this.title,
    required this.name,
    required this.avatar,
    required this.texts,
    required this.hint,
    required this.onProfile,
  });

  final AccountBandMetrics metrics;
  final String title;
  final String name;
  final ImageProvider? avatar;
  final SummaryTexts? texts;
  final String hint;
  final VoidCallback onProfile;

  @override
  double get maxExtent => metrics.maxExtent;

  @override
  double get minExtent => metrics.minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = metrics.progressAt(shrinkOffset);
    final colors = context.appColors;
    final text = context.appText;
    final summary = texts;
    final opacity = AccountBandMetrics.summaryOpacityAt(progress);
    final titleStyle = TextStyle.lerp(
      text.titleLg,
      text.headline,
      progress,
    )!.copyWith(color: colors.textOnNavy);
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.band,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.bgNavy,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(AccountBandMetrics.cornerAt(progress)),
          ),
        ),
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minHeight: 0,
            maxHeight: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: metrics.safeTop),
                SizedBox(
                  height: AccountBandMetrics.titleRowAt(progress),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Semantics(
                        header: true,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: titleStyle,
                        ),
                      ),
                    ),
                  ),
                ),
                if (summary != null)
                  Opacity(
                    opacity: opacity,
                    // Once faded out the summary can no longer be tapped or
                    // read: it is not on screen.
                    child: IgnorePointer(
                      ignoring: opacity < 1,
                      child: ExcludeSemantics(
                        excluding: opacity < 1,
                        child: ProfileSummary(
                          name: name,
                          lines: summary.lines,
                          semanticLabel: summary.semanticLabel,
                          avatar: avatar,
                          hint: hint,
                          onTap: onProfile,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_AccountBandDelegate oldDelegate) =>
      title != oldDelegate.title ||
      name != oldDelegate.name ||
      avatar != oldDelegate.avatar ||
      hint != oldDelegate.hint ||
      onProfile != oldDelegate.onProfile ||
      metrics.maxExtent != oldDelegate.metrics.maxExtent ||
      metrics.safeTop != oldDelegate.metrics.safeTop ||
      metrics.hasSummary != oldDelegate.metrics.hasSummary ||
      texts?.semanticLabel != oldDelegate.texts?.semanticLabel ||
      !_sameLines(texts?.lines, oldDelegate.texts?.lines);

  static bool _sameLines(List<String>? a, List<String>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
