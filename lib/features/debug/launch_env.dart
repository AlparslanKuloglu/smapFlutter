import 'dart:io';

/// A start value for a debug run, read without a rebuild: the process
/// environment (`SIMCTL_CHILD_<name>=… xcrun simctl launch …`), else a file
/// named `<name>` in the app's temporary directory (`launch_env/`), which a
/// screenshot script writes with `xcrun simctl get_app_container … data`.
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
