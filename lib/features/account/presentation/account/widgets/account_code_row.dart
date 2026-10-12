part of '../account_view.dart';

/// "Koçluk" of a coach (pano 9.1 kare 4): one group whose row is not a link:
/// "Koçluk kodun" with the code under it and two 48 pt icon buttons, Copy
/// ("Kodu kopyala") and ShareNetwork ("Kodu paylaş"). Without a code the
/// group is not drawn (nothing to show, nothing invented).
class _CoachCodeGroup
    extends SelectorViewModelWidget<AccountViewModel, String?> {
  const _CoachCodeGroup();

  @override
  String? selector(AccountViewModel viewModel) => viewModel.menu.coachCode;

  @override
  Widget build(BuildContext context, String? code) {
    if (code == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return AppRowGroup(
      title: l10n.account_groupCoaching,
      children: [_CoachCodeRow(code: code)],
    );
  }
}

/// The code row: icon, "Koçluk kodun" 16/24 · 600, the code 15/24 · 700 with
/// 0,5 letter spacing, and the two icon buttons (the share one pulled 12 to
/// the right so its icon sits at the group's edge padding).
class _CoachCodeRow extends StatelessWidget {
  const _CoachCodeRow({required this.code});

  final String code;

  /// The code's letter spacing (spec 9.1 kare 4).
  static const double _letterSpacing = 0.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AccountViewModel>(
      context,
      listen: false,
    );
    return AppRowShell(
      minHeight: AppSize.rowMinTwoLine,
      padding: const EdgeInsets.only(
        left: AppSpacing.s16,
        right: AppSpacing.s4,
      ),
      child: Row(
        children: [
          PhosphorIcon(
            PhosphorIconsRegular.users,
            size: AppSize.icon,
            color: colors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.account_coachCodeTitle,
                    style: text.titleSm.copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    code,
                    style: text.bodyStrong.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: _letterSpacing,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppIconButton(
            icon: PhosphorIconsRegular.copy,
            semanticLabel: l10n.account_coachCodeCopy,
            iconSize: 22,
            color: colors.textSecondary,
            onPressed: () => unawaited(viewModel.copyCode()),
          ),
          Builder(
            builder: (buttonContext) => AppIconButton(
              icon: PhosphorIconsRegular.shareNetwork,
              semanticLabel: l10n.account_coachCodeShare,
              iconSize: 22,
              color: colors.textSecondary,
              onPressed: () => unawaited(
                viewModel.shareCode(l10n, origin: _originOf(buttonContext)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The rectangle of the button on screen, for an iPad's share popover.
  static Rect? _originOf(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}
