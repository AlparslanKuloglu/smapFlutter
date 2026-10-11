import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_state_level.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

/// The empty state (C77 "EmptyState"; board 1.22 kare 3 and 4; UI guide §5
/// #29), at two levels.
///
/// **screen** ("Henüz deneme yok"): centered, 32 pt side padding, an optional
/// 128 pt [illustration] (a clay picture of the 1.25 set: Harita, Ampul,
/// Hokka, the subject's picture; at most one per screen, skipped by the
/// screen reader), the [title] 20/28 · 700 24 pt under it, one [message]
/// sentence 15/24 `textSecondary` 8 under the title, and at most one primary
/// action ("İlk Denemeni Okut"), 24 under the text. Without an
/// [illustration] nothing is drawn in its place and the block starts with the
/// title: no placeholder art. The screen reader starts reading at the title
/// and the block is a live region.
///
/// **section** ("Bugün için programında konu yok."): a card with 16 padding
/// holding one [message] sentence and a text button ("Haftalık Programını
/// Kur"); the rest of the screen keeps working.
///
/// Empty means the answer was empty, never "not loaded" (that is the
/// skeleton) and never "failed" (that is `AppErrorState`).
class AppEmptyState extends StatelessWidget {
  /// The screen-level block.
  const AppEmptyState.screen({
    required String this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.illustration,
    this.topPadding = AppSpacing.s64,
    super.key,
  }) : level = AppStateLevel.screen;

  /// The section-level card.
  const AppEmptyState.section({
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : level = AppStateLevel.section,
       title = null,
       actionIcon = null,
       illustration = null,
       topPadding = 0;

  final AppStateLevel level;

  /// "Henüz deneme yok" (screen level only).
  final String? title;

  /// One sentence: what is missing and what will fill it.
  final String message;

  /// The one action ("İlk Denemeni Okut"); null draws none.
  final String? actionLabel;
  final VoidCallback? onAction;

  /// A Phosphor icon in front of the primary label (screen level).
  final IconData? actionIcon;

  /// The clay picture, drawn 128 x 128 (screen level). Null leaves the area
  /// empty.
  final Widget? illustration;

  /// Space above the block: 64 in a tab, 88 on a full screen (1.25).
  final double topPadding;

  /// Edge of the picture.
  static const double illustrationSize = 128;

  @override
  Widget build(BuildContext context) {
    return level == AppStateLevel.screen
        ? _ScreenEmpty(state: this)
        : _SectionEmpty(state: this);
  }
}

class _ScreenEmpty extends StatelessWidget {
  const _ScreenEmpty({required this.state});

  final AppEmptyState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final action = state.actionLabel;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s32,
        state.topPadding,
        AppSpacing.s32,
        0,
      ),
      child: Semantics(
        container: true,
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.illustration case final picture?) ...[
              ExcludeSemantics(
                child: SizedBox.square(
                  dimension: AppEmptyState.illustrationSize,
                  child: picture,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
            ],
            Semantics(
              header: true,
              child: Text(
                state.title ?? '',
                textAlign: TextAlign.center,
                style: text.titleMd.copyWith(color: colors.textPrimary),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: text.body.copyWith(color: colors.textSecondary),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.s24),
              AppButton(
                label: action,
                icon: state.actionIcon,
                onPressed: state.onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.state});

  final AppEmptyState state;

  /// Card bottom padding: the 48 pt button already holds 12 of the 16.
  static const double _bottom = AppSpacing.s4;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final action = state.actionLabel;
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s16,
          AppSpacing.s16,
          action == null ? AppSpacing.s16 : _bottom,
        ),
        child: Semantics(
          container: true,
          liveRegion: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.message,
                style: text.body.copyWith(color: colors.textSecondary),
              ),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.s4),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AlignedTextAction(
                    child: AppButton(
                      label: action,
                      variant: AppButtonVariant.text,
                      size: AppButtonSize.md40,
                      onPressed: state.onAction,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
