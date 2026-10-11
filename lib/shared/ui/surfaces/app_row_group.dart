import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/surfaces/app_row.dart';

/// A titled group of rows on one rounded surface (C18 "ListGroup"; board 1.13;
/// UI guide §5 #14): `bgSurface`, radius 16, the content clipped, rows
/// divided by 1 pt `bgSunken` rules.
///
/// The rule between two rows starts where their text starts: 52 from the
/// left when the row has an icon, 16 otherwise ([AppRow.textInset]). The
/// optional [title] is a group heading above the card (13/20 · 600
/// `textSecondary`, 8 below it, 4 from the left) and read as a heading; the
/// optional [footer] is a note under it. Groups are 20 apart (the caller's
/// gap). A dangerous row (sign out) goes in a group of its own.
class AppRowGroup extends StatelessWidget {
  const AppRowGroup({
    required this.children,
    this.title,
    this.footer,
    super.key,
  });

  /// The rows; usually [AppRow]s.
  final List<Widget> children;

  /// "Hesap".
  final String? title;

  /// A note under the card.
  final String? footer;

  /// Left offset of a heading and a footer (C18: 4).
  static const double _headingInset = AppSpacing.s4;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final caption = context.appText.caption.copyWith(
      color: colors.textSecondary,
    );
    final stacked = <Widget>[];
    for (final (i, row) in children.indexed) {
      if (i > 0) {
        final inset = row is AppRow && row.hasLeading
            ? AppRow.textInset
            : AppSpacing.s16;
        stacked.add(
          Padding(
            padding: EdgeInsets.only(left: inset),
            child: Divider(height: 1, thickness: 1, color: colors.bgSunken),
          ),
        );
      }
      stacked.add(row);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title case final heading?)
          Padding(
            padding: const EdgeInsets.only(
              left: _headingInset,
              bottom: AppSpacing.s8,
            ),
            child: Semantics(
              header: true,
              child: Text(
                heading,
                style: caption.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: AppRadius.borderLg,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.borderLg,
            child: Column(mainAxisSize: MainAxisSize.min, children: stacked),
          ),
        ),
        if (footer case final note?)
          Padding(
            padding: const EdgeInsets.only(
              left: _headingInset,
              top: AppSpacing.s8,
            ),
            child: Text(note, style: caption),
          ),
      ],
    );
  }
}
