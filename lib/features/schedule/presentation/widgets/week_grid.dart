import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_icons.dart';
import 'package:smap/features/schedule/application/hour_range.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/week_grid_layout.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/controls/clear_color.dart';
import 'package:smap/shared/ui/pickers/calendar_math.dart';

part 'week_grid_parts.dart';

/// The weekly grid (C63 "WeekGrid"; Tur 6 G5; pano 3.4 kare 4, 3.7, 3.8 dark):
/// the hours of a program down the side, its days across, a block where a
/// topic is planned.
///
/// - **Measures**: hour column 44, day column 84, hour row 40, header row 44
///   (and the block height 36), all times the text scale up to 1,5
///   ([WeekGridMetrics]); the grid's own text is held to that limit.
///   Lines are 1 pt (`bgSunken` in light, `borderSubtle` in dark); the hour
///   labels are 13/20 · 600 `textSecondary`.
/// - **Header**: the weekday (13/20 · 600) over the day number (15/20 · 700);
///   under today's a 32 x 3 `accentLine` bar.
/// - **Blocks**: 36 high, radius 8, in the lesson's tint, a 14 pt glyph over
///   the short lesson name (13/16 · 700 in the lesson accent: the one place a
///   subject color is text). No topic name: it shows when the block is
///   tapped ([onOpenEntry], the topic detail). Topics less than 54 minutes
///   apart share the column side by side.
/// - **Scrolling**: the grid scrolls both ways inside its own box; the header
///   stays on top while the rows scroll and the hour column stays at the left
///   while the days scroll, with a 12 pt `bgCanvas` fade over the days'
///   left edge once they have scrolled. It opens with today's column third
///   among the visible columns and the earliest topic in view. Give it a
///   bounded height (the screen fills the rest of the page with it).
/// - **Hours**: 06:00 to 23:00, wider when a stored topic lies outside.
///
/// Read as one grid ("Haftalık program, 06:00–23:00; Pazartesi–Çarşamba
/// solda") whose blocks are buttons ("Cumartesi 10:00, Türkçe, Fiilde Çatı").
class WeekGrid extends StatefulWidget {
  const WeekGrid({
    required this.days,
    required this.entries,
    required this.today,
    required this.onOpenEntry,
    this.bottomPadding = 0,
    super.key,
  });

  /// The day columns, oldest first.
  final List<DateTime> days;

  /// Every entry of the program; the grid picks each column's own.
  final List<ProgramEntry> entries;

  /// The day with the orange bar.
  final DateTime today;

  /// A block was tapped; null entries cannot be opened (the block is still
  /// drawn, as a plain element).
  final ValueChanged<ProgramEntry>? onOpenEntry;

  /// Room under the last row (the bottom bar's height).
  final double bottomPadding;

  /// Column and row sizes (C63).
  static const double hourColumn = 44;
  static const double dayColumn = 84;
  static const double hourRow = 40;
  static const double headerRow = 44;

  /// Block height and its inset inside a row and a column (C63: 78 x 36 in an
  /// 84 x 40 cell).
  static const double blockHeight = 36;
  static const double _blockInsetY = 2;
  static const double _blockInsetX = 3;

  /// Width of the fade at the days' left edge (C63).
  static const double edgeFade = 12;

  @override
  State<WeekGrid> createState() => _WeekGridState();
}

class _WeekGridState extends State<WeekGrid> {
  final ScrollController _days = ScrollController();
  final ScrollController _header = ScrollController();
  final ScrollController _rows = ScrollController();
  final ValueNotifier<bool> _scrolledSideways = ValueNotifier<bool>(false);
  int _visibleColumns = 1;
  bool _positioned = false;

  @override
  void initState() {
    super.initState();
    _days.addListener(_followDays);
  }

  @override
  void dispose() {
    _days
      ..removeListener(_followDays)
      ..dispose();
    _header.dispose();
    _rows.dispose();
    _scrolledSideways.dispose();
    super.dispose();
  }

  /// The header row follows the day columns.
  void _followDays() {
    _scrolledSideways.value = _days.hasClients && _days.offset > 0.5;
    if (!_header.hasClients || !_days.hasClients) return;
    final target = _days.offset.clamp(0.0, _header.position.maxScrollExtent);
    if ((_header.offset - target).abs() > 0.1) _header.jumpTo(target);
  }

  /// Opens on today's column and the earliest topic, once the first layout
  /// has told how many columns fit. No animation: it is placement, not motion.
  void _openOnce(HourRange range, WeekGridMetrics m) {
    if (_positioned) return;
    _positioned = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final column = WeekGridLayout.firstVisibleColumn(
        days: widget.days,
        focus: _focus,
        visibleColumns: _visibleColumns,
      );
      final row = WeekGridLayout.firstVisibleRow(
        entries: widget.entries,
        range: range,
      );
      if (_days.hasClients) {
        _days.jumpTo(
          math.min(column * m.dayColumn, _days.position.maxScrollExtent),
        );
      }
      if (_rows.hasClients) {
        _rows.jumpTo(math.min(row * m.hourRow, _rows.position.maxScrollExtent));
      }
    });
  }

  DateTime get _focus => WeekGridLayout.focusDay(
    days: widget.days,
    today: widget.today,
    entries: widget.entries,
  );

  String _hiddenLeft(AppLocalizations l10n) {
    final column = WeekGridLayout.firstVisibleColumn(
      days: widget.days,
      focus: _focus,
      visibleColumns: _visibleColumns,
    );
    if (column <= 0) return '';
    final first = TrFormat.gunAdi(widget.days.first);
    final last = TrFormat.gunAdi(widget.days[column - 1]);
    return l10n.schedule_weekGridHiddenLeft(
      column == 1 ? first : '$first–$last',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final dark = Theme.brightnessOf(context) == Brightness.dark;
    final m = WeekGridMetrics.of(context);
    final range = HourRange.of(widget.entries);
    final line = dark ? colors.borderSubtle : colors.bgSunken;
    final columns = widget.days.length;
    final bodyHeight = range.rows * m.hourRow;
    final bodyWidth = columns * m.dayColumn;

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: WeekGridMetrics.maxScale,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _visibleColumns = math.max(
            1,
            ((constraints.maxWidth - m.hourColumn) / m.dayColumn).floor(),
          );
          _openOnce(range, m);
          final hours =
              '${TrFormat.saatParcali(range.first)}–'
              '${TrFormat.saatParcali(range.last)}';
          final hidden = _hiddenLeft(l10n);
          final label = [
            l10n.schedule_weekGridA11y(hours),
            if (hidden.isNotEmpty) hidden,
          ].join('; ');

          return Semantics(
            container: true,
            label: label,
            explicitChildNodes: true,
            child: Column(
              children: [
                SizedBox(
                  height: m.headerRow,
                  child: Row(
                    children: [
                      SizedBox(width: m.hourColumn),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _header,
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          child: Row(
                            children: [
                              for (final day in widget.days)
                                _DayHeader(
                                  metrics: m,
                                  day: day,
                                  today: CalendarMath.sameDay(
                                    day,
                                    widget.today,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _rows,
                    padding: EdgeInsets.only(bottom: widget.bottomPadding),
                    child: SizedBox(
                      height: bodyHeight,
                      child: Stack(
                        children: [
                          Positioned(
                            left: m.hourColumn,
                            top: 0,
                            right: 0,
                            bottom: 0,
                            child: SingleChildScrollView(
                              controller: _days,
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: bodyWidth,
                                height: bodyHeight,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _GridLinePainter(
                                          metrics: m,
                                          color: line,
                                          rows: range.rows,
                                          columns: columns,
                                        ),
                                      ),
                                    ),
                                    for (var i = 0; i < columns; i++)
                                      ..._blocksOfColumn(
                                        context,
                                        m,
                                        widget.days[i],
                                        i,
                                        range,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: m.hourColumn,
                            child: _HourColumn(range: range, metrics: m),
                          ),
                          Positioned(
                            left: m.hourColumn,
                            top: 0,
                            bottom: 0,
                            width: WeekGrid.edgeFade,
                            child: IgnorePointer(
                              child: ValueListenableBuilder<bool>(
                                valueListenable: _scrolledSideways,
                                builder: (context, scrolled, _) =>
                                    AnimatedOpacity(
                                      opacity: scrolled ? 1 : 0,
                                      duration: context.motion(
                                        AppMotion.fast,
                                        reduced: AppMotion.reducedFade,
                                      ),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              colors.bgCanvas,
                                              colors.bgCanvas.clear,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _blocksOfColumn(
    BuildContext context,
    WeekGridMetrics m,
    DateTime day,
    int column,
    HourRange range,
  ) {
    final dayEntries = [
      for (final entry in widget.entries)
        if (CalendarMath.sameDay(entry.day, day)) entry,
    ];
    final blocks = WeekGridLayout.blocksOf(dayEntries);
    final open = widget.onOpenEntry;
    final inner = m.dayColumn - 2 * m.blockInsetX;
    return [
      for (final block in blocks)
        Positioned(
          left:
              column * m.dayColumn +
              m.blockInsetX +
              block.lane * inner / block.lanes,
          top:
              (block.entry.minutes - range.first * 60) * m.hourRow / 60 +
              m.blockInsetY,
          width: inner / block.lanes,
          height: m.blockHeight,
          child: _Block(
            metrics: m,
            entry: block.entry,
            onTap: open == null || !block.entry.canOpenTopic
                ? null
                : () => open(block.entry),
          ),
        ),
    ];
  }
}
