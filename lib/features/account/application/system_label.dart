/// The system line of a support mail ("Sistem: iOS 18.2 (Build 22C150)"):
/// the operating system's name and version as the platform reports them,
/// tidied. No device model is read (that would need another plugin); the
/// version of the system is what support needs first. Pure and unit-tested.
abstract final class SystemLabel {
  /// [os] is `Platform.operatingSystem` (`ios`, `android`, `macos` ...),
  /// [version] is `Platform.operatingSystemVersion` ("Version 18.2 (Build
  /// 22C150)").
  static String of(String os, String version) {
    final name = switch (os) {
      'ios' => 'iOS',
      'android' => 'Android',
      'macos' => 'macOS',
      'windows' => 'Windows',
      'linux' => 'Linux',
      _ => os,
    };
    final tidy = version
        .replaceFirst(RegExp(r'^\s*Version\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return tidy.isEmpty ? name : '$name $tidy';
  }
}
