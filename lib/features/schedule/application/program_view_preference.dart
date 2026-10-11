import 'package:smap/core/services/device_preferences.dart';

/// Gün or Hafta (pano 3.4 kare 3 and 4).
enum ProgramViewMode {
  /// One day's list.
  day,

  /// The weekly grid.
  week;

  static ProgramViewMode? parse(String? name) {
    for (final mode in values) {
      if (mode.name == name) return mode;
    }
    return null;
  }
}

/// Where the Gün / Hafta choice is remembered ("Gün / Hafta seçimi cihazda
/// hatırlanır", pano 3.4).
///
/// The choice goes to `DevicePreferences` under [key] once the key is in the
/// preferences' allow list (the coordinator adds it); until then it is kept
/// for the session only, so nothing throws and nothing is lost silently:
/// [persists] says which one it is.
class ProgramViewPreference {
  ProgramViewPreference([this._preferences]);

  /// The `DevicePreferences` key: "day" or "week" (`String`).
  static const String key = 'schedule.programView';

  final DevicePreferences? _preferences;
  ProgramViewMode? _memory;

  /// Whether the choice survives a restart.
  bool get persists =>
      _preferences != null && DevicePreferences.allowedKeys.contains(key);

  /// The remembered mode; [ProgramViewMode.day] when none.
  ProgramViewMode read() {
    final remembered = _memory;
    if (remembered != null) return remembered;
    if (persists) {
      return ProgramViewMode.parse(_preferences!.getString(key)) ??
          ProgramViewMode.day;
    }
    return ProgramViewMode.day;
  }

  /// Remembers [mode].
  Future<void> write(ProgramViewMode mode) async {
    _memory = mode;
    if (persists) await _preferences!.setString(key, mode.name);
  }
}
