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

part 'app_sheet_frame_parts.dart';

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
      // A medium or full sheet's viewport already stops above the keyboard
      // (`AppSheetRoute`), so its band stays whole instead of being hidden by
      // the inset. A small sheet is not lifted: its band keeps the default and
      // rides the keyboard.
      bottomBarVisibility: BottomBarVisibility.always(
        ignoreBottomInset: stretch,
      ),
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
