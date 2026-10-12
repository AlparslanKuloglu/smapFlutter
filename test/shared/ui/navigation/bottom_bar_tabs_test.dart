import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/shared/ui/navigation/bottom_bar_tabs.dart';

void main() {
  group('AppBottomBarTabs.forRole', () {
    test('student: Anasayfa, Analizlerim, Derslerim, Hesap', () {
      expect(
        AppBottomBarTabs.forRole(
          AppBottomBarRole.student,
        ).map((tab) => tab.destination),
        [
          AppNavDestination.home,
          AppNavDestination.analytics,
          AppNavDestination.lessons,
          AppNavDestination.account,
        ],
      );
    });

    test('coach: Anasayfa, Öğrencilerim, Görüşmelerim, Hesap', () {
      expect(
        AppBottomBarTabs.forRole(
          AppBottomBarRole.coach,
        ).map((tab) => tab.destination),
        [
          AppNavDestination.home,
          AppNavDestination.students,
          AppNavDestination.meetings,
          AppNavDestination.account,
        ],
      );
    });

    test('both roles have four tabs; the camera is not one of them', () {
      for (final role in AppBottomBarRole.values) {
        expect(
          AppBottomBarTabs.forRole(role),
          hasLength(AppBottomBarTabs.tabCount),
        );
      }
    });

    test('Regular icon unselected, Fill icon selected', () {
      final analytics = AppBottomBarTabs.forRole(AppBottomBarRole.student)[1];
      expect(analytics.icon, PhosphorIconsRegular.chartLineUp);
      expect(analytics.activeIcon, PhosphorIconsFill.chartLineUp);
      final meetings = AppBottomBarTabs.forRole(AppBottomBarRole.coach)[2];
      expect(meetings.icon, PhosphorIconsRegular.chats);
      expect(meetings.activeIcon, PhosphorIconsFill.chats);
    });
  });

  group('slots', () {
    test('the camera takes the middle of five slots', () {
      expect(AppBottomBarTabs.slotCount, 5);
      expect(
        [for (var i = 0; i < 4; i++) AppBottomBarTabs.slotOf(i)],
        [0, 1, 3, 4],
      );
    });

    test('screen readers count five positions', () {
      expect(
        [for (var i = 0; i < 4; i++) AppBottomBarTabs.positionOf(i)],
        [1, 2, 4, 5],
      );
    });

    test('4 x 82,5 + 72 on a 402 pt bar', () {
      final slots = [
        for (var s = 0; s < 5; s++)
          AppBottomBarTabs.slotRect(s, width: 402, cameraWidth: 72),
      ];
      expect(slots[0], (left: 0.0, width: 82.5));
      expect(slots[1], (left: 82.5, width: 82.5));
      expect(slots[2], (left: 165.0, width: 72.0));
      expect(slots[3], (left: 237.0, width: 82.5));
      expect(slots[4], (left: 319.5, width: 82.5));
      expect(slots[4].left + slots[4].width, 402);
    });

    test('the camera slot is centered', () {
      for (final width in [320.0, 375.0, 402.0, 430.0]) {
        final camera = AppBottomBarTabs.slotRect(
          AppBottomBarTabs.cameraSlot,
          width: width,
          cameraWidth: 72,
        );
        expect(camera.left + camera.width / 2, closeTo(width / 2, 0.001));
      }
    });
  });

  group('semantic label', () {
    // The phrase is the ARB template with its placeholder filled, so a
    // change to the Turkish copy fails here.
    late String phraseTemplate;

    setUpAll(() {
      final arb =
          jsonDecode(File('lib/l10n/arb/nav_tr.arb').readAsStringSync())
              as Map<String, dynamic>;
      phraseTemplate = arb['nav_a11yTabPosition'] as String;
    });

    String phrase(int position) =>
        phraseTemplate.replaceAll('{position}', '$position');

    test('Analizlerim, sekme, 5\'te 2', () {
      final position = AppBottomBarTabs.positionOf(1);
      expect(
        AppBottomBarTabs.semanticLabel('Analizlerim', phrase(position)),
        "Analizlerim, sekme, 5'te 2",
      );
    });

    test('the third tab is the fourth of five slots', () {
      expect(
        AppBottomBarTabs.semanticLabel(
          'Görüşmelerim',
          phrase(AppBottomBarTabs.positionOf(2)),
        ),
        "Görüşmelerim, sekme, 5'te 4",
      );
    });

    test('the last tab is the fifth', () {
      expect(
        AppBottomBarTabs.semanticLabel(
          'Hesap',
          phrase(AppBottomBarTabs.positionOf(3)),
        ),
        "Hesap, sekme, 5'te 5",
      );
    });
  });

  group('labelScale (FIN14E: one scale for the five labels)', () {
    // 4 x 82,5 tab slots and the 72 camera slot of a 402 bar.
    const slots = [82.5, 82.5, 82.5, 82.5, 72.0];

    test('1 when every label fits its slot', () {
      expect(
        AppBottomBarTabs.labelScale(
          textWidths: [50, 60, 55, 30, 28],
          slotWidths: slots,
        ),
        1,
      );
    });

    test('the tightest label sets the scale for all', () {
      // Room is slot - 2 x 4 = 74,5; a 93 wide label needs 0,8.
      final scale = AppBottomBarTabs.labelScale(
        textWidths: [70, 93, 60, 40, 30],
        slotWidths: slots,
      );
      expect(scale, closeTo(74.5 / 93, 1e-9));
      // That scale fits every label.
      for (final (i, width) in [70.0, 93.0, 60.0, 40.0, 30.0].indexed) {
        expect(width * scale, lessThanOrEqualTo(slots[i] - 8 + 1e-9));
      }
    });

    test('the narrow camera slot counts too', () {
      final scale = AppBottomBarTabs.labelScale(
        textWidths: [10, 10, 10, 10, 80],
        slotWidths: slots,
      );
      expect(scale, closeTo(64 / 80, 1e-9));
    });

    test('a slot without room never gives a zero or negative scale', () {
      expect(
        AppBottomBarTabs.labelScale(textWidths: [40], slotWidths: [6]),
        greaterThan(0),
      );
    });
  });
}
