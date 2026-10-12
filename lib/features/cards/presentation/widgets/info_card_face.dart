import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_shadows.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/lessons/presentation/widgets/eksik_tag.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_glyph.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';

/// The face of a study card in the card deck (C52 "CardDeck" + "StudyCard";
/// pano 8.1 "Kart Destesi · 4 Kare", screen 7.3).
///
/// Only the card itself: the deck (swipe, the two edges behind, the "Detay" and
/// "Öğrendim" buttons, the progress) is built on it by the screen.
///
/// `bgSurface`, radius 24 (`AppRadius.xl`), padding 24, at least [minHeight]
/// high (392 in the board; the deck gives it a tight height). Top row: the 28
/// pt [SubjectGlyph] (glyph 15) and the subject name 13 · 700 (8 apart), and at
/// the right the favorite star (22, `borderControl`; Star Fill in `primary`
/// when set; a 48 pt target). Then the title 20/28 · 700 (20 below) and the
/// body 16/26 (12 below). At the bottom left, 24 / 20 from the edges, the
/// item-level [EksikTag] "Eksik", only on a card that is still missing;
/// "Bildiklerim" cards have none.
///
/// A card has no edge and no shadow, except while it is dragged: [dragging]
/// adds `shadow-overlay` (0 8 24). It is read as "Tarih, Edirne-Segedin
/// Antlaşması (1444), eksik" and the star is its own button.
class InfoCardFace extends StatelessWidget {
  const InfoCardFace({
    required this.subject,
    required this.subjectName,
    required this.title,
    this.body,
    this.isMissing = false,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.dragging = false,
    this.announce = false,
    this.minHeight = defaultMinHeight,
    super.key,
  });

  /// The subject color; null draws a neutral glyph tile.
  final SubjectKey? subject;

  /// "Tarih".
  final String subjectName;

  /// "Edirne-Segedin Antlaşması (1444)".
  final String title;

  /// The card text; null draws no body.
  final String? body;

  /// The card is in "Eksiklerim": the "Eksik" tag shows.
  final bool isMissing;
  final bool isFavorite;

  /// Toggles the favorite; null hides the star.
  final VoidCallback? onFavoriteTap;

  /// The card is being dragged: the shadow shows.
  final bool dragging;

  /// The card on top of a deck: a screen reader reads it again when it
  /// changes (live region), so "Sonraki kart" tells which card came.
  final bool announce;
  final double minHeight;

  /// The board's example height.
  static const double defaultMinHeight = 392;

  /// Padding of the face.
  static const double padding = AppSpacing.s24;

  /// Distance of the "Eksik" tag from the bottom edge (20; the side is the
  /// padding, 24).
  static const double _tagBottom = 20;

  /// The star's 48 pt target is placed so that the 22 pt icon meets the
  /// 24 pt padding: 13 pt of the target stick out of it on the right, and
  /// 14 pt above the top row's center line.
  static const double _starRight = 11;
  static const double _starTop = 14;

  /// Room kept free in the top row for the star.
  static const double _starRoom = 35;

  /// Gap under the title and under the body.
  static const double _titleGap = 20;
  static const double _bodyGap = AppSpacing.s12;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final bodyText = body;
    final reading = [
      subjectName,
      title,
      ?bodyText,
      if (isMissing) l10n.lessons_missingItem,
    ].where((part) => part.isNotEmpty).join(', ');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.borderXl,
        boxShadow: dragging ? AppShadows.overlayOf(context) : null,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Stack(
          children: [
            Semantics(
              container: true,
              liveRegion: announce,
              label: reading,
              excludeSemantics: true,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  padding,
                  padding,
                  padding,
                  isMissing ? _tagBottom + EksikTag.height + _bodyGap : padding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        SubjectGlyph(
                          subject: subject,
                          size: SubjectGlyphSize.card,
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Expanded(
                          child: Text(
                            subjectName,
                            style: text.caption.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (onFavoriteTap != null)
                          const SizedBox(width: _starRoom),
                      ],
                    ),
                    const SizedBox(height: _titleGap),
                    Text(
                      title,
                      style: text.titleMd.copyWith(color: colors.textPrimary),
                    ),
                    if (bodyText != null) ...[
                      const SizedBox(height: _bodyGap),
                      Text(
                        bodyText,
                        style: text.bodyReading.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (onFavoriteTap != null)
              Positioned(
                top: _starTop,
                right: _starRight,
                child: AppIconButton(
                  icon: PhosphorIconsRegular.star,
                  selectedIcon: PhosphorIconsFill.star,
                  selected: isFavorite,
                  iconSize: 22,
                  color: isFavorite ? colors.primary : colors.borderControl,
                  semanticLabel: isFavorite
                      ? l10n.cards_favoriteRemove
                      : l10n.cards_favoriteAdd,
                  onPressed: onFavoriteTap,
                ),
              ),
            if (isMissing)
              const Positioned(
                left: padding,
                bottom: _tagBottom,
                // Part of the card's reading above.
                child: ExcludeSemantics(child: EksikTag()),
              ),
          ],
        ),
      ),
    );
  }
}

/// A card edge showing behind the front card of the deck (C52; pano 8.1
/// "arkada iki kart kenarı").
///
/// The first card behind sits 12 pt lower and 12 pt in from each side at 75 %
/// opacity; the second 24 pt lower and 24 in at 50 %. It is a bare `bgSurface`
/// rounded shape without content, hidden from the screen reader. The deck
/// places it under the front card (for instance with a [Stack] and
/// [offset]); the face has no state of its own.
class InfoCardBackEdge extends StatelessWidget {
  const InfoCardBackEdge({required this.depth, super.key})
    : assert(depth == 1 || depth == 2);

  /// 1 for the card right behind the front card, 2 for the next one.
  final int depth;

  /// How far a card at [depth] sits below the front card and in from its
  /// sides: 12 at depth 1, 24 at depth 2.
  static double offset(int depth) => AppSpacing.s12 * depth;

  /// The opacity of a card at [depth]: 0,75 then 0,5.
  static double opacityOf(int depth) => depth == 1 ? 0.75 : 0.5;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Opacity(
        opacity: opacityOf(depth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.appColors.bgSurface,
            borderRadius: AppRadius.borderXl,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
