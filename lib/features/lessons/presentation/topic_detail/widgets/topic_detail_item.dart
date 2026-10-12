part of '../topic_detail_view.dart';

/// One item (madde) of a sub-topic (C50 second level; pano 7.3): a divider
/// on top, the number in a 28 pt circle, the name 16/24 · 600, the amber
/// "Eksik" tag while its card is missing and the caret. Opening it (250 ms,
/// the caret turns) shows the definition 16/26, the example in its own box
/// and "Kartı Aç".
///
/// At least 56 high; the header padding is 12 / 8 / 12 / 16 and the body
/// 0 / 16 / 16 / 56, so the text starts under the name. A long name wraps and
/// is never cut. Read as "1. Temel Anlam, Eksik, genişletildi".
class _ItemTile extends StatefulWidget {
  const _ItemTile({
    required this.item,
    required this.initiallyOpen,
    required this.onOpenCard,
    super.key,
  });

  final ItemView item;
  final bool initiallyOpen;
  final VoidCallback onOpenCard;

  @override
  State<_ItemTile> createState() => _ItemTileState();
}

class _ItemTileState extends State<_ItemTile> {
  late bool _open = widget.initiallyOpen;

  /// The header's padding (pano 7.3: 12 / 8 / 12 / 16).
  static const EdgeInsets _headerPadding = EdgeInsets.fromLTRB(
    AppSpacing.s16,
    AppSpacing.s12,
    AppSpacing.s8,
    AppSpacing.s12,
  );

  /// The body's padding (pano 7.3: 0 / 16 / 16 / 56).
  static const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(
    _bodyInset,
    0,
    AppSpacing.s16,
    AppSpacing.s16,
  );

  /// Where the body's text starts: under the name (16 + 28 + 12).
  static const double _bodyInset = 56;

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final item = widget.item;
    final fast = context.motion(AppMotion.base, reduced: Duration.zero);
    final reading = [
      l10n.lessons_topicRowA11y(item.number, item.name),
      if (item.isMissing) l10n.lessons_missingItem,
    ].join(', ');
    return KeyedSubtree(
      key: _TopicAnchors.of(context, item.key),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(height: 1, thickness: 1, color: colors.bgSunken),
          Semantics(
            button: true,
            expanded: _open,
            label: reading,
            onTap: _toggle,
            child: ExcludeSemantics(
              child: InkWell(
                onTap: _toggle,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppSize.rowMin),
                  child: Padding(
                    padding: _headerPadding,
                    child: Row(
                      children: [
                        _NumberBadge(number: item.number),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(
                          child: Text(
                            item.name,
                            style: text.titleSm.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        if (item.isMissing) ...[
                          const SizedBox(width: AppSpacing.s8),
                          const EksikTag(),
                        ],
                        const SizedBox(width: AppSpacing.s8),
                        AnimatedRotation(
                          turns: _open ? 0.5 : 0,
                          duration: fast,
                          curve: AppMotion.standard,
                          child: PhosphorIcon(
                            PhosphorIconsRegular.caretDown,
                            size: AppSize.iconInButton,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: fast,
            curve: AppMotion.standard,
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: _bodyPadding,
                    child: _ItemBody(item: item, onOpenCard: widget.onOpenCard),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// The 28 pt number circle of an item (`bgSunken`, 13/28 · 700).
class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number});

  final int number;

  static const double _size = 28;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // The circle grows with the text (the line is 28 high at scale 1), so the
    // number stays inside it and centered at large text sizes.
    final size = MediaQuery.textScalerOf(context).scale(_size);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgSunken,
        borderRadius: AppRadius.borderFull,
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: Text(
            '$number',
            style: context.appText.caption.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              height: _size / 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// What an open item shows: the definition paragraphs 16/26, the example
/// boxes 12 below and, when the item has a card, "Kartı Aç" (Cards 20, pulled
/// 12 to the left so its label lines up with the text).
class _ItemBody extends StatelessWidget {
  const _ItemBody({required this.item, required this.onOpenCard});

  final ItemView item;
  final VoidCallback onOpenCard;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Its own node: without it the paragraphs merge into the sub-topic
        // card and a screen reader reads them before the item's title.
        if (item.text.definition.isNotEmpty)
          Semantics(
            container: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, paragraph)
                    in item.text.definition.indexed) ...[
                  if (index > 0) const SizedBox(height: AppSpacing.s8),
                  Text(
                    paragraph,
                    style: text.bodyReading.copyWith(color: colors.textPrimary),
                  ),
                ],
              ],
            ),
          ),
        for (final example in item.text.examples) ...[
          const SizedBox(height: AppSpacing.s12),
          ExampleBox(example: example.text, explanation: example.explanation),
        ],
        if (item.hasCard) ...[
          const SizedBox(height: AppSpacing.s8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AlignedTextAction(
              child: AppButton(
                label: l10n.topicDetail_openCard,
                icon: PhosphorIconsRegular.cards,
                variant: AppButtonVariant.text,
                size: AppButtonSize.md40,
                onPressed: onOpenCard,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
