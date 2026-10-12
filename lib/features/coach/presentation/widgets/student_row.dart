import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';
import 'package:smap/shared/ui/surfaces/app_row_shell.dart';
import 'package:smap/shared/ui/text/highlight_text.dart';

/// The coach's student row (C31 `StudentRow`; pano 10.2 kare 1 and 2; Tur 9):
/// a 40 pt avatar, the name 16/24 · 600 and under it the meta line 13/20
/// `textSecondary` ("12. Sınıf · Eşit Ağırlık · 10 deneme"), and the arrow.
///
/// What the student has to say is at the right, only when there is something
/// to say: [lastNet] "67,5" 17/24 · 700 with [lastNetLabel] "son net" 13/20
/// under it. The student document has no last net yet (spec §6.3 #29), so the
/// list does not pass one today; a row without it draws no value and no label
/// (never "-" or "0").
///
/// The part of the name that the search matched is marked ([query], through
/// `HighlightText`: case and the Turkish marks are ignored). The row is a
/// `bgSurface` strip at least 64 high with 12 / 16 padding and 12 between the
/// parts; the rule between two rows is the list's. A long name wraps to a
/// second line, it is never cut.
///
/// Read as one button: [semanticLabel], "Alparslan Kuloğlu, 12. Sınıf, Eşit
/// Ağırlık, 10 deneme".
class StudentRow extends StatelessWidget {
  const StudentRow({
    required this.name,
    required this.semanticLabel,
    required this.onTap,
    this.query = '',
    this.avatar,
    this.meta,
    this.lastNet,
    this.lastNetLabel,
    super.key,
  });

  /// "Alparslan Kuloğlu".
  final String name;

  /// The reading of the whole row.
  final String semanticLabel;

  /// Null makes the row static.
  final VoidCallback? onTap;

  /// The search query; the matches in [name] are marked.
  final String query;

  /// The picture; the initials show when null or when it fails.
  final ImageProvider? avatar;

  /// "12. Sınıf · Eşit Ağırlık · 10 deneme"; none draws no line.
  final String? meta;

  /// The last exam's net as written ("67,5"); with [lastNetLabel] it fills
  /// the right side.
  final String? lastNet;

  /// "son net".
  final String? lastNetLabel;

  /// The row's least height (the board's CSS; the board text says 72, the
  /// content makes 68, spec §6 #5).
  static const double minHeight = 64;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final line = meta;
    final net = lastNet;
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: AppRowShell(
        onTap: onTap,
        minHeight: minHeight,
        child: Row(
          children: [
            AppAvatar(name: name, image: avatar, decorative: true),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  HighlightText(
                    text: name,
                    query: query,
                    style: text.titleSm.copyWith(color: colors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (line != null && line.isNotEmpty)
                    Text(
                      line,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.caption.copyWith(color: colors.textSecondary),
                    ),
                ],
              ),
            ),
            if (net != null && net.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.s12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    net,
                    style: text.headline.copyWith(color: colors.textPrimary),
                  ),
                  if (lastNetLabel case final label?)
                    Text(
                      label,
                      style: text.caption.copyWith(color: colors.textSecondary),
                    ),
                ],
              ),
            ],
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.s8),
              PhosphorIcon(
                PhosphorIconsRegular.caretRight,
                size: AppSize.iconInButton,
                color: colors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
