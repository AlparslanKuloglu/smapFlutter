import 'package:flutter/widgets.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';

/// The three heights of a sheet (C71 "Boylar"; board 1.20 "Sheet Çerçevesi").
enum AppSheetSize {
  /// Fits its content (board 1.20 kare 1, "Matematik ve Geometri").
  small,

  /// About two thirds of the screen (kare 2, the filter sheet).
  medium,

  /// Everything below the safe area plus 8 pt (kare 3, "Öğrenci Ekle").
  full,
}

/// The measures of a sheet as pure functions, so they can be tested without a
/// widget tree (C71).
abstract final class SheetLayoutMath {
  /// `medium` takes this share of the viewport (board 1.20 kare 2: top at
  /// 300 of 874, which is 574 high, 66 %).
  static const double mediumFraction = 0.66;

  /// Gap kept above a sheet under the top safe area.
  static const double topGap = AppSpacing.s8;

  /// Footer bottom padding while the keyboard is open.
  static const double footerBottomWithKeyboard = AppSpacing.s16;

  /// Footer bottom padding without the keyboard, on top of the safe area.
  static const double footerBottomGap = AppSpacing.s8;

  /// The distance between the top of the viewport and the top of the sheet's
  /// largest extent. `full` and `small` leave the safe area plus 8; `medium`
  /// leaves the rest of the screen above its two thirds (never less than the
  /// full measure).
  static double topInset({
    required AppSheetSize size,
    required double viewportHeight,
    required double safeTop,
  }) {
    final full = safeTop + topGap;
    if (size != AppSheetSize.medium) return full;
    final medium = viewportHeight * (1 - mediumFraction);
    return medium > full ? medium : full;
  }

  /// The footer's bottom padding: 16 above the keyboard, otherwise the
  /// bottom safe area plus 8 (42 pt on an iPhone with a home indicator).
  static double footerBottom({
    required bool keyboardOpen,
    required double safeBottom,
  }) => keyboardOpen ? footerBottomWithKeyboard : safeBottom + footerBottomGap;

  /// Share of the sheet that must stay visible for a released drag to keep
  /// it open: more than [AppMotion.sheetDismissFraction] (25 %) of the way
  /// down closes it.
  static const double keepOpenFraction = 1 - AppMotion.sheetDismissFraction;

  /// A fling closes the sheet above this velocity; the smooth_sheets ratio
  /// is the velocity over the viewport height, so the 700 px/s decision of
  /// [AppMotion.sheetFlingVelocity] stays the same on every screen height.
  static double flingVelocityRatio(double viewportHeight) =>
      viewportHeight <= 0 ? 1 : AppMotion.sheetFlingVelocity / viewportHeight;

  /// Whether a released drag closes the sheet: [dragged] is the share of the
  /// sheet's height moved down (0..1), [velocity] the downward speed in
  /// px/s. Mirrors what the route does; kept here to pin the rule in a test.
  static bool dismisses({required double dragged, required double velocity}) =>
      velocity >= AppMotion.sheetFlingVelocity ||
      dragged > AppMotion.sheetDismissFraction;
}

/// Tells the frame inside a sheet which [AppSheetSize] it was opened with.
class AppSheetScope extends InheritedWidget {
  const AppSheetScope({required this.size, required super.child, super.key});

  final AppSheetSize size;

  /// The size of the nearest sheet; `small` outside one.
  static AppSheetSize sizeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSheetScope>()?.size ??
      AppSheetSize.small;

  @override
  bool updateShouldNotify(AppSheetScope oldWidget) => size != oldWidget.size;
}
