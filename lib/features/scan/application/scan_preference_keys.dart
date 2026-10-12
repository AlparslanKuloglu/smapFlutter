/// The scan's own `DevicePreferences` keys that the shared key list does not
/// carry (`DevicePreferences.cameraPrimerAnsweredKey` and
/// `cameraTutorialSeenKey` are already there).
///
/// A key must be in `DevicePreferences.allowedKeys` before it can be read or
/// written; that file is shared, so the coordinator adds [cornersHintHidden]
/// to the list (the scan's report names it).
abstract final class ScanPreferenceKeys {
  /// "Bir daha gösterme" of the hint card on the corner screen was pressed
  /// (`bool`; pano 4.4 kare 1: "ipucunu kalıcı gizler"). The old flow kept it
  /// under `omd_corner_hint_hidden`.
  static const String cornersHintHidden = 'scan.cornersHintHidden';
}
