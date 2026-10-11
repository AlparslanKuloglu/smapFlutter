import 'package:flutter/material.dart';
import 'package:smap/shared/ui/sheets/app_sheet_route.dart';
import 'package:smap/shared/ui/sheets/sheet_outcome.dart';
import 'package:smap/shared/ui/sheets/sheet_layout.dart';

export 'package:smap/shared/ui/sheets/app_sheet_frame.dart';
export 'package:smap/shared/ui/sheets/sheet_layout.dart'
    show AppSheetScope, AppSheetSize;
export 'package:smap/shared/ui/sheets/sheet_outcome.dart';

/// Opens sheets (C71 "BottomSheet"; board 1.20; UI guide §5 #24, §6 rule 15).
///
/// Every dialog of the app is a sheet that returns a typed result; the
/// calling ViewModel writes, toasts and undoes. `showDialog`, `AlertDialog`
/// and `showModalBottomSheet` are not used.
///
/// ```dart
/// final grade = await AppSheet.show<Grade>(
///   context: context,
///   size: AppSheetSize.medium,
///   builder: (_) => const GradeSheet(),
/// );
/// ```
///
/// With a [BuildContext] the sheet opens on the root navigator, so it covers
/// the bottom bar. Without one (a ViewModel, a service) it opens on
/// [navigatorKey], which the app sets once to its router's key
/// (`AppSheet.navigatorKey = router.navigatorKey`); with neither, nothing
/// opens and the future completes with `null`. [dismissible] false makes a
/// sheet that drag and scrim cannot close (session expired, 2.7 kare 2).
abstract final class AppSheet {
  /// The root navigator used when [show] gets no context. Set by the app
  /// shell (the router's `navigatorKey`); the kit never imports the router.
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Shows the sheet built by [builder] and completes with what it pops, or
  /// `null` when it was dismissed.
  static Future<T?> show<T>({
    required WidgetBuilder builder,
    BuildContext? context,
    AppSheetSize size = AppSheetSize.small,
    bool dismissible = true,
  }) {
    final NavigatorState? navigator = context != null
        ? Navigator.maybeOf(context, rootNavigator: true)
        : navigatorKey?.currentState;
    if (navigator == null) return Future<T?>.value();
    final navContext = navigator.context;
    return navigator.push<T>(
      AppSheetRoute<T>(
        builder: (context) => AppSheetScope(
          size: size,
          child: Builder(builder: builder),
        ),
        reduceMotion: MediaQuery.maybeDisableAnimationsOf(navContext) ?? false,
        size: size,
        viewportHeight: MediaQuery.maybeSizeOf(navContext)?.height ?? 0,
        dismissible: dismissible,
      ),
    );
  }

  /// [show] as a [SheetOutcome]: tells "dismissed" from "chose a value".
  static Future<SheetOutcome<T>> showForOutcome<T extends Object>({
    required WidgetBuilder builder,
    BuildContext? context,
    AppSheetSize size = AppSheetSize.small,
    bool dismissible = true,
  }) async {
    final result = await show<T>(
      builder: builder,
      context: context,
      size: size,
      dismissible: dismissible,
    );
    return SheetOutcome.of<T>(result);
  }
}
