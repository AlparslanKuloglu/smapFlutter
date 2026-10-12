import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/coach/domain/interview_type.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/controls/app_tag.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';
import 'package:smap/shared/ui/surfaces/app_row_shell.dart';
import 'package:smap/shared/ui/text/metric_text.dart';

/// Which of the two looks of a meeting row (C34).
enum MeetingRowStyle {
  /// The coach home: a date block, a 36 pt avatar and "Pazartesi 16:00 ·
  /// Öğrenci" (pano 10.1).
  dateBlock,

  /// "Görüşmelerim": a 40 pt avatar, "12 Ekim 2026 Pazartesi · 16:00" and the
  /// kind as a tag (pano 10.5).
  list,
}

/// A meeting with a student or a parent (C34 `MeetingRow`; Kit 1.16 and Tur 9
/// G5; pano 10.1 and 10.5).
///
/// At least 64 high, padding 12 / 16, 12 between the parts, centred, ending in
/// CaretRight 20. The whole row is one button that opens the meeting.
///
/// - [MeetingRow.dateBlock]: the 44 pt wide date block (the day in `metricMd`
///   24/32 · 700, the month under it in 13/20 · 600 `textSecondary`: "12" /
///   "Eki."), the 36 pt avatar, the name (16/24 · 600) and the meta in 13/20
///   `textSecondary` ("Pazartesi 16:00 · Öğrenci"; the kind is left out when the
///   server did not say).
/// - [MeetingRow.list]: the 40 pt avatar, the name, the meta with the year
///   ("12 Ekim 2026 Pazartesi · 16:00") and, at the end, the [AppTag] "Öğrenci"
///   or "Veli".
///
/// Read as "Alparslan Kuloğlu, 12 Ekim 2026 Pazartesi, 16:00, Öğrenci
/// görüşmesi". The rows of a card are separated by the card, not here.
class MeetingRow extends StatelessWidget {
  const MeetingRow.dateBlock({
    required this.name,
    required this.date,
    this.type,
    this.avatar,
    this.onTap,
    super.key,
  }) : style = MeetingRowStyle.dateBlock;

  const MeetingRow.list({
    required this.name,
    required this.date,
    this.type,
    this.avatar,
    this.onTap,
    super.key,
  }) : style = MeetingRowStyle.list;

  final MeetingRowStyle style;

  /// With whom: "Alparslan Kuloğlu".
  final String name;

  /// When (local time).
  final DateTime date;

  /// Student or parent; `null` leaves the kind out.
  final InterviewType? type;

  /// The person's picture; initials when null.
  final ImageProvider? avatar;

  /// Opens the meeting.
  final VoidCallback? onTap;

  /// The row's minimum height (C34).
  static const double minHeight = 64;

  /// The date block's width (C34).
  static const double dateBlockWidth = 44;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final isList = style == MeetingRowStyle.list;
    final time = TrFormat.saat(date);
    final kind = switch (type) {
      InterviewType.student => l10n.coachWidgets_meetingStudent,
      InterviewType.parent => l10n.coachWidgets_meetingParent,
      null => null,
    };
    final meta = isList
        ? l10n.coachWidgets_meetingListMeta(TrFormat.uzunTarihGun(date), time)
        : kind == null
        ? l10n.coachWidgets_meetingMetaPlain(TrFormat.gunAdi(date), time)
        : l10n.coachWidgets_meetingMeta(TrFormat.gunAdi(date), time, kind);
    final kindA11y = switch (type) {
      InterviewType.student => l10n.coachWidgets_meetingKindStudentA11y,
      InterviewType.parent => l10n.coachWidgets_meetingKindParentA11y,
      null => null,
    };
    final label = kindA11y == null
        ? l10n.coachWidgets_meetingA11yPlain(
            name,
            TrFormat.uzunTarihGun(date),
            time,
          )
        : l10n.coachWidgets_meetingA11y(
            name,
            TrFormat.uzunTarihGun(date),
            time,
            kindA11y,
          );

    return Semantics(
      button: onTap != null,
      onTap: onTap,
      label: label,
      excludeSemantics: true,
      child: AppRowShell(
        onTap: onTap,
        minHeight: minHeight,
        child: Row(
          children: [
            if (!isList) ...[
              SizedBox(
                width: dateBlockWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MetricText(value: '${date.day}', size: MetricSize.md),
                    Text(
                      l10n.coachWidgets_meetingMonth(
                        TrFormat.monthsShort[date.month - 1],
                      ),
                      style: text.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
            ],
            AppAvatar(
              name: name,
              image: avatar,
              size: isList ? AppAvatarSize.md : AppAvatarSize.meeting,
              decorative: true,
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: text.titleSm.copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    meta,
                    style: text.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isList && kind != null) ...[
              const SizedBox(width: AppSpacing.s8),
              AppTag(label: kind),
            ],
            const SizedBox(width: AppSpacing.s8),
            PhosphorIcon(
              PhosphorIconsRegular.caretRight,
              size: AppSize.iconInButton,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
