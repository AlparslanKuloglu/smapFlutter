import 'dart:convert';

import 'package:smap/core/services/device_preferences.dart';

/// The starred exams of the Denemelerim list, kept on the device only (spec
/// decision 4.8 "Favori yalnız cihazda"; the server's `isStarred` is
/// ignored). A set of exam result ids in one JSON text of
/// [DevicePreferences.favoriteExamsKey].
class ExamFavorites {
  ExamFavorites(this._preferences)
    : _ids = _read(_preferences.getString(DevicePreferences.favoriteExamsKey));

  final DevicePreferences _preferences;
  Set<String> _ids;

  /// The starred result ids (a copy).
  Set<String> get ids => Set.unmodifiable(_ids);

  bool contains(String id) => _ids.contains(id);

  /// Stars or unstars [id]; returns the new state of the star.
  Future<bool> toggle(String id) async {
    final next = {..._ids};
    final starred = next.add(id);
    if (!starred) next.remove(id);
    _ids = next;
    await _preferences.setString(
      DevicePreferences.favoriteExamsKey,
      jsonEncode(next.toList()..sort()),
    );
    return starred;
  }

  static Set<String> _read(String? text) {
    if (text == null || text.isEmpty) return const {};
    try {
      final decoded = jsonDecode(text);
      if (decoded is List) {
        return {
          for (final entry in decoded)
            if (entry is String && entry.isNotEmpty) entry,
        };
      }
    } on FormatException {
      // A damaged value reads as no favorites.
    }
    return const {};
  }
}
