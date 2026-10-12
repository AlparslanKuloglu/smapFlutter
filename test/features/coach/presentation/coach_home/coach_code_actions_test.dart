import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/coach/application/coach_code_actions.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/shared/ui/feedback/toast_host.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';

class _NoPresenter implements ToastPresenter {
  @override
  bool screenReaderOn = false;

  @override
  bool present(ToastSlot slot, ValueListenable<double?> barHeight) => true;
}

void main() {
  late ToastService toast;
  late List<String> copied;
  late List<(String, Rect?)> shared;
  late CoachCodeActions actions;

  setUp(() {
    toast = ToastService(presenter: _NoPresenter());
    copied = [];
    shared = [];
    actions = CoachCodeActions(
      copyText: (text) async => copied.add(text),
      shareText: (text, {origin}) async => shared.add((text, origin)),
      toast: toast,
    );
  });

  tearDown(() => toast.dispose());

  test('copy puts the code on the clipboard and says it in a toast', () async {
    await actions.copy('MOZK-4821');

    expect(copied, ['MOZK-4821']);
    final entry = toast.slot.current.value!;
    expect(entry.title(AppLocalizationsTr()), 'Kod kopyalandı.');
    expect(entry.kind, AppToastKind.success);
  });

  test('share passes the sentence and the button rectangle on', () async {
    const origin = Rect.fromLTWH(10, 20, 100, 40);

    await actions.share("SMAP'te koçluk kodum: MOZK-4821", origin: origin);

    expect(shared, [("SMAP'te koçluk kodum: MOZK-4821", origin)]);
  });

  test('a failed copy raises no toast', () async {
    final failing = CoachCodeActions(
      copyText: (text) async => throw StateError('no clipboard'),
      shareText: (text, {origin}) async {},
      toast: toast,
    );

    await expectLater(failing.copy('X'), throwsStateError);
    expect(toast.slot.current.value, isNull);
  });
}
