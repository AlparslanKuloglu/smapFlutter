import 'package:flutter/foundation.dart';

import 'package:smap/core/domain/user_role.dart';

/// A debug-only way to look at a shell without an account:
/// `flutter run --dart-define=SHELL_PREVIEW=student` (or `coach`) opens the
/// launch screen straight onto that shell, past the guards.
///
/// For the shell's own checks (bottom bar, tab stacks, offline strip) while
/// there is no test account; the screens inside show their empty or error
/// states. It is off in release (`kDebugMode`) and without the define.
abstract final class ShellPreview {
  static const String _define = String.fromEnvironment('SHELL_PREVIEW');

  /// The role to preview; `null` when the preview is off.
  static UserRole? get role => kDebugMode ? parse(_define) : null;

  /// Whether the preview is on.
  static bool get active => role != null;

  /// The role a `SHELL_PREVIEW` value names: `student` or `coach`.
  @visibleForTesting
  static UserRole? parse(String value) => switch (value) {
    'student' => UserRole.student,
    'coach' => UserRole.coach,
    _ => null,
  };
}
