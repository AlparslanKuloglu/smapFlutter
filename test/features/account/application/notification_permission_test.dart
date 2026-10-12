import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smap/features/account/application/notification_permission.dart';
import 'package:smap/features/account/data/notification_permission_gateway.dart';

void main() {
  group('NotificationPermissionRules.isOff', () {
    test('granted is never off', () {
      for (final answered in [true, false]) {
        expect(
          NotificationPermissionRules.isOff(
            NotificationPermissionStatus.granted,
            primerAnswered: answered,
          ),
          isFalse,
        );
      }
    });

    test('blocked is always off', () {
      for (final answered in [true, false]) {
        expect(
          NotificationPermissionRules.isOff(
            NotificationPermissionStatus.blocked,
            primerAnswered: answered,
          ),
          isTrue,
        );
      }
    });

    test('a plain denied counts only after the app asked', () {
      expect(
        NotificationPermissionRules.isOff(
          NotificationPermissionStatus.denied,
          primerAnswered: false,
        ),
        isFalse,
      );
      expect(
        NotificationPermissionRules.isOff(
          NotificationPermissionStatus.denied,
          primerAnswered: true,
        ),
        isTrue,
      );
    });
  });

  group('PermissionHandlerNotificationPermission.statusOf', () {
    test('maps permission_handler statuses', () {
      NotificationPermissionStatus of(PermissionStatus s) =>
          PermissionHandlerNotificationPermission.statusOf(s);
      expect(
        of(PermissionStatus.granted),
        NotificationPermissionStatus.granted,
      );
      expect(
        of(PermissionStatus.provisional),
        NotificationPermissionStatus.granted,
      );
      expect(
        of(PermissionStatus.limited),
        NotificationPermissionStatus.granted,
      );
      expect(of(PermissionStatus.denied), NotificationPermissionStatus.denied);
      expect(
        of(PermissionStatus.permanentlyDenied),
        NotificationPermissionStatus.blocked,
      );
      expect(
        of(PermissionStatus.restricted),
        NotificationPermissionStatus.blocked,
      );
    });
  });
}
