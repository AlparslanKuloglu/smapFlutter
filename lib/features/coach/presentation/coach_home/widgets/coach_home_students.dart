part of '../coach_home_view.dart';

/// "Öğrencilerin" (pano 10.1 kare 1 to 3; C32 `StudentTile`): a horizontal
/// strip of 108 pt tiles, the students in Turkish alphabetical order, and the
/// one link of the section, "Öğrenci Ekle" with a Plus (the header's text
/// button, pulled 12 to the edge).
///
/// A tile opens the student's profile. Loading shows the skeleton; a failure
/// shows "Öğrenciler yüklenemedi." with "Tekrar Dene" under the header, which
/// keeps its link. An empty list never gets here: the body shows the page of
/// kare 3 instead.
class _StudentsSection
    extends
        SelectorViewModelWidget<
          CoachHomeViewModel,
          AsyncSection<StudentStrip>
        > {
  const _StudentsSection();

  @override
  AsyncSection<StudentStrip> selector(CoachHomeViewModel viewModel) =>
      viewModel.students;

  @override
  Widget build(BuildContext context, AsyncSection<StudentStrip> section) {
    final l10n = AppLocalizations.of(context);
    switch (section.state) {
      case SectionState.loading:
        return const _StudentsSkeleton();
      case SectionState.empty:
        return const SizedBox.shrink();
      case SectionState.error:
      case SectionState.offline:
        return Padding(
          padding: _gutter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _StudentsHeader(),
              AppErrorState.section(
                message: l10n.coachHome_studentsError,
                onRetry: getParentViewModel<CoachHomeViewModel>(
                  context,
                  listen: false,
                ).retryStudents,
              ),
            ],
          ),
        );
      case SectionState.ready:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(padding: _gutter, child: _StudentsHeader()),
            _StudentTiles(strip: section.data!),
          ],
        );
    }
  }
}

/// The header of the section: "Öğrencilerin" and "Öğrenci Ekle".
class _StudentsHeader extends StatelessWidget {
  const _StudentsHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionHeader(
      title: l10n.coachHome_students,
      actionLabel: l10n.coachHome_addStudent,
      actionIcon: PhosphorIconsRegular.plus,
      onAction: () => unawaited(_openAddStudent(context)),
    );
  }
}

/// The strip: tiles of one height side by side, 8 apart, 16 at the sides.
class _StudentTiles extends StatelessWidget {
  const _StudentTiles({required this.strip});

  final StudentStrip strip;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: _gutter,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (index, student) in strip.students.indexed) ...[
              if (index > 0) const SizedBox(width: AppSpacing.s8),
              StudentTile(
                name: student.name,
                avatar: CoachAvatars.imageOf(student.photo),
                onTap: () => _openStudent(context, id: student.id),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
