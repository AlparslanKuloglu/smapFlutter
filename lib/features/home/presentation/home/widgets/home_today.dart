part of '../home_view.dart';

/// What "Bugün" reads: its state with the data, and today's date.
typedef _TodayData = (AsyncSection<TodaySummary>, DateTime);

/// "Bugün" (pano 3.1 kare 1 and 3, 3.2 kare 1 to 3): the topics planned for
/// today, saatiyle; tamamlama işareti yok (D-26).
///
/// - ready: "Bugün", "Cumartesi, 10 Ekim · Ekim 2. Hafta" and the one text
///   button "Programım", over a card of `ProgramItemRow`s (a row opens its
///   topic). A program with nothing today draws the header only: the board
///   has no copy for that day and nothing is made up.
/// - empty (no program at all, kare 3): only the date, no "Programım"; a
///   card with "Haftalık programın yok. …" and the text button "Haftalık
///   Programını Kur".
/// - loading: the skeleton; error or offline (kare 2): the header and the
///   section error card with "Tekrar Dene" that refreshes only this section.
class _TodaySection extends SelectorViewModelWidget<HomeViewModel, _TodayData> {
  const _TodaySection();

  @override
  _TodayData selector(HomeViewModel viewModel) =>
      (viewModel.today, viewModel.todayDate);

  @override
  Widget build(BuildContext context, _TodayData data) {
    final (section, day) = data;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<HomeViewModel>(context, listen: false);
    final date = l10n.home_todayDate(
      TrFormat.gunAdi(day),
      '${day.day}',
      TrFormat.months[day.month - 1],
    );
    switch (section.state) {
      case SectionState.loading:
        return const _TodaySkeleton();
      case SectionState.empty:
        return Padding(
          padding: _gutter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(title: l10n.home_today, meta: date),
              const _NoProgramCard(),
            ],
          ),
        );
      case SectionState.error:
      case SectionState.offline:
        return Padding(
          padding: _gutter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: l10n.home_today,
                meta: date,
                actionLabel: l10n.home_myProgram,
                onAction: () => _openProgram(context),
              ),
              AppErrorState.section(
                message: l10n.home_todayError,
                onRetry: viewModel.retryToday,
              ),
            ],
          ),
        );
      case SectionState.ready:
        final today = section.data!;
        final program = today.programName;
        return Padding(
          padding: _gutter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: l10n.home_today,
                meta: program == null
                    ? date
                    : l10n.home_todaySub(date, program),
                actionLabel: l10n.home_myProgram,
                onAction: () => _openProgram(context),
              ),
              if (today.rows.isNotEmpty) _TodayRows(rows: today.rows),
            ],
          ),
        );
    }
  }
}

/// The card with the day's rows (pano 3.1: radius 16, 1 pt rules between
/// rows).
class _TodayRows extends StatelessWidget {
  const _TodayRows({required this.rows});

  final List<TodayRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        children: [
          for (final (index, row) in rows.indexed) ...[
            if (index > 0)
              Divider(height: 1, thickness: 1, color: colors.bgSunken),
            ProgramItemRow(
              hour: row.hour,
              minute: row.minute,
              subjectName: row.subjectName,
              topic: row.topic,
              subject: row.subject,
              onTap: () => _openTopic(context, row),
            ),
          ],
        ],
      ),
    );
  }
}

/// The card of a student with no program (pano 3.1 kare 3: padding 16 16 8,
/// the sentence 15/24 and the text button pulled 12 to the left).
class _NoProgramCard extends StatelessWidget {
  const _NoProgramCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.home_noProgram,
            style: context.appText.body.copyWith(
              color: context.appColors.textPrimary,
            ),
          ),
          AlignedTextAction(
            child: AppButton(
              label: l10n.home_setupProgram,
              variant: AppButtonVariant.text,
              size: AppButtonSize.md40,
              onPressed: () => _openProgramSetup(context),
            ),
          ),
        ],
      ),
    );
  }
}
