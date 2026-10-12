part of 'app_home_band.dart';

class _GreetingRow extends StatelessWidget {
  const _GreetingRow({required this.band, required this.progress});

  final AppHomeBand band;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final greeting = Semantics(
      header: true,
      child: Text(
        AppHomeBand.greetingText(l10n, band.name),
        maxLines: HomeBandMetrics.greetingMaxLines(progress),
        overflow: TextOverflow.ellipsis,
        style: TextStyle.lerp(
          text.titleMd,
          text.headline,
          progress,
        )!.copyWith(color: colors.textOnNavy),
      ),
    );
    final counter = band.counter;
    final compact = counter == null || band.role != AppHomeBandRole.student
        ? null
        : l10n.nav_homeCounterCompact(TrFormat.sira(counter.daysLeft));

    return Row(
      children: [
        AppAvatar(
          name: band.avatarName ?? band.name,
          image: band.avatar,
          size: HomeBandMetrics.avatarAt(progress),
          decorative: true,
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          // The text block is laid out at its own height and centered in the
          // row; the band clips it, so a shrinking row never shows an
          // overflow while the greeting goes from two lines to one.
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            minHeight: 0,
            maxHeight: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                greeting,
                if (band.role == AppHomeBandRole.coach)
                  ClipRect(
                    child: Align(
                      alignment: Alignment.topLeft,
                      heightFactor: HomeBandMetrics.openContentOpacity(
                        progress,
                      ),
                      child: Opacity(
                        opacity: HomeBandMetrics.openContentOpacity(progress),
                        child: _CoachSummary(
                          line: AppHomeBand.coachLine(
                            l10n,
                            band.studentCount,
                            band.upcomingMeetings,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (compact != null)
          ClipRect(
            child: Align(
              alignment: Alignment.centerRight,
              widthFactor: HomeBandMetrics.collapsedCounterWidthFactor(
                progress,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.s8),
                child: ExcludeSemantics(
                  child: Opacity(
                    opacity: HomeBandMetrics.collapsedContentOpacity(progress),
                    child: Text(
                      compact,
                      maxLines: 1,
                      softWrap: false,
                      style: text.caption
                          .copyWith(fontWeight: FontWeight.w600)
                          .copyWith(color: colors.textOnNavy2),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CoachSummary extends StatelessWidget {
  const _CoachSummary({required this.line});

  final String? line;

  @override
  Widget build(BuildContext context) {
    final text = line;
    if (text == null) return const SizedBox.shrink();
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: context.appText.caption.copyWith(
        color: context.appColors.textOnNavy2,
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({required this.counter});

  final AppHomeCounter counter;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final days = TrFormat.sira(counter.daysLeft);
    final date = TrFormat.uzunTarihGun(counter.examDate);
    return Semantics(
      label: l10n.nav_homeCounterA11y(days, date),
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MetricText(
            value: days,
            size: MetricSize.lg,
            color: colors.textOnNavy,
          ),
          const SizedBox(width: AppSpacing.s12),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.nav_homeCounterUnit,
                    style: text.bodyStrong.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textOnNavy,
                    ),
                  ),
                  Text(
                    l10n.nav_homeCounterExam(date),
                    style: text.caption.copyWith(color: colors.textOnNavy2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
