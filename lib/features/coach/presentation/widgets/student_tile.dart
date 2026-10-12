import 'package:flutter/material.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

/// A student of the coach's strip (C32 `StudentTile`; Tur 9 G3; pano 10.1 kare
/// 1: "Alparslan Kuloğlu" with "Son deneme 5 Eki.").
///
/// A 108 pt wide card (wider with large text, [widthOf]) (radius 16, padding 14, no edge, no shadow), content
/// left-aligned and 8 apart: the 48 pt [AppAvatar], the [name] in 15/20 · 600
/// (two lines at most) and, only when [lastExam] is known, "Son deneme 5 Eki."
/// in 13/20 `textSecondary`. The strip puts 8 between tiles and 16 at the
/// sides; the tile itself is one button that opens the student's profile.
///
/// The last exam date is not in the student document yet (spec §6.3 #29), so
/// the coach home passes none today and the line is not drawn. Read as the
/// name, plus "son deneme 5 Eki." when there is a date.
class StudentTile extends StatelessWidget {
  const StudentTile({
    required this.name,
    this.avatar,
    this.lastExam,
    this.onTap,
    super.key,
  });

  /// "Alparslan Kuloğlu".
  final String name;

  /// The student's picture; initials when null.
  final ImageProvider? avatar;

  /// When the last exam was read; the line is left out when null.
  final DateTime? lastExam;

  /// Opens the student's profile.
  final VoidCallback? onTap;

  /// The tile's width (C32): 108 at the normal text size.
  static const double width = 108;

  /// The width at the reader's text size: the tile grows with the text so a
  /// first name still fits a line at scale 1,3 instead of breaking in the
  /// middle of the word.
  static double widthOf(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(width);

  /// The tile's padding (C32: 14).
  static const double padding = 14;

  /// The name's 15/20 line (a `bodyStrong` with the board's tighter line).
  static const double _nameHeight = 20 / 15;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final date = lastExam;
    final dateText = date == null ? null : TrFormat.kisaTarih(date);
    return SizedBox(
      width: widthOf(context),
      child: AppCard(
        padding: const EdgeInsets.all(padding),
        onTap: onTap,
        semanticLabel: dateText == null
            ? l10n.coachWidgets_tileA11y(name)
            : l10n.coachWidgets_tileA11yLastExam(name, dateText),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(
                name: name,
                image: avatar,
                size: AppAvatarSize.tile,
                decorative: true,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.bodyStrong.copyWith(
                  height: _nameHeight,
                  color: colors.textPrimary,
                ),
              ),
              if (dateText != null) ...[
                const SizedBox(height: AppSpacing.s8),
                Text(
                  l10n.coachWidgets_tileLastExam(dateText),
                  style: text.caption.copyWith(color: colors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
