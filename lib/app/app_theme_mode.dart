import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The app's theme mode (plan K9: light only while the screens migrate;
/// `ThemeMode.system` once the dark audit, task FIN1, is done).
///
/// A debug build can force a mode for the audit:
/// `flutter run --dart-define=THEME_MODE=dark` (or `light`, `system`).
/// Release builds ignore the define.
abstract final class AppThemeMode {
  static const String _define = String.fromEnvironment('THEME_MODE');

  /// The mode `MaterialApp` uses.
  static ThemeMode get current {
    if (kDebugMode) {
      final forced = of(_define);
      if (forced != null) return forced;
    }
    return ThemeMode.light;
  }

  /// The mode a `THEME_MODE` value names; `null` for anything else.
  @visibleForTesting
  static ThemeMode? of(String value) => switch (value) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    'system' => ThemeMode.system,
    _ => null,
  };
}
