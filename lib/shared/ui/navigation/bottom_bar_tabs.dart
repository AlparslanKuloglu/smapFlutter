import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Which side of the app the bottom bar belongs to (C84 `role`).
enum AppBottomBarRole { student, coach }

/// A place the bottom bar can lead to. The camera is not one of them: it is
/// a button, not a tab.
enum AppNavDestination { home, analytics, lessons, students, meetings, account }

/// One tab of the bar: where it leads and its two icons.
@immutable
class AppNavTabSpec {
  const AppNavTabSpec({
    required this.destination,
    required this.icon,
    required this.activeIcon,
  });

  final AppNavDestination destination;

  /// Phosphor Regular, shown while the tab is not selected.
  final IconData icon;

  /// Phosphor Fill, shown while it is selected.
  final IconData activeIcon;
}

/// The tab lists and the slot arithmetic of the bottom bar (C84; pano
/// 1.19; spec §3.2).
///
/// Student: Anasayfa · Analizlerim · [Okut] · Derslerim · Hesap. Coach:
/// Anasayfa · Öğrencilerim · [Okut] · Görüşmelerim · Hesap (D-29). The bar
/// has five slots and the camera button holds the middle one, so four tabs
/// sit at slots 0, 1, 3, 4 and a screen reader says "5'te 2" for the second
/// tab and "5'te 4" for the third.
abstract final class AppBottomBarTabs {
  /// Tabs in a bar.
  static const int tabCount = 4;

  /// Slots in a bar: four tabs and the camera.
  static const int slotCount = 5;

  /// The slot (0-based) of the camera button.
  static const int cameraSlot = 2;

  static const AppNavTabSpec _home = AppNavTabSpec(
    destination: AppNavDestination.home,
    icon: PhosphorIconsRegular.house,
    activeIcon: PhosphorIconsFill.house,
  );

  static const AppNavTabSpec _account = AppNavTabSpec(
    destination: AppNavDestination.account,
    icon: PhosphorIconsRegular.userCircle,
    activeIcon: PhosphorIconsFill.userCircle,
  );

  static const List<AppNavTabSpec> _student = [
    _home,
    AppNavTabSpec(
      destination: AppNavDestination.analytics,
      icon: PhosphorIconsRegular.chartLineUp,
      activeIcon: PhosphorIconsFill.chartLineUp,
    ),
    AppNavTabSpec(
      destination: AppNavDestination.lessons,
      icon: PhosphorIconsRegular.bookOpen,
      activeIcon: PhosphorIconsFill.bookOpen,
    ),
    _account,
  ];

  static const List<AppNavTabSpec> _coach = [
    _home,
    AppNavTabSpec(
      destination: AppNavDestination.students,
      icon: PhosphorIconsRegular.users,
      activeIcon: PhosphorIconsFill.users,
    ),
    AppNavTabSpec(
      destination: AppNavDestination.meetings,
      icon: PhosphorIconsRegular.chats,
      activeIcon: PhosphorIconsFill.chats,
    ),
    _account,
  ];

  /// The four tabs of [role], left to right (the camera sits between the
  /// second and the third).
  static List<AppNavTabSpec> forRole(AppBottomBarRole role) => switch (role) {
    AppBottomBarRole.student => _student,
    AppBottomBarRole.coach => _coach,
  };

  /// The 0-based slot of tab [tabIndex] (0..3): the camera takes slot 2.
  static int slotOf(int tabIndex) =>
      tabIndex < cameraSlot ? tabIndex : tabIndex + 1;

  /// The 1-based position a screen reader says for tab [tabIndex].
  static int positionOf(int tabIndex) => slotOf(tabIndex) + 1;

  /// The spoken name of a tab: "Analizlerim, sekme, 5'te 2". [positionPhrase]
  /// is the localized "sekme, 5'te 2" (`nav_a11yTabPosition`).
  static String semanticLabel(String label, String positionPhrase) =>
      '$label, $positionPhrase';

  /// Space kept free on each side of a tab label inside its slot.
  static const double labelSidePadding = 4;

  /// The one scale all five labels (four tabs and "Okut") share, 0..1 (pano
  /// 1.19 "etiketler sığmazsa küçülür"; C77 to C79).
  ///
  /// [textWidths] are the labels laid out at the current text scale (in the
  /// heaviest weight, so selecting a tab never changes the answer),
  /// [slotWidths] the room each of them has. The result is the smallest
  /// ratio that makes the tightest label fit; 1 when every label fits. All
  /// labels use it, so they stay the same size and sit on one baseline
  /// instead of each shrinking by itself.
  static double labelScale({
    required List<double> textWidths,
    required List<double> slotWidths,
  }) {
    assert(textWidths.length == slotWidths.length);
    var scale = 1.0;
    for (var i = 0; i < textWidths.length; i++) {
      final text = textWidths[i];
      if (text <= 0) continue;
      final room = math.max(1.0, slotWidths[i] - 2 * labelSidePadding);
      scale = math.min(scale, room / text);
    }
    return scale;
  }

  /// Left edge of slot [slot] and the slot's width in a bar of [width] whose
  /// camera slot is [cameraWidth] wide: the four tab slots share the rest
  /// equally (C84: 4 × 82,5 + 72 at 402).
  static ({double left, double width}) slotRect(
    int slot, {
    required double width,
    required double cameraWidth,
  }) {
    final tabWidth = (width - cameraWidth) / tabCount;
    if (slot == cameraSlot) {
      return (left: cameraSlot * tabWidth, width: cameraWidth);
    }
    final left = slot < cameraSlot
        ? slot * tabWidth
        : cameraSlot * tabWidth +
              cameraWidth +
              (slot - cameraSlot - 1) * tabWidth;
    return (left: left, width: tabWidth);
  }
}
