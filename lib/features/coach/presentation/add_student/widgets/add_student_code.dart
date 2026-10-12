part of '../add_student_sheet.dart';

/// The "ya da" section (pano 10.3 kare 1 and 2): 20 under the button, two
/// rules with "ya da" between them (13/20 · 600 `textSecondary`), "Öğrencin
/// kendi hesabıyla bağlansın" 16/24 · 600 (16 above, 8 below) and the coaching
/// code card with "Kopyala" and "Paylaş" (C35, E15's `CodeCard`). Not drawn
/// when the coach has no code: nothing is invented.
class _CodeSection extends StatelessWidget {
  const _CodeSection();

  @override
  Widget build(BuildContext context) {
    final viewModel = getParentViewModel<AddStudentViewModel>(
      context,
      listen: false,
    );
    final code = viewModel.coachCode;
    if (code == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: _addStudentSectionGap),
        Row(
          children: [
            Expanded(child: Divider(height: 1, color: colors.bgSunken)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
              child: Text(
                l10n.addStudent_or,
                style: text.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ),
            Expanded(child: Divider(height: 1, color: colors.bgSunken)),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),
        Semantics(
          header: true,
          child: Text(
            l10n.addStudent_codeHeading,
            style: text.titleSm.copyWith(color: colors.textPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        CodeCard(
          code: code,
          onCopy: viewModel.copyCode,
          onShare: (origin) => viewModel.shareCode(l10n, origin: origin),
        ),
      ],
    );
  }
}
