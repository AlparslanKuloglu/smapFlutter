part of 'week_grid.dart';

/// The grid's measures at the user's text scale: the board's sizes (hour
/// column 44, day column 84, hour row 40, header 44, block 36) times the text
/// scale, so a topic block, a header and an hour label keep the room their
/// text needs and are never cut (text scale 1,3 rule). The scale stops at
/// [maxScale]; the grid's own text is held to the same limit, the blocks stay
/// readable as buttons through their semantics label.
class WeekGridMetrics {
  const WeekGridMetrics(this.scale);

  /// The scale the grid grows to at most.
  static const double maxScale = 1.5;

  /// The metrics for the text scale of [context].
  factory WeekGridMetrics.of(BuildContext context) =>
      WeekGridMetrics.forTextScale(
        MediaQuery.textScalerOf(context).scale(16) / 16,
      );

  /// The metrics for a text scale factor: never below the board's sizes (1)
  /// and never above [maxScale].
  factory WeekGridMetrics.forTextScale(double factor) =>
      WeekGridMetrics(factor.clamp(1.0, maxScale));

  final double scale;

  double get hourColumn => WeekGrid.hourColumn * scale;
  double get dayColumn => WeekGrid.dayColumn * scale;
  double get hourRow => WeekGrid.hourRow * scale;
  double get headerRow => WeekGrid.headerRow * scale;
  double get blockHeight => WeekGrid.blockHeight * scale;
  double get blockInsetX => WeekGrid._blockInsetX * scale;
  double get blockInsetY => WeekGrid._blockInsetY * scale;
  double get glyph => 14 * scale;
}

// The pieces of the week grid (C63): a day header, the hour column, the line
// painter and a block.

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.metrics,
    required this.day,
    required this.today,
  });

  final WeekGridMetrics metrics;
  final DateTime day;
  final bool today;

  /// The bar under today's number (C63: 32 x 3).
  static const double _barWidth = 32;
  static const double _barHeight = 3;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return SizedBox(
      width: metrics.dayColumn,
      height: metrics.headerRow,
      child: Semantics(
        header: true,
        label: TrFormat.uzunTarihGun(day),
        excludeSemantics: true,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TrFormat.gunKisa(day),
                  maxLines: 1,
                  style: text.caption.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${day.day}',
                  maxLines: 1,
                  style: text.labelMd.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 20 / 15,
                  ),
                ),
              ],
            ),
            if (today)
              Positioned(
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.accentLine,
                    borderRadius: AppRadius.borderXs,
                  ),
                  child: const SizedBox(width: _barWidth, height: _barHeight),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HourColumn extends StatelessWidget {
  const _HourColumn({required this.range, required this.metrics});

  final HourRange range;
  final WeekGridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return ExcludeSemantics(
      child: ColoredBox(
        color: colors.bgCanvas,
        child: Column(
          children: [
            for (final hour in range.hours)
              SizedBox(
                height: metrics.hourRow,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.s4),
                    child: Text(
                      TrFormat.saatParcali(hour),
                      maxLines: 1,
                      style: text.caption.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GridLinePainter extends CustomPainter {
  const _GridLinePainter({
    required this.metrics,
    required this.color,
    required this.rows,
    required this.columns,
  });

  final WeekGridMetrics metrics;
  final Color color;
  final int rows;
  final int columns;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var row = 0; row <= rows; row++) {
      final y = row * metrics.hourRow;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (var column = 0; column <= columns; column++) {
      final x = column * metrics.dayColumn;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_GridLinePainter old) =>
      old.metrics.scale != metrics.scale ||
      old.color != color ||
      old.rows != rows ||
      old.columns != columns;
}

class _Block extends StatelessWidget {
  const _Block({
    required this.metrics,
    required this.entry,
    required this.onTap,
  });

  final WeekGridMetrics metrics;
  final ProgramEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final subject = entry.subject;
    final SubjectTone? tone = subject == null
        ? null
        : context.appSubject(subject);
    final SmapColors c = colors;
    final fill = tone?.bg ?? c.bgSunken;
    final accent = tone?.fg ?? c.textSecondary;
    final icon = subject == null ? subjectFallbackIcon : subjectIcons[subject]!;

    return Semantics(
      button: onTap != null,
      onTap: onTap,
      label: l10n.schedule_weekBlockA11y(
        TrFormat.gunAdi(entry.day),
        entry.timeLabel,
        entry.shortLesson,
        entry.title,
      ),
      excludeSemantics: true,
      child: AppPressable(
        onTap: onTap,
        builder: (context, states) => AppFocusRing(
          focused: states.contains(WidgetState.focused),
          borderRadius: AppRadius.borderSm,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: AppRadius.borderSm,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: ClipRect(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PhosphorIcon(icon, size: metrics.glyph, color: accent),
                    // A long name ("Matematik", "Coğrafya") shrinks a little
                    // instead of ending in "…": the block has no other line.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        entry.shortLesson,
                        maxLines: 1,
                        softWrap: false,
                        style: text.caption.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                          height: 16 / 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
