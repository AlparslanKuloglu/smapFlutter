import 'dart:io';

/// A start value for a debug run, read without a rebuild: the process
/// environment, else a file named after [name] in the app's temporary
/// directory (`launch_env/`). On iOS 26 simulators the `SIMCTL_CHILD_` prefix
/// of `xcrun simctl launch` does not reach the app, so use the file:
/// `tool/sim_env.sh booted NAME=value` writes it into the app's data
/// container.
///
/// Debug tooling only (the gallery, `ShellPreview`); never read in release
/// code paths.
String? debugLaunchEnv(String name) {
  final env = Platform.environment[name];
  if (env != null && env.isNotEmpty) return env;
  try {
    final file = File('${Directory.systemTemp.path}/launch_env/$name');
    if (file.existsSync()) return file.readAsStringSync().trim();
  } on FileSystemException {
    return null;
  }
  return null;
}
