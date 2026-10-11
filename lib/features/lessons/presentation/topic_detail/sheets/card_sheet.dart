import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/features/lessons/presentation/topic_detail/sheets/card_sheet_viewmodel.dart';
import 'package:smap/features/lessons/presentation/widgets/eksik_tag.dart';
import 'package:smap/features/lessons/presentation/widgets/example_box.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/sheets/app_confirm_sheet.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// What the card sheet returned: "Öğrendim" was pressed (and confirmed) and
/// whether "Bir daha sorma" was checked.
@immutable
class CardSheetResult {
  const CardSheetResult({this.dontAskAgain = false});

  /// The confirmation's box was checked: the device stops asking.
  final bool dontAskAgain;

  /// "Öğrendim" is the only thing the sheet returns.
  bool get learned => true;
}

/// The card sheet of an item (C53 "CardSheet"; pano 7.3 kare 3, 7.6; spec §4.F
/// 7.3).
///
/// A small sheet. The head: "Türkçe · Sözcükte Anlam" 13/20 · 600
/// `textSecondary`, the item's name 20/28 · 700 2 below, and at the right the
/// star (Star 22, filled when favorite; "Favorilere ekle") and the close
/// button. The body (12 down, 24 at the sides): the amber "Eksik" tag while
/// the card is missing, the definition 16/26 (12 below the tag) and the
/// example box (12 below). The primary "Öğrendim" is there only while the
/// card is missing; the first press asks once "Kartı Bildiklerim'e
/// taşıyalım mı?" with "Bir daha sorma" (pano 8.1 kare 2), then the sheet
/// closes with a [CardSheetResult] and the ViewModel that opened it sends the
/// card. The star is sent by [onFavorite] and flips back if it fails.
class CardSheet extends StatelessWidget {
  const CardSheet({
    required this.item,
    required this.contextLine,
    required this.askConfirm,
    required this.onFavorite,
    super.key,
  });

  final ItemView item;

  /// "Türkçe · Sözcükte Anlam".
  final String Function(AppLocalizations l10n) contextLine;

  /// The first "Öğrendim" asks for a confirmation.
  final bool askConfirm;

  /// Sends the star; answers whether it was saved.
  final Future<bool> Function(bool favorite) onFavorite;

  /// Opens the sheet; completes with the result of "Öğrendim", or `null`.
  static Future<CardSheetResult?> show({
    required ItemView item,
    required String Function(AppLocalizations l10n) contextLine,
    required bool askConfirm,
    required Future<bool> Function(bool favorite) onFavorite,
    BuildContext? context,
  }) => AppSheet.show<CardSheetResult>(
    context: context,
    builder: (_) => CardSheet(
      item: item,
      contextLine: contextLine,
      askConfirm: askConfirm,
      onFavorite: onFavorite,
    ),
  );

  /// Space between the tag and the definition, and the definition and the
  /// example box (pano 7.3 kare 3).
  static const double _gap = AppSpacing.s12;

  /// Space between two definition paragraphs.
  static const double _paragraphGap = AppSpacing.s8;

  Future<void> _learn(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    var dontAsk = false;
    if (askConfirm) {
      final answer = await AppConfirmSheet.show(
        context: context,
        title: l10n.cardSheet_confirmTitle,
        message: l10n.cardSheet_confirmBody(item.name),
        confirmLabel: l10n.cardSheet_learned,
        dontAskAgainLabel: l10n.cardSheet_dontAsk,
      );
      if (!answer.confirmed) return;
      dontAsk = answer.dontAskAgain;
    }
    if (!context.mounted) return;
    Navigator.of(context).pop(CardSheetResult(dontAskAgain: dontAsk));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return ViewModelBuilder<CardSheetViewModel>.reactive(
      viewModelBuilder: () => CardSheetViewModel(
        isFavorite: item.isFavorite,
        canFavorite: item.canFavorite,
        onFavorite: onFavorite,
      ),
      builder: (context, viewModel, _) => AppSheetFrame(
        semanticLabel: item.name,
        showClose: false,
        header: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s24,
            AppSpacing.s12,
            AppSpacing.s12,
            0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contextLine(l10n),
                        style: text.caption.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Semantics(
                        header: true,
                        child: Text(
                          item.name,
                          style: text.titleMd.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (viewModel.canFavorite)
                AppIconButton(
                  icon: PhosphorIconsRegular.star,
                  selectedIcon: PhosphorIconsFill.star,
                  selected: viewModel.isFavorite,
                  iconSize: 22,
                  color: viewModel.isFavorite
                      ? colors.primary
                      : colors.borderControl,
                  focusGapColor: colors.bgRaised,
                  semanticLabel: viewModel.isFavorite
                      ? l10n.cards_favoriteRemove
                      : l10n.cards_favoriteAdd,
                  onPressed: viewModel.toggleFavorite,
                ),
              AppIconButton(
                icon: PhosphorIconsRegular.x,
                semanticLabel: l10n.common_close,
                variant: AppIconButtonVariant.close,
                focusGapColor: colors.bgRaised,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
        bodyPadding: const EdgeInsets.fromLTRB(
          AppSpacing.s24,
          AppSpacing.s12,
          AppSpacing.s24,
          0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.isMissing)
              const Align(
                alignment: AlignmentDirectional.centerStart,
                child: EksikTag(),
              ),
            if (item.text.definition.isNotEmpty) ...[
              if (item.isMissing) const SizedBox(height: _gap),
              for (final (index, paragraph)
                  in item.text.definition.indexed) ...[
                if (index > 0) const SizedBox(height: _paragraphGap),
                Text(
                  paragraph,
                  style: text.bodyReading.copyWith(color: colors.textPrimary),
                ),
              ],
            ],
            for (final example in item.text.examples) ...[
              const SizedBox(height: _gap),
              ExampleBox(
                example: example.text,
                explanation: example.explanation,
                onSheet: true,
              ),
            ],
          ],
        ),
        primary: item.canLearn
            ? AppSheetAction(
                label: l10n.cardSheet_learned,
                onPressed: () => _learn(context),
              )
            : null,
      ),
    );
  }
}
