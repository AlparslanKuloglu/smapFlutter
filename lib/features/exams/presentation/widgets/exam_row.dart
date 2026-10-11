import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/presentation/widgets/dyb_counter.dart';
import 'package:smap/features/exams/presentation/widgets/exam_cover.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/controls/app_tag.dart';
import 'package:smap/shared/ui/surfaces/app_row_shell.dart';

/// One exam in the list of "Denemelerim" (C24 "ExamRow"; pano 1.16 "Deneme
/// kartı · liste", screens 6.2 and 10.4; the list form of the 1.16 card).
///
/// Padding 12 / 16, items aligned to the top, 12 apart. Left to right: the
/// 40 x 54 [ExamCover]; the text column; the net; the favorite star.
///
/// - Text column: the exam name 16/24 · 600 (wraps, never cut); 4 under it the
///   type [AppTag] ("AYT") and the short date 13 `textSecondary` ("5 Eki.
///   2026", 8 apart); when the data has it, the publisher ("Örnek
///   Yayınları") on its own line, 4 under (Ek D-32: publisher and name on
///   separate lines); 6 under that the small lettered D/Y/B counter. Fields
///   without data are not drawn.
/// - Net: 24/32 · 700 · −0,4 with "net" 13 · 600 `textSecondary` under it,
///   right aligned: "67,5".
/// - Favorite: an [AppIconButton] with a 48 pt target, Star 20 in
///   `borderControl`, Star Fill in `primary` when set. The favorite is kept on
///   the device only and is low emphasis; it plays a selection haptic.
///
/// The row opens the exam detail. It is read as "Türkiye Geneli Deneme 6,
/// AYT, 5 Eki. 2026, 67,5 net"; the star is its own button ("Favorilere
/// ekle" / "Favorilerden çıkar").
class ExamRow extends StatelessWidget {
  const ExamRow({
    required this.name,
    required this.net,
    required this.counts,
    required this.date,
    required this.typeLabel,
    this.publisher,
    this.coverUrl,
    this.isFavorite = false,
    this.onFavoriteChanged,
    this.onTap,
    super.key,
  });

  final String name;

  /// The net from the server.
  final double net;
  final DybCounts counts;
  final DateTime date;

  /// "TYT" or "AYT".
  final String typeLabel;

  /// "Örnek Yayınları"; null when the data has none.
  final String? publisher;
  final String? coverUrl;
  final bool isFavorite;

  /// Receives the new favorite value; null hides the star.
  final ValueChanged<bool>? onFavoriteChanged;

  /// Opens the exam detail.
  final VoidCallback? onTap;

  /// Gap between the parts of the row.
  static const double _gap = AppSpacing.s12;

  /// Edge of the favorite star icon.
  static const double _starSize = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final dateText = TrFormat.kisaTarih(date, withYear: true);
    final netText = TrFormat.net(net);
    final favoriteChanged = onFavoriteChanged;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      button: onTap != null,
      onTap: onTap,
      label: l10n.exams_examRowA11y(name, typeLabel, dateText, netText),
      child: AppRowShell(
        onTap: onTap,
        padding: EdgeInsets.only(
          left: AppSpacing.s16,
          right: favoriteChanged == null ? AppSpacing.s16 : AppSpacing.s4,
          bottom: AppSpacing.s12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ExamCover.row(),
                    const SizedBox(width: _gap),
                    Expanded(
                      child: _ExamTexts(
                        name: name,
                        typeLabel: typeLabel,
                        dateText: dateText,
                        publisher: publisher,
                        counts: counts,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    _ExamNet(netText: netText),
                  ],
                ),
              ),
            ),
            if (favoriteChanged != null)
              AppIconButton(
                icon: PhosphorIconsRegular.star,
                selectedIcon: PhosphorIconsFill.star,
                selected: isFavorite,
                iconSize: _starSize,
                color: isFavorite ? colors.primary : colors.borderControl,
                semanticLabel: isFavorite
                    ? l10n.exams_favoriteRemove
                    : l10n.exams_favoriteAdd,
                onPressed: () {
                  AppHaptics.selection();
                  favoriteChanged(!isFavorite);
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// The name, type tag, date, publisher and counter of an [ExamRow].
class _ExamTexts extends StatelessWidget {
  const _ExamTexts({
    required this.name,
    required this.typeLabel,
    required this.dateText,
    required this.publisher,
    required this.counts,
  });

  final String name;
  final String typeLabel;
  final String dateText;
  final String? publisher;
  final DybCounts counts;

  /// Gap above the counter.
  static const double _counterGap = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final publisherName = publisher;
    final meta = text.caption.copyWith(color: colors.textSecondary);
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: text.titleSm.copyWith(color: colors.textPrimary)),
          const SizedBox(height: AppSpacing.s4),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppTag(label: typeLabel),
              Text(dateText, style: meta),
            ],
          ),
          if (publisherName != null) ...[
            const SizedBox(height: AppSpacing.s4),
            Text(publisherName, style: meta),
          ],
          const SizedBox(height: _counterGap),
          DybCounter(counts: counts),
        ],
      ),
    );
  }
}

/// The net of an [ExamRow]: the figure and "net" under it.
class _ExamNet extends StatelessWidget {
  const _ExamNet({required this.netText});

  final String netText;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            netText,
            style: text.metricMd.copyWith(color: colors.textPrimary),
          ),
          Text(
            AppLocalizations.of(context).exams_netUnit,
            style: text.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
