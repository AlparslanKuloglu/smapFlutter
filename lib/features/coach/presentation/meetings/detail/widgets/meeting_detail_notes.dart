part of '../meeting_detail_view.dart';

/// "Notlar" with "Not Ekle" and the notes under it (pano 10.5 kare 3, 10.6
/// kare 4). The title is 20/28 · 700 and "Not Ekle" is the text button with
/// the Plus on its right; while the notes load or failed the button is off
/// (a note's position is not known).
class _NotesSection
    extends SelectorViewModelWidget<MeetingDetailViewModel, MeetingNotesData> {
  const _NotesSection();

  @override
  MeetingNotesData selector(MeetingDetailViewModel viewModel) =>
      viewModel.notes;

  @override
  Widget build(BuildContext context, MeetingNotesData data) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<MeetingDetailViewModel>(
      context,
      listen: false,
    );
    final writable =
        data.state == SectionState.ready || data.state == SectionState.empty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.coachMeetings_notesTitle,
          actionLabel: l10n.coachMeetings_noteAdd,
          actionIcon: PhosphorIconsRegular.plus,
          onAction: writable ? () => unawaited(viewModel.addNote()) : null,
        ),
        switch (data.state) {
          SectionState.loading => const _NotesSkeleton(),
          SectionState.error || SectionState.offline => const _NotesError(),
          SectionState.empty => AppEmptyState.section(
            message: l10n.coachMeetings_notesEmpty,
          ),
          SectionState.ready => _NoteCards(notes: data.notes),
        },
      ],
    );
  }
}

/// The note cards, 8 apart.
class _NoteCards extends StatelessWidget {
  const _NoteCards({required this.notes});

  final List<MeetingNote> notes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, note) in notes.indexed) ...[
          if (i > 0) const SizedBox(height: AppSpacing.s8),
          _NoteCard(key: ValueKey(note.index), note: note),
        ],
      ],
    );
  }
}

/// One note (pano 10.6 "Not kartı"): the text at 16/26, and under it the text
/// buttons "Düzenle" (pencil) and "Sil" (trash, `error`), 40 high, 4 apart.
class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, super.key});

  final MeetingNote note;

  /// Card padding: 16, but the buttons' 4 pt invisible margin already holds
  /// part of the bottom edge.
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    AppSpacing.s16,
    AppSpacing.s16,
    AppSpacing.s16,
    AppSpacing.s8,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final viewModel = getParentViewModel<MeetingDetailViewModel>(
      context,
      listen: false,
    );
    return AppCard(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.text,
            style: context.appText.bodyReading.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Row(
            children: [
              AppButton(
                label: l10n.coachMeetings_noteEdit,
                icon: PhosphorIconsRegular.pencilSimple,
                variant: AppButtonVariant.text,
                size: AppButtonSize.md40,
                onPressed: () => unawaited(viewModel.editNote(note)),
              ),
              const SizedBox(width: AppSpacing.s4),
              AppButton(
                label: l10n.coachMeetings_noteDelete,
                icon: PhosphorIconsRegular.trash,
                variant: AppButtonVariant.textDanger,
                size: AppButtonSize.md40,
                onPressed: () => unawaited(viewModel.deleteNote(note)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
