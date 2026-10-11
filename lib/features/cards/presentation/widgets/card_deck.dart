import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;

import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/features/cards/application/deck_swipe.dart';
import 'package:smap/features/cards/presentation/widgets/info_card_face.dart';
import 'package:smap/l10n/app_localizations.dart';

/// Draws the card on top of a [CardDeck]; [dragging] is true while it moves
/// (the face adds its shadow then).
typedef DeckFaceBuilder = Widget Function(BuildContext context, bool dragging);

/// Lets a screen move the top card of a [CardDeck] by itself: "Öğrendim"
/// sends the card out to the right, the way a finger would.
class CardDeckController {
  _CardDeckState? _state;

  /// A deck is showing.
  bool get attached => _state != null;

  /// Sends the top card out toward [exit] and completes when it has gone
  /// (250 ms, exit curve; a 150 ms fade under "Reduce motion"). It does not
  /// call `onExit`: the caller changes the cards itself afterwards. Completes
  /// at once when no deck is showing.
  Future<void> exitFront(DeckExit exit) async => _state?._leave(exit);
}

/// The card deck (C52 "CardDeck"; pano 8.1 "Kart Destesi · 4 Kare", 8.2 koyu;
/// spec §4.G): the top card with up to two cards behind it.
///
/// The top card follows the finger sideways. On release it leaves when it was
/// dragged past 30 % of its width or flung faster than 800 px/s
/// ([DeckSwipe.verdict]), in 250 ms on the exit curve, and the card behind it
/// comes forward as it goes (scale 0,933 to 1, opacity 0,75 to 1); otherwise
/// it springs back. **A swipe only goes on to the next card**, it never learns
/// one: [onExit] tells the screen which way the card went, and the screen
/// moves its cards on. The shadow shows only while the card is dragged (the
/// face's [DeckFaceBuilder] gets `dragging`).
///
/// Behind the top card (cut to the top card's height, the face is the real next
/// card): [next] is the card right behind it, at rest 12 pt in from each side
/// at 75 % opacity; [behind] is the number of cards behind the top one: with
/// two or more a bare [InfoCardBackEdge] shows 12 pt below the top card, 24
/// in from each side, at 50 %. Under "Reduce motion" the card does not follow
/// the finger and does not slide: it fades out in 150 ms while the next one
/// fades in.
///
/// [frontKey] identifies the top card: when it changes the deck is at rest on
/// the new card. [canSwipe] is false with a single card (it stays still). The
/// top card carries the screen-reader actions "Sonraki kart" and "Önceki kart"
/// ([onNext], [onPrevious]).
class CardDeck extends StatefulWidget {
  const CardDeck({
    required this.frontKey,
    required this.front,
    required this.behind,
    required this.canSwipe,
    required this.onExit,
    required this.onNext,
    required this.onPrevious,
    required this.controller,
    this.next,
    super.key,
  });

  /// The key of the card on top.
  final Object frontKey;

  /// The face of the card on top.
  final DeckFaceBuilder front;

  /// The face of the card right behind the top one; `null` with no card behind.
  final Widget? next;

  /// How many cards are behind the top one, 0 to 2.
  final int behind;

  /// The cards can be moved (more than one is in the deck).
  final bool canSwipe;

  /// The top card was swiped away toward the given side.
  final ValueChanged<DeckExit> onExit;

  /// "Sonraki kart" for a screen reader.
  final VoidCallback onNext;

  /// "Önceki kart" for a screen reader.
  final VoidCallback onPrevious;

  final CardDeckController controller;

  /// How far the first card behind sits in from each side and below the top
  /// one, at rest (12; pano 8.1: left/right 28 against 16).
  static const double _inset = AppSpacing.s12;

  /// The distance the card leaves beyond the screen edge.
  static const double _beyondEdge = AppSpacing.s32;

  @override
  State<CardDeck> createState() => _CardDeckState();
}

class _CardDeckState extends State<CardDeck>
    with SingleTickerProviderStateMixin {
  /// The top card's horizontal offset.
  final ValueNotifier<double> _offset = ValueNotifier<double>(0);

  /// The top card's opacity (1 except while it fades under "Reduce motion").
  final ValueNotifier<double> _fade = ValueNotifier<double>(1);

  /// How far the cards behind have come forward: 0 at rest, 1 once the top
  /// card has left (slid out, or faded out under "Reduce motion").
  final ValueNotifier<double> _reveal = ValueNotifier<double>(0);

  late final AnimationController _anim = AnimationController(vsync: this);
  double _drag = 0;
  double _width = 0;
  bool _moving = false;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
    _offset.addListener(_syncReveal);
    _fade.addListener(_syncReveal);
  }

  void _syncReveal() {
    final slid = DeckSwipe.reveal(dx: _offset.value, width: _width);
    final faded = 1 - _fade.value;
    _reveal.value = slid > faded ? slid : faded;
  }

  @override
  void didUpdateWidget(CardDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._state = null;
      widget.controller._state = this;
    }
    if (oldWidget.frontKey != widget.frontKey) _rest();
  }

  @override
  void dispose() {
    if (widget.controller._state == this) widget.controller._state = null;
    _anim.dispose();
    _offset.dispose();
    _fade.dispose();
    _reveal.dispose();
    super.dispose();
  }

  /// The deck is at rest on its card.
  void _rest() {
    _anim.stop();
    _offset.value = 0;
    _fade.value = 1;
    _drag = 0;
    _moving = false;
  }

  /// Runs [apply] from 0 to 1 over [duration] on [curve]; completes when done
  /// (or when the deck is gone).
  Future<void> _run(
    Duration duration,
    Curve curve,
    ValueChanged<double> apply,
  ) async {
    final curved = CurvedAnimation(parent: _anim, curve: curve);
    void tick() => apply(curved.value);
    curved.addListener(tick);
    _anim.duration = duration;
    try {
      await _anim.forward(from: 0).orCancel;
    } on TickerCanceled {
      // The deck went away or came to rest on another card.
    } finally {
      curved.removeListener(tick);
      curved.dispose();
    }
  }

  Future<void> _leave(DeckExit exit) async {
    if (_moving || !mounted) return;
    _moving = true;
    final key = widget.frontKey;
    if (context.reduceMotion) {
      await _run(AppMotion.reducedFade, AppMotion.linear, (t) {
        _fade.value = 1 - t;
      });
    } else {
      final from = _offset.value;
      final to =
          exit.sign * (MediaQuery.sizeOf(context).width + CardDeck._beyondEdge);
      await _run(AppMotion.base, AppMotion.exit, (t) {
        _offset.value = from + (to - from) * t;
      });
    }
    if (!mounted) return;
    // The screen changes its cards right after this (before the next frame).
    // If it did not (it refused the move), the card comes back.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _moving && widget.frontKey == key) _rest();
    });
  }

  Future<void> _springBack() async {
    final from = _offset.value;
    if (from == 0) return;
    _moving = true;
    await _run(AppMotion.base, AppMotion.standard, (t) {
      _offset.value = from * (1 - t);
    });
    _moving = false;
  }

  void _dragStart(DragStartDetails details) {
    if (_moving || !widget.canSwipe) return;
    _drag = 0;
  }

  void _dragUpdate(DragUpdateDetails details) {
    if (_moving || !widget.canSwipe) return;
    _drag += details.delta.dx;
    if (!context.reduceMotion) _offset.value = _drag;
  }

  Future<void> _dragEnd(DragEndDetails details) async {
    if (_moving || !widget.canSwipe) return;
    final verdict = DeckSwipe.verdict(
      dx: _drag,
      velocityX: details.velocity.pixelsPerSecond.dx,
      width: _width,
    );
    _drag = 0;
    if (verdict == null) {
      await _springBack();
      return;
    }
    await _leave(verdict);
    if (mounted) widget.onExit(verdict);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (widget.behind >= 2)
              Positioned.fill(
                child: ExcludeSemantics(
                  child: _Behind(
                    depth: 2,
                    reveal: _reveal,
                    width: _width,
                    child: const InfoCardBackEdge(depth: 2),
                  ),
                ),
              ),
            if (widget.behind >= 1 && widget.next != null)
              Positioned.fill(
                child: ExcludeSemantics(
                  child: _Behind(
                    depth: 1,
                    reveal: _reveal,
                    width: _width,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topCenter,
                        maxHeight: double.infinity,
                        child: widget.next,
                      ),
                    ),
                  ),
                ),
              ),
            Semantics(
              customSemanticsActions: {
                if (widget.canSwipe) ...{
                  CustomSemanticsAction(label: l10n.cardDeck_nextA11y):
                      widget.onNext,
                  CustomSemanticsAction(label: l10n.cardDeck_previousA11y):
                      widget.onPrevious,
                },
              },
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onHorizontalDragStart: _dragStart,
                onHorizontalDragUpdate: _dragUpdate,
                onHorizontalDragEnd: _dragEnd,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_offset, _fade]),
                  builder: (context, _) => Opacity(
                    opacity: _fade.value,
                    child: Transform.translate(
                      offset: Offset(_offset.value, 0),
                      child: widget.front(context, _offset.value != 0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A card behind the top one: it sits [depth] steps back (12 in from each side
/// per step; the second step also 12 lower than the top card) and moves up one
/// step, to the place of the card in front of it, as the top card leaves.
///
/// Its width is the top card's width scaled down, anchored at the bottom: the
/// cards behind keep their bottom edge, so only the second one peeks out under
/// the top card.
class _Behind extends StatelessWidget {
  const _Behind({
    required this.depth,
    required this.reveal,
    required this.width,
    required this.child,
  });

  final int depth;
  final ValueListenable<double> reveal;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: reveal,
      child: child,
      builder: (context, r, child) {
        // Steps behind the top card right now: 1 or 2 at rest, one less when
        // the top card has gone.
        final back = depth - r;
        final scale = width <= 0 ? 1.0 : 1 - 2 * CardDeck._inset * back / width;
        // Only the card at the second step sits lower; it comes up as it
        // moves forward.
        final drop = CardDeck._inset * (back - 1).clamp(0.0, 1.0);
        // The first card behind is a real card, drawn at 75 %; it reaches full
        // opacity as it takes the top. The second is a bare edge that carries
        // its own opacity.
        final opacity = depth == 1 ? 0.75 + 0.25 * r : 1.0;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, drop),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
