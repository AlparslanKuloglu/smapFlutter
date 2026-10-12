import 'package:smap/features/scan/application/form_quad.dart';

/// Turns the detector's per-frame answers into a steady "form found" state
/// (pano 4.3 kare 2: "form bulununca çerçeve köşeleri saydamlaşır, dörtgen
/// belirir"; the shutter works either way, detection is a suggestion).
///
/// A form is *found* only after [confirmFrames] frames in a row agree within
/// [tolerance] (so one stray rectangle does not flash), and *lost* only after
/// [lostFrames] frames in a row show nothing usable (so one missed frame does
/// not make the quadrilateral blink). Coordinates are in the unit square of the
/// preview. The found quadrilateral follows the detector with a light smoothing.
class FormTracker {
  FormTracker({
    this.confirmFrames = 2,
    this.lostFrames = 3,
    this.tolerance = 0.05,
    this.minArea = 0.12,
    this.minSide = 0.1,
  });

  /// Frames that must agree before the form counts as found.
  final int confirmFrames;

  /// Frames without a usable form before it counts as lost.
  final int lostFrames;

  /// How far, per corner, two frames may differ and still agree (unit square).
  final double tolerance;

  /// The smallest share of the preview a form may cover.
  final double minArea;

  /// The shortest side a form may have (unit square).
  final double minSide;

  FormQuad? _current;
  FormQuad? _candidate;
  var _hits = 0;
  var _misses = 0;

  /// The form as it stands now; `null` while none is found.
  FormQuad? get current => _current;

  /// Takes one frame's [detected] quadrilateral (or `null`); returns whether
  /// [current] changed.
  bool update(FormQuad? detected) {
    final before = _current;
    if (_usable(detected)) {
      final quad = detected!;
      final candidate = _candidate;
      _hits = candidate != null && candidate.isCloseTo(quad, tolerance)
          ? _hits + 1
          : 1;
      _candidate = quad;
      _misses = 0;
      if (_hits >= confirmFrames) {
        final held = _current;
        _current = held == null ? quad : held.lerpTo(quad, 0.5);
      }
    } else {
      _misses++;
      if (_misses >= lostFrames) {
        _current = null;
        _candidate = null;
        _hits = 0;
      }
    }
    return _current != before;
  }

  /// Forgets everything (the camera was paused).
  void reset() {
    _current = null;
    _candidate = null;
    _hits = 0;
    _misses = 0;
  }

  bool _usable(FormQuad? quad) =>
      quad != null &&
      quad.isConvex &&
      quad.area >= minArea &&
      quad.shortestSide >= minSide;
}
