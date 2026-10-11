import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';

/// The strip under a coach's student screens that says whose data this is
/// (C83 `SmapContextStrip`; pano 1.18 kare 6, 10.4; UI guide §5 #34).
///
/// 40 high (more at large text), `bgContext` with a 1 pt `borderSubtle` line
/// on top and bottom, 16 side padding. A 24 pt avatar, 8 pt, then
/// "Alparslan Kuloğlu'nun verileri" (13/20 · 600; the name gets its Turkish
/// genitive suffix from `TurkishSuffix`), and on the right [detail], "12.
/// Sınıf · EA" (13/20, `textSecondary`). The field abbreviations are SAY, EA,
/// SÖZ and DİL; the screen composes the string.
///
/// Read as one phrase: "Alparslan Kuloğlu'nun verileri, 12. sınıf, Eşit
/// Ağırlık" ([detailSemantics] is the spoken form of [detail]).
///
/// It stays with the bar when the page scrolls: put it in a
/// `PinnedHeaderSliver` right after the `AppDetailBar`; the content moves 40
/// down. A box, not a sliver, so a screen that shows it conditionally can
/// place it anywhere.
class AppContextStrip extends StatelessWidget {
  const AppContextStrip({
    required this.student,
    this.detail,
    this.detailSemantics,
    super.key,
  });

  /// Whose data is shown.
  final StudentRef student;

  /// The visible class and field, "12. Sınıf · EA".
  final String? detail;

  /// The spoken form of [detail], "12. sınıf, Eşit Ağırlık"; [detail] when
  /// null.
  final String? detailSemantics;

  /// Height at text scale 1 (C83).
  static const double height = 40;

  /// Avatar edge.
  static const double avatarSize = AppAvatarSize.xs;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final title = l10n.nav_contextStripTitle(
      TurkishSuffix.genitive(student.name),
    );
    final spoken = detailSemantics ?? detail;
    final label = spoken == null
        ? title
        : l10n.nav_contextStripA11y(title, spoken);
    final line = BorderSide(color: colors.borderSubtle);

    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.bgContext,
          border: Border(top: line, bottom: line),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: height),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.gutter,
              vertical: AppSpacing.s4,
            ),
            child: Row(
              children: [
                AppAvatar(
                  name: student.name,
                  image: student.avatar,
                  size: avatarSize,
                  decorative: true,
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                if (detail case final trailing?) ...[
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    trailing,
                    maxLines: 1,
                    style: text.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
