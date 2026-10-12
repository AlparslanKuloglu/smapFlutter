import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/scan/application/scan_flow_state.dart';
import 'package:smap/features/scan/presentation/capture/scan_capture_dialogs.dart';
import 'package:smap/features/scan/presentation/scan_error/scan_error_viewmodel.dart';

import '../scan_fakes.dart';

class _Dialogs implements ScanCaptureDialogs {
  final List<bool> shown = [];

  @override
  Future<void> showTutorial({required bool first}) async => shown.add(first);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Dialogs dialogs;
  late RecordingActions actions;

  ScanErrorViewModel build(ScanErrorKind kind) =>
      ScanErrorViewModel(kind: kind, dialogs: dialogs, actions: actions);

  setUp(() {
    dialogs = _Dialogs();
    actions = RecordingActions();
  });

  group('Formu bulamadık (pano 4.10 kare 1)', () {
    test('"Yeni Fotoğraf" goes back to the camera', () {
      final vm = build(ScanErrorKind.formNotFound)..newPhoto();
      expect(actions.calls, ['retake']);
      vm.dispose();
    });

    test(
      '"Nasıl Çekilir?" opens the sheet without the checkbox and stays',
      () async {
        final vm = build(ScanErrorKind.formNotFound);
        await vm.showTutorial();
        expect(dialogs.shown, [false]);
        expect(actions.calls, isEmpty);
        vm.dispose();
      },
    );

    test('Kapat leaves the scan', () {
      build(ScanErrorKind.formNotFound).close();
      expect(actions.calls, ['close']);
    });
  });

  group('Bağlantı yok, planlı (pano 4.10 kare 3)', () {
    test('"Tamam" leaves and "Şimdi Tekrar Dene" sends again', () {
      final vm = build(ScanErrorKind.offline)
        ..close()
        ..retryNow();
      expect(actions.calls, ['close', 'retryUpload']);
      vm.dispose();
    });
  });
}
