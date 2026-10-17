import 'dart:async';

import 'package:flutter/foundation.dart';

/// Lets the screen that hosts the program as a section (the coach's student
/// profile, Tur 12 A, pano 14.1 kare 1 and 3) follow the section's edit mode:
/// in edit mode the host's bar shows "Bitti" and no back, and its header and
/// tabs step aside, exactly as the board's edit frame has it.
///
/// The host owns one link and hands it to the section; the section's
/// ViewModel [attach]es its "Bitti" to it and keeps [editing] and [title] up
/// to date. The host's bar listens to [editing] and calls [finish].
class ProgramEditLink {
  /// `true` while the section is in edit mode.
  final ValueNotifier<bool> editing = ValueNotifier<bool>(false);

  /// The program's name, for the host's bar title once its large title has
  /// scrolled away; empty until edit mode starts.
  String title = '';

  VoidCallback? _finish;
  bool _disposed = false;

  /// Called by the section's ViewModel: [finish] ends its edit mode.
  void attach(VoidCallback finish) => _finish = finish;

  /// The section went away: edit mode is over. Deferred to a microtask so the
  /// host is not told to rebuild while the tree is being torn down.
  void detach() {
    _finish = null;
    if (!editing.value) return;
    scheduleMicrotask(() {
      if (!_disposed) editing.value = false;
    });
  }

  /// Called by the section's ViewModel when edit mode starts or ends.
  void report({required bool editing, required String title}) {
    this.title = title;
    this.editing.value = editing;
  }

  /// "Bitti" of the host's bar.
  void finish() => _finish?.call();

  void dispose() {
    _disposed = true;
    editing.dispose();
  }
}
