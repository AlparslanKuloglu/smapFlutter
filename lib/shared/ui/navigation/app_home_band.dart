import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';
import 'package:smap/shared/ui/navigation/band_math.dart';
import 'package:smap/shared/ui/text/metric_text.dart';

/// The YKS countdown of the student home band: days left and the exam date.
///
/// The band only draws it; the home screen computes [daysLeft] on the device
/// (renewed at midnight, no network) from the exam date in `AppConfig`.
@immutable
class AppHomeCounter {
  const AppHomeCounter({required this.daysLeft, required this.examDate});

  /// Whole days until the exam; 0 or more.
  final int daysLeft;

  /// The exam day ("19 Haziran 2027 Cumartesi").
  final DateTime examDate;

  @override
  bool operator ==(Object other) =>
      other is AppHomeCounter &&
      other.daysLeft == daysLeft &&
      other.examDate == examDate;

  @override
  int get hashCode => Object.hash(daysLeft, examDate);
}

/// The greeting band of the home screen (C81 `SmapHomeBand(role: student |
/// coach)`; pano 3.1 kare 1 to 3, 10.1 kare 1 to 4; UI guide §5 #32).
///
/// A pinned sliver like `AppRootBand`, `bgNavy` with 24 bottom corners.
/// Padding 62 (safe area) / 16 / 20.
///
/// - [AppHomeBand.student]: a 40 pt avatar and "Merhaba, Alparslan" (20/28 ·
///   700, white); under them the counter row, aligned to the bottom: the
///   figure ("252", metric-lg), "gün kaldı" (15 · 700) and "YKS · 19 Haziran
///   2027 Cumartesi" (13, `textOnNavy2`). Read as one phrase: "YKS'ye 252 gün
///   kaldı. Sınav 19 Haziran 2027 Cumartesi." 194 high.
/// - [AppHomeBand.coach]: avatar, "Merhaba, Mehmet" and one line under it,
///   "5 öğrenci · önümüzdeki 7 günde 2 görüşme" ("Henüz öğrencin yok" without
///   students). No counter. 138 high.
///
/// While the page scrolls the band shrinks to 110: the avatar to 32, the
/// greeting to 17/24, the counter row fades out and the student gets the
/// one-line "YKS'ye 252 gün" (13 · 600) on the right. The corners go flat.
/// Pull-to-refresh belongs to the screen (`RefreshIndicator`); there is no
/// eyebrow and no gray sub line besides the ones above.
class AppHomeBand extends StatelessWidget {
  const AppHomeBand.student({
    required this.name,
    this.avatar,
    this.avatarName,
    this.counter,
    this.safeTop,
    super.key,
  }) : role = AppHomeBandRole.student,
       studentCount = null,
       upcomingMeetings = null;

  const AppHomeBand.coach({
    required this.name,
    this.avatar,
    this.avatarName,
    this.studentCount,
    this.upcomingMeetings,
    this.safeTop,
    super.key,
  }) : role = AppHomeBandRole.coach,
       counter = null;

  final AppHomeBandRole role;

  /// First name for the greeting ("Alparslan").
  final String name;

  /// The signed-in person's picture; initials when null.
  final ImageProvider? avatar;

  /// Name for the initials when [name] (a first name) is not enough.
  final String? avatarName;

  /// Student: the YKS counter; null draws no counter row.
  final AppHomeCounter? counter;

  /// Coach: number of students; null leaves the sub line out.
  final int? studentCount;

  /// Coach: meetings in the next seven days; null or 0 leaves that part out.
  final int? upcomingMeetings;

  /// Override for the top safe area (gallery frames).
  final double? safeTop;

  /// The coach sub line: "5 öğrenci · önümüzdeki 7 günde 2 görüşme", "Henüz
  /// öğrencin yok" without students, only the student count without a
  /// meeting count (the design gives no copy for zero meetings). Null when
  /// [students] is unknown.
  static String? coachLine(
    AppLocalizations l10n,
    int? students,
    int? meetings,
  ) {
    if (students == null) return null;
    if (students == 0) return l10n.nav_homeCoachNoStudents;
    final count = TrFormat.sira(students);
    if (meetings == null || meetings == 0) {
      return l10n.nav_homeCoachStudents(count);
    }
    return l10n.nav_homeCoachSummary(count, TrFormat.sira(meetings));
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final metrics = HomeBandMetrics(
      role: role,
      safeTop: safeTop ?? MediaQuery.paddingOf(context).top,
      hasCounter: counter != null,
      subtitleHeight: _measureSubtitle(context, scaler),
      textScaler: scaler,
    );
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HomeBandDelegate(band: this, metrics: metrics),
    );
  }
}

extension on AppHomeBand {
  /// Height of the coach sub line at the width it gets (up to two lines);
  /// null for a student and when there is no sub line.
  double? _measureSubtitle(BuildContext context, TextScaler scaler) {
    if (role != AppHomeBandRole.coach) return null;
    final line = AppHomeBand.coachLine(
      AppLocalizations.of(context),
      studentCount,
      upcomingMeetings,
    );
    if (line == null) return null;
    final width =
        MediaQuery.sizeOf(context).width -
        2 * AppSpacing.gutter -
        HomeBandMetrics.avatarOpen -
        AppSpacing.s12;
    final painter = TextPainter(
      text: TextSpan(text: line, style: context.appText.caption),
      textDirection: Directionality.of(context),
      textScaler: scaler,
      maxLines: 2,
    )..layout(maxWidth: width);
    final height = painter.height;
    painter.dispose();
    return height;
  }
}

class _HomeBandDelegate extends SliverPersistentHeaderDelegate {
  _HomeBandDelegate({required this.band, required this.metrics});

  final AppHomeBand band;
  final HomeBandMetrics metrics;

  @override
  double get maxExtent => metrics.maxExtent;

  @override
  double get minExtent => metrics.minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.band,
      child: _HomeBandSurface(
        band: band,
        metrics: metrics,
        progress: metrics.progressAt(shrinkOffset),
      ),
    );
  }

  @override
  bool shouldRebuild(_HomeBandDelegate oldDelegate) =>
      band.role != oldDelegate.band.role ||
      band.name != oldDelegate.band.name ||
      band.avatar != oldDelegate.band.avatar ||
      band.avatarName != oldDelegate.band.avatarName ||
      band.counter != oldDelegate.band.counter ||
      band.studentCount != oldDelegate.band.studentCount ||
      band.upcomingMeetings != oldDelegate.band.upcomingMeetings ||
      metrics.safeTop != oldDelegate.metrics.safeTop ||
      metrics.maxExtent != oldDelegate.metrics.maxExtent ||
      metrics.textScaler != oldDelegate.metrics.textScaler;
}

class _HomeBandSurface extends StatelessWidget {
  const _HomeBandSurface({
    required this.band,
    required this.metrics,
    required this.progress,
  });

  final AppHomeBand band;
  final HomeBandMetrics metrics;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final openOpacity = HomeBandMetrics.openContentOpacity(progress);
    final counter = band.counter;
    final rowHeight = BandMath.lerp(
      metrics.openRow,
      HomeBandMetrics.collapsedRow,
      progress,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgNavy,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(BandMath.lerp(AppRadius.xl, 0, progress)),
        ),
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minHeight: 0,
          maxHeight: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: metrics.safeTop),
                SizedBox(
                  height: rowHeight,
                  child: _GreetingRow(band: band, progress: progress),
                ),
                if (counter != null && band.role == AppHomeBandRole.student)
                  Opacity(
                    opacity: openOpacity,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: HomeBandMetrics.counterGap,
                      ),
                      child: _CounterRow(counter: counter),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
        l10n.nav_homeGreeting(band.name),
        maxLines: 1,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              greeting,
              if (band.role == AppHomeBandRole.coach)
                ClipRect(
                  child: Align(
                    alignment: Alignment.topLeft,
                    heightFactor: HomeBandMetrics.openContentOpacity(progress),
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
        if (compact != null)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.s8),
            child: ExcludeSemantics(
              child: Opacity(
                opacity: HomeBandMetrics.collapsedContentOpacity(progress),
                child: Text(
                  compact,
                  maxLines: 1,
                  style: text.caption
                      .copyWith(fontWeight: FontWeight.w600)
                      .copyWith(color: colors.textOnNavy2),
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
