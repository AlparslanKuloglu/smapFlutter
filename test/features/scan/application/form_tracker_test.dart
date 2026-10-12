import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/scan/application/form_quad.dart';
import 'package:smap/features/scan/application/form_tracker.dart';

final form = FormQuad.fromRect(const Rect.fromLTRB(0.1, 0.2, 0.9, 0.8));

void main() {
  test('one frame is not enough to find a form', () {
    final tracker = FormTracker();
    expect(tracker.update(form), isFalse);
    expect(tracker.current, isNull);
  });

  test('two agreeing frames find it (pano 4.3 kare 2)', () {
    final tracker = FormTracker();
    tracker.update(form);
    expect(tracker.update(form), isTrue);
    expect(tracker.current, form);
  });

  test('frames that disagree start counting again', () {
    final tracker = FormTracker();
    tracker.update(form);
    tracker.update(FormQuad.fromRect(const Rect.fromLTRB(0.3, 0.3, 0.7, 0.9)));
    expect(tracker.current, isNull);
  });

  test('one missed frame does not lose it, three do', () {
    final tracker = FormTracker();
    tracker.update(form);
    tracker.update(form);
    tracker.update(null);
    tracker.update(null);
    expect(tracker.current, isNotNull);
    expect(tracker.update(null), isTrue);
    expect(tracker.current, isNull);
  });

  test('a sliver or a tiny rectangle is not a form', () {
    final tracker = FormTracker();
    final tiny = FormQuad.fromRect(const Rect.fromLTRB(0.4, 0.4, 0.5, 0.5));
    final sliver = FormQuad.fromRect(const Rect.fromLTRB(0.1, 0.1, 0.9, 0.15));
    for (var i = 0; i < 4; i++) {
      tracker.update(tiny);
      tracker.update(sliver);
    }
    expect(tracker.current, isNull);
  });

  test('a found form follows the detector smoothly', () {
    final tracker = FormTracker();
    tracker.update(form);
    tracker.update(form);
    final shifted = form.map((c) => c + const Offset(0.02, 0));
    tracker.update(shifted);
    expect(tracker.current!.topLeft.dx, closeTo(0.11, 1e-9));
  });

  test('reset forgets everything', () {
    final tracker = FormTracker();
    tracker.update(form);
    tracker.update(form);
    tracker.reset();
    expect(tracker.current, isNull);
  });
}
