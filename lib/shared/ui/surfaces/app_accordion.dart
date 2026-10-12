import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';

/// How the open/closed state is drawn at the right of an accordion header.
enum AppAccordionIndicator {
  /// A 32 pt circle: `bgSunken` and `textPrimary` while open, bare and
  /// `textSecondary` while closed; CaretDown 18 (board 1.13 "Akordeon
  /// başlığı").
  circle,

  /// A bare CaretDown 24 in `textSecondary`, no circle (the test header of
  /// 5.4 and the topic rows of 7.3).
  plain,
}

/// The expanding section (C50 "Accordion"; board 1.13 "Akordeon başlığı"; Tur
/// 3, Tur 5 G4; UI guide §5 #15).
///
/// The whole header is the touch target. [title] is 16/24 · 600 and wraps
/// (never truncated); [summary] sits 6 below it (the small D/Y/B counters);
/// the indicator is at the right. The card is `bgSurface`, radius 16, 14 / 16
/// header padding and 12 between the parts.
///
/// Opening takes [AppMotion.base] (250 ms, standard curve) and the caret
/// turns 180 degrees; under "Reduce motion" it is immediate. When a section
/// opens it is scrolled into view with `Scrollable.ensureVisible` so its
/// body is not left below the fold (C50 "Hareket"). No haptic on open (the
/// guide reserves them for outcomes); pass [haptic] when a screen wants one.
///
/// Controlled with [expanded] and [onChanged], or uncontrolled with
/// [initiallyExpanded].
///
/// Screen reader: the header is one node that reads "title, summary,
/// daraltılmış" or "genişletilmiş" (button, with the expanded state). The summary
/// part is [summaryLabel] when given; otherwise the summary widget's own
/// semantics are merged in after the title. The body is its own container
/// node, and a closed body is not in the semantics tree.
class AppAccordion extends StatefulWidget {
  const AppAccordion({
    required this.title,
    required this.child,
    this.summary,
    this.summaryLabel,
    this.expanded,
    this.initiallyExpanded = false,
    this.onChanged,
    this.indicator = AppAccordionIndicator.circle,
    this.headerPadding = const EdgeInsets.fromLTRB(
      AppSpacing.s16,
      14,
      AppSpacing.s16,
      14,
    ),
    this.bodyPadding = const EdgeInsets.fromLTRB(
      AppSpacing.s16,
      0,
      AppSpacing.s16,
      AppSpacing.s16,
    ),
    this.titleStyle,
    this.card = true,
    this.scrollIntoView = true,
    this.haptic = false,
    this.focusGapColor,
    super.key,
  });

  /// "Türk Dili ve Edebiyatı-Sosyal Bilimler 1".
  final String title;

  /// The body, shown when open.
  final Widget child;

  /// A line under the title in the header (the small D/Y/B counters).
  final Widget? summary;

  /// What a screen reader says for [summary] ("4 madde, 1 eksik"). Give it
  /// when the summary is drawn from small parts that would read badly one by
  /// one; null leaves the summary widget's own semantics in the header
  /// reading.
  final String? summaryLabel;

  /// Non-null makes the accordion controlled.
  final bool? expanded;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onChanged;
  final AppAccordionIndicator indicator;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry bodyPadding;

  /// Overrides the 16/24 · 600 title (the 7.3 sub-topic uses 17/24 · 700).
  final TextStyle? titleStyle;

  /// Draws the `bgSurface` rounded card; false for a bare section in a row
  /// group.
  final bool card;

  /// Scrolls the opened section into view.
  final bool scrollIntoView;
  final bool haptic;
  final Color? focusGapColor;

  /// The circle indicator edge.
  static const double circle = 32;

  @override
  State<AppAccordion> createState() => _AppAccordionState();
}

class _AppAccordionState extends State<AppAccordion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _open = AnimationController(
    vsync: this,
    duration: AppMotion.base,
    value: _isExpanded(widget) ? 1 : 0,
  );
  late bool _inner = widget.initiallyExpanded;

  static bool _isExpanded(AppAccordion w) => w.expanded ?? w.initiallyExpanded;

  bool get _expanded => widget.expanded ?? _inner;

  @override
  void didUpdateWidget(AppAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != null && widget.expanded != oldWidget.expanded) {
      unawaited(_drive(widget.expanded!));
    }
  }

  @override
  void dispose() {
    _open.dispose();
    super.dispose();
  }

  Future<void> _drive(bool open) async {
    if (context.reduceMotion) {
      _open.value = open ? 1 : 0;
    } else {
      await (open ? _open.forward() : _open.reverse());
    }
    if (open && widget.scrollIntoView && mounted) _reveal();
  }

  void _reveal() {
    final box = context;
    if (!box.mounted || Scrollable.maybeOf(box) == null) return;
    unawaited(
      Scrollable.ensureVisible(
        box,
        duration: box.motion(AppMotion.base, reduced: Duration.zero),
        curve: AppMotion.standard,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      ),
    );
  }

  void _toggle() {
    final next = !_expanded;
    if (widget.haptic) AppHaptics.selection();
    if (widget.expanded == null) {
      setState(() => _inner = next);
      unawaited(_drive(next));
    }
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final expanded = _expanded;

    final l10n = AppLocalizations.of(context);
    final explicitSummary = widget.summaryLabel;
    final summary = widget.summary;
    final title = Text(
      widget.title,
      style: (widget.titleStyle ?? text.titleSm).copyWith(
        color: colors.textPrimary,
      ),
    );

    final header = Semantics(
      container: true,
      button: true,
      expanded: expanded,
      label: explicitSummary == null
          ? widget.title
          : '${widget.title}, $explicitSummary',
      value: expanded
          ? l10n.kit_a11yAccordionExpanded
          : l10n.kit_a11yAccordionCollapsed,
      child: AppPressable(
        onTap: _toggle,
        scale: 1,
        builder: (context, states) => AppFocusRing(
          focused: states.contains(WidgetState.focused),
          style: AppFocusRingStyle.inset,
          borderRadius: widget.card ? AppRadius.borderLg : BorderRadius.zero,
          child: Padding(
            padding: widget.headerPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The title is in the node's label already.
                      ExcludeSemantics(child: title),
                      if (summary != null) ...[
                        const SizedBox(height: 6),
                        // Read from the label when there is one; else the
                        // widget's own semantics join the header node.
                        if (explicitSummary != null)
                          ExcludeSemantics(child: summary)
                        else
                          summary,
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                ExcludeSemantics(
                  child: _Indicator(
                    kind: widget.indicator,
                    turns: _open,
                    open: expanded,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final body = AnimatedBuilder(
      animation: _open,
      builder: (context, child) {
        if (_open.isDismissed) return const SizedBox.shrink();
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: AppMotion.standard.transform(_open.value),
            child: child,
          ),
        );
      },
      child: Semantics(
        container: true,
        child: Padding(padding: widget.bodyPadding, child: widget.child),
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [header, body],
    );
    if (!widget.card) return content;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.borderLg,
      ),
      child: ClipRRect(borderRadius: AppRadius.borderLg, child: content),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    required this.kind,
    required this.turns,
    required this.open,
  });

  final AppAccordionIndicator kind;
  final Animation<double> turns;
  final bool open;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final circle = kind == AppAccordionIndicator.circle;
    final caret = RotationTransition(
      turns: Tween<double>(begin: 0, end: 0.5).animate(turns),
      child: PhosphorIcon(
        PhosphorIconsRegular.caretDown,
        size: circle ? 18 : AppSize.icon,
        color: circle && open ? colors.textPrimary : colors.textSecondary,
      ),
    );
    if (!circle) return caret;
    return AnimatedContainer(
      duration: context.motion(AppMotion.fast, reduced: AppMotion.fast),
      width: AppAccordion.circle,
      height: AppAccordion.circle,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: open ? colors.bgSunken : colors.bgSurface,
      ),
      child: caret,
    );
  }
}
