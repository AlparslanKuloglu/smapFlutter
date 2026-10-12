part of '../students_view.dart';

/// The navy band of Öğrencilerim (pano 10.2 kare 1; 1.18 kare 1): the title and
/// the one action, a Plus named "Öğrenci ekle". It shrinks as the list scrolls.
class _StudentsBand extends StatelessWidget {
  const _StudentsBand();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<StudentsViewModel>(
      context,
      listen: false,
    );
    return AppRootBand(
      title: l10n.nav_tabStudents,
      action: AppIconButton(
        icon: PhosphorIconsRegular.plus,
        semanticLabel: l10n.students_addA11y,
        variant: AppIconButtonVariant.onNavy,
        onPressed: viewModel.addStudent,
      ),
    );
  }
}
