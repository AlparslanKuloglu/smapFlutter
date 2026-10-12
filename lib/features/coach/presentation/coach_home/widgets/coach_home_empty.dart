part of '../coach_home_view.dart';

/// What the page of a coach with no student reads: the coaching code, `null`
/// when the server did not send one.
typedef _EmptyData = String?;

/// The page of a coach with no student (pano 10.1 kare 3; flow 13.11): three
/// 72 pt avatars overlapping 16, "İlk öğrencini ekle" (20/28 · 700, 20 under
/// the avatars), "Öğrencin koçluk kodunla kendi hesabından bağlanabilir ya da
/// hesabını sen açabilirsin." (15/24 `textSecondary`, 6 under), the one
/// primary button "Öğrenci Ekle" with a Plus and the `CodeCard` (Kopyala,
/// Paylaş), 16 apart.
///
/// The three pictures are the kit's avatar set, not people: the page has no
/// student to show. The code card draws only when the coach has a code. The
/// sections, the meetings included, do not exist on this page.
class _NoStudentsPage
    extends SelectorViewModelWidget<CoachHomeViewModel, _EmptyData> {
  const _NoStudentsPage();

  /// The three avatars of the board, `av-1`, `av-4` and `av-3` of the seven
  /// the kit offers (decision 9.1 "1.25 eşlemesi"; `AvatarCatalog` order).
  static const List<int> _avatars = [0, 3, 2];

  /// The block's top inside the body: the board puts it at 190, the body
  /// starts at 182, and the block pads itself 12 more (kare 3: 8 + 12).
  static const double _blockTop = 20;

  /// The gaps of the text block (pano 10.1 kare 3: 20 under the avatars, 6
  /// under the title).
  static const double _titleGap = 20;
  static const double _messageGap = 6;

  @override
  _EmptyData selector(CoachHomeViewModel viewModel) => viewModel.coachCode;

  @override
  Widget build(BuildContext context, _EmptyData code) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<CoachHomeViewModel>(
      context,
      listen: false,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        _blockTop,
        AppSpacing.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
            child: Column(
              children: [
                ExcludeSemantics(
                  child: AppAvatarStack.large(
                    people: [
                      for (final index in _avatars)
                        (
                          name: '',
                          image: CoachAvatars.imageOf(
                            AvatarCatalog.fileAt(index),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: _titleGap),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.coachHome_emptyTitle,
                    textAlign: TextAlign.center,
                    style: text.titleMd.copyWith(color: colors.textPrimary),
                  ),
                ),
                const SizedBox(height: _messageGap),
                Text(
                  l10n.coachHome_emptyMessage,
                  textAlign: TextAlign.center,
                  style: text.body.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppButton(
            label: l10n.coachHome_addStudent,
            icon: PhosphorIconsRegular.plus,
            expand: true,
            onPressed: () => unawaited(_openAddStudent(context)),
          ),
          if (code != null) ...[
            const SizedBox(height: AppSpacing.s16),
            CodeCard(
              code: code,
              onCopy: () => unawaited(viewModel.copyCode()),
              onShare: (origin) =>
                  unawaited(viewModel.shareCode(l10n, origin: origin)),
            ),
          ],
        ],
      ),
    );
  }
}
