import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_state_level.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

/// The error state (C78 "ErrorState"; board 1.22 kare 4 and 5; UI guide §5
/// #29), at two levels. It says what failed and offers "Tekrar Dene"; it
/// never shows a raw error text or an inner code, and a failed load is never
/// an endless skeleton.
///
/// **screen** ("Analizin yüklenemedi"): a tab's content, centered, 32 pt
/// sides, 120 from the top: a 64 pt `errorBg` circle with a 32 pt
/// WarningCircle in `error`, the [title] 20/28 · 700 20 under it, the
/// [message] 15/24 `textSecondary` 8 under that ("Bağlantını kontrol edip
/// tekrar dene. Sorun sürerse biraz sonra yeniden açabilirsin.") and the
/// secondary (outlined) "Tekrar Dene" button with an ArrowClockwise, 24
/// under the text. Announced as an alert.
///
/// **section** ("Dersler yüklenemedi."): a card of 16 padding with a 24 pt
/// WarningCircle in `error`, the [message] 15/24 · 600 and a text button
/// "Tekrar Dene" with an 18 pt ArrowClockwise under it. It refreshes only
/// that section. With a [title] ("Programlar yüklenemedi", board 14.3 kare 2)
/// the title takes the 15/24 · 600 line and the [message] under it is the
/// plain 15/24 `textSecondary` sentence ("Bağlantını kontrol edip tekrar
/// dene."). No haptic at either level.
///
/// "Tekrar Dene" returns the owner to the skeleton (`AsyncSection.loading`);
/// a repeated failure keeps the same text.
class AppErrorState extends StatelessWidget {
  /// The screen-level block.
  const AppErrorState.screen({
    required String this.title,
    required this.message,
    required this.onRetry,
    this.retryLabel,
    this.topPadding = screenTopPadding,
    super.key,
  }) : level = AppStateLevel.screen;

  /// The section-level card.
  const AppErrorState.section({
    required this.message,
    required this.onRetry,
    this.title,
    this.retryLabel,
    super.key,
  }) : level = AppStateLevel.section,
       topPadding = 0;

  final AppStateLevel level;

  /// "Analizin yüklenemedi" (screen level); the optional bold first line of
  /// the section card ("Programlar yüklenemedi").
  final String? title;

  /// A short cause-and-next-step sentence, no inner code.
  final String message;

  /// "Tekrar Dene" (the shared `common_retry`) when null.
  final String? retryLabel;
  final VoidCallback onRetry;

  /// Space above the block: 120 in a tab.
  final double topPadding;

  /// Screen-level top padding (C78).
  static const double screenTopPadding = 120;

  /// The icon circle and its icon (screen level).
  static const double circle = 64;
  static const double circleIcon = 32;

  @override
  Widget build(BuildContext context) {
    return level == AppStateLevel.screen
        ? _ScreenError(state: this)
        : _SectionError(state: this);
  }
}

class _ScreenError extends StatelessWidget {
  const _ScreenError({required this.state});

  final AppErrorState state;

  /// Circle to title (C78: 20).
  static const double _titleGap = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
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
            ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.errorBg,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: AppErrorState.circle,
                  child: Center(
                    child: PhosphorIcon(
                      PhosphorIconsRegular.warningCircle,
                      size: AppErrorState.circleIcon,
                      color: colors.error,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: _titleGap),
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
            const SizedBox(height: AppSpacing.s24),
            AppButton(
              label: state.retryLabel ?? l10n.common_retry,
              icon: PhosphorIconsRegular.arrowClockwise,
              variant: AppButtonVariant.outline,
              onPressed: state.onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.state});

  final AppErrorState state;

  /// Icon size and its gap to the text.
  static const double _icon = 24;

  /// Card bottom padding: the 48 pt button already holds 12 of the 16.
  static const double _bottom = AppSpacing.s4;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s16,
          AppSpacing.s16,
          _bottom,
        ),
        child: Semantics(
          container: true,
          liveRegion: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: PhosphorIcon(
                  PhosphorIconsRegular.warningCircle,
                  size: _icon,
                  color: colors.error,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.s4),
                      child: Text(
                        state.title ?? state.message,
                        style: text.bodyStrong.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    if (state.title != null)
                      Text(
                        state.message,
                        style: text.body.copyWith(color: colors.textSecondary),
                      ),
                    const SizedBox(height: AppSpacing.s4),
                    AlignedTextAction(
                      child: AppButton(
                        label: state.retryLabel ?? l10n.common_retry,
                        icon: PhosphorIconsRegular.arrowClockwise,
                        variant: AppButtonVariant.text,
                        size: AppButtonSize.md40,
                        onPressed: state.onRetry,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
