import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_shadows.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/sheets/sheet_layout.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

/// The modal route behind every sheet (C71; board 1.20; handoff 11.15 "Sheet
/// açılış / kapanış").
///
/// Opens in 350 ms (`ease-enter`) and closes in 250 ms (`ease-exit`); the
/// scrim (`SmapColors.scrim`: 48 % light, 64 % dark) fades in with it over an
/// 8 pt blur (`AppBlur.scrim`), the only blur besides the bottom bar. Under
/// "Reduce motion" the slide becomes a 150 ms opacity fade. While a finger
/// drags the sheet it follows linearly. A drag of more than 25 % of the way
/// down, or a fling over 700 px/s, closes it; a sheet that cannot be closed
/// (busy) says so through a `SheetPopScope` in its frame, which also turns
/// the drag off.
///
/// The viewport leaves the safe area plus 8 pt above the sheet; `medium`
/// leaves more ([SheetLayoutMath.topInset]). Use `AppSheet.show`.
class AppSheetRoute<T> extends ModalSheetRoute<T> {
  AppSheetRoute({
    required super.builder,
    required this.reduceMotion,
    required AppSheetSize size,
    required double viewportHeight,
    bool dismissible = true,
    super.settings,
  }) : super(
         swipeDismissible: dismissible,
         barrierDismissible: dismissible,
         transitionDuration: reduceMotion
             ? AppMotion.reducedFade
             : AppMotion.slow,
         transitionCurve: AppMotion.enter,
         swipeDismissSensitivity: SwipeDismissSensitivity(
           minFlingVelocityRatio: SheetLayoutMath.flingVelocityRatio(
             viewportHeight,
           ),
           dismissalOffset: const SheetOffset(SheetLayoutMath.keepOpenFraction),
         ),
         viewportBuilder: (context, child) => _viewport(context, child, size),
       );

  final bool reduceMotion;

  @override
  Duration get reverseTransitionDuration =>
      reduceMotion ? AppMotion.reducedFade : AppMotion.sheetClose;

  static Widget _viewport(
    BuildContext context,
    Widget child,
    AppSheetSize size,
  ) {
    final media = MediaQuery.of(context);
    final top = SheetLayoutMath.topInset(
      size: size,
      viewportHeight: media.size.height,
      safeTop: media.viewPadding.top,
    );
    return SheetViewport(
      padding: EdgeInsets.only(top: top),
      child: child,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (reduceMotion) return FadeTransition(opacity: animation, child: child);
    // Follow the finger while the sheet is dragged down.
    final dragging = navigator?.userGestureInProgress ?? false;
    final curved = dragging
        ? animation
        : CurvedAnimation(
            parent: animation,
            curve: AppMotion.enter,
            reverseCurve: AppMotion.exit,
          );
    return SlideTransition(
      position: Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }

  @override
  ModalSheetBarrierBuilder<T>? get barrierBuilder => _scrim;

  Widget _scrim(ModalRoute<T> route, VoidCallback onDismiss) => _SheetScrim(
    animation: route.animation!,
    dismissible: barrierDismissible,
    onDismiss: onDismiss,
    label: AppLocalizations.of(navigator!.context).common_close,
  );
}

/// The scrim: `scrim` over an 8 pt blur, fading with the route. The blur
/// exists only here (spec 1.7 "Bulanıklık"); the sheet itself has no shadow
/// and no blur.
class _SheetScrim extends StatelessWidget {
  const _SheetScrim({
    required this.animation,
    required this.dismissible,
    required this.onDismiss,
    required this.label,
  });

  final Animation<double> animation;
  final bool dismissible;
  final VoidCallback onDismiss;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: dismissible ? label : null,
      button: dismissible,
      onTap: dismissible ? onDismiss : null,
      child: GestureDetector(
        onTap: dismissible ? onDismiss : null,
        behavior: HitTestBehavior.opaque,
        child: FadeTransition(
          opacity: animation,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppBlur.scrim,
              sigmaY: AppBlur.scrim,
            ),
            child: ColoredBox(
              color: context.appColors.scrim,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}
