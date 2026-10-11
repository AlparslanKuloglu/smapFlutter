import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/controls/clear_color.dart';
import 'package:smap/shared/ui/sheets/sheet_layout.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

/// One action of the sheet's button band (C71 "Eylem alanı").
class AppSheetAction {
  const AppSheetAction({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.autofocus = false,
    this.disabledReason,
  });

  /// "Öğrenciyi Kaydet", "Vazgeç".
  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final IconData? trailingIcon;

  /// The spinner state of the button; a busy frame sets it on the primary.
  final bool loading;

  /// Takes the focus when the sheet opens (the "Vazgeç" of a dangerous
  /// confirmation).
  final bool autofocus;
  final String? disabledReason;
}

/// The one sheet frame (C71 "BottomSheet"; board 1.20 "Sheet Çerçevesi · 5
/// kare"; UI guide §5 #24).
///
/// Anatomy, top to bottom: the 36 x 4 handle 8 pt from the top
/// (`borderStrong`); the header, either [title] with an optional [subtitle]
/// and a "Kapat" close button (20/28 · 700 title, 15/24 `textSecondary`
/// subtitle, 24 left and 12 right padding) or a custom [header]; the
/// scrolling [body] (16/24 padding by default; the caller spaces its items 20
/// apart); and the fixed button band: [primary] on top, [secondary] under it
/// (a quiet "Vazgeç"), both full width, 12 apart, 16 above the first
/// button and the bottom safe area plus 8 below (16 while the keyboard is
/// open: the band rides directly above it). A 1 pt `borderSubtle` rule
/// appears over the band while the body is scrolled under it.
///
/// The surface is `bgRaised` (white; `#18263D` in dark), top corners 24, no
/// shadow (the scrim separates it).
///
/// **Busy** ([busy], board 1.20 kare 5): the close button is hidden, the
/// handle fades to `bgSunken`, the body is read only at 0,6 opacity, the
/// primary button shows its spinner, and drag, scrim and the Android back
/// gesture cannot close the sheet. After a failure the caller sets [busy] to
/// false and the sheet stays open with the input intact.
///
/// [onCloseAttempt] is for a sheet holding unsaved input: drag, scrim, back
/// and Kapat call it instead of closing ("Vazgeçilsin mi?"); close with
/// `Navigator.pop` afterwards.
///
/// The size (`small` fits, `medium` and `full` fill) comes from the
/// `AppSheet.show` that opened it. Read by the screen reader as a dialog
/// named after [title].
class AppSheetFrame extends StatefulWidget {
  const AppSheetFrame({
    required this.body,
    this.title,
    this.subtitle,
    this.header,
    this.showClose = true,
    this.primary,
    this.secondary,
    this.busy = false,
    this.bodyPadding = const EdgeInsets.fromLTRB(
      AppSpacing.s24,
      AppSpacing.s16,
      AppSpacing.s24,
      0,
    ),
    this.footerTopPadding = AppSpacing.s16,
    this.onCloseAttempt,
    this.semanticLabel,
    super.key,
  });

  /// "Öğrenci Ekle" (Turkish title case).
  final String? title;

  /// "Hesabı sen açarsın; öğrenci bu bilgilerle giriş yapar."
  final String? subtitle;

  /// Replaces the title row (a confirmation's question with its icon).
  final Widget? header;

  /// Shows the "Kapat" button next to the title.
  final bool showClose;
  final Widget body;
  final AppSheetAction? primary;
  final AppSheetAction? secondary;
  final bool busy;
  final EdgeInsetsGeometry bodyPadding;

  /// Space above the first button (24 in a confirmation).
  final double footerTopPadding;
  final VoidCallback? onCloseAttempt;

  /// The dialog's accessible name when there is no [title].
  final String? semanticLabel;

  /// The handle strip: 8 above and the handle itself.
  static const double handleStrip =
      AppSpacing.s8 + AppSpacing.s4; // 8 gap + 4 high

  /// The close button's box and its pull toward the top (margin-top -8).
  static const double _closeBox = 32;

  @override
  State<AppSheetFrame> createState() => _AppSheetFrameState();
}

class _AppSheetFrameState extends State<AppSheetFrame> {
  final ValueNotifier<bool> _underFooter = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _underFooter.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollMetrics metrics) {
    _underFooter.value = metrics.extentAfter > 0.5;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final widget = this.widget;
    final media = MediaQuery.of(context);
    final keyboardOpen = media.viewInsets.bottom > 0;
    final sheetColor = colors.bgRaised;
    final stretch = AppSheetScope.sizeOf(context) != AppSheetSize.small;
    final fade = context.motion(AppMotion.fast, reduced: AppMotion.fast);

    final body = NotificationListener<ScrollMetricsNotification>(
      onNotification: (n) => n.depth == 0 && _onScroll(n.metrics),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) => n.depth == 0 && _onScroll(n.metrics),
        child: SingleChildScrollView(
          padding: widget.bodyPadding,
          child: AnimatedOpacity(
            opacity: widget.busy ? 0.6 : 1,
            duration: fade,
            child: IgnorePointer(ignoring: widget.busy, child: widget.body),
          ),
        ),
      ),
    );

    Widget scaffold = SheetContentScaffold(
      backgroundColor: sheetColor,
      topBar: _Header(
        title: widget.title,
        subtitle: widget.subtitle,
        header: widget.header,
        showClose: widget.showClose,
        busy: widget.busy,
        onClose: _close,
      ),
      bottomBarVisibility: const BottomBarVisibility.always(),
      bottomBar: _Footer(
        primary: widget.primary,
        secondary: widget.secondary,
        busy: widget.busy,
        topPadding: widget.footerTopPadding,
        bottomPadding: SheetLayoutMath.footerBottom(
          keyboardOpen: keyboardOpen,
          safeBottom: media.viewPadding.bottom,
        ),
        underFooter: _underFooter,
        gapColor: sheetColor,
      ),
      body: body,
    );
    if (stretch) {
      scaffold = SizedBox(height: double.infinity, child: scaffold);
    }

    final sheet = Sheet(
      decoration: MaterialSheetDecoration(
        size: SheetSize.stretch,
        color: sheetColor,
        borderRadius: AppRadius.sheetTop,
        clipBehavior: Clip.antiAlias,
      ),
      child: scaffold,
    );

    final ask = widget.onCloseAttempt;
    final locked = widget.busy;
    return SheetPopScope<Object?>(
      canPop: !locked && ask == null,
      onPopInvokedWithResult: locked || ask == null
          ? null
          : (didPop, _) {
              if (!didPop) ask();
            },
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: widget.title ?? widget.semanticLabel,
        child: sheet,
      ),
    );
  }

  void _close() {
    final ask = widget.onCloseAttempt;
    if (ask != null) {
      ask();
    } else {
      Navigator.of(context).maybePop();
    }
  }
}

/// Handle and title row.
class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.header,
    required this.showClose,
    required this.busy,
    required this.onClose,
  });

  final String? title;
  final String? subtitle;
  final Widget? header;
  final bool showClose;
  final bool busy;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final fade = context.motion(AppMotion.fast, reduced: AppMotion.fast);

    final titleRow =
        header ??
        (title == null && subtitle == null
            ? null
            : Padding(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title case final value?)
                            Semantics(
                              header: true,
                              child: Text(
                                value,
                                style: text.titleMd.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          if (subtitle case final value?) ...[
                            const SizedBox(height: AppSpacing.s4),
                            Text(
                              value,
                              style: text.body.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showClose && !busy)
                      SizedBox(
                        width: AppSize.touch,
                        height: AppSheetFrame._closeBox,
                        child: OverflowBox(
                          minHeight: AppSize.touch,
                          maxHeight: AppSize.touch,
                          child: AppIconButton(
                            icon: PhosphorIconsRegular.x,
                            semanticLabel: l10n.common_close,
                            variant: AppIconButtonVariant.close,
                            focusGapColor: colors.bgRaised,
                            onPressed: onClose,
                          ),
                        ),
                      )
                    else if (showClose)
                      const SizedBox(width: AppSize.touch),
                  ],
                ),
              ));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: SizedBox(
            height: AppSheetFrame.handleStrip,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: fade,
                width: AppSize.sheetHandleWidth,
                height: AppSize.sheetHandleHeight,
                decoration: BoxDecoration(
                  color: busy ? colors.bgSunken : colors.borderStrong,
                  borderRadius: AppRadius.borderFull,
                ),
              ),
            ),
          ),
        ),
        ?titleRow,
      ],
    );
  }
}

/// The fixed button band.
class _Footer extends StatelessWidget {
  const _Footer({
    required this.primary,
    required this.secondary,
    required this.busy,
    required this.topPadding,
    required this.bottomPadding,
    required this.underFooter,
    required this.gapColor,
  });

  final AppSheetAction? primary;
  final AppSheetAction? secondary;
  final bool busy;
  final double topPadding;
  final double bottomPadding;
  final ValueListenable<bool> underFooter;
  final Color gapColor;

  Widget _button(AppSheetAction action, {required bool locked}) {
    return AppButton(
      label: action.label,
      onPressed: locked ? null : action.onPressed,
      variant: action.variant,
      icon: action.icon,
      trailingIcon: action.trailingIcon,
      loading: action.loading || (locked && action == primary),
      expand: true,
      autofocus: action.autofocus,
      focusGapColor: gapColor,
      disabledReason: action.disabledReason,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final actions = [?primary, ?secondary];
    final content = actions.isEmpty
        ? SizedBox(height: bottomPadding)
        : Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s24,
              topPadding,
              AppSpacing.s24,
              bottomPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, action) in actions.indexed) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.s12),
                  _button(
                    action,
                    // A busy sheet keeps the primary's spinner and silences
                    // the rest.
                    locked: busy,
                  ),
                ],
              ],
            ),
          );
    return ValueListenableBuilder<bool>(
      valueListenable: underFooter,
      builder: (context, scrolled, child) => DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: scrolled ? colors.borderSubtle : colors.borderSubtle.clear,
            ),
          ),
        ),
        child: child,
      ),
      child: content,
    );
  }
}
