import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';

void main() {
  group('StudentRef', () {
    test('is equal by id, name and avatar', () {
      const a = StudentRef(id: '1', name: 'Elif Şahin');
      const b = StudentRef(id: '1', name: 'Elif Şahin');
      const other = StudentRef(id: '2', name: 'Elif Şahin');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == other, isFalse);
    });

    test('the strip texts and the field are part of the value', () {
      const a = StudentRef(
        id: '1',
        name: 'Alparslan Kuloğlu',
        detail: '12. Sınıf · EA',
        detailSemantics: '12. Sınıf, Eşit Ağırlık',
        aimType: 2,
      );
      const same = StudentRef(
        id: '1',
        name: 'Alparslan Kuloğlu',
        detail: '12. Sınıf · EA',
        detailSemantics: '12. Sınıf, Eşit Ağırlık',
        aimType: 2,
      );
      const otherField = StudentRef(
        id: '1',
        name: 'Alparslan Kuloğlu',
        detail: '12. Sınıf · EA',
        detailSemantics: '12. Sınıf, Eşit Ağırlık',
        aimType: 3,
      );
      expect(a, same);
      expect(a.hashCode, same.hashCode);
      expect(a == otherField, isFalse);
      expect(
        a == const StudentRef(id: '1', name: 'Alparslan Kuloğlu'),
        isFalse,
      );
    });

    test('a different picture is a different student ref', () {
      const picture = AssetImage('a.png');
      const a = StudentRef(id: '1', name: 'Elif Şahin', avatar: picture);
      const b = StudentRef(id: '1', name: 'Elif Şahin');
      expect(a == b, isFalse);
    });
  });

  group('AppSystemOverlay', () {
    test('the band has light icons in both themes', () {
      for (final theme in Brightness.values) {
        final style = AppSystemOverlay.of(AppSystemOverlayKind.band, theme);
        expect(style.statusBarIconBrightness, Brightness.light);
        // iOS names the background, which is dark under light icons.
        expect(style.statusBarBrightness, Brightness.dark);
      }
    });

    test('the detail bar has dark icons in light and light icons in dark', () {
      final light = AppSystemOverlay.of(
        AppSystemOverlayKind.bar,
        Brightness.light,
      );
      final dark = AppSystemOverlay.of(
        AppSystemOverlayKind.bar,
        Brightness.dark,
      );
      expect(light.statusBarIconBrightness, Brightness.dark);
      expect(light.statusBarBrightness, Brightness.light);
      expect(dark.statusBarIconBrightness, Brightness.light);
      expect(dark.statusBarBrightness, Brightness.dark);
    });

    test('the camera is dark in both themes, with light icons', () {
      for (final theme in Brightness.values) {
        final style = AppSystemOverlay.of(AppSystemOverlayKind.camera, theme);
        expect(style.statusBarIconBrightness, Brightness.light);
        expect(style.systemNavigationBarIconBrightness, Brightness.light);
      }
    });

    test('the system bars are transparent without a contrast scrim', () {
      final style = AppSystemOverlay.of(
        AppSystemOverlayKind.bar,
        Brightness.light,
      );
      expect(style.statusBarColor!.a, 0);
      expect(style.systemNavigationBarColor!.a, 0);
      expect(style.systemNavigationBarContrastEnforced, isFalse);
      expect(style, isA<SystemUiOverlayStyle>());
    });
  });
}
