import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/indicators/app_spinner.dart';

/// The tint of the circle of an [AppStatusView] (C79 "Rozet tonları").
enum AppStatusTone {
  /// `successBg` and `success`: password updated, account deleted.
  success,

  /// `errorBg` and `error`: unknown role, a failed step.
  error,

  /// `infoBg` and `info`: maintenance, session expired.
  info,

  /// `bgSunken` and `textSecondary`: offline and other neutral stops.
  neutral;

  Color fillOf(SmapColors colors) => switch (this) {
    success => colors.successBg,
    error => colors.errorBg,
    info => colors.infoBg,
    neutral => colors.bgSunken,
  };

  Color inkOf(SmapColors colors) => switch (this) {
    success => colors.success,
    error => colors.error,
    info => colors.info,
    neutral => colors.textSecondary,
  };
}

/// The three steps of a status view (C79; spec §1 "Kademe").
enum AppStatusSize {
  /// 80 pt circle, 40 pt icon, title 20/28 · 700: the camera error sheet-like
  /// screens (4.10 kare 4).
  compact(circle: 80, icon: 40, top: 220),

  /// 80 pt circle, 40 pt icon, title 24/32 · 700: "Talebin alındı" (4.9),
  /// the error screens of 4.10.
  flow(circle: 80, icon: 40, top: 220),

  /// 96 pt circle, 48 pt icon, display title 32/40 · 800: the general screens
  /// of 2.7 and the end of a flow (9.4 "Hesabın silindi" with
  /// `smallTitle`).
  blocking(circle: 96, icon: 48, top: 200);

  const AppStatusSize({
    required this.circle,
    required this.icon,
    required this.top,
  });

  /// Circle edge.
  final double circle;

  /// Icon edge inside the circle.
  final double icon;

  /// Default space above the circle.
  final double top;
}

/// A button of the status view (at most two: the primary and a quiet or text
/// one).
class AppStatusAction {
  const AppStatusAction({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
}

/// The full-screen status (C79 "Tam ekran durum"; boards 2.7 "Genel
/// Ekranlar", 4.9, 4.10 "Hata Ekranları", 9.4 "Hesabı Sil"; UI guide §5 #30).
///
/// An icon circle (96 pt, or 80 pt) in the [tone] color, the [title], one
/// [message] sentence in `bodyReading` (16/26) `textSecondary`, and at most
/// two buttons pinned to the bottom (24 at the sides, the safe area plus 8
/// below). The content sits about 200 pt from the top and scrolls when the
/// text is large. No illustration and no inner code: kil pictures belong to
/// onboarding and empty states only. The message is a live region (alert for
/// an error, status otherwise).
///
/// [blocking] is for stops the user cannot leave ("Yeni sürüm gerekli",
/// "Hesabın siliniyor"): the screen sits in a `PopScope(canPop: false)`, so
/// the back gesture and the Android back button do nothing. The button that
/// leaves the stop (update, sign in) is the caller's. [onClose] draws a
/// "Kapat" at the top left for the flows that may be left.
///
/// [AppStatusView.busy] is the 9.4 "Hesabın siliniyor" screen: a 48 pt
/// spinner, a 20/28 title and "Uygulamayı kapatma." with no button; always
/// blocking. Haptics are the caller's: `error` only when an action the user
/// took failed.
class AppStatusView extends StatelessWidget {
  const AppStatusView({
    required this.title,
    required this.message,
    this.tone = AppStatusTone.info,
    this.icon,
    this.leading,
    this.size = AppStatusSize.blocking,
    this.smallTitle = false,
    this.primary,
    this.secondary,
    this.blocking = false,
    this.onClose,
    this.closeLabel,
    this.topPadding,
    super.key,
  }) : busy = false,
       assert(
         icon != null || leading != null,
         'A status view needs an icon or a leading widget',
       ),
       assert(
         onClose == null || closeLabel != null,
         'The close button needs its accessible name',
       );

  /// "Hesabın siliniyor" (9.4 kare 4): spinner, title, one line, no buttons,
  /// back closed.
  const AppStatusView.busy({
    required this.title,
    required this.message,
    this.topPadding,
    super.key,
  }) : busy = true,
       tone = AppStatusTone.neutral,
       icon = null,
       leading = null,
       size = AppStatusSize.compact,
       smallTitle = false,
       primary = null,
       secondary = null,
       blocking = true,
       onClose = null,
       closeLabel = null;

  final String title;
  final String message;
  final AppStatusTone tone;

  /// Phosphor icon drawn in the circle.
  final IconData? icon;

  /// A widget in place of the circle (the 96 pt app icon of the forced
  /// update, radius 21,5).
  final Widget? leading;
  final AppStatusSize size;

  /// 24/32 title on a `blocking` screen (9.4 "Hesabın silindi").
  final bool smallTitle;
  final AppStatusAction? primary;
  final AppStatusAction? secondary;

  /// Closes the back gesture and the Android back button.
  final bool blocking;
  final VoidCallback? onClose;
  final String? closeLabel;

  /// Space above the circle; the size's default (200 or 220) when null.
  final double? topPadding;

  /// The spinner of the busy variant.
  final bool busy;

  /// Spinner edge of [AppStatusView.busy].
  static const double spinnerSize = 48;

  /// Busy variant top padding (9.4: 300).
  static const double busyTop = 300;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final actions = [?primary, ?secondary];

    // A `Material` of its own: the launch, maintenance and unknown-role pages
    // have no Scaffold above, and a `Text` without a Material ancestor draws
    // the yellow double underline.
    final view = Material(
      color: colors.bgCanvas,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (onClose != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: _CloseButton(label: closeLabel!, onPressed: onClose!),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.s24,
                  topPadding ?? (busy ? busyTop : size.top),
                  AppSpacing.s24,
                  AppSpacing.s24,
                ),
                child: _Content(view: this),
              ),
            ),
            if (actions.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.s24,
                  0,
                  AppSpacing.s24,
                  safeBottom + AppSpacing.s8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, action) in actions.indexed) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.s12),
                      AppButton(
                        label: action.label,
                        onPressed: action.onPressed,
                        variant: action.variant,
                        icon: action.icon,
                        loading: action.loading,
                        expand: true,
                        autofocus: i == 0,
                      ),
                    ],
                  ],
                ),
              )
            else
              SizedBox(height: safeBottom),
          ],
        ),
      ),
    );
    return blocking ? PopScope(canPop: false, child: view) : view;
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.view});

  final AppStatusView view;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final size = view.size;
    final TextStyle titleStyle;
    final TextStyle messageStyle;
    if (view.busy) {
      titleStyle = text.titleMd;
      messageStyle = text.body;
    } else {
      titleStyle = switch (size) {
        AppStatusSize.compact => text.titleMd,
        AppStatusSize.flow => text.titleLg,
        AppStatusSize.blocking => view.smallTitle ? text.titleLg : text.display,
      };
      messageStyle = size == AppStatusSize.blocking
          ? text.bodyReading
          : text.body;
    }
    final Widget mark;
    if (view.busy) {
      mark = const AppSpinner(size: AppStatusView.spinnerSize);
    } else if (view.leading case final leading?) {
      mark = SizedBox.square(dimension: size.circle, child: leading);
    } else {
      mark = DecoratedBox(
        decoration: BoxDecoration(
          color: view.tone.fillOf(colors),
          shape: BoxShape.circle,
        ),
        child: SizedBox.square(
          dimension: size.circle,
          child: Center(
            child: PhosphorIcon(
              view.icon!,
              size: size.icon,
              color: view.tone.inkOf(colors),
            ),
          ),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: mark),
        const SizedBox(height: AppSpacing.s24),
        Semantics(
          header: true,
          child: Text(
            view.title,
            textAlign: TextAlign.center,
            style: titleStyle.copyWith(color: colors.textPrimary),
          ),
        ),
        SizedBox(
          height: size == AppStatusSize.blocking && !view.busy
              ? AppSpacing.s12
              : AppSpacing.s8,
        ),
        Semantics(
          liveRegion: true,
          container: true,
          child: Text(
            view.message,
            textAlign: TextAlign.center,
            style: messageStyle.copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.s4),
      child: AppIconButton(
        icon: PhosphorIconsRegular.x,
        semanticLabel: label,
        onPressed: onPressed,
      ),
    );
  }
}
