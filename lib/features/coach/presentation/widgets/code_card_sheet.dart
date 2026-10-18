import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/coach/presentation/widgets/code_card.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/app_state_level.dart';
import 'package:smap/shared/ui/text/metric_text.dart';

/// What the code box of the sheet shows (pano 14.11 kare 2, 4 and 5).
enum CodeCardPhase {
  /// The code is on its way: a skeleton bar, the buttons are off (kare 4).
  loading,

  /// The code is there (kare 2, 3 and 6).
  ready,

  /// The code could not be loaded: the section error inside the card, the
  /// buttons are off (kare 5).
  error,
}

/// The body of the coaching code sheet (C35 `CodeCard` sheet hâli; pano 14.11
/// kare 2 to 6): the framed code box with the code centered in `metricMd`
/// (24/32 · 700, 1 pt letter spacing), the explanation [paragraphs] under it
/// (the first 15/24 `textPrimary`, the rest 13/20 `textSecondary`), the
/// optional [note] ("Kod cihazında saklı; ...") and the two outlined buttons
/// "Kopyala" and "Paylaş" of equal weight, 12 apart.
///
/// The box is 1 pt `borderSubtle`, `bgSurface`, radius 16, padding 20 / 16, the
/// one card with an edge. [CodeCardPhase.loading] draws a skeleton bar in it;
/// [CodeCardPhase.error] draws the section error ([errorTitle], [errorMessage]
/// and "Tekrar Dene" calling [onRetry]); both switch the buttons off. The code
/// reads as [spokenCode] ("Koçluk kodun M O Z K tire 4 8 2 1"). The copy
/// words come from the caller; the screen's sheet frame supplies the title,
/// the close button and the bottom space.
class CodeCardSheetBody extends StatelessWidget {
  const CodeCardSheetBody({
    required this.phase,
    required this.paragraphs,
    required this.onCopy,
    required this.onShare,
    this.code,
    this.spokenCode,
    this.note,
    this.errorTitle,
    this.errorMessage,
    this.onRetry,
    this.loadingLabel,
    super.key,
  });

  final CodeCardPhase phase;

  /// The code, `MOZK-4821` (ready).
  final String? code;

  /// What the screen reader says for the code.
  final String? spokenCode;

  /// The explanation: the first paragraph is the main line, the others are
  /// quiet.
  final List<String> paragraphs;

  /// A quiet line under the paragraphs ("Kod cihazında saklı; ...").
  final String? note;

  /// "Kodun yüklenemedi." (error).
  final String? errorTitle;

  /// "Bağlantını kontrol edip tekrar dene." (error).
  final String? errorMessage;

  /// "Tekrar Dene" (error).
  final VoidCallback? onRetry;

  /// The skeleton's reading ("Kod yükleniyor").
  final String? loadingLabel;

  /// "Kopyala".
  final VoidCallback onCopy;

  /// "Paylaş"; gets the button's rectangle for the iPad popover.
  final ValueChanged<Rect?> onShare;

  /// Space between the blocks (pano 14.11: 14).
  static const double _gap = 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final ready = phase == CodeCardPhase.ready;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CodeBox(
          phase: phase,
          code: code,
          spokenCode: spokenCode,
          errorTitle: errorTitle,
          errorMessage: errorMessage,
          onRetry: onRetry,
          loadingLabel: loadingLabel,
        ),
        for (final (i, paragraph) in paragraphs.indexed) ...[
          const SizedBox(height: _gap),
          Text(
            paragraph,
            style: i == 0
                ? text.body.copyWith(color: colors.textPrimary)
                : text.caption.copyWith(color: colors.textSecondary),
          ),
        ],
        if (note case final line?) ...[
          const SizedBox(height: AppSpacing.s8),
          Text(line, style: text.caption.copyWith(color: colors.textSecondary)),
        ],
        const SizedBox(height: AppSpacing.s16),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: l10n.coachWidgets_codeCopy,
                onPressed: ready ? onCopy : null,
                variant: AppButtonVariant.outline,
                icon: PhosphorIconsRegular.copy,
                expand: true,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Builder(
                builder: (buttonContext) => AppButton(
                  label: l10n.coachWidgets_codeShare,
                  onPressed: ready
                      ? () => onShare(CodeCard.originOf(buttonContext))
                      : null,
                  variant: AppButtonVariant.outline,
                  icon: PhosphorIconsRegular.shareNetwork,
                  expand: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The framed code box of [CodeCardSheetBody] in the look of its phase.
class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.phase,
    this.code,
    this.spokenCode,
    this.errorTitle,
    this.errorMessage,
    this.onRetry,
    this.loadingLabel,
  });

  final CodeCardPhase phase;
  final String? code;
  final String? spokenCode;
  final String? errorTitle;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String? loadingLabel;

  /// The box's padding (pano 14.11: 20 / 16).
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    vertical: 20,
    horizontal: AppSpacing.s16,
  );

  /// The skeleton bar of the code (pano 14.11 kare 4).
  static const double _barWidth = 120;
  static const double _barHeight = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final Widget inside;
    switch (phase) {
      case CodeCardPhase.error:
        inside = _CodeError(
          title: errorTitle ?? '',
          message: errorMessage ?? '',
          onRetry: onRetry,
        );
      case CodeCardPhase.loading:
        inside = Padding(
          padding: _padding,
          child: Center(
            child: AppSkeleton(
              semanticLabel: loadingLabel,
              child: const SkeletonBox(width: _barWidth, height: _barHeight),
            ),
          ),
        );
      case CodeCardPhase.ready:
        inside = Padding(
          padding: _padding,
          child: Semantics(
            label: spokenCode,
            excludeSemantics: spokenCode != null,
            child: Text(
              code ?? '',
              textAlign: TextAlign.center,
              style: MetricSize.md
                  .styleOf(text)
                  .copyWith(
                    letterSpacing: CodeCard.codeSpacing,
                    color: colors.textPrimary,
                  ),
            ),
          ),
        );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: inside,
    );
  }
}

/// The section error inside the code box (pano 14.11 kare 5; 1.22 pattern): a
/// 24 pt WarningCircle in `error`, the bold title "Kodun yüklenemedi.", the
/// plain `textSecondary` message and the text button "Tekrar Dene". A live
/// region. No second card: the box's own frame is the card.
class _CodeError extends StatelessWidget {
  const _CodeError({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  /// The box's padding (16; the 48 pt button already holds 12 of the bottom).
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    AppSpacing.s16,
    AppSpacing.s16,
    AppSpacing.s16,
    AppSpacing.s4,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: _padding,
      child: Semantics(
        container: true,
        liveRegion: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: PhosphorIcon(
                PhosphorIconsRegular.warningCircle,
                size: AppSize.icon,
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
                      title,
                      style: text.bodyStrong.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    message,
                    style: text.body.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  AlignedTextAction(
                    child: AppButton(
                      label: l10n.common_retry,
                      variant: AppButtonVariant.text,
                      size: AppButtonSize.md40,
                      onPressed: onRetry,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
