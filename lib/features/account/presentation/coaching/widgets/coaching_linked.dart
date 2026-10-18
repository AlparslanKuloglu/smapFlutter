part of '../coaching_view.dart';

typedef _LinkedData = ({CoachLink? coach, bool busy, bool online});

/// "Koçun var" (pano 9.5 kare 1; pano 14.10 kare 1, 5 and 6): the coach card,
/// the info box, the outlined full-width "Koçu Değiştir" with ArrowsLeftRight
/// and the red text button "Bağlantıyı Kaldır" pulled to the left edge. The
/// card's "Sıradaki görüşme" row is not drawn (T12.22: no meeting, and no
/// endpoint tells the student's next one).
///
/// Offline (kare 6) both actions are off and one line under them says "Koçunu
/// değiştirmek ya da bağlantıyı kaldırmak için bağlantı gerekiyor."; the card
/// stays as last loaded. While an action runs both are off too.
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
    final enabled = !data.busy && data.online;
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
          AppButton(
            label: l10n.coachingChange_open,
            icon: PhosphorIconsRegular.arrowsLeftRight,
            variant: AppButtonVariant.outline,
            expand: true,
            onPressed: enabled ? viewModel.changeCoach : null,
          ),
          _PulledText(
            child: AppButton(
              label: l10n.coaching_unlinkAction,
              variant: AppButtonVariant.textDanger,
              onPressed: enabled ? viewModel.unlink : null,
            ),
          ),
          if (!data.online)
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.coachingChange_offlineNote,
                style: context.appText.caption.copyWith(
                  color: colors.textSecondary,
                ),
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
/// name 17/700 and "Koçun" 13/20, on a card with 16 padding. After a change
/// the focus moves here (pano 14.10 kare 5: "odak koç kartına").
class _CoachCard extends StatefulWidget {
  const _CoachCard({required this.coach});

  final CoachLink coach;

  /// Between the avatar and the name (pano 9.5: 14).
  static const double _avatarGap = 14;

  @override
  State<_CoachCard> createState() => _CoachCardState();
}

class _CoachCardState extends State<_CoachCard> {
  final FocusNode _focus = FocusNode(debugLabel: 'coach card');
  ValueListenable<int>? _requests;

  void _onRequest() => _focus.requestFocus();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final requests = getParentViewModel<CoachingViewModel>(
      context,
      listen: false,
    ).cardFocus;
    if (requests == _requests) return;
    _requests?.removeListener(_onRequest);
    _requests = requests..addListener(_onRequest);
  }

  @override
  void dispose() {
    _requests?.removeListener(_onRequest);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final coach = widget.coach;
    final asset = AvatarAsset.pathOf(coach.photo);
    return Focus(
      focusNode: _focus,
      child: AppCard(
        child: MergeSemantics(
          child: Semantics(
            focusable: true,
            child: Row(
              children: [
                AppAvatar(
                  name: coach.name,
                  image: asset == null ? null : AssetImage(asset),
                  size: AppAvatarSize.coachCard,
                  decorative: true,
                ),
                const SizedBox(width: _CoachCard._avatarGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coach.name,
                        style: text.headline.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        l10n.coaching_coachLabel,
                        style: text.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
