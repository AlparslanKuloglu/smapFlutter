part of '../coaching_view.dart';

typedef _LinkedData = ({CoachLink? coach, bool busy, bool online});

/// "Koçun var" (pano 9.5 kare 1, Tur 12 F): the coach card, the info box and
/// the two text buttons.
class _LinkedSection
    extends SelectorViewModelWidget<CoachingViewModel, _LinkedData> {
  const _LinkedSection();

  @override
  _LinkedData selector(CoachingViewModel viewModel) => (
    coach: viewModel.coach,
    busy: viewModel.isWorking,
    online: viewModel.isOnline,
  );

  @override
  Widget build(BuildContext context, _LinkedData data) {
    final coach = data.coach;
    if (coach == null) return const SliverToBoxAdapter(child: SizedBox());
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final viewModel = getParentViewModel<CoachingViewModel>(
      context,
      listen: false,
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _CoachCard(coach: coach),
          const SizedBox(height: AppSpacing.s16),
          AppNoticeBox(message: l10n.coaching_infoBox(coach.name)),
          const SizedBox(height: AppSpacing.s16),
          _PulledText(
            child: AppButton(
              label: l10n.coachingChange_open,
              icon: PhosphorIconsRegular.arrowsLeftRight,
              variant: AppButtonVariant.text,
              onPressed: data.busy || !data.online
                  ? null
                  : viewModel.changeCoach,
            ),
          ),
          if (!data.online)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s8),
              child: Text(
                l10n.coachingChange_offlineNote,
                style: context.appText.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          _PulledText(
            child: AppButton(
              label: l10n.coaching_unlinkAction,
              variant: AppButtonVariant.textDanger,
              onPressed: data.busy ? null : viewModel.unlink,
            ),
          ),
        ]),
      ),
    );
  }
}

/// A text button pulled 12 to the left so its label lines up with the
/// content (pano 9.5: "margin-left -12"); the 48 pt target stays whole.
class _PulledText extends StatelessWidget {
  const _PulledText({required this.child});

  final Widget child;

  /// The text button's own side padding.
  static const double _pull = -12;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Transform.translate(offset: const Offset(_pull, 0), child: child),
  );
}

/// The coach card (pano 9.5 kare 1; C-coach card): the 64 pt avatar, the
/// name 17/700 and "Koçun" 13/20, on a card with 16 padding.
class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.coach});

  final CoachLink coach;

  /// Between the avatar and the name (pano 9.5: 14).
  static const double _avatarGap = 14;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final asset = AvatarAsset.pathOf(coach.photo);
    return AppCard(
      child: MergeSemantics(
        child: Row(
          children: [
            AppAvatar(
              name: coach.name,
              image: asset == null ? null : AssetImage(asset),
              size: AppAvatarSize.coachCard,
              decorative: true,
            ),
            const SizedBox(width: _avatarGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach.name,
                    style: text.headline.copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    l10n.coaching_coachLabel,
                    style: text.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
